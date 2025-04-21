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

if ($action === 'check') {
    if ($input === null || !isset($input['mobile'])) {
        sendResponse(400, "Invalid input or missing mobile number");
    }

    $mobile = trim($input['mobile']);

    // Validate mobile number format
    if (!preg_match("/^[0-9]{10}$/", $mobile)) {
        sendResponse(400, "Mobile number must be 10 digits");
    }

    try {
        // Check if mobile number already exists
        $stmt = $conn->prepare("SELECT id FROM merchant WHERE mobile = :mobile");
        $stmt->execute([':mobile' => $mobile]);
        
        if ($stmt->fetch()) {
            // Mobile number already in use
            sendResponse(409, "Mobile number already registered", [
                'available' => false
            ]);
        } else {
            // Mobile number is available
            sendResponse(200, "Mobile number is available", [
                'available' => true
            ]);
        }
    } catch (PDOException $e) {
        sendResponse(500, "Database error: " . $e->getMessage());
    }
} else {
    sendResponse(400, "Invalid action specified");
}

$conn = null;
?>
