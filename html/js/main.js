/* =========================================================
   GLOBAL APPLICATION STATE
========================================================= */

window.AppState = window.AppState || {

    currentLabData: null,
    currentLabFile: null,
    currentLabState: null,
    labStateMap: {},
    currentUser: null

};


/* =========================================================
   OPEN LAB PORTAL
========================================================= */

function openlab() {

    console.log("openlab() called");

    const landingPage =
        document.getElementById("landingPage");

    const labPopup =
        document.getElementById("labPopup");


    if (!landingPage) {

        console.error("landingPage not found");
        return;

    }


    if (!labPopup) {

        console.error("labPopup not found");
        return;

    }


    /* Hide landing page */

    landingPage.style.display = "none";


    /* Show lab popup */

    labPopup.style.display = "flex";


    /* Load labs */

    if (
        typeof window.loadLabSection ===
        "function"
    ) {

        window.loadLabSection();

    } else {

        console.error(
            "loadLabSection is not available."
        );

    }

}


/* =========================================================
   CLOSE LAB POPUP
========================================================= */

function closeLabPopup() {

    const labPopup =
        document.getElementById("labPopup");

    const landingPage =
        document.getElementById("landingPage");


    if (labPopup) {

        labPopup.style.display = "none";

    }


    if (landingPage) {

        landingPage.style.display = "flex";

    }

}


/* =========================================================
   OPEN LAB
========================================================= */

function openItem(section, file) {

    console.log(
        "openItem:",
        section,
        file
    );


    if (section !== "lab") {

        console.error(
            "Invalid section:",
            section
        );

        return;

    }


    if (!file) {

        console.error(
            "Lab file not specified."
        );

        return;

    }


    fetch(
        "get_item.php?file=" +
        encodeURIComponent(file),
        {
            method: "GET",
            credentials: "include"
        }
    )

    .then(response => {

        if (!response.ok) {

            throw new Error(
                "HTTP Error: " +
                response.status
            );

        }

        return response.json();

    })

    .then(data => {

        console.log(
            "LAB DATA LOADED:",
            data
        );


        /* Store lab */

        AppState.currentLabData =
            data;

        AppState.currentLabFile =
            file;


        /* Initialize lab state */

        if (
            !AppState.labStateMap[file]
        ) {

            AppState.labStateMap[file] = {

                data: data,
                status: {}

            };

        } else {

            AppState.labStateMap[file].data =
                data;

        }


        AppState.currentLabState =
            AppState.labStateMap[file];


        /* Hide popup */

        const labPopup =
            document.getElementById("labPopup");

        if (labPopup) {

            labPopup.style.display = "none";

        }


        /* Show work area */

        const workArea =
            document.getElementById("work-area");

        if (workArea) {

            workArea.style.display = "block";

        }


        /* Render lab */

        if (
            typeof window.renderLabQuestions ===
            "function"
        ) {

            window.renderLabQuestions();

        } else {

            console.error(
                "renderLabQuestions is not available."
            );

        }

    })

    .catch(error => {

        console.error(
            "openItem error:",
            error
        );


        const labList =
            document.getElementById("labList");


        if (labList) {

            labList.innerHTML = `

                <div style="
                    background:#7f1d1d;
                    color:#fecaca;
                    padding:15px;
                    border-radius:8px;
                ">

                    Error loading lab:
                    ${escapeHtml(error.message)}

                </div>

            `;

        }

    });

}


/* =========================================================
   LOAD SECTION
========================================================= */

function loadSection(type) {

    if (type === "lab") {

        if (
            typeof window.loadLabSection ===
            "function"
        ) {

            window.loadLabSection();

        } else {

            console.error(
                "loadLabSection is not available."
            );

        }

        return;

    }


    if (type === "leaderboard") {

        if (
            typeof window.loadLeaderboardSection ===
            "function"
        ) {

            window.loadLeaderboardSection();

        } else {

            console.error(
                "loadLeaderboardSection is not available."
            );

        }

        return;

    }


    console.error(
        "Unknown section:",
        type
    );

}


/* =========================================================
   LOAD USER
========================================================= */

fetch(
    "user.php",
    {
        method: "GET",
        credentials: "include"
    }
)

.then(async response => {

    const text =
        await response.text();


    try {

        return JSON.parse(text);

    }

    catch (error) {

        console.error(
            "user.php invalid response:",
            text
        );

        return {
            user: null
        };

    }

})

.then(data => {

    AppState.currentUser =
        data.user || null;


    const currentUser =
        document.getElementById("currentUser");


    if (currentUser) {

        currentUser.innerText =
            data.user || "Guest";

    }

})

.catch(error => {

    console.error(
        "User loading error:",
        error
    );

});


/* =========================================================
   EXPORT
========================================================= */

window.openlab =
    openlab;

window.closeLabPopup =
    closeLabPopup;

window.openItem =
    openItem;

window.loadSection =
    loadSection;
