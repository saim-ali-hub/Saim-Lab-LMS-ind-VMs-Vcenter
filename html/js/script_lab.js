/* =========================================================
   LOAD LAB SECTION
========================================================= */

function loadLabSection() {

    const labList = document.getElementById("labList");

    if (!labList) {
        console.error("labList not found");
        return;
    }

    labList.innerHTML = `
        <div class="loading">
            Loading labs...
        </div>
    `;

    fetch("get_item.php?file=list.json", {
        method: "GET",
        credentials: "include"
    })
    .then(res => {

        if (!res.ok) {
            throw new Error("HTTP error: " + res.status);
        }

        return res.json();

    })
    .then(data => {

        if (!Array.isArray(data)) {

            labList.innerHTML = `
                <div class="error">
                    Invalid lab data.
                </div>
            `;

            return;
        }

        if (data.length === 0) {

            labList.innerHTML = `
                <div class="loading">
                    No labs are currently available.
                </div>
            `;

            return;
        }

        labList.innerHTML = "";

        const groups = {};

        /* =====================================================
           GROUP LABS BY CATEGORY
        ===================================================== */

        data.forEach(item => {

            if (!item.file || !item.name) {
                return;
            }

            const category = item.category || "General Labs";

            if (!groups[category]) {
                groups[category] = [];
            }

            groups[category].push(item);

        });


        /* =====================================================
           CREATE CATEGORY SECTIONS
        ===================================================== */

        for (const category in groups) {

            const wrapper = document.createElement("div");

            wrapper.className = "category";


            /* =================================================
               CATEGORY HEADING
            ================================================= */

            const heading = document.createElement("div");

            heading.className = "category-heading";

            heading.innerHTML = `
                <span>▶</span>
                <span>${escapeHtml(category)}</span>
            `;


            /* =================================================
               LAB LIST
            ================================================= */

            const list = document.createElement("ul");

            list.className = "category-items";

            list.style.display = "none";


            /* =================================================
               CREATE LAB ITEMS
            ================================================= */

            groups[category].forEach(item => {

                const li = document.createElement("li");

                li.className = "category-item";

                li.innerHTML = `
                    <span class="item-icon">🧪</span>
                    <span>${escapeHtml(item.name)}</span>
                `;


                /* =============================================
                   OPEN LAB
                ============================================= */

                li.onclick = function () {

                    openItem("lab", item.file);

                };


                list.appendChild(li);

            });


            /* =================================================
               CATEGORY OPEN / CLOSE
            ================================================= */

            heading.onclick = function () {

                const arrow = heading.querySelector("span:first-child");

                if (list.style.display === "none") {

                    list.style.display = "block";

                    arrow.textContent = "▼";

                } else {

                    list.style.display = "none";

                    arrow.textContent = "▶";

                }

            };


            wrapper.appendChild(heading);

            wrapper.appendChild(list);

            labList.appendChild(wrapper);

        }

    })
    .catch(err => {

        console.error("Lab load error:", err);

        labList.innerHTML = `
            <div class="error">
                Error loading labs.
            </div>
        `;

    });

}


/* =========================================================
   RENDER LAB QUESTIONS
========================================================= */

