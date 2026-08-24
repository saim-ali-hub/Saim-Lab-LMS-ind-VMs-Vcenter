<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Content-Type: text/html; charset=UTF-8");

session_start();
session_write_close();

require_once "/var/www/html/config/ldap.php";
require_once "/var/www/html/config/vcenter.php";
require_once "/var/www/html/config/functions.php";


/* =========================================================
   1. READ INPUT
========================================================= */

$rawInput = file_get_contents("php://input");

$input = json_decode($rawInput, true);

if (!is_array($input)) {

    http_response_code(400);

    exit("Invalid JSON input");
}


/* =========================================================
   2. GET LAB
========================================================= */

$lab = basename(
    $input['lab'] ?? '',
    ".json"
);

if (!$lab) {

    http_response_code(400);

    exit("Missing lab");
}


/* =========================================================
   3. VALIDATE LAB FORMAT
========================================================= */

if (!preg_match('/^lab[0-9]+$/', $lab)) {

    http_response_code(400);

    exit("Invalid lab format");
}


/* =========================================================
   4. GET LOGGED-IN USER, VM and IP
========================================================= */

if (!isset($_SESSION["user"])) {

    http_response_code(401);

    exit("Not logged in");
}

$username = $_SESSION["user"];

$session = vcenterLogin();

if (!$session) {
    die("Unable to login to vCenter");
}

$vmName = getVmName($username);

$vmId = getVmID($session, $vmName);

if (!$vmId) {
    die("VM not found");
}

$ip = getGuestIP($session, $vmId);

if (!$ip) {
    die("Guest IP not available");
}


/* =========================================================
   5. VALIDATE USERNAME
========================================================= */

if (!preg_match('/^[a-zA-Z0-9._-]+$/', $username)) {

    http_response_code(400);

    exit("Invalid username");
}

if (!preg_match('/^lab[0-9]+$/', $lab)) {
    die("Invalid lab format");
}


/* =========================================================
   6. BLOCK SYSTEM USERS
========================================================= */

$blocked_users = [
    'root',
    'nginx',
    'apache',
    'mysql',
    'bin',
    'daemon'
];

if (in_array($username, $blocked_users, true)) {

    http_response_code(403);

    exit("System user not allowed");
}

/* ===========================
   7. GET USER HOME DIRECTORY
=========================== */

$homeDir = "/home/" . $username;

/* =========================================================
   8. SAFE LOGGING
========================================================= */

$logFile =
    "/var/www/private_data/lab/results/debug.log";

file_put_contents(
    $logFile,
    date("Y-m-d H:i:s") .
    " USER=$username LAB=$lab HOME=$homeDir\n",
    FILE_APPEND | LOCK_EX
);


/* =========================================================
   9. VALIDATION SCRIPT
========================================================= */

$script =
    "/var/www/private_data/lab/validate_lab.sh";


/* =========================================================
   10. BUILD COMMAND
========================================================= */

$cmd = [
    "/usr/bin/sudo",
    "-n",
    "-u",
    "validator",
    $script,
    $username,
    $ip,
    $lab
];

$escaped = array_map(
    "escapeshellarg",
    $cmd
);

$command =
    implode(" ", $escaped) .
    " 2>&1";


/* =========================================================
   11. EXECUTE VALIDATION
========================================================= */

$output = [];

$status = 0;

exec(
    $command,
    $output,
    $status
);

/* TEMPORARY DEBUG */
file_put_contents(
    "/var/www/private_data/lab/results/php_debug.log",
    date("Y-m-d H:i:s") .
    " USER=$username LAB=$lab IP=$ip STATUS=$status OUTPUT_LINES=" .
    count($output) . "\n" .
    implode("\n", $output) .
    "\n============================================\n",
    FILE_APPEND | LOCK_EX
);

/* =========================================================
   12. STORE RESULT
========================================================= */

$resultFile =
    "/var/www/private_data/lab/results/{$lab}_result.txt";


/*
 * Convert validator output into one string
 */
$resultOutput = implode("\n", $output);


/* =========================================================
   CALCULATE TOTAL AND PASSED FROM TASK RESULTS
========================================================= */

$total = 0;
$passed = 0;

foreach ($output as $line) {

    /*
     * Remove ANSI color escape sequences
     */
    $cleanLine = preg_replace(
        '/\x1B\[[0-9;]*[mK]/',
        '',
        $line
    );

    /*
     * Count task result lines
     *
     * Example:
     * Task 1: Something – Pass
     * Task 2: Something – Fail
     */
    if (preg_match('/Task\s+[0-9]+\s*:/i', $cleanLine)) {

        $total++;

        if (preg_match('/\bPass\b/i', $cleanLine)) {
            $passed++;
        }
    }
}


/*
 * Calculate percentage
 */
$percentage = 0;

if ($total > 0) {

    $percentage =
        (int)round(($passed * 100) / $total);
}


file_put_contents(
    "/var/www/private_data/lab/results/php_debug.log",
    "COUNT RESULT: TOTAL=$total PASSED=$passed PERCENTAGE=$percentage\n",
    FILE_APPEND | LOCK_EX
);


/* =========================================================
   CREATE RESULT FILE IF NEEDED
========================================================= */

if (!file_exists($resultFile)) {

    $header =
        "Result - " . $lab . "\n" .
        "=======================================================================================\n" .
        sprintf(
            "%-5s %-25s %-22s %-6s %-6s %-10s\n",
            "Sr.#",
            "Name",
            "Date",
            "Total",
            "Passed",
            "Percentage"
        ) .
        "---------------------------------------------------------------------------------------\n";

    file_put_contents(
        $resultFile,
        $header,
        LOCK_EX
    );
}


/* =========================================================
   CALCULATE NEXT SERIAL NUMBER
========================================================= */

$lines = file(
    $resultFile,
    FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES
);

$studentRows = max(0, count($lines) - 4);

$srNo = $studentRows + 1;


/* =========================================================
   CREATE RESULT ROW
========================================================= */

$date = date("Y-m-d H:i:s");

$resultRow = sprintf(
    "%-5d %-25s %-22s %-6d %-6d %-10s\n",
    $srNo,
    $username,
    $date,
    $total,
    $passed,
    $percentage . "%"
);


/* =========================================================
   APPEND RESULT
========================================================= */

file_put_contents(
    $resultFile,
    $resultRow,
    FILE_APPEND | LOCK_EX
);


/* =========================================================
   13. RETURN RESULT
========================================================= */

if ($status !== 0) {

    http_response_code(500);

}

echo $resultOutput;

?>
