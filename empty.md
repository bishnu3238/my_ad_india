<?php
// auth.php - Updated with SMS integration for BulkSMSWale with correct API endpoint

require_once 'db_connect.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

function logError($message, $file = 'error.log') {
    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] ERROR: $message" . PHP_EOL;
    file_put_contents($file, $logEntry, FILE_APPEND);
}

header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');

$request_method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Improved path handling
$basePath = '/ead_api/auth/new_auth.php'; // Adjust based on your server path
$pathParts = explode($basePath, $path);
$cleanPath = end($pathParts);

// If cleanPath is empty or just has a slash, it's the base path
if (empty($cleanPath) || $cleanPath === '/') {
    $cleanPath = '/';
} else {
    // Make sure it starts with a slash for consistent matching
    if (strpos($cleanPath, '/') !== 0) {
        $cleanPath = '/' . $cleanPath;
    }
}

logError("Request path: $path, Processed path: $cleanPath"); // Debug the processed path

$rateLimitFile = 'rate_limit.txt';
$rateLimit = checkRateLimit();

if ($rateLimit['status'] === 'error') {
    sendResponse('error', $rateLimit['message'], null, 429);
    exit;
}

// Handle OPTIONS requests for CORS
if ($request_method === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    exit;
}

// SMS configuration - Replace with your actual credentials
define('SMS_API_URL', 'http://inbox.bulksmswale.in/sendsms.jsp');
define('SMS_USERNAME', 'xxxxxx'); // Replace with your BulkSMSWale username
define('SMS_PASSWORD', 'xxxxxxxxxxxxx'); // Replace with your BulkSMSWale password
define('SMS_SENDER_ID', 'xxxxxxxxxxxx'); // Replace with your sender ID
define('SMS_ENTITY_ID', 'xxxxxxxxxxxxxxxxxxx'); // Replace with your entity ID
define('SMS_TEMPLATE_ID', 'xxxxxxxxxxxxxxxx'); // Replace with your template ID

// Simpler route handling
switch (true) {
    case ($cleanPath === '/auth/login' && $request_method === 'POST'):
        login();
        break;
    case ($cleanPath === '/auth/signup' && $request_method === 'POST'):
        signup();
        break;
    case ($cleanPath === '/auth/send-otp' && $request_method === 'POST'):
        sendOTP();
        break;
    case ($cleanPath === '/auth/verify-otp' && $request_method === 'POST'):
        verifyOTP();
        break;
    case ($cleanPath === '/auth/reset-password' && $request_method === 'POST'):
        resetPassword();
        break;
    case ($cleanPath === '/auth/forgot-password' && $request_method === 'POST'):
        forgotPassword();
        break;
    case ($cleanPath === '/auth/change-password' && $request_method === 'POST'):
        changePassword();
        break;
    case ($cleanPath === '/auth/logout' && $request_method === 'POST'):
        logout();
        break;
    default:
        logError("No route match for path: $cleanPath");
        sendResponse('error', 'Endpoint not found', null, 404);
        break;
}

