<?php

ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(E_ALL);

session_start();

require_once __DIR__ . "/config/ldap.php";

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$username = trim($data["username"] ?? "");
$password = $data["password"] ?? "";

/*
 * Temporary diagnostic logging.
 * Do NOT log the actual password.
 */
error_log("LOGIN USERNAME: [" . $username . "]");
error_log("LOGIN PASSWORD LENGTH: " . strlen($password));

if (!$username || !$password) {

    echo json_encode([
        "status" => "error",
        "message" => "Username and password are required"
    ]);

    exit;
}

if (authenticateStudent($username, $password)) {

    $_SESSION["user"] = strtolower($username);

    echo json_encode([
        "status" => "success",
        "user"   => strtolower($username)
    ]);

} else {

    echo json_encode([
        "status" => "error",
        "message" => "Invalid login"
    ]);
}

