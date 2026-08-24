/* =========================================================
   LAB LEADERBOARD
========================================================= */

function showLeaderBoard() {

    console.log("Leaderboard button clicked");

    const landingPage =
        document.getElementById("landingPage");

    const workArea =
        document.getElementById("work-area");

    const contentArea =
        document.getElementById("contentArea");


    if (!workArea) {
        console.error("work-area not found");
        return;
    }

    if (!contentArea) {
        console.error("contentArea not found");
        return;
    }


    /* Hide landing page */
    if (landingPage) {
        landingPage.style.display = "none";
    }


    /* Show work area */
    workArea.style.display = "block";


    /* Show loading message */
    contentArea.innerHTML = `
        <h2>LAB LEADERBOARD</h2>

        <p>
            Loading lab results...
        </p>
    `;


    /* Load lab list */
    loadLabResultList();
}

/* =========================================================
   LOAD LAB RESULT LIST
========================================================= */

function loadLabResultList() {

    const contentArea =
        document.getElementById("contentArea");

    if (!contentArea) {
        console.error("contentArea not found");
        return;
    }


    contentArea.innerHTML = `
        <h2>LAB RESULTS</h2>

        <div class="loading">
            Loading lab results...
        </div>
    `;


    fetch("get_results.php?type=lab", {
        method: "GET",
        credentials: "include"
    })

    .then(response => {

        console.log(
            "get_results.php status:",
            response.status
        );

        if (!response.ok) {
            throw new Error(
                "Unable to load lab results"
            );
        }

        return response.json();

    })


    .then(data => {

        console.log(
            "Lab result list:",
            data
        );


        if (!Array.isArray(data)) {

            contentArea.innerHTML = `
                <h2>LAB RESULTS</h2>

                <div class="error">
                    Invalid lab result data.
                </div>
            `;

            return;
        }


        if (data.length === 0) {

            contentArea.innerHTML = `
                <h2>LAB RESULTS</h2>

                <div class="loading">
                    No lab results are currently available.
                </div>
            `;

            return;
        }


        /*
         * =====================================================
         * MAIN LAB LIST CONTAINER
         * =====================================================
         */

        const labList =
            document.createElement("div");

        labList.id =
            "leaderboardLabList";


        /*
         * =====================================================
         * GROUP LABS BY CATEGORY
         * =====================================================
         */

        const groups = {};


        data.forEach(item => {

            if (!item.file || !item.name) {
                return;
            }


            const category =
                item.category || "General Labs";


            if (!groups[category]) {
                groups[category] = [];
            }


            groups[category].push(item);

        });


        /*
         * =====================================================
         * CREATE CATEGORY SECTIONS
         * SAME STRUCTURE AS script_lab.js
         * =====================================================
         */

        for (const category in groups) {

            const wrapper =
                document.createElement("div");

            wrapper.className =
                "category";


            /*
             * =================================================
             * CATEGORY HEADING
             * =================================================
             */

            const heading =
                document.createElement("div");

            heading.className =
                "category-heading";


            heading.innerHTML = `
                <span>▶</span>
                <span>
                    ${escapeHtml(category)}
                </span>
            `;


            /*
             * =================================================
             * LAB RESULT LIST
             * =================================================
             */

            const list =
                document.createElement("ul");

            list.className =
                "category-items";

            list.style.display =
                "none";


            /*
             * =================================================
             * CREATE LAB RESULT ITEMS
             * =================================================
             */

            groups[category].forEach(item => {

                const li =
                    document.createElement("li");

                li.className =
                    "category-item";


                /*
                 * Remove _result.txt from result filename
                 */

                const originalFile =
                    item.file || "";


                const file =
                    originalFile.replace(
                        /_result\.txt$/i,
                        ""
                    );


                /*
                 * Use trophy icon for leaderboard
                 */

                li.innerHTML = `
                    <span class="item-icon">🏆</span>
                    <span>
                        ${escapeHtml(item.name)}
                    </span>
                `;


                /*
                 * =================================================
                 * OPEN SELECTED LAB LEADERBOARD
                 * =================================================
                 */

                li.onclick = function () {

                    loadLabLeaderboard(file);

                };


                list.appendChild(li);

            });


            /*
             * =================================================
             * CATEGORY OPEN / CLOSE
             * Same behavior as script_lab.js
             * =================================================
             */

            heading.onclick = function () {

                const arrow =
                    heading.querySelector(
                        "span:first-child"
                    );


                if (list.style.display === "none") {

                    list.style.display =
                        "block";

                    arrow.textContent =
                        "▼";

                } else {

                    list.style.display =
                        "none";

                    arrow.textContent =
                        "▶";

                }

            };


            /*
             * =================================================
             * ADD CATEGORY TO LIST
             * =================================================
             */

            wrapper.appendChild(
                heading
            );

            wrapper.appendChild(
                list
            );

            labList.appendChild(
                wrapper
            );

        }


        /*
         * =====================================================
         * DISPLAY FINAL RESULT
         * =====================================================
         */

        contentArea.innerHTML = `
            <h2>LAB RESULTS</h2>
        `;

        contentArea.appendChild(
            labList
        );

    })


    .catch(error => {

        console.error(
            "Lab result list error:",
            error
        );


        contentArea.innerHTML = `
            <h2>LAB RESULTS</h2>

            <div class="error">
                Error loading lab results.
            </div>
        `;

    });

}