function renderLabQuestions() {

    console.log("NEW LAB RENDER FUNCTION LOADED");

    const data = AppState.currentLabState?.data;
    const state = AppState.currentLabState?.status || {};

    if (!data) {

        console.error("Lab data missing");

        return;
    }


    let html = `

        <div class="question-box">

            <h2 style="color:#000080;">
                ${escapeHtml(data.title || "Lab")}
            </h2>

            <h2 style="color:#000080;">
                ${escapeHtml(data.description || "")}
            </h2>

    `;


    /* =====================================================
       LAB OBJECTIVE
    ===================================================== */

    if (data.lab_objective) {

        html += `

            <div style="
                background:#e0f2fe;
                color:#0f172a;
                padding:15px;
                border-radius:8px;
                margin-bottom:20px;
            ">

                <h3>
                    ${escapeHtml(
                        data.lab_objective.description || ""
                    )}
                </h3>

        `;


        /* =================================================
           OBJECTIVES
        ================================================= */

        if (Array.isArray(data.lab_objective.objectives)) {

            html += `

                <ul>

                    ${data.lab_objective.objectives
                        .map(obj => `
                            <li>
                                ${escapeHtml(obj)}
                            </li>
                        `)
                        .join("")}

                </ul>

            `;

        }


        html += `
            </div>
        `;

    }


    /* =====================================================
       SCENARIO
    ===================================================== */

    if (
        data.lab_objective &&
        data.lab_objective.scenario
    ) {

        html += `

            <div style="
                background:#fef3c7;
                color:#000;
                padding:15px;
                border-radius:8px;
                margin-bottom:20px;
            ">

                <h3>Scenario</h3>

                <p>
                    ${escapeHtml(
                        data.lab_objective.scenario
                    )}
                </p>

            </div>

        `;

    }


    /* =====================================================
       EMPLOYEES
    ===================================================== */

    if (
        data.lab_objective &&
        Array.isArray(data.lab_objective.employees)
    ) {

        html += `

            <div style="
                background:#dcfce7;
                color:#000;
                padding:15px;
                border-radius:8px;
                margin-bottom:20px;
            ">

                <h3>Employees</h3>

                <ul>

                    ${data.lab_objective.employees
                        .map(emp => `
                            <li>
                                ${escapeHtml(emp)}
                            </li>
                        `)
                        .join("")}

                </ul>

            </div>

        `;

    }


    /* =====================================================
       COMMANDS COVERED
    ===================================================== */

    if (Array.isArray(data.commands_covered)) {

        html += `

            <div style="
                margin-bottom:25px;
                color:blue;
                line-height:1.8;
            ">

                <b style="color:#38bdf8;">
                    Commands Covered:
                </b>

                ${data.commands_covered
                    .map(escapeHtml)
                    .join(", ")}

            </div>

        `;

    }


    /* =====================================================
       LAB TASKS / QUESTIONS
    ===================================================== */

    (data.questions || data.tasks || []).forEach(
        (q, index) => {

            const status = state[index] || "";

            const borderColor =
                status === "done"
                    ? "#22c55e"
                    : status === "review"
                    ? "#f59e0b"
                    : "#38bdf8";


            const doneBg =
                status === "done"
                    ? "#22c55e"
                    : "#334155";


            const reviewBg =
                status === "review"
                    ? "#f59e0b"
                    : "#334155";


            html += `

                <div style="
                    padding:12px;
                    margin-bottom:12px;
                    border-radius:8px;
                    background:#1e293b;
                    color:white;
                    border-left:4px solid ${borderColor};
                ">

                    <div style="
                        padding:12px;
                        margin-bottom:12px;
                        background:#1e293b;
                        color:white;
                    ">

                        <h3 style="color:#38bdf8;">

                            Task ${escapeHtml(q.task_number)}
                            :
                            ${escapeHtml(q.title)}

                        </h3>

            `;


            /* =============================================
               TASK STEPS
            ============================================= */

            if (Array.isArray(q.steps)) {

                html += `

                    <ul style="line-height:1.8;">

                        ${q.steps
                            .map(step => `
                                <li>
                                    ${escapeHtml(step)}
                                </li>
                            `)
                            .join("")}

                    </ul>

                `;

            }


            html += `

                    </div>

                    <div>

                        <button
                            onclick="setStatus(${index}, 'done')"
                            style="
                                padding:6px 12px;
                                border:none;
                                border-radius:5px;
                                margin-right:10px;
                                cursor:pointer;
                                background:${doneBg};
                                color:white;
                            "
                        >
                            Done
                        </button>


                        <button
                            onclick="setStatus(${index}, 'review')"
                            style="
                                padding:6px 12px;
                                border:none;
                                border-radius:5px;
                                cursor:pointer;
                                background:${reviewBg};
                                color:white;
                            "
                        >
                            Review
                        </button>

                    </div>

                </div>

            `;

        }
    );


    /* =====================================================
       COMPLETION MESSAGE
    ===================================================== */

    html += `

        <div style="
            margin-top:20px;
            padding:15px;
            background:#065f46;
            color:white;
            border-radius:8px;
            font-size:18px;
        ">

            ${escapeHtml(
                data.completion_message || ""
            )}

        </div>

    `;


    /* =====================================================
       VALIDATE BUTTON
    ===================================================== */

    html += `

        <button
            onclick="validateLab()"
            style="
                margin-top:20px;
                padding:10px 18px;
                background:#16a34a;
                color:white;
                border:none;
                border-radius:6px;
                cursor:pointer;
            "
        >
            VALIDATE
        </button>

        </div>

    `;


    const contentArea =
        document.getElementById("contentArea");

    if (contentArea) {

        contentArea.innerHTML = html;

    } else {

        console.error("contentArea not found");

    }

}


