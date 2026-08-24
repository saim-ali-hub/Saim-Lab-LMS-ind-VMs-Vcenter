<?php

$type = $_GET['type'] ?? '';
$item = basename($_GET['item'] ?? '');

/*
 * ---------------------------------------------------------
 * VALIDATE TYPE
 * ---------------------------------------------------------
 */

if ($type !== 'lab') {
    http_response_code(400);
    exit("Invalid result type");
}


/*
 * ---------------------------------------------------------
 * VALIDATE LAB NAME
 * ---------------------------------------------------------
 */

if (!preg_match('/^lab[0-9]+$/i', $item)) {
    http_response_code(400);
    exit("Invalid lab");
}


/*
 * ---------------------------------------------------------
 * RESULT FILE
 * ---------------------------------------------------------
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


/*
 * ---------------------------------------------------------
 * READ RESULT FILE
 * ---------------------------------------------------------
 */

$content = file_get_contents($resultFile);


/*
 * ---------------------------------------------------------
 * PARSE RESULT LINES
 *
 * Expected format:
 *
 * 21    abdullah.anjum    2026-08-09 17:43:22    10    10    100%
 * ---------------------------------------------------------
 */

$lines = preg_split('/\R/', $content);


/*
 * ---------------------------------------------------------
 * STUDENT RESULTS
 * ---------------------------------------------------------
 */

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

        $name       = trim($match[1]);
        $date       = $match[2];
        $total      = (int)$match[3];
        $passed     = (int)$match[4];
        $percentage = (int)$match[5];


        /*
         * -------------------------------------------------
         * CASE-INSENSITIVE STUDENT KEY
         *
         * Example:
         *
         * Abdullah.Anjum
         * abdullah.anjum
         * ABDULLAH.ANJUM
         *
         * All are treated as the same student.
         * -------------------------------------------------
         */

        $key = strtolower(
            preg_replace('/\s+/', ' ', $name)
        );


        /*
         * Ignore invalid names.
         */

        if (
            $key === '' ||
            $key === 'null' ||
            !preg_match('/[a-zA-Z]/', $key)
        ) {
            continue;
        }


        /*
         * -------------------------------------------------
         * KEEP BEST ATTEMPT ONLY
         *
         * If the same student has multiple attempts,
         * keep the attempt with the highest percentage.
         *
         * If percentage is equal, keep the attempt with
         * the highest passed count.
         * -------------------------------------------------
         */

        if (
            !isset($students[$key]) ||

            $percentage > $students[$key]['percentage'] ||

            (
                $percentage === $students[$key]['percentage'] &&
                $passed > $students[$key]['passed']
            )
        ) {

            $students[$key] = [
                'name'       => $name,
                'date'       => $date,
                'total'      => $total,
                'passed'     => $passed,
                'percentage' => $percentage
            ];
        }
    }
}


/*
 * ---------------------------------------------------------
 * CONVERT ASSOCIATIVE ARRAY TO NORMAL ARRAY
 * ---------------------------------------------------------
 */

$students = array_values($students);


/*
 * ---------------------------------------------------------
 * SORT LEADERBOARD
 *
 * 1. Percentage DESC
 * 2. Passed DESC
 * 3. Name ASC
 * ---------------------------------------------------------
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

<style>

/*
 * =========================================================
 * LEADERBOARD CONTAINER
 * =========================================================
 */

.leaderboard-wrapper {

    width: 95%;
    max-width: 1200px;

    margin: 0 auto;

}


/*
 * =========================================================
 * TITLE
 * =========================================================
 */

.leaderboard-title {

    text-align: center;

    margin: 5px 0 20px 0;

    color: #0066CC;

    font-size: 24px;

    font-weight: 600;

}


/*
 * =========================================================
 * SEARCH BOX
 * =========================================================
 */

.search-box {

    width: 100%;

    display: flex;

    justify-content: flex-end;

    margin-bottom: 15px;

}


.search-box input {

    width: 300px;

    max-width: 100%;

    padding: 10px 15px;

    border: 1px solid #CBD5E1;

    border-radius: 8px;

    font-size: 14px;

    box-sizing: border-box;

    outline: none;

}


.search-box input:focus {

    border-color: #0066CC;

    box-shadow:
        0 0 0 2px rgba(0,102,204,0.10);

}


/*
 * =========================================================
 * TABLE
 * =========================================================
 */