/* =========================================================
   LOAD SELECTED LAB LEADERBOARD
========================================================= */

function loadLabLeaderboard(file) {

    console.log(
        "Loading leaderboard:",
        file
    );


    const contentArea =
        document.getElementById("contentArea");


    if (!contentArea) {
        console.error("contentArea not found");
        return;
    }


    contentArea.innerHTML = `

        <p>
            Loading ${file} leaderboard...
        </p>

    `;


    fetch(
        "leaderboard.php?type=lab&item=" +
        encodeURIComponent(file)
    )

        .then(response => {

            console.log(
                "leaderboard.php status:",
                response.status
            );


            if (!response.ok) {
                throw new Error(
                    "HTTP " + response.status
                );
            }


            return response.text();
        })

        .then(html => {

            console.log(
                 "Leaderboard HTML received"
        );

        contentArea.innerHTML = `
	    ${html}
             <div style="
            margin-top: 25px;
            padding: 15px 0;
            text-align: center;
           ">
            <button
               onclick="loadLabResultList()"
               style="
                margin-bottom: 15px;
                padding: 8px 16px;
                border: none;
                border-radius: 6px;
                background: #2563eb;
                color: white;
                cursor: pointer;
                font-size: 14px;
              "
            >
                ← Back to Lab Results
            </button>
	    </div>

          `;
        })


        .catch(error => {

            console.error(
                "Leaderboard error:",
                error
            );


            contentArea.innerHTML = `

                <div
                    style="
                        padding:15px;
                        color:#b91c1c;
                        background:#fee2e2;
                        border-radius:8px;
                    "
                >

                    Unable to load leaderboard.

                    <br><br>

                    ${error.message}

                </div>

            `;
        });
}


/* =========================================================
   SEARCH STUDENTS
========================================================= */

document.addEventListener(
    "input",
    function(e) {

        if (
            !e.target ||
            e.target.id !== "resultSearch"
        ) {
            return;
        }


        const search =
            e.target.value
                .toLowerCase()
                .trim();


        const table =
            document.getElementById(
                "leaderboardTable"
            );


        if (!table) {
            return;
        }


        const rows =
            table.querySelectorAll(
                "tbody tr"
            );


        rows.forEach(row => {

            const nameCell =
                row.cells[1];


            if (!nameCell) {
                return;
            }


            const name =
                nameCell.innerText
                    .toLowerCase();


            row.style.display =
                name.includes(search)
                    ? ""
                    : "none";
        });
    }
);


/* =========================================================
   GO BACK
========================================================= */

function goBack() {

    const landingPage =
        document.getElementById(
            "landingPage"
        );


    const workArea =
        document.getElementById(
            "work-area"
        );


    if (workArea) {
        workArea.style.display =
            "none";
    }


    if (landingPage) {
        landingPage.style.display =
            "flex";
    }
}


/* =========================================================
   EXPORT
========================================================= */

window.showLeaderBoard =
    showLeaderBoard;

window.loadLabResultList =
    loadLabResultList;

window.loadLabLeaderboard =
    loadLabLeaderboard;

window.goBack =
    goBack;

window.loadLabResultList =
    loadLabResultList;
