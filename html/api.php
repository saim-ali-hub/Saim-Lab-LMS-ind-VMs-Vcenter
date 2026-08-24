<?php

function respond($data, $code = 200)
{
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

$action = $_GET['action'] ?? '';

if ($action === "lab") {

    $validator = "/var/www/private_data/validator/evaluate_lab.php";

    if (!file_exists($validator)) {
        respond(["error" => "Lab validator missing"], 500);
    }

    require $validator;
    exit;
}

respond(["error" => "Invalid action"], 400);