function login() {
    global $pdo;
    logError("Login attempt started");
    $data = json_decode(file_get_contents('php://input'), true);

    if (!$data) {
        logError("Login: Invalid input data");
        sendResponse('error', 'Invalid input data', null, 400);
        return;
    }

    // Validate required fields
    if (!isset($data['identifier']) || !isset($data['password'])) {
        logError("Login: Missing required fields");
        sendResponse('error', 'Missing required fields', null, 400);
        return;
    }

    $identifier = sanitizeInput($data['identifier']);
    $password = $data['password'];

    $stmt = $pdo->prepare(
        "SELECT * FROM customers 
         WHERE email = :identifier 
         OR username = :identifier 
         OR mobile = :identifier"
    );

    try {
        $stmt->execute(['identifier' => $identifier]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            $storedPassword = $user['password'];

            $isPasswordValid = false;

            // Check with bcrypt
            if (password_verify($password, $storedPassword)) {
                $isPasswordValid = true;
            } 
            // Check with MD5 (for legacy passwords)
            elseif ($storedPassword === md5($password)) {
                $isPasswordValid = true;

                // Re-hash the password with bcrypt and update it in the database
                $newHashedPassword = password_hash($password, PASSWORD_DEFAULT);
                $updateStmt = $pdo->prepare("UPDATE customers SET password = :password WHERE id = :id");
                $updateStmt->execute(['password' => $newHashedPassword, 'id' => $user['id']]);
            }

            if ($isPasswordValid) {
                $otp = generateOTP();
                storeOTP($user['id'], $otp);

                if ($user['otp_verify'] === 0) {
                    // Send OTP via SMS since verification is required
                    if (!empty($user['mobile'])) {
                        sendSMS($user['mobile'], $otp);
                    }
                    
                    logError("Login: OTP verification required for user ID: " . $user['id']);
                    sendResponse('success', 'OTP verification required', [
                        'user_id' => $user['id'],
                        'otp' => $otp // You might want to remove this in production
                    ]);
                } else {
                    $token = generateToken($user['id']);
                    logError("Login: Successful for user ID: " . $user['id']);
                    sendResponse('success', 'Login successful', [
                        'token' => $token,
                        'user' => formatUserResponse($user)
                    ]);
                }
            } else {
                logError("Login: Invalid password for identifier: $identifier");
                sendResponse('error', 'Invalid credentials', null, 401);
            }
        } else {
            logError("Login: User not found for identifier: $identifier");
            sendResponse('error', 'Invalid credentials', null, 401);
        }
    } catch (Exception $e) {
        logError("Login error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function signup() {
    global $pdo;
    logError("Signup attempt started");
    
    // Get the raw input data
    $rawData = file_get_contents('php://input');
    logError("Raw data received: " . $rawData);
    
    $data = json_decode($rawData, true);
    
    if (!$data) {
        logError("Signup: Invalid JSON data");
        sendResponse('error', 'Invalid input data', null, 400);
        return;
    }
    
    // Validate required fields
    $requiredFields = ['password', 'name', 'phone'];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || trim($data[$field]) === '') {
            logError("Signup: Missing required field: $field");
            sendResponse('error', "Missing required field: $field", null, 400);
            return;
        }
    }
    
    $email = sanitizeInput($data['email'] ?? '');
    $phoneNo = sanitizeInput($data['phone']);
    $password = $data['password'];
    $username = sanitizeInput($data['name']);
    
    // Check if phone exists
    try {
        $phoneCheckStmt = $pdo->prepare("SELECT id FROM customers WHERE mobile = :mobile");
        $phoneCheckStmt->execute(['mobile' => $phoneNo]);
        if ($phoneCheckStmt->rowCount() > 0) {
            logError("Signup: Phone number already exists: $phoneNo");
            sendResponse('error', 'Phone number already exists', null, 400);
            return;
        }
        
        // Hash password securely
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        // Proceed with insertion
        $stmt = $pdo->prepare(
            "INSERT INTO customers (username, email, mobile, password, created_at) 
             VALUES (:username, :email, :phoneNo, :password, NOW())"
        );
        
        $stmt->execute([
            'username' => $username,
            'email' => $email,
            'phoneNo'=> $phoneNo,
            'password' => $hashedPassword
        ]);
        
        $userId = $pdo->lastInsertId();
        logError("Signup: User created with ID: $userId");
        
        $otp = generateOTP();
        storeOTP($userId, $otp);
        
        // Send OTP via SMS
        $smsResult = sendSMS($phoneNo, $otp);
        logError("SMS send result: " . json_encode($smsResult));
        
        sendResponse('success', 'Signup successful, please verify OTP', [
            'user_id' => $userId,
            'otp' => $otp, // You might want to remove this in production
            'sms_sent' => isset($smsResult['status']) && $smsResult['status'] === 'success'
        ]);
        
    } catch (PDOException $e) {
        logError("Signup error: " . $e->getMessage());
        
        // More specific error messages based on error code
        $errorCode = $e->getCode();
        if ($errorCode == 23000) { // Integrity constraint violation
            sendResponse('error', 'Account with this email or phone already exists', null, 400);
        } else {
            sendResponse('error', 'Database error occurred', null, 500);
        }
    }
}

