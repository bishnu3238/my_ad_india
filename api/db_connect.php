<?php
header("Access-Control-Allow-Origin: *"); // Allow CORS
header("Content-Type: application/json");

$host = "localhost";
$dbname = "add";
$username = "add25"; // Default XAMPP username
$password = "101010";     // Default XAMPP password (empty)

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["error" => "Connection failed: " . $e->getMessage()]);
    exit;
}
?>
