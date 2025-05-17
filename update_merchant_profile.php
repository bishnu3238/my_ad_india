<?php
header('Content-Type: application/json');
require_once 'db_connect.php'; // Your DB connection

function response($status, $message, $extra = []) {
    echo json_encode(array_merge(['status' => $status, 'message' => $message], $extra));
    exit;
}

try {
    // Check for POST
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        response('error', 'Invalid request method');
    }

    // Validate required fields
    $required = [
        'id', 'username', 'email', 'mobile', 'company_name', 'address',
        'business_location', 'gender', 'business_start_year', 'mobile_status', 'pincode'
    ];
    foreach ($required as $field) {
        if (empty($_POST[$field])) {
            response('error', "Missing required field: $field");
        }
    }

    $id = intval($_POST['id']);
    $username = $_POST['username'];
    $email = $_POST['email'];
    $mobile = $_POST['mobile'];
    $company_name = $_POST['company_name'];
    $gstin = $_POST['gstin'] ?? null;
    $pan = $_POST['pan'] ?? null;
    $address = $_POST['address'];
    $business_location = $_POST['business_location'];
    $gender = $_POST['gender'];
    $business_start_year = intval($_POST['business_start_year']);
    $mobile_status = $_POST['mobile_status'];
    $pincode = $_POST['pincode'];

    // Optional: Validate email, mobile, etc.

    // Handle file upload if present
    $company_logo_url = null;
    if (isset($_FILES['company_logo']) && $_FILES['company_logo']['error'] === UPLOAD_ERR_OK) {
        $upload_dir = 'uploads/merchant_logos/';
        if (!is_dir($upload_dir)) mkdir($upload_dir, 0777, true);
        $ext = pathinfo($_FILES['company_logo']['name'], PATHINFO_EXTENSION);
        $filename = 'merchant_' . $id . '_' . time() . '.' . $ext;
        $target = $upload_dir . $filename;
        if (move_uploaded_file($_FILES['company_logo']['tmp_name'], $target)) {
            $company_logo_url = $target;
        } else {
            response('error', 'Failed to upload company logo');
        }
    }

    // Build update query
    $fields = [
        "username = ?",
        "email = ?",
        "mobile = ?",
        "company_name = ?",
        "gstin = ?",
        "pan = ?",
        "address = ?",
        "business_location = ?",
        "gender = ?",
        "business_start_year = ?",
        "mobile_status = ?",
        "pincode = ?"
    ];
    $params = [
        $username, $email, $mobile, $company_name, $gstin, $pan,
        $address, $business_location, $gender, $business_start_year, $mobile_status, $pincode
    ];

    if ($company_logo_url) {
        $fields[] = "company_logo = ?";
        $params[] = $company_logo_url;
    }

    $params[] = $id;

    $sql = "UPDATE merchant SET " . implode(', ', $fields) . " WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    if ($stmt->execute($params)) {
        response('success', 'Profile updated successfully', [
            'company_logo' => $company_logo_url
        ]);
    } else {
        response('error', 'Failed to update profile');
    }
} catch (Exception $e) {
    response('error', 'Server error: ' . $e->getMessage());
}
