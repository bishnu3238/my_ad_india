<?php
require_once '../db_connect.php';

// Headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle OPTIONS request for CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Response function
function sendResponse($statusCode, $message, $data = null) {
    http_response_code($statusCode);
    echo json_encode([
        'status' => $statusCode,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('c')
    ]);
    exit;
}

// Validate required fields
function validateRequiredFields($data, $requiredFields) {
    $missing = [];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || empty(trim($data[$field]))) {
            $missing[] = $field;
        }
    }
    return $missing;
}

// Sanitize input
function sanitizeInput($input) {
    return trim($input);
}

// Ensure only POST requests are processed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(405, "Method not allowed");
}

$input = json_decode(file_get_contents("php://input"), true);
$action = isset($_GET['action']) ? $_GET['action'] : '';

if ($action === 'register') {
    if ($input === null) {
        sendResponse(400, "Invalid JSON input");
    }

    // Required fields for merchant and subscription
    $requiredFields = [
        'username', 'email', 'mobile', 'state', 'pincode', 'password', 'address', 'gender',
        'business_start_year', 'mobile_status', 'receive_options', 'business_location',
        'company_name', 'plan_id', 'plan_name', 'gst', 'amount', 'start_date', 'end_date', 'validity'
    ];

    $missing = validateRequiredFields($input, $requiredFields);
    if (!empty($missing)) {
        sendResponse(400, "Missing required fields", $missing);
    }

    // Validate specific fields
    if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
        sendResponse(400, "Invalid email format");
    }
    if (!preg_match("/^[0-9]{10}$/", $input['mobile'])) {
        sendResponse(400, "Mobile number must be 10 digits");
    }
    if (!preg_match("/^[0-9]{6}$/", $input['pincode'])) {
        sendResponse(400, "Pincode must be 6 digits");
    }
    if (!in_array(strtolower($input['gender']), ['male', 'female', 'other'])) {
        sendResponse(400, "Invalid gender value");
    }
    if (!in_array(strtolower($input['mobile_status']), ['public', 'private'])) {
        sendResponse(400, "Invalid mobile_status value");
    }

    // Prepare data
    $data = array_map('sanitizeInput', $input);
    $data['password'] = password_hash($data['password'], PASSWORD_BCRYPT);
    $data['otp'] = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT); // Generate 6-digit OTP
    $data['otp_verify'] = 0; // OTP verification required
    $data['status'] = 1; // Active status
    $data['dated'] = date("Y-m-d H:i:s");
    $data['added_by'] = $data['username'];

    try {
        $conn->beginTransaction();

        // Check for duplicate email or username or mobile
        $stmt = $conn->prepare("SELECT id FROM merchant WHERE email = :email OR username = :username OR mobile = :mobile");
        $stmt->execute([
            ':email' => $data['email'], 
            ':username' => $data['username'],
            ':mobile' => $data['mobile']
        ]);
        
        if ($stmt->fetch()) {
            // Check which field is duplicate
            $stmt = $conn->prepare("SELECT id FROM merchant WHERE email = :email");
            $stmt->execute([':email' => $data['email']]);
            if ($stmt->fetch()) {
                $conn->rollBack();
                sendResponse(409, "Email already registered");
            }
            
            $stmt = $conn->prepare("SELECT id FROM merchant WHERE username = :username");
            $stmt->execute([':username' => $data['username']]);
            if ($stmt->fetch()) {
                $conn->rollBack();
                sendResponse(409, "Username already taken");
            }
            
            $stmt = $conn->prepare("SELECT id FROM merchant WHERE mobile = :mobile");
            $stmt->execute([':mobile' => $data['mobile']]);
            if ($stmt->fetch()) {
                $conn->rollBack();
                sendResponse(409, "Mobile number already registered");
            }
        }

        // Insert into merchant table
        $sql = "INSERT INTO merchant (
            username, gstin, pan, company_name, email, mobile, state, city, pincode, password, 
            address, gender, business_start_year, mobile_status, receive_options, business_location, 
            company_logo, kyc, latitude, longitude, otp_verify, otp, status, dated, added_by
        ) VALUES (
            :username, :gstin, :pan, :company_name, :email, :mobile, :state, :city, :pincode, :password, 
            :address, :gender, :business_start_year, :mobile_status, :receive_options, :business_location, 
            :company_logo, :kyc, :latitude, :longitude, :otp_verify, :otp, :status, :dated, :added_by
        )";

        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':username' => $data['username'],
            ':gstin' => $data['gstin'] ?? null,
            ':pan' => $data['pan'] ?? null,
            ':company_name' => $data['company_name'],
            ':email' => $data['email'],
            ':mobile' => $data['mobile'],
            ':state' => (int)$data['state'],
            ':city' => isset($data['city']) ? (int)$data['city'] : null,
            ':pincode' => $data['pincode'],
            ':password' => $data['password'],
            ':address' => $data['address'],
            ':gender' => $data['gender'],
            ':business_start_year' => (int)$data['business_start_year'],
            ':mobile_status' => $data['mobile_status'],
            ':receive_options' => $data['receive_options'],
            ':business_location' => $data['business_location'],
            ':company_logo' => $data['company_logo'] ?? null,
            ':kyc' => isset($data['kyc']) ? (int)$data['kyc'] : 0,
            ':latitude' => isset($data['latitude']) ? (float)$data['latitude'] : null,
            ':longitude' => isset($data['longitude']) ? (float)$data['longitude'] : null,
            ':otp_verify' => $data['otp_verify'],
            ':otp' => $data['otp'],
            ':status' => $data['status'],
            ':dated' => $data['dated'],
            ':added_by' => $data['added_by']
        ]);

        $merchant_id = $conn->lastInsertId();

        // Insert into merchant_subscription table
        $sql = "INSERT INTO merchant_subscription (
            merchant_id, plan_id, plan_name, gst, amount, start_date, end_date, validity, 
            payment_status, status, subscription_type, plan_status
        ) VALUES (
            :merchant_id, :plan_id, :plan_name, :gst, :amount, :start_date, :end_date, :validity, 
            'Pending', 1, 'new', 'active'
        )";

        $stmt = $conn->prepare($sql);
        $stmt->execute([
            ':merchant_id' => $merchant_id,
            ':plan_id' => (int)$data['plan_id'],
            ':plan_name' => $data['plan_name'],
            ':gst' => (float)$data['gst'],
            ':amount' => (float)$data['amount'],
            ':start_date' => $data['start_date'],
            ':end_date' => $data['end_date'],
            ':validity' => (int)$data['validity']
        ]);

        $subscription_id = $conn->lastInsertId();

        // Prepare full response data
        $merchantData = [
            'id' => $merchant_id,
            'username' => $data['username'],
            'gstin' => $data['gstin'] ?? null,
            'pan' => $data['pan'] ?? null,
            'company_name' => $data['company_name'],
            'email' => $data['email'],
            'mobile' => $data['mobile'],
            'state' => (int)$data['state'],
            'city' => isset($data['city']) ? (int)$data['city'] : null,
            'pincode' => $data['pincode'],
            'address' => $data['address'],
            'gender' => $data['gender'],
            'business_start_year' => (int)$data['business_start_year'],
            'mobile_status' => $data['mobile_status'],
            'receive_options' => $data['receive_options'],
            'business_location' => $data['business_location'],
            'company_logo' => $data['company_logo'] ?? null,
            'kyc' => isset($data['kyc']) ? (int)$data['kyc'] : 0,
            'latitude' => isset($data['latitude']) ? (float)$data['latitude'] : null,
            'longitude' => isset($data['longitude']) ? (float)$data['longitude'] : null,
            'otp_verify' => $data['otp_verify'],
            'status' => $data['status'],
            'dated' => $data['dated'],
            'added_by' => $data['added_by']
        ];

        $subscriptionData = [
            'subscription_id' => $subscription_id,
            'merchant_id' => $merchant_id,
            'plan_id' => (int)$data['plan_id'],
            'plan_name' => $data['plan_name'],
            'gst' => (float)$data['gst'],
            'amount' => (float)$data['amount'],
            'start_date' => $data['start_date'],
            'end_date' => $data['end_date'],
            'validity' => (int)$data['validity'],
            'payment_status' => 'Pending',
            'status' => 1,
            'subscription_type' => 'new',
            'plan_status' => 'active'
        ];

        // Convert int based status codes to string for better readability
        $merchantData['mobile_status'] = $merchantData['mobile_status'] === 0 ? 'private' : 'public';
        $merchantData['receive_options'] = $merchantData['receive_options'] === 0 ? 'chat' : 'email';
        $merchantData['status'] = $merchantData['status'] === 0 ? 'inActive' : 'active';
        $subscriptionData['status'] = $subscriptionData['status'] === 0 ? 'inActive' : 'active';

        $conn->commit();
        
        // Return OTP verification required response
        sendResponse(201, "Please verify your mobile number with OTP", [
            'merchant_id' => $merchant_id,
            'otp' => $data['otp'], // For testing/demo purposes only
            'merchant' => $merchantData,
            'subscription' => $subscriptionData
        ]);

    } catch (PDOException $e) {
        $conn->rollBack();
        sendResponse(500, "Failed to register merchant: " . $e->getMessage());
    }
} else {
    sendResponse(400, "Invalid action specified");
}

$conn = null;
?>
