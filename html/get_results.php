<?php

header('Content-Type: application/json');


/*
 * =========================================================
 * CONFIGURATION
 * =========================================================
 */

$resultsDir = '/var/www/private_data/lab/results';

$listFile = '/var/www/private_data/lab/list.json';


/*
 * =========================================================
 * CHECK RESULTS DIRECTORY
 * =========================================================
 */

if (!is_dir($resultsDir)) {

    http_response_code(404);

    echo json_encode([
        'error' => 'Lab results directory not found'
    ]);

    exit;
}


/*
 * =========================================================
 * CHECK LAB LIST
 * =========================================================
 */

if (!is_file($listFile)) {

    http_response_code(404);

    echo json_encode([
        'error' => 'Lab list file not found'
    ]);

    exit;
}


/*
 * =========================================================
 * LOAD LAB LIST
 * =========================================================
 */

$listJson =
    file_get_contents($listFile);


$labList =
    json_decode($listJson, true);


if (
    !is_array($labList)
) {

    http_response_code(500);

    echo json_encode([
        'error' => 'Invalid lab list JSON'
    ]);

    exit;
}


/*
 * =========================================================
 * BUILD LAB RESULT LIST
 * =========================================================
 */

$results = [];


foreach ($labList as $lab) {

    /*
     * -----------------------------------------------------
     * Validate required fields
     * -----------------------------------------------------
     */

    if (
        empty($lab['file']) ||
        empty($lab['name'])
    ) {
        continue;
    }


    /*
     * -----------------------------------------------------
     * Get lab category
     * -----------------------------------------------------
     */

    $category =
        !empty($lab['category'])
        ? $lab['category']
        : 'General Labs';


    /*
     * -----------------------------------------------------
     * Convert:
     *
     * lab201-2026.json
     *
     * to:
     *
     * lab201_result.txt
     * -----------------------------------------------------
     */

    $labFile =
        pathinfo(
            $lab['file'],
            PATHINFO_FILENAME
        );


    /*
     * Remove year suffix.
     *
     * lab201-2026
     * becomes
     * lab201
     */

    $labNumber =
        preg_replace(
            '/-\d{4}$/',
            '',
            $labFile
        );


    /*
     * Expected result file
     */

    $resultFile =
        $labNumber . '_result.txt';


    $resultPath =
        $resultsDir . '/' . $resultFile;


    /*
     * -----------------------------------------------------
     * Only show labs that have result files
     * -----------------------------------------------------
     */

    if (!is_file($resultPath)) {
        continue;
    }


    /*
     * -----------------------------------------------------
     * Add result
     * -----------------------------------------------------
     */

    $results[] = [

        'category' => $category,

        'name' => $lab['name'],

        'file' => $resultFile

    ];

}


/*
 * =========================================================
 * SORT RESULTS NUMERICALLY BY LAB NUMBER
 * =========================================================
 */

usort(
    $results,
    function ($a, $b) {

        preg_match(
            '/\d+/',
            $a['file'],
            $matchA
        );


        preg_match(
            '/\d+/',
            $b['file'],
            $matchB
        );


        return
            ((int)$matchA[0])
            <=>
            ((int)$matchB[0]);
    }
);


/*
 * =========================================================
 * RETURN JSON
 * =========================================================
 */

echo json_encode(
    $results,
    JSON_PRETTY_PRINT
);

exit;