/* =========================================================
   SET STATUS
========================================================= */

function setStatus(index, value) {

    if (!AppState.currentLabState) {
        return;
    }

    AppState.currentLabState.status[index] = value;

    renderLabQuestions();

}

/* =========================================================
   VALIDATE LAB
========================================================= */


function validateLab() {

    const payload = {

        lab: AppState.currentLabFile,

        status:
            AppState.currentLabState?.status || {}

    };


    const contentArea =
        document.getElementById("contentArea");

    if (!contentArea) {
        return;
    }


    /* =====================================================
       LOADING MESSAGE
    ===================================================== */

    contentArea.innerHTML = `

        <div style="
            padding:20px;
            text-align:center;
        ">

            <h2 style="
                color:#38bdf8;
                margin-bottom:15px;
            ">
                LAB RESULT
            </h2>

            <div style="
                padding:15px;
                background:#1e293b;
                color:#e2e8f0;
                border-radius:8px;
            ">
                Sit tight. Validation is in process...
            </div>

        </div>

    `;


    /* =====================================================
       SEND VALIDATION REQUEST
    ===================================================== */

    fetch("api.php?action=lab", {

        method: "POST",

        credentials: "include",

        headers: {
            "Content-Type": "application/json"
        },

        body: JSON.stringify(payload)

    })

    .then(res => res.text())

    .then(data => {

        console.log("Validation response:", data);


        /* =================================================
           DISPLAY RESULT AS HTML
        ================================================= */

        contentArea.innerHTML = `

            <div>

                <h2 style="
                    color:#38bdf8;
                    margin-bottom:20px;
                ">
                    LAB RESULT
                </h2>


                <div class="validation-output">

                    ${data}

                </div>


                <div style="
                    margin-top:25px;
                    text-align:center;
                ">

                    <button
                        onclick="goBack()"
                        style="
                            padding:10px 25px;
                            background:#16a34a;
                            color:white;
                            border:none;
                            border-radius:6px;
                            cursor:pointer;
                            font-weight:600;
                            font-size:15px;
                        "
                    >
                        BACK
                    </button>

                </div>

            </div>

        `;

    })

    .catch(err => {

        console.error("Lab validation error:", err);


        contentArea.innerHTML = `

            <div style="
                color:#fecaca;
                background:#7f1d1d;
                padding:15px;
                border-radius:8px;
            ">

                Error validating lab.

            </div>

        `;

    });

}
/* =========================================================
   HTML SAFE HELPER
========================================================= */

function escapeHtml(str) {

    if (str === null || str === undefined) {
        return "";
    }

    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");

}


/* =========================================================
   GO BACK
========================================================= */

function goBack() {

    document.getElementById("labPopup").style.display = "block";

    loadLabSection();

}

/* =========================================================
   EXPORT FUNCTIONS
========================================================= */

window.loadLabSection = loadLabSection;

window.renderLabQuestions = renderLabQuestions;

window.setStatus = setStatus;

window.validateLab = validateLab;

window.goBack = goBack;
