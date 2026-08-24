<?php

function respond($data, $code = 200)
{
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

$file = basename($_GET['file'] ?? '');

if (!$file) {
    respond(["error" => "File not specified"], 400);
}

$path = "/var/www/private_data/lab/" . $file;

if (!file_exists($path)) {
    respond(["error" => "File not found"], 404);
}

echo file_get_contents($path);
exit;