function sendOTP() {
    global $pdo;
    logError("Send OTP attempt started");
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Check if request is by email or phone
    $isEmailRequest = isset($data['email']) && trim($data['email']) !== '';
    $isPhoneRequest = isset($data['phone']) && trim($data['phone']) !== '';
    
    if (!$data || (!$isEmailRequest && !$isPhoneRequest)) {
        logError("Send OTP: Missing email or phone");
        sendResponse('error', 'Email or phone is required', null, 400);
        return;
    }
    
    try {
        if ($isEmailRequest) {
            $email = sanitizeInput($data['email']);
            $stmt = $pdo->prepare("SELECT id, mobile FROM customers WHERE email = :email");
            $stmt->execute(['email' => $email]);
        } else {
            $phone = sanitizeInput($data['phone']);
            $stmt = $pdo->prepare("SELECT id, mobile FROM customers WHERE mobile = :mobile");
            $stmt->execute(['mobile' => $phone]);
        }
        
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            $otp = generateOTP();
            storeOTP($user['id'], $otp);
            
            // Send OTP via SMS if we have a mobile number
            if (!empty($user['mobile'])) {
                $smsResult = sendSMS($user['mobile'], $otp);
                logError("SMS send result: " . json_encode($smsResult));
            }
            
            logError("Send OTP: OTP sent for user ID: " . $user['id']);
            sendResponse('success', 'OTP sent successfully', [
                'otp' => $otp, // You might want to remove this in production
                'sms_sent' => !empty($user['mobile'])
            ]);
        } else {
            logError("Send OTP: User not found");
            sendResponse('error', 'User not found', null, 404);
        }
    } catch (Exception $e) {
        logError("Send OTP error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function verifyOTP() {
    global $pdo;
    logError("Verify OTP attempt started");
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data || !isset($data['otp']) || !isset($data['user_id'])) {
        logError("Verify OTP: Missing required fields");
        sendResponse('error', 'OTP and user_id are required', null, 400);
        return;
    }
    
    $otp = sanitizeInput($data['otp']);
    $userId = intval($data['user_id']);
    
    $stmt = $pdo->prepare("SELECT * FROM customers WHERE id = :id AND otp = :otp");
    try {
        $stmt->execute(['id' => $userId, 'otp' => $otp]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            $stmt = $pdo->prepare(
                "UPDATE customers SET otp_verify = 1, otp = NULL WHERE id = :id"
            );
            $stmt->execute(['id' => $userId]);
            
            $token = generateToken($userId);
            logError("Verify OTP: Successful for user ID: $userId");
            sendResponse('success', 'OTP verified', [
                'token' => $token,
                'user' => formatUserResponse($user)
            ]);
        } else {
            logError("Verify OTP: Invalid OTP for user ID: $userId");
            sendResponse('error', 'Invalid OTP', null, 400);
        }
    } catch (Exception $e) {
        logError("Verify OTP error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function resetPassword() {
    global $pdo;
    logError("Reset password attempt started");
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data || !isset($data['reset_token']) || !isset($data['new_password'])) {
        logError("Reset Password: Missing required fields");
        sendResponse('error', 'Reset token and new password are required', null, 400);
        return;
    }
    
    $resetToken = sanitizeInput($data['reset_token']);
    $newPassword = password_hash($data['new_password'], PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare(
        "UPDATE customers SET password = :password, otp = NULL 
         WHERE otp = :resetToken"
    );
    try {
        $stmt->execute(['password' => $newPassword, 'resetToken' => $resetToken]);
        
        if ($stmt->rowCount() > 0) {
            logError("Reset Password: Successful");
            sendResponse('success', 'Password reset successful');
        } else {
            logError("Reset Password: Invalid reset token: $resetToken");
            sendResponse('error', 'Invalid reset token', null, 400);
        }
    } catch (Exception $e) {
        logError("Reset password error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function forgotPassword() {
    global $pdo;
    logError("Forgot password attempt started");
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Check if request is by email or phone
    $identifier = null;
    $identifierField = null;
    
    if (isset($data['email']) && trim($data['email']) !== '') {
        $identifier = sanitizeInput($data['email']);
        $identifierField = 'email';
    } elseif (isset($data['phone']) && trim($data['phone']) !== '') {
        $identifier = sanitizeInput($data['phone']);
        $identifierField = 'mobile';
    } else {
        logError("Forgot Password: Missing email or phone");
        sendResponse('error', 'Email or phone is required', null, 400);
        return;
    }
    
    $stmt = $pdo->prepare("SELECT id, mobile FROM customers WHERE $identifierField = :identifier");
    try {
        $stmt->execute(['identifier' => $identifier]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($user) {
            $otp = generateOTP();
            storeOTP($user['id'], $otp);
            
            // Send OTP via SMS if we have a mobile number
            if (!empty($user['mobile'])) {
                // $smsResult = sendSMS($user['mobile'], $otp);
                $smsResult = true;
                logError("SMS send result: " . json_encode($smsResult));
            }
            
            logError("Forgot Password: Reset OTP sent for user ID: " . $user['id']);
            sendResponse('success', 'Reset OTP sent', [
                'otp' => $otp, // You might want to remove this in production
                'user_id' => $user['id'], 
                'sms_sent' => !empty($user['mobile'])
            ]);
        } else {
            logError("Forgot Password: User not found for identifier: $identifier");
            sendResponse('error', 'User not found', null, 404);
        }
    } catch (Exception $e) {
        logError("Forgot password error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function changePassword() {
    global $pdo;
    logError("Change password attempt started");
    $data = json_decode(file_get_contents('php://input'), true);
    $token = getBearerToken();
    
    if (!$token) {
        logError("Change Password: No token provided");
        sendResponse('error', 'No token provided', null, 401);
        return;
    }
    
    $userId = validateToken($token);
    if (!$userId) {
        logError("Change Password: Invalid token");
        sendResponse('error', 'Unauthorized', null, 401);
        return;
    }
    
    if (!$data || !isset($data['current_password']) || !isset($data['new_password'])) {
        logError("Change Password: Missing required fields");
        sendResponse('error', 'Current and new passwords are required', null, 400);
        return;
    }
    
    $stmt = $pdo->prepare("SELECT password FROM customers WHERE id = :id");
    try {
        $stmt->execute(['id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            logError("Change Password: User not found for ID: $userId");
            sendResponse('error', 'User not found', null, 404);
            return;
        }
        
        if (password_verify($data['current_password'], $user['password'])) {
            $newPassword = password_hash($data['new_password'], PASSWORD_DEFAULT);
            $stmt = $pdo->prepare(
                "UPDATE customers SET password = :password WHERE id = :id"
            );
            $stmt->execute(['password' => $newPassword, 'id' => $userId]);
            logError("Change Password: Successful for user ID: $userId");
            sendResponse('success', 'Password changed successfully');
        } else {
            logError("Change Password: Current password incorrect for user ID: $userId");
            sendResponse('error', 'Current password incorrect', null, 400);
        }
    } catch (Exception $e) {
        logError("Change password error: " . $e->getMessage());
        sendResponse('error', 'Server error', null, 500);
    }
}

function logout() {
    $token = getBearerToken();
    if ($token) {
        logError("Logout: Successful");
        sendResponse('success', 'Logout successful');
    } else {
        logError("Logout: No token provided");
        sendResponse('error', 'No token provided', null, 400);
    }
}

// SMS Functions
function sendSMS($phoneNumber, $otp) {
    // SMS Panel Configuration
    $smsConfig = [
        'baseUrl' => 'http://inbox.bulksmswale.in/sendsms.jsp',
        'user' => 'EAZYTC',
        'password' => '734a73d6feXX',
        'senderid' => 'EAZYTC',
        'entityid' => '1501413500000036227',
        'tempid' => '1707173104531911463'
    ];
    
    // Prepare SMS text - URL encoded
    $smsText = rawurlencode("{$otp} is the OTP to login at https://eazytechno.com/eazy-doctor/doctor_signin.php
OTPs are SECRET. DO NOT disclose it to anyone. -EAZYTC");
    
    // Construct the complete URL
    $smsUrl = sprintf(
        "%s?user=%s&password=%s&senderid=%s&entityid=%s&tempid=%s&mobiles=%s&sms=%s",
        $smsConfig['baseUrl'],
        $smsConfig['user'],
        $smsConfig['password'],
        $smsConfig['senderid'],
        $smsConfig['entityid'],
        $smsConfig['tempid'],
        $phoneNumber,
        $smsText
    );
    
    // Send the request
    $response = null;
    $error = null;
    
    try {
        // Using cURL to make the request
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $smsUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        $response = curl_exec($ch);
        
        if(curl_errno($ch)) {
            $error = curl_error($ch);
        }
        
        curl_close($ch);
        
        // Log the SMS sending attempt
        error_log("SMS OTP Sent to $phoneNumber. Response: $response");
        
        if($error) {
            error_log("SMS Error: $error");
            return false;
        }
        
        return true;
    } catch (Exception $e) {
        error_log("SMS Exception: " . $e->getMessage());
        return false;
    }
}


// Security Helper Functions
function sanitizeInput($input) {
    return htmlspecialchars(strip_tags(trim($input)), ENT_QUOTES, 'UTF-8');
}

function generateToken($userId) {
    // In production, use a proper environment variable or secure storage for the secret
    $secret = getenv('JWT_SECRET') ?: 'your-secret-key-change-in-production';
    $timestamp = time();
    $expiry = $timestamp + 86400; // 24 hours
    $data = "$userId:$timestamp:$expiry";
    $hash = hash_hmac('sha256', $data, $secret);
    return base64_encode("$data:$hash");
}

function validateToken($token) {
    try {
        // In production, use a proper environment variable or secure storage for the secret
        $secret = getenv('JWT_SECRET') ?: 'your-secret-key-change-in-production';
        $decoded = base64_decode($token);
        
        if ($decoded === false) {
            logError("Token validation error: Invalid base64 encoding");
            return false;
        }
        
        $parts = explode(':', $decoded);
        if (count($parts) < 3) {
            logError("Token validation error: Invalid token format");
            return false;
        }
        
        list($userId, $timestamp, $expiry) = $parts;
        $hash = $parts[3] ?? '';
        
        $data = "$userId:$timestamp:$expiry";
        $expectedHash = hash_hmac('sha256', $data, $secret);
        
        if (hash_equals($hash, $expectedHash) && time() < $expiry) {
            return $userId;
        }
        
        logError("Token validation error: Token expired or invalid hash");
        return false;
    } catch (Exception $e) {
        logError("Token validation error: " . $e->getMessage());
        return false;
    }
}

function generateOTP() {
    return sprintf("%06d", mt_rand(100000, 999999));
}

function storeOTP($userId, $otp) {
    global $pdo;
    try {
        $stmt = $pdo->prepare(
            "UPDATE customers SET otp = :otp, otp_verify = 0 WHERE id = :id"
        );
        $stmt->execute(['otp' => $otp, 'id' => $userId]);
        return true;
    } catch (Exception $e) {
        logError("Store OTP error: " . $e->getMessage());
        return false;
    }
}

function checkRateLimit() {
    global $rateLimitFile;
    $ip = $_SERVER['REMOTE_ADDR'];
    $time = time();
    $limit = 100; // requests
    $window = 3600; // seconds
    
    if (!file_exists($rateLimitFile)) {
        file_put_contents($rateLimitFile, json_encode([]));
    }
    
    $data = json_decode(file_get_contents($rateLimitFile), true);
    if (!isset($data[$ip])) {
        $data[$ip] = ['count' => 1, 'start' => $time];
    } else {
        if ($time - $data[$ip]['start'] > $window) {
            $data[$ip] = ['count' => 1, 'start' => $time];
        } else {
            $data[$ip]['count']++;
            if ($data[$ip]['count'] > $limit) {
                logError("Rate limit exceeded for IP: $ip");
                return ['status' => 'error', 'message' => 'Rate limit exceeded'];
            }
        }
    }
    
    file_put_contents($rateLimitFile, json_encode($data));
    return ['status' => 'success'];
}

function getBearerToken() {
    $headers = function_exists('apache_request_headers') ? apache_request_headers() : [];
    
    // Check Authorization header
    if (isset($headers['Authorization'])) {
        $auth = $headers['Authorization'];
        if (strpos($auth, 'Bearer ') === 0) {
            return substr($auth, 7);
        }
    }
    
    // Fallback to check in $_SERVER
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $auth = $_SERVER['HTTP_AUTHORIZATION'];
        if (strpos($auth, 'Bearer ') === 0) {
            return substr($auth, 7);
        }
    }
    
    return null;
}

function formatUserResponse($user) {
    return [
        'id' => $user['id'],
        'name' => $user['username'],
        'email' => $user['email'],
        'mobile' => $user['mobile'],
        'profile_image' => $user['image'] ?? null,
        'metadata' => [
            'address' => $user['address'] ?? null,
            'gender' => $user['gender'] ?? null,
            'latitude' => $user['latitude'] ?? null,
            'longitude' => $user['longitude'] ?? null
        ]
    ];
}

function sendResponse($status, $message, $data = null, $code = 200) {
    http_response_code($code);
    $response = ['status' => $status, 'message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}