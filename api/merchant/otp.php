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

// Ensure only POST requests are processed
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(405, "Method not allowed");
}

$input = json_decode(file_get_contents("php://input"), true);
$action = isset($_GET['action']) ? $_GET['action'] : '';

// Verify OTP
if ($action === 'verify') {
    if ($input === null || !isset($input['merchantId']) || !isset($input['otp'])) {
        sendResponse(400, "Invalid input or missing required fields");
    }

    $merchantId = trim($input['merchantId']);
    $otp = trim($input['otp']);

    // Validate OTP format
    if (!preg_match("/^[0-9]{6}$/", $otp)) {
        sendResponse(400, "OTP must be 6 digits");
    }

    try {
        // Check if merchant exists
        $stmt = $conn->prepare("SELECT id, otp, otp_verify FROM merchant WHERE id = :merchantId");
        $stmt->execute([':merchantId' => $merchantId]);
        $merchant = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$merchant) {
            sendResponse(404, "Merchant not found", ['status' => 'not_found']);
        }

        // Check if OTP is already verified
        if ($merchant['otp_verify'] == 1) {
            sendResponse(200, "OTP already verified", ['status' => 'already_verified']);
        }

        // Verify OTP
        if ($merchant['otp'] !== $otp) {
            sendResponse(400, "Invalid OTP", ['status' => 'invalid_otp']);
        }

        // Update merchant status to verified
        $stmt = $conn->prepare("UPDATE merchant SET otp_verify = 1 WHERE id = :merchantId");
        $stmt->execute([':merchantId' => $merchantId]);

        // Get updated merchant data
        $stmt = $conn->prepare("SELECT * FROM merchant WHERE id = :merchantId");
        $stmt->execute([':merchantId' => $merchantId]);
        $updatedMerchant = $stmt->fetch(PDO::FETCH_ASSOC);

        // Get subscription data
        $stmt = $conn->prepare("SELECT * FROM merchant_subscription WHERE merchant_id = :merchantId");
        $stmt->execute([':merchantId' => $merchantId]);
        $subscription = $stmt->fetch(PDO::FETCH_ASSOC);

        sendResponse(200, "OTP verified successfully", [
            'status' => 'verified',
            'merchant_id' => $merchantId,
            'merchant' => $updatedMerchant,
            'subscription' => $subscription
        ]);
    } catch (PDOException $e) {
        sendResponse(500, "Database error: " . $e->getMessage());
    }
}
// Resend OTP
else if ($action === 'resend') {
    if ($input === null || !isset($input['merchantId'])) {
        sendResponse(400, "Invalid input or missing merchant ID");
    }

    $merchantId = trim($input['merchantId']);

    try {
        // Check if merchant exists
        $stmt = $conn->prepare("SELECT id, mobile, otp_verify FROM merchant WHERE id = :merchantId");
        $stmt->execute([':merchantId' => $merchantId]);
        $merchant = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$merchant) {
            sendResponse(404, "Merchant not found");
        }

        // Check if OTP is already verified
        if ($merchant['otp_verify'] == 1) {
            sendResponse(200, "Mobile number already verified", ['status' => 'already_verified']);
        }

        // Generate new OTP
        $newOtp = str_pad(rand(0, 999999), 6, '0', STR_PAD_LEFT);
        
        // Update merchant with new OTP
        $stmt = $conn->prepare("UPDATE merchant SET otp = :otp WHERE id = :merchantId");
        $stmt->execute([
            ':otp' => $newOtp,
            ':merchantId' => $merchantId
        ]);

        // In a production environment, you would send the OTP via SMS here
        // For testing purposes, we return the OTP in the response
        sendResponse(200, "OTP resent successfully", [
            'merchant_id' => $merchantId,
            'mobile' => $merchant['mobile'],
            'otp' => $newOtp
        ]);
    } catch (PDOException $e) {
        sendResponse(500, "Database error: " . $e->getMessage());
    }
} else {
    sendResponse(400, "Invalid action specified");
}

$conn = null;
?>
