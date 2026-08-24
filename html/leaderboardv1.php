<?php

$type = $_GET['type'] ?? '';
$item = basename($_GET['item'] ?? '');

if ($type !== 'lab') {
    http_response_code(400);
    exit("Invalid result type");
}

if (!preg_match('/^lab[0-9]+$/i', $item)) {
    http_response_code(400);
    exit("Invalid lab");
}

/*
 * Result files are stored here.
 */
$resultFile =
    "/var/www/private_data/lab/results/" .
    $item .
    "_result.txt";


if (!file_exists($resultFile)) {

    http_response_code(404);

    echo "
        <div style='padding:15px;color:#b91c1c;'>
            Result file not found.
        </div>
    ";

    exit;
}


$content =
    file_get_contents($resultFile);


/*
 * Parse result lines.
 *
 * Expected format:
 *
 * 21    abdullah.anjum    2026-08-09 17:43:22    10    10    100%
 */
$lines =
    preg_split(
        '/\R/',
        $content
    );


$students = [];


foreach ($lines as $line) {

    $line = trim($line);

    /*
     * Ignore headers and blank lines.
     */
    if (
        $line === '' ||
        stripos($line, 'Sr.#') === 0 ||
        stripos($line, '# Result') === 0 ||
        stripos($line, 'Name') === 0
    ) {
        continue;
    }


    /*
     * Parse:
     *
     * old serial
     * username
     * date
     * total
     * passed
     * percentage
     */
    if (
        preg_match(
            '/^\s*\d+\s+(\S+)\s+(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+(\d+)\s+(\d+)\s+(\d+)%\s*$/',
            $line,
            $match
        )
    ) {

        $students[] = [
            'name'       => $match[1],
            'date'       => $match[2],
            'total'      => (int)$match[3],
            'passed'     => (int)$match[4],
            'percentage' => (int)$match[5]
        ];
    }
}


/*
 * Sort:
 *
 * 1. Percentage DESC
 * 2. Passed DESC
 * 3. Name ASC
 */
usort(
    $students,
    function ($a, $b) {

        if ($a['percentage'] !== $b['percentage']) {
            return $b['percentage']
                <=> $a['percentage'];
        }

        if ($a['passed'] !== $b['passed']) {
            return $b['passed']
                <=> $a['passed'];
        }

        return strcasecmp(
            $a['name'],
            $b['name']
        );
    }
);


?>

<div style="margin-bottom:20px;">

    <input
        type="text"
        id="resultSearch"
        placeholder="🔍 Search student..."
        style="
            width:100%;
            max-width:500px;
            padding:12px 15px;
            border:1px solid #CBD5E1;
            border-radius:8px;
            font-size:15px;
            box-sizing:border-box;
        "
    >

</div>


<div
    style="
        overflow-x:auto;
        width:100%;
    "
>

<table
    id="leaderboardTable"
    style="
        width:100%;
        border-collapse:collapse;
        background:white;
        font-size:14px;
    "
>

<thead>

<tr
    style="
        background:#1E293B;
        color:white;
    "
>

    <th style="padding:12px;text-align:center;">
        Sr.#
    </th>

    <th style="padding:12px;text-align:left;">
        Name
    </th>

    <th style="padding:12px;text-align:left;">
        Date
    </th>

    <th style="padding:12px;text-align:center;">
        Total
    </th>

    <th style="padding:12px;text-align:center;">
        Passed
    </th>

    <th style="padding:12px;text-align:center;">
        Percentage
    </th>

</tr>

</thead>


<tbody>

<?php

$rank = 1;

foreach ($students as $student):

?>

<tr>

    <td
        style="
            padding:10px;
            text-align:center;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= $rank ?>
    </td>


    <td
        style="
            padding:10px;
            font-weight:500;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= htmlspecialchars($student['name']) ?>
    </td>


    <td
        style="
            padding:10px;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= htmlspecialchars($student['date']) ?>
    </td>


    <td
        style="
            padding:10px;
            text-align:center;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= $student['total'] ?>
    </td>


    <td
        style="
            padding:10px;
            text-align:center;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= $student['passed'] ?>
    </td>


    <td
        style="
            padding:10px;
            text-align:center;
            font-weight:bold;
            border-bottom:1px solid #E2E8F0;
        "
    >
        <?= $student['percentage'] ?>%
    </td>

</tr>

<?php

$rank++;

endforeach;

?>

</tbody>

</table>

</div>


<?php if (count($students) === 0): ?>

<div
    style="
        padding:20px;
        color:#64748B;
        text-align:center;
    "
>
    No valid lab results found.
</div>

<?php endif; ?>