.leaderboard-table {

    width: 100%;

    border-collapse: collapse;

    background: white;

    font-size: 14px;

}


/*
 * =========================================================
 * TABLE HEADER
 * =========================================================
 */

.leaderboard-table thead tr {

    background: #1E293B;

    color: white;

}


.leaderboard-table thead th {

    padding: 12px;

}


/*
 * =========================================================
 * TABLE CELLS
 * =========================================================
 */

.leaderboard-table tbody td {

    padding: 10px;

    border-bottom: 1px solid #E2E8F0;

}


/*
 * =========================================================
 * ALTERNATING ROW COLORS
 * =========================================================
 */

.leaderboard-table tbody tr:nth-child(even) {

    background: #F8FAFC;

}


/*
 * =========================================================
 * HOVER EFFECT
 * =========================================================
 */

.leaderboard-table tbody tr:hover {

    background: #EFF6FF;

}


/*
 * =========================================================
 * COLUMN ALIGNMENT
 * =========================================================
 */

.leaderboard-table th:nth-child(1),
.leaderboard-table td:nth-child(1) {

    text-align: center;

}


.leaderboard-table th:nth-child(2),
.leaderboard-table td:nth-child(2) {

    text-align: left;

}


.leaderboard-table th:nth-child(3),
.leaderboard-table td:nth-child(3) {

    text-align: left;

}


.leaderboard-table th:nth-child(4),
.leaderboard-table td:nth-child(4),

.leaderboard-table th:nth-child(5),
.leaderboard-table td:nth-child(5),

.leaderboard-table th:nth-child(6),
.leaderboard-table td:nth-child(6) {

    text-align: center;

}


/*
 * =========================================================
 * NAME
 * =========================================================
 */

.leaderboard-table tbody td:nth-child(2) {

    font-weight: 500;

}


/*
 * =========================================================
 * PERCENTAGE
 * =========================================================
 */

.leaderboard-table tbody td:nth-child(6) {

    font-weight: bold;

}


/*
 * =========================================================
 * MOBILE
 * =========================================================
 */

@media (max-width: 700px) {

    .leaderboard-wrapper {

        width: 100%;

    }


    .search-box {

        justify-content: stretch;

    }


    .search-box input {

        width: 100%;

    }


    .leaderboard-table {

        font-size: 13px;

    }


    .leaderboard-table thead th,
    .leaderboard-table tbody td {

        padding: 8px 6px;

    }

}

</style>

<div class="leaderboard-wrapper">

<!-- =====================================================
     TITLE
     ===================================================== -->

<div class="leaderboard-title">

    Leaderboard -
    <?= htmlspecialchars(strtoupper($item)) ?>

</div>


<!-- =====================================================
     SEARCH
     ===================================================== -->

<div class="search-box">

    <input
        type="text"
        id="resultSearch"
        placeholder="🔍 Search student..."
        onkeyup="filterResults()"
    >

</div>


<!-- =====================================================
     TABLE
     ===================================================== -->

<div style="
    overflow-x:auto;
    width:100%;
">

    <table
        id="leaderboardTable"
        class="leaderboard-table"
    >

        <thead>

            <tr>

                <th>
                    Sr.#
                </th>

                <th>
                    Name
                </th>

                <th>
                    Date
                </th>

                <th>
                    Total
                </th>

                <th>
                    Passed
                </th>

                <th>
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

                <td>
                    <?= $rank ?>
                </td>


                <td>
                    <?= htmlspecialchars($student['name']) ?>
                </td>


                <td>
                    <?= htmlspecialchars($student['date']) ?>
                </td>


                <td>
                    <?= $student['total'] ?>
                </td>


                <td>
                    <?= $student['passed'] ?>
                </td>


                <td>
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

    <div style="
        padding:20px;
        color:#64748B;
        text-align:center;
    ">
        No valid lab results found.
    </div>

<?php endif; ?>

</div>

<script>

function filterResults() {

    const searchInput =
        document.getElementById("resultSearch");

    const search =
        searchInput.value
        .toLowerCase()
        .trim();


    const rows =
        document.querySelectorAll(
            "#leaderboardTable tbody tr"
        );


    rows.forEach(function(row) {

        const text =
            row.innerText.toLowerCase();


        row.style.display =
            text.includes(search) ? "" : "none";

    });

}

</script>

