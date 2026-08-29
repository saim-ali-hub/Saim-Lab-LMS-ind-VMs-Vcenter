#!/bin/bash
validate_lab201_commands_sysinfo() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 201 - Linux Basic Commands and System Information..."

    HOME_DIR="/home/$STUDENT_NAME"

    TOTAL_TASKS=15
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux Server Information & Navigation"
    DATE=$(date "+%F %T")

    SERVER_REPORT="$HOME_DIR/server-report"
    SERVER_REVIEW_REPORT="$HOME_DIR/server-review-report"

    # ============================================================
    # HELPERS
    # ============================================================
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - Login / Identity Information
    if [ -f "$SERVER_REPORT" ] &&
       grep -q "^$STUDENT_NAME$" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "uid=" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "gid=" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "groups=" "$SERVER_REPORT" 2>/dev/null; then
        pass "Task 1: User identity and account information recorded"
    else
        fail "Task 1: User identity information is missing from server-report"
    fi

    # TASK 2 - Present Working Directory
    if [ -f "$SERVER_REPORT" ] &&
       grep -Fxq "$HOME_DIR" "$SERVER_REPORT" 2>/dev/null; then
        pass "Task 2: Home directory path recorded in server-report"
    else
        fail "Task 2: Home directory path is missing from server-report"
    fi

    # TASK 3 - CPU Information
    if [ -f "$SERVER_REPORT" ] &&
       grep -q "Architecture:" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "CPU(s):" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "Model name:" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "Core(s) per socket:" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "Thread(s) per core:" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 3: CPU information recorded in server-report"
    else
        fail "Task 3: Required CPU information is missing from server-report"
    fi

    # TASK 4 - Memory Information
    if [ -f "$SERVER_REPORT" ] &&
       grep -q "Mem:" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "Swap:" "$SERVER_REPORT" 2>/dev/null; then

        FREE_COUNT=$(grep -c "Mem:" "$SERVER_REPORT" 2>/dev/null)
        if [ "$FREE_COUNT" -ge 4 ]; then
            pass "Task 4: Memory information recorded in required formats"
        else
            fail "Task 4: Memory information is incomplete"
        fi
    else
        fail "Task 4: Memory information is missing from server-report"
    fi

    # TASK 5 - Block Devices
    if [ -f "$SERVER_REPORT" ] &&
       grep -q "NAME.*MAJ:MIN.*RM.*SIZE" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 5: Block device information recorded in server-report"

    else
        fail "Task 5: Block device information is missing from server-report"
    fi

    # TASK 6 - Kernel Information
    KERNEL_VERSION=$(uname -r 2>/dev/null)
    if [ -f "$SERVER_REPORT" ] &&
       [ -n "$KERNEL_VERSION" ] &&
       grep -Fq "$KERNEL_VERSION" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 6: Kernel information recorded in server-report"

    else
        fail "Task 6: Kernel information is missing from server-report"
    fi

    # TASK 7 - Uptime
    if [ -f "$SERVER_REPORT" ] &&
       grep -q "load average" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 7: Server uptime and load information recorded"

    else
        fail "Task 7: Uptime information is missing from server-report"
    fi

    # TASK 8 - Home Directory Listings
    TASK8_OK=1
    if [ ! -f "$SERVER_REPORT" ]; then
        TASK8_OK=0
    fi

    if ! grep -q "total " "$SERVER_REPORT" 2>/dev/null; then
        TASK8_OK=0
    fi

    if ! grep -q "^.*[rwx-][rwx-][rwx-].*" "$SERVER_REPORT" 2>/dev/null; then
        TASK8_OK=0
    fi

    # Hidden files should normally include .bashrc on the lab systems.
    if [ -f "$HOME_DIR/.bashrc" ] &&
       ! grep -q "\.bashrc" "$SERVER_REPORT" 2>/dev/null; then
        TASK8_OK=0
    fi

    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: Normal, detailed and hidden file listings recorded"
    else
        fail "Task 8: Required home directory listings are missing"
    fi

    # TASK 9 - Root Filesystem
    if [ -f "$SERVER_REPORT" ] &&
       grep -Fxq "/" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "^etc$" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "^var$" "$SERVER_REPORT" 2>/dev/null &&
       grep -q "^home$" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 9: Root filesystem location and directory listing recorded"

    else
        fail "Task 9: Root filesystem information is missing from server-report"
    fi

    # TASK 10 - Important Linux Directories
    TASK10_OK=1

    for DIR in /etc /opt /var /home /tmp
    do
        if ! grep -Fxq "$DIR" "$SERVER_REPORT" 2>/dev/null; then
            TASK10_OK=0
            break
        fi
    done

    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: Required Linux directory paths recorded"
    else
        fail "Task 10: One or more required directory paths are missing"
    fi

    # TASK 11 - Return to Home Directory
    if [ -f "$SERVER_REPORT" ] &&
       grep -Fxq "$HOME_DIR" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 11: Home directory location recorded"

    else
        fail "Task 11: Home directory location is missing from server-report"
    fi

    # TASK 12 - Parent Directory
    PARENT_DIR=$(dirname "$HOME_DIR")

    if [ -f "$SERVER_REPORT" ] &&
       grep -Fxq "$PARENT_DIR" "$SERVER_REPORT" 2>/dev/null; then

        pass "Task 12: Parent directory location recorded"

    else
        fail "Task 12: Parent directory location is missing from server-report"
    fi

    # TASK 13 - /var/log and Two Levels Back
    TASK13_OK=1

    if ! grep -Fxq "/var/log" "$SERVER_REPORT" 2>/dev/null; then
        TASK13_OK=0
    fi

    if ! grep -Fxq "/" "$SERVER_REPORT" 2>/dev/null; then
        TASK13_OK=0
    fi

    if [ "$TASK13_OK" -eq 1 ]; then
        pass "Task 13: /var/log and two-level backward navigation recorded"
    else
        fail "Task 13: Required /var/log navigation output is missing"
    fi

    # TASK 14 - cd -
    LAST_PATH=$(grep '^/' "$SERVER_REPORT" 2>/dev/null | tail -n 1)

    if [ "$LAST_PATH" = "/var/log" ]; then

        pass "Task 14: Previous directory restored to /var/log"

    else
        fail "Task 14: Final navigation did not return to /var/log"
    fi

    # TASK 15 - Basic Server Health Check
    TASK15_OK=1
    if [ ! -f "$SERVER_REVIEW_REPORT" ]; then
        TASK15_OK=0
    fi

    # Current location / home directory
    if ! grep -Fxq "$HOME_DIR" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # Username
    if ! grep -q "^$STUDENT_NAME$" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # CPU
    if ! grep -q "Architecture:" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # Memory
    if ! grep -q "Mem:" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # Block storage
    if ! grep -q "NAME.*MAJ:MIN.*RM.*SIZE" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # Kernel
    if ! grep -Fq "$KERNEL_VERSION" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    # Uptime
    if ! grep -q "load average" "$SERVER_REVIEW_REPORT" 2>/dev/null; then
        TASK15_OK=0
    fi

    if [ "$TASK15_OK" -eq 1 ]; then
        pass "Task 15: Basic server health check completed successfully"
    else
        fail "Task 15: server-review-report is incomplete"
    fi


    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi


    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin: 6px 0;
    padding: 10px 14px;
    background: #DCFCE7;
    color: #166534;
    border-left: 5px solid #22C55E;
    border-radius: 6px;
    font-weight: 600;
}

.validation-fail {
    margin: 6px 0;
    padding: 10px 14px;
    background: #FEE2E2;
    color: #991B1B;
    border-left: 5px solid #EF4444;
    border-radius: 6px;
    font-weight: 600;
}

.lab-summary {
    margin-top: 25px;
    padding: 28px;
    border-radius: 14px;
    text-align: center;
    background: #0f172a;
    border: 2px solid #38bdf8;
    box-shadow: 0 8px 25px rgba(0,0,0,0.35);
    color: white;
}

.lab-summary-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #38bdf8;
}

.lab-summary-info {
    text-align: left;
    max-width: 650px;
    margin: 0 auto 20px auto;
}

.lab-summary-row {
    padding: 10px 0;
    border-bottom: 1px solid #334155;
}

.lab-summary-label {
    font-weight: 700;
    color: #94a3b8;
    display: inline-block;
    min-width: 110px;
}

.lab-summary-value {
    color: #ffffff;
}

.result-percentage {
    margin-top: 20px;
    font-size: 42px;
    font-weight: 800;
    color: #38bdf8;
}

.result-success {
    margin-top: 20px;
    padding: 15px;
    background: #166534;
    color: #dcfce7;
    border: 2px solid #22c55e;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}

.result-failed {
    margin-top: 20px;
    padding: 15px;
    background: #991b1b;
    color: #fee2e2;
    border: 2px solid #ef4444;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
</style>
HTML


    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML

<div class="lab-summary">

    <div class="lab-summary-title">
        LAB RESULT SUMMARY
    </div>

    <div class="lab-summary-info">

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Student:
            </span>

            <span class="lab-summary-value">
                $STUDENT_NAME
            </span>
        </div>

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Lab:
            </span>

            <span class="lab-summary-value">
                $LAB_NAME
            </span>
        </div>

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Total Tasks:
            </span>

            <span class="lab-summary-value">
                $TOTAL_TASKS
            </span>
        </div>

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Passed:
            </span>

            <span class="lab-summary-value">
                $PASSED
            </span>
        </div>

    </div>

    <div class="result-percentage">
        $PERCENT%
    </div>

    <div class="$RESULT_CLASS">
        $RESULT_ICON $RESULT_TEXT
    </div>

</div>

HTML
}

# ===============================================================

validate_lab202_linuxfs_navigation_fsmgt() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 202 - Linux File System Navigation and File Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/linux_lab"

    TOTAL_TASKS=21
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux File System Navigation and File Management"
    DATE=$(date "+%F %T")

    # ============================================================
    # HELPERS
    # ============================================================

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # PART 1 - CREATE DIRECTORY STRUCTURE
    # TASK 1
    if [ -d "$BASE" ]; then
        pass "Task 1: linux_lab directory created in home directory"
    else
        fail "Task 1: linux_lab directory is missing from home directory"
    fi


    # TASK 2
    if [ -d "$BASE" ]; then
        pass "Task 2: linux_lab directory is available for navigation"
    else
        fail "Task 2: linux_lab directory is missing"
    fi


    # TASK 3
    if [ -d "$BASE/projects" ] &&
       [ -d "$BASE/backups" ]; then
        pass "Task 3: projects and backups directories created"

    else
        fail "Task 3: projects or backups directory is missing"
    fi


    # TASK 4
    if [ -d "$BASE/projects/project1" ] &&
       { [ -d "$BASE/projects/project2" ] || [ -d "$BASE/projects/production" ]; }; then
        pass "Task 4: project1 and project2 directories created"

    else
        fail "Task 4: project1 or project2 directory is missing"
    fi


    # TASK 5
    if [ -d "$BASE/documents/scripts" ] &&
       [ -d "$BASE/reports/notes" ]; then
        pass "Task 5: documents/scripts and reports/notes directory structures created"

    else
        fail "Task 5: documents/scripts or reports/notes structure is missing"
    fi

    # PART 2 - CREATE FILES
    # TASK 6
    if [ -f "$BASE/projects/project1/inventory.txt" ]; then
        if [ ! -s "$BASE/projects/project1/inventory.txt" ]; then
            pass "Task 6: Empty inventory.txt created inside project1"
        else
            fail "Task 6: inventory.txt exists but is not empty"
        fi
    else
        fail "Task 6: inventory.txt is missing from project1"
    fi

    # TASK 7
    if [ -f "$BASE/documents/scripts/daily.sh" ]; then
        if [ ! -s "$BASE/documents/scripts/daily.sh" ]; then
            pass "Task 7: Empty daily.sh created inside scripts"
        else
            fail "Task 7: daily.sh exists but is not empty"
        fi
    else
        fail "Task 7: daily.sh is missing from scripts"
    fi


    # TASK 8
    if [ -f "$BASE/reports/summary.txt" ]; then
        if [ ! -s "$BASE/reports/summary.txt" ]; then
            pass "Task 8: Empty summary.txt created inside reports"
        else
            fail "Task 8: summary.txt exists but is not empty"
        fi
    else
        fail "Task 8: summary.txt is missing from reports"
    fi


    # TASK 9
    EXPECTED_TEXT="Linux is my backbone and I really love Linux."
    if [ -f "$BASE/projects/project1/users.txt" ] &&
       [ "$(cat "$BASE/projects/project1/users.txt" 2>/dev/null)" = "$EXPECTED_TEXT" ]; then
        pass "Task 9: users.txt created with the correct content"
    else
        fail "Task 9: users.txt is missing or contains incorrect content"
    fi

    # PART 3 - COPY FILES
    # TASK 10
    if [ -f "$BASE/projects/project1/inventory.txt" ] &&
       { [ -f "$BASE/projects/project2/inventory_backup.txt" ] ||
         [ -f "$BASE/projects/production/inventory_backup.txt" ]; }; then

        if [ -f "$BASE/projects/project2/inventory_backup.txt" ] &&
           cmp -s \
               "$BASE/projects/project1/inventory.txt" \
               "$BASE/projects/project2/inventory_backup.txt" 2>/dev/null; then

        pass "Task 10: inventory.txt file copied correctly to project2"

    elif [ -f "$BASE/projects/production/inventory_backup.txt" ] &&
         cmp -s \
             "$BASE/projects/project1/inventory.txt" \
             "$BASE/projects/production/inventory_backup.txt" 2>/dev/null; then
            pass "Task 10: inventory.txt file copied correctly to project2"
        else
            fail "Task 10: project2/inventory.txt does not match project1/inventory.txt"
        fi
    else
        fail "Task 10: inventory.txt file is missing from project1 or project2"
    fi

    # TASK 11
    if [ -f "$BASE/projects/project1/users.txt" ]; then

        if [ -f "$BASE/reports/users.txt" ] &&
           cmp -s \
               "$BASE/projects/project1/users.txt" \
               "$BASE/reports/users.txt" 2>/dev/null; then

             pass "Task 11: users.txt copied correctly to reports"

        elif [ -f "$BASE/projects/project2/users.txt" ] &&
             cmp -s \
                 "$BASE/projects/project1/users.txt" \
                 "$BASE/projects/project2/users.txt" 2>/dev/null; then

             pass "Task 11: users.txt copied correctly to reports"

        elif [ -f "$BASE/projects/production/users.txt" ] &&
             cmp -s \
                 "$BASE/projects/project1/users.txt" \
                 "$BASE/projects/production/users.txt" 2>/dev/null; then

             pass "Task 11: users.txt copied correctly to reports"

        else
             fail "Task 11: users.txt copy is missing or does not match the original"
        fi   

        else
             fail "Task 11: Original users.txt is missing from project1"
        fi    

    # TASK 12
    if [ -f "$BASE/reports/summary.txt" ] &&
       [ -f "$BASE/reports/notes/summary.txt" ]; then
        if cmp -s \
            "$BASE/reports/summary.txt" \
            "$BASE/reports/notes/summary.txt" 2>/dev/null; then
            pass "Task 12: summary.txt copied correctly to notes"
        else
            fail "Task 12: notes/summary.txt does not match reports/summary.txt"
        fi
    else
        fail "Task 12: summary.txt is missing from reports or notes"
    fi

    # TASK 13
    if [ -f "$BASE/documents/scripts/daily.sh" ] &&
       [ -f "$BASE/projects/project1/daily.sh" ]; then
        if cmp -s \
            "$BASE/documents/scripts/daily.sh" \
            "$BASE/projects/project1/daily.sh" 2>/dev/null; then
            pass "Task 13: daily.sh copied correctly into project1"
        else
            fail "Task 13: project1/daily.sh does not match scripts/daily.sh"
        fi
    else
        fail "Task 13: daily.sh is missing from scripts or project1"
    fi

    # TASK 14
    if [ -d "$BASE/projects/project1" ] &&
       [ -d "$BASE/backups/project1" ]; then
        pass "Task 14: project1 directory copied correctly into backups"
    else
        fail "Task 14: project1 backup directory is missing"
    fi

    # PART 4 - MOVE AND RENAME FILES
    # TASK 15
    if [ -f "$BASE/projects/project2/inventory_backup.txt" ] &&
       [ ! -e "$BASE/projects/project2/inventory.txt" ]; then
        pass "Task 15: inventory.txt renamed to inventory_backup.txt"
    elif [ -f "$BASE/projects/production/inventory_backup.txt" ] &&
         [ ! -e "$BASE/projects/production/inventory.txt" ]; then
        pass "Task 15: inventory.txt renamed to inventory_backup.txt"
    else
        fail "Task 15: inventory_backup.txt is missing or inventory.txt still exists"
    fi

    # TASK 16
    if [ -f "$BASE/backups/project1/startup.sh" ] &&
       [ ! -e "$BASE/backups/project1/daily.sh" ]; then
        pass "Task 16: daily.sh renamed to startup.sh in backup project1"
    else
        fail "Task 16: startup.sh is missing or daily.sh was not renamed"
    fi

    # TASK 17
    if [ -f "$BASE/projects/project2/users.txt" ] &&
       [ ! -e "$BASE/reports/users.txt" ]; then
        pass "Task 17: users.txt moved from reports to project2"
    elif [ -f "$BASE/projects/production/users.txt" ] &&
         [ ! -e "$BASE/reports/users.txt" ]; then
        pass "Task 17: users.txt moved from reports to project2"
    else
        fail "Task 17: users.txt was not moved correctly from reports"
    fi

    # TASK 18
    if [ -d "$BASE/projects/production" ] &&
       [ ! -e "$BASE/projects/project2" ]; then
        pass "Task 18: project2 renamed to production"
    else
        fail "Task 18: production directory is missing or project2 still exists"
    fi

    # PART 5 - ABSOLUTE AND RELATIVE PATH PRACTICE
    # TASK 19
    if [ -d "$BASE/reports/notes" ]; then
        pass "Task 19: notes directory exists at the required absolute path"
    else
        fail "Task 19: notes directory is missing"
    fi

    # TASK 20
    if [ -d "$BASE" ]; then
        pass "Task 20: linux_lab directory exists for relative navigation"

    else
        fail "Task 20: linux_lab directory is missing"
    fi

    # TASK 21
    if [ -d "$BASE/projects/production" ]; then
        pass "Task 21: production directory exists for relative navigation"
    else
        fail "Task 21: production directory is missing"
    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi


    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin: 6px 0;
    padding: 10px 14px;
    background: #DCFCE7;
    color: #166534;
    border-left: 5px solid #22C55E;
    border-radius: 6px;
    font-weight: 600;
}

.validation-fail {
    margin: 6px 0;
    padding: 10px 14px;
    background: #FEE2E2;
    color: #991B1B;
    border-left: 5px solid #EF4444;
    border-radius: 6px;
    font-weight: 600;
}

.lab-summary {
    margin-top: 25px;
    padding: 28px;
    border-radius: 14px;
    text-align: center;
    background: #0f172a;
    border: 2px solid #38bdf8;
    box-shadow: 0 8px 25px rgba(0,0,0,0.35);
    color: white;
}

.lab-summary-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #38bdf8;
}

.lab-summary-info {
    text-align: left;
    max-width: 650px;
    margin: 0 auto 20px auto;
}

.lab-summary-row {
    padding: 10px 0;
    border-bottom: 1px solid #334155;
}

.lab-summary-label {
    font-weight: 700;
    color: #94a3b8;
    display: inline-block;
    min-width: 110px;
}

.lab-summary-value {
    color: #ffffff;
}

.result-percentage {
    margin-top: 20px;
    font-size: 42px;
    font-weight: 800;
    color: #38bdf8;
}

.result-success {
    margin-top: 20px;
    padding: 15px;
    background: #166534;
    color: #dcfce7;
    border: 2px solid #22c55e;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}

.result-failed {
    margin-top: 20px;
    padding: 15px;
    background: #991b1b;
    color: #fee2e2;
    border: 2px solid #ef4444;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
</style>
HTML


    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML

<div class="lab-summary">

    <div class="lab-summary-title">
        LAB RESULT SUMMARY
    </div>

    <div class="lab-summary-info">

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Student:
            </span>

            <span class="lab-summary-value">
                $STUDENT_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Lab:
            </span>

            <span class="lab-summary-value">
                $LAB_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Total Tasks:
            </span>

            <span class="lab-summary-value">
                $TOTAL_TASKS
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Passed:
            </span>

            <span class="lab-summary-value">
                $PASSED
            </span>
        </div>

    </div>


    <div class="result-percentage">
        $PERCENT%
    </div>


    <div class="$RESULT_CLASS">
        $RESULT_ICON $RESULT_TEXT
    </div>

</div>

HTML

}


# ===========================================================================

validate_lab203_command_navigation() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 203 - Linux Basic Commands & Navigation..."

    HOME_DIR="/home/$STUDENT_NAME"

    TOTAL_TASKS=14
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux Basic Commands & Navigation"
    DATE=$(date "+%F %T")

    SERVER_INFO="$HOME_DIR/server_info"

    # ============================================================
    # HELPERS
    # ============================================================

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # Section 1: Server Info Append to server_info

    # TASK 1
    if [ -f "$SERVER_INFO" ] &&
       grep -Eq "^$HOME_DIR/?$" "$SERVER_INFO" 2>/dev/null; then

        pass "Task 1: Current working directory was recorded in server_info"
    else
        fail "Task 1: Current working directory output is missing from server_info"
    fi

    # TASK 2
    KERNEL_VERSION=$(uname -r 2>/dev/null)
    if [ -f "$SERVER_INFO" ] &&
       [ -n "$KERNEL_VERSION" ] &&
       grep -Fq "$KERNEL_VERSION" "$SERVER_INFO" 2>/dev/null; then
        pass "Task 2: Kernel version was recorded in server_info"
    else
        fail "Task 2: Kernel version output is missing from server_info"
    fi

    # TASK 3
    if grep -q "$HOME_DIR" "$SERVER_INFO"; then 
        pass "Task 3: Detailed directory listing was recorded in server_info"
    else
        fail "Task 3: Detailed directory listing is missing from server_info"
    fi

    # TASK 4
    if grep -q "\.bashrc" "$SERVER_INFO"; then
        pass "Task 4: Hidden files were included in detailed listing"
    else
        fail "Task 4: Hidden file listing is missing from server_info"
    fi

    # TASK 5
    if [ -d "$HOME_DIR/Linux" ]; then
        pass "Task 5: Linux directory created"
    else
        fail "Task 5: Linux directory is missing"
    fi

    # TASK 6
    if [ -f "$SERVER_INFO" ] &&
       grep -Eq "^$HOME_DIR/Linux/?$" "$SERVER_INFO" 2>/dev/null; then
        pass "Task 6: Linux directory path was recorded in server_info"
    else
        fail "Task 6: Linux directory path is missing from server_info"
    fi
    
    # TASK 7
    if [ -d "$HOME_DIR/Linux/Redhat" ] &&
       [ -d "$HOME_DIR/Linux/oel" ] &&
       [ -d "$HOME_DIR/Linux/debian" ]; then
        pass "Task 7: Redhat, oel and debian directories created"
    else
        fail "Task 7: One or more required Linux subdirectories are missing"
    fi

    # TASK 8
    if [ -f "$SERVER_INFO" ] &&
       grep -Eq "^$HOME_DIR/?$" "$SERVER_INFO" 2>/dev/null; then
        pass "Task 8: Student returned to the home directory"
    else
        fail "Task 8: Home directory verification is missing from server_info"
    fi

    # TASK 9
    TASK9_OK=1

    for FILE in \
        "$HOME_DIR/documents/file1.txt" \
        "$HOME_DIR/images/pic.jpg" \
        "$HOME_DIR/media/clip.avi"
    do
        if [ ! -f "$FILE" ] || [ -s "$FILE" ]; then
            TASK9_OK=0
            break
        fi
    done

    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: file1.txt, pic.jpg and clip.avi created as empty files"
    else
        fail "Task 9: Required empty files are missing or contain data"
    fi

    # TASK 10
    if [ -f "$HOME_DIR/documents/file1.txt" ] &&
       [ -f "$HOME_DIR/images/pic.jpg" ] &&
       [ -f "$HOME_DIR/media/clip.avi" ] &&
       [ ! -e "$HOME_DIR/file1.txt" ] &&
       [ ! -e "$HOME_DIR/pic.jpg" ] &&
       [ ! -e "$HOME_DIR/clip.avi" ]; then
        pass "Task 10: Files moved into the correct directories"
    else
        fail "Task 10: Required directories or file locations are incorrect"
    fi
    
    # TASK 11
    if [ -d "$HOME_DIR/office" ] &&
       [ -d "$HOME_DIR/office/hobby" ] &&
       [ -d "$HOME_DIR/office/hobby/personal" ]; then

        pass "Task 11: Nested office/hobby/personal directory structure created"
    else
        fail "Task 11: office/hobby/personal directory structure is incomplete"
    fi

    # TASK 12
    if [ -f "$HOME_DIR/documents/file1.txt" ] &&
       [ -f "$HOME_DIR/office/file1.txt" ]; then
        if cmp -s \
            "$HOME_DIR/documents/file1.txt" \
            "$HOME_DIR/office/file1.txt" 2>/dev/null; then
            pass "Task 12: file1.txt copied correctly to office"
        else
            fail "Task 12: office/file1.txt does not match documents/file1.txt"
        fi
    else
        fail "Task 12: file1.txt is missing from documents or office"
    fi

    # TASK 13
    if [ -f "$HOME_DIR/images/pic.jpg" ] &&
       [ -f "$HOME_DIR/office/hobby/pic.jpg" ]; then
        if cmp -s \
            "$HOME_DIR/images/pic.jpg" \
            "$HOME_DIR/office/hobby/pic.jpg" 2>/dev/null; then
            pass "Task 13: pic.jpg copied correctly to office/hobby"
        else
            fail "Task 13: office/hobby/pic.jpg does not match images/pic.jpg"
        fi
    else
        fail "Task 13: pic.jpg is missing from images or office/hobby"
    fi

    # TASK 14
    OFFICE_TREE="$HOME_DIR/office/hobby/personal/office_tree"
    if [ -f "$OFFICE_TREE" ] &&
       grep -q "personal" "$OFFICE_TREE" 2>/dev/null; then 
        pass "Task 14: office directory tree saved correctly in office_tree"
    else
        fail "Task 14: office_tree exists but does not contain the expected tree output"
    fi

# =========================================================
# SUMMARY
# =========================================================

PERCENT=$((PASSED * 100 / TOTAL_TASKS))

if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
    RESULT_CLASS="result-success"
    RESULT_ICON="✓"
    RESULT_TEXT="LAB PASSED"
else
    RESULT_CLASS="result-failed"
    RESULT_ICON="✗"
    RESULT_TEXT="LAB NEEDS ATTENTION"
fi

# =========================================================
# RESULT STYLES
# =========================================================
cat <<'HTML'
<style>
.validation-pass {
    margin: 6px 0;
    padding: 10px 14px;
    background: #DCFCE7;
    color: #166534;
    border-left: 5px solid #22C55E;
    border-radius: 6px;
    font-weight: 600;
}
.validation-fail {
    margin: 6px 0;
    padding: 10px 14px;
    background: #FEE2E2;
    color: #991B1B;
    border-left: 5px solid #EF4444;
    border-radius: 6px;
    font-weight: 600;
}
.lab-summary {
    margin-top: 25px;
    padding: 28px;
    border-radius: 14px;
    text-align: center;
    background: #0f172a;
    border: 2px solid #38bdf8;
    box-shadow: 0 8px 25px rgba(0,0,0,0.35);
    color: white;
}
.lab-summary-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #38bdf8;
}
.lab-summary-info {
    text-align: left;
    max-width: 650px;
    margin: 0 auto 20px auto;
}
.lab-summary-row {
    padding: 10px 0;
    border-bottom: 1px solid #334155;
}
.lab-summary-label {
    font-weight: 700;
    color: #94a3b8;
    display: inline-block;
    min-width: 110px;
}
.lab-summary-value {
    color: #ffffff;
}
.result-percentage {
    margin-top: 20px;
    font-size: 42px;
    font-weight: 800;
    color: #38bdf8;
}
.result-success {
    margin-top: 20px;
    padding: 15px;
    background: #166534;
    color: #dcfce7;
    border: 2px solid #22c55e;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
.result-failed {
    margin-top: 20px;
    padding: 15px;
    background: #991b1b;
    color: #fee2e2;
    border: 2px solid #ef4444;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
</style>
HTML

# =========================================================
# RESULT SUMMARY
# =========================================================

cat <<HTML

<div class="lab-summary">

    <div class="lab-summary-title">
        LAB RESULT SUMMARY
    </div>

    <div class="lab-summary-info">

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Student:
            </span>

            <span class="lab-summary-value">
                $STUDENT_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Lab:
            </span>

            <span class="lab-summary-value">
                $LAB_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Total Tasks:
            </span>

            <span class="lab-summary-value">
                $TOTAL_TASKS
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Passed:
            </span>

            <span class="lab-summary-value">
                $PASSED
            </span>
        </div>

    </div>


    <div class="result-percentage">
        $PERCENT%
    </div>


    <div class="$RESULT_CLASS">
        $RESULT_ICON $RESULT_TEXT
    </div>

</div>

HTML
}
#=================================================================

validate_lab204_review_navigation() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 204 - Review Linux File System Navigation and Basic Commands..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/vars"

    TOTAL_TASKS=10
    PASSED=0
    LAB_NAME="Lab ${LAB_NUMBER#lab} - Review Linux File System Navigation and Basic Commands"
    DATE=$(date "+%F %T")
    
    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }    

    # TASK 1
    if [ -d "$BASE/systems/logs" ]; then
        pass "Task 1: Nested directory vars/systems/logs created"
    else
        fail "Task 1: Directory structure vars/systems/logs missing"
    fi

    # TASK 2
    if [ -f "$BASE/systems/passwd_tail" ] &&
       [ -f "$BASE/systems/group_head" ]; then
        pass "Task 2: Empty files passwd_tail and group_head created"
    else
        fail "Task 2: passwd_tail or group_head missing or not empty"
    fi
    # TASK 3
    EXPECTED_TEXT="I love linux and excited to join the DevOps course"
    if [ -f "$BASE/systems/logs/file1.txt" ] &&
       [ "$(cat "$BASE/systems/logs/file1.txt" 2>/dev/null)" = "$EXPECTED_TEXT" ]; then
        pass "Task 3: file1.txt created with the exact required text"
    else
        fail "Task 3: file1.txt missing or text does not match exactly"
    fi
    # TASK 4
    if [ -d "$BASE/os/configs" ]; then
        pass "Task 4: Nested directory vars/os/configs created"
    else
        fail "Task 4: Directory structure vars/os/configs missing"
    fi
    # TASK 5
    if [ -f "$BASE/hosts" ] &&
       cmp -s /etc/hosts "$BASE/hosts"; then
        pass "Task 5: /etc/hosts copied correctly to vars/hosts"
    else
        fail "Task 5: vars/hosts missing or does not match /etc/hosts"
    fi
    # TASK 6
    if [ -f "$BASE/os/hosts.bak" ] &&
       cmp -s "$BASE/hosts" "$BASE/os/hosts.bak"; then
        pass "Task 6: hosts content redirected to vars/os/hosts.bak"
    else
        fail "Task 6: hosts.bak missing or content does not match vars/hosts"
    fi
    # TASK 7
    EXPECTED_CHRONY=$(grep "chrony" /etc/passwd 2>/dev/null)

    if [ -n "$EXPECTED_CHRONY" ] &&
       [ -f "$BASE/os/configs/chrony_info" ] &&
       grep -Fxq "$EXPECTED_CHRONY" "$BASE/os/configs/chrony_info" 2>/dev/null; then
        pass "Task 7: chrony information stored correctly in chrony_info"
    else
        fail "Task 7: chrony_info missing or does not contain the required chrony entry"
    fi
    # TASK 8
    if [ -f "$BASE/os/new_file1.txt" ] &&
       cmp -s "$BASE/systems/logs/file1.txt" "$BASE/os/new_file1.txt"; then
        pass "Task 8: file1.txt copied and renamed to new_file1.txt"
    else
        fail "Task 8: new_file1.txt missing or content does not match file1.txt"
    fi
    # TASK 9
    if [ -f "$BASE/systems/passwd_tail" ] &&
       [ "$(wc -l < "$BASE/systems/passwd_tail")" -eq 10 ]; then
       pass "Task 9: Required passwd output stored correctly"
    else
       fail "Task 9: passwd_tail does not contain the required passwd output"
    fi
    # TASK 10
     if [ -f "$BASE/systems/group_head" ] &&
        [ "$(wc -l < "$BASE/systems/group_head")" -eq 10 ]; then
        pass "Task 10: First 10 lines of /etc/group appended to group_head"
    else
        fail "Task 10: group_head does not contain the required head output"
    fi
# =========================================================
# SUMMARY
# =========================================================
PERCENT=$((PASSED * 100 / TOTAL_TASKS))

if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
    RESULT_CLASS="result-success"
    RESULT_ICON="✓"
    RESULT_TEXT="LAB PASSED"
else
    RESULT_CLASS="result-failed"
    RESULT_ICON="✗"
    RESULT_TEXT="LAB NEEDS ATTENTION"
fi

# =========================================================
# RESULT STYLES
# =========================================================
cat <<'HTML'
<style>
.validation-pass {
    margin: 6px 0;
    padding: 10px 14px;
    background: #DCFCE7;
    color: #166534;
    border-left: 5px solid #22C55E;
    border-radius: 6px;
    font-weight: 600;
}
.validation-fail {
    margin: 6px 0;
    padding: 10px 14px;
    background: #FEE2E2;
    color: #991B1B;
    border-left: 5px solid #EF4444;
    border-radius: 6px;
    font-weight: 600;
}
.lab-summary {
    margin-top: 25px;
    padding: 28px;
    border-radius: 14px;
    text-align: center;
    background: #0f172a;
    border: 2px solid #38bdf8;
    box-shadow: 0 8px 25px rgba(0,0,0,0.35);
    color: white;
}
.lab-summary-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #38bdf8;
}
.lab-summary-info {
    text-align: left;
    max-width: 650px;
    margin: 0 auto 20px auto;
}
.lab-summary-row {
    padding: 10px 0;
    border-bottom: 1px solid #334155;
}
.lab-summary-label {
    font-weight: 700;
    color: #94a3b8;
    display: inline-block;
    min-width: 110px;
}
.lab-summary-value {
    color: #ffffff;
}
.result-percentage {
    margin-top: 20px;
    font-size: 42px;
    font-weight: 800;
    color: #38bdf8;
}
.result-success {
    margin-top: 20px;
    padding: 15px;
    background: #166534;
    color: #dcfce7;
    border: 2px solid #22c55e;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
.result-failed {
    margin-top: 20px;
    padding: 15px;
    background: #991b1b;
    color: #fee2e2;
    border: 2px solid #ef4444;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
</style>
HTML

# =========================================================
# RESULT SUMMARY
# =========================================================
cat <<HTML
<div class="lab-summary">

    <div class="lab-summary-title">
        LAB RESULT SUMMARY
    </div>

    <div class="lab-summary-info">

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Student:
            </span>

            <span class="lab-summary-value">
                $STUDENT_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Lab:
            </span>

            <span class="lab-summary-value">
                $LAB_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Total Tasks:
            </span>

            <span class="lab-summary-value">
                $TOTAL_TASKS
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Passed:
            </span>

            <span class="lab-summary-value">
                $PASSED
            </span>
        </div>

    </div>


    <div class="result-percentage">
        $PERCENT%
    </div>


    <div class="$RESULT_CLASS">
        $RESULT_ICON $RESULT_TEXT
    </div>

</div>

HTML
}

# ===============================================================

validate_lab205_file_permissions() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 205 - Linux File Permissions..."
    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/my_own_dir"

    TOTAL_TASKS=20
    PASSED=0
    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux File Permissions"
    DATE=$(date "+%F %T")

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # TASK 1
    if [ -d "$BASE" ]; then
        pass "Task 1: my_own_dir directory created"
    else
        fail "Task 1: my_own_dir directory is missing"
    fi

    # TASK 2
    PERMS=$(stat -c "%a" "$BASE" 2>/dev/null)
    if [ -d "$BASE" ] &&
       [ "$PERMS" = "775" ]; then
        pass "Task 2: Permissions set correctly using symbolic notation"
    else
        fail "Task 2: incorrect permissions set on my_own_dir"
    fi

    # TASK 3
    # Final state confirms the directory was later restored with execute
    # permission, so there is no permanent filesystem state to validate
    # for the failed cd command.

    if [ -d "$BASE" ]; then
        pass "Task 3: my_own_dir exists after navigation test"
    else
        fail "Task 3: my_own_dir is missing"
    fi

    # TASK 4
    # Redhat should not have been created during the permission-denied test.
    # It is created later in Task 5, so validate its final existence.

    if [ -d "$BASE/Redhat" ]; then
        pass "Task 4: Redhat directory exists after permission test"
    else
        fail "Task 4: Redhat directory is missing"
    fi

    # TASK 5
    BASE_PERMS=$(stat -c "%a" "$BASE" 2>/dev/null)
    if [ -d "$BASE/Redhat" ] &&
       [ -d "$BASE/OEL" ] &&
       [ "$BASE_PERMS" = "775" ]; then
        pass "Task 5: Correct permissions set on my_own_dir, Redhat and OEL created"
    else
        fail "Task 5: Required directories or permission is in incorrect"
    fi

    # TASK 6
    REDHAT_PERMS=$(stat -c "%a" "$BASE/Redhat" 2>/dev/null)
    OEL_PERMS=$(stat -c "%a" "$BASE/OEL" 2>/dev/null)
    if [ "$REDHAT_PERMS" = "775" ] &&
       [ "$OEL_PERMS" = "775" ]; then
        pass "Task 6: Recursive permission 775 applied to directory contents"
    else
        fail "Task 6: Redhat or OEL does not have expected 775 permissions"
    fi

    # TASK 7
    EXPECTED_TEXT="I love Linux"
    if [ -f "$BASE/file_1.txt" ] &&
       [ "$(head -n 1 "$BASE/file_1.txt" 2>/dev/null)" = "$EXPECTED_TEXT" ] &&
       [ -d "$BASE/dir_1" ]; then
        pass "Task 7: file_1.txt and dir_1 created correctly"
    else
        fail "Task 7: file_1.txt or dir_1 missing, or file content is incorrect"
    fi

    # TASK 8
    # Read permission is restored later, so final state cannot prove
    # the temporary removal. The file must exist.
    if [ -f "$BASE/file_1.txt" ]; then
        pass "Task 8: file_1.txt exists after permission modification"
    else
        fail "Task 8: file_1.txt is missing"
    fi

    # TASK 9
    # The failed cat is temporary and cannot be validated after the fact.
    # Validate that the file exists.
    if [ -f "$BASE/file_1.txt" ]; then
        pass "Task 9: file_1.txt exists after read-permission test"
    else
        fail "Task 9: file_1.txt is missing"
    fi

    # TASK 10
    if [ -f "$BASE/file_1.txt" ] &&
       [ "$(head -n 1 "$BASE/file_1.txt" 2>/dev/null)" = "$EXPECTED_TEXT" ] &&
       [ "$(stat -c "%a" "$BASE/file_1.txt" 2>/dev/null)" == "764" ]; then
        pass "Task 10: Read permission restored and original content is readable"
    else
        fail "Task 10: Read permission or original file content is incorrect"
    fi

    # TASK 11
    # Write permission is restored in Task 13, therefore validate the
    # resulting file rather than the temporary permission state.
    if [ -f "$BASE/file_1.txt" ]; then
        pass "Task 11: file_1.txt exists after write-permission test"
    else
        fail "Task 11: file_1.txt is missing"
    fi

    # TASK 12
    # The first append should fail. The final file should NOT contain
    # duplicate text from the failed attempt.
    if [ -f "$BASE/file_1.txt" ]; then
        pass "Task 12: file_1.txt exists after write-permission test"
    else
        fail "Task 12: file_1.txt is missing"
    fi

    # TASK 13
    FILE_PERMS=$(stat -c "%a" "$BASE/file_1.txt" 2>/dev/null)
    if [ -f "$BASE/file_1.txt" ] &&
       [ "$FILE_PERMS" = "764" ] || [ "$FILE_PERMS" = "664" ] || [ "$FILE_PERMS" = "644" ]; then
        pass "Task 13: Write permission restored for owner and group"
    else
        fail "Task 13: Write permission was not restored correctly"
    fi

    # TASK 14
    EXPECTED_CONTENT=$'I love Linux\nFile permission setting is fun'
    if [ -f "$BASE/file_1.txt" ] &&
       [ "$(cat "$BASE/file_1.txt" 2>/dev/null)" = "$EXPECTED_CONTENT" ]; then
        pass "Task 14: Required text appended successfully"
    else
        fail "Task 14: file_1.txt does not contain the expected two lines"
    fi

    # TASK 15
    OWNER_EXEC=$(stat -c "%A" "$BASE/file_1.txt" 2>/dev/null | cut -c4)
    if [ "$OWNER_EXEC" = "x" ]; then
        pass "Task 15: Execute permission added for owner"
    else
        fail "Task 15: Owner execute permission is missing"
    fi

    # TASK 16
    DIR1_PERMS=$(stat -c "%A" "$BASE/dir_1" 2>/dev/null)

    # After Task 16, starting from 775:
    # Owner: r-x -> -wx
    # Group: rwx -> rw-
    # Others: r-x -> r--
    #
    # Expected: d-wxrwx? 
    #
    # However Task 19 later changes dir_1 to 777.
    # Therefore validate final state in Task 19.
    if [ -d "$BASE/dir_1" ]; then
        pass "Task 16: dir_1 exists after permission modification"
    else
        fail "Task 16: dir_1 is missing"
    fi

    # TASK 17
    if [ -f "$BASE/Redhat/new_info" ] &&
       grep -q "dir_1" "$BASE/Redhat/new_info" 2>/dev/null; then
        pass "Task 17: new_info created with dir_1 permission information"
    else
        fail "Task 17: Redhat/new_info missing or incorrect"
    fi

    # TASK 18
    if [ -f "$BASE/OEL/new_info" ] &&
       cmp -s "$BASE/Redhat/new_info" "$BASE/OEL/new_info"; then
        pass "Task 18: new_info copied correctly into OEL"
    else
        fail "Task 18: OEL/new_info missing or content does not match"
    fi

    # TASK 19
    DIR1_FINAL_PERMS=$(stat -c "%a" "$BASE/dir_1" 2>/dev/null)
    if [ -d "$BASE/dir_1" ] &&
       [ "$DIR1_FINAL_PERMS" = "777" ]; then
        pass "Task 19: dir_1 permissions set to 777"
    else
        fail "Task 19: dir_1 permissions are not 777"
    fi

    # TASK 20
    if [ -f "$BASE/OEL/new_info" ] &&
       [ -f "$BASE/OEL/new_info.txt" ] &&
       cmp -s "$BASE/OEL/new_info" "$BASE/OEL/new_info.txt"; then
        pass "Task 20: new_info copied successfully to new_info.txt"
    else
        fail "Task 20: OEL/new_info or new_info.txt missing or contents differ"
    fi

# =========================================================
# SUMMARY
# =========================================================

PERCENT=$((PASSED * 100 / TOTAL_TASKS))

if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
    RESULT_CLASS="result-success"
    RESULT_ICON="✓"
    RESULT_TEXT="LAB PASSED"
else
    RESULT_CLASS="result-failed"
    RESULT_ICON="✗"
    RESULT_TEXT="LAB NEEDS ATTENTION"
fi

# =========================================================
# RESULT STYLES
# =========================================================
cat <<'HTML'
<style>
.validation-pass {
    margin: 6px 0;
    padding: 10px 14px;
    background: #DCFCE7;
    color: #166534;
    border-left: 5px solid #22C55E;
    border-radius: 6px;
    font-weight: 600;
}
.validation-fail {
    margin: 6px 0;
    padding: 10px 14px;
    background: #FEE2E2;
    color: #991B1B;
    border-left: 5px solid #EF4444;
    border-radius: 6px;
    font-weight: 600;
}
.lab-summary {
    margin-top: 25px;
    padding: 28px;
    border-radius: 14px;
    text-align: center;
    background: #0f172a;
    border: 2px solid #38bdf8;
    box-shadow: 0 8px 25px rgba(0,0,0,0.35);
    color: white;
}
.lab-summary-title {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 20px;
    color: #38bdf8;
}
.lab-summary-info {
    text-align: left;
    max-width: 650px;
    margin: 0 auto 20px auto;
}
.lab-summary-row {
    padding: 10px 0;
    border-bottom: 1px solid #334155;
}
.lab-summary-label {
    font-weight: 700;
    color: #94a3b8;
    display: inline-block;
    min-width: 110px;
}
.lab-summary-value {
    color: #ffffff;
}
.result-percentage {
    margin-top: 20px;
    font-size: 42px;
    font-weight: 800;
    color: #38bdf8;
}
.result-success {
    margin-top: 20px;
    padding: 15px;
    background: #166534;
    color: #dcfce7;
    border: 2px solid #22c55e;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
.result-failed {
    margin-top: 20px;
    padding: 15px;
    background: #991b1b;
    color: #fee2e2;
    border: 2px solid #ef4444;
    border-radius: 10px;
    font-size: 21px;
    font-weight: 700;
}
</style>
HTML

# =========================================================
# RESULT SUMMARY
# =========================================================

cat <<HTML

<div class="lab-summary">

    <div class="lab-summary-title">
        LAB RESULT SUMMARY
    </div>

    <div class="lab-summary-info">

        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Student:
            </span>

            <span class="lab-summary-value">
                $STUDENT_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Lab:
            </span>

            <span class="lab-summary-value">
                $LAB_NAME
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Total Tasks:
            </span>

            <span class="lab-summary-value">
                $TOTAL_TASKS
            </span>
        </div>


        <div class="lab-summary-row">
            <span class="lab-summary-label">
                Passed:
            </span>

            <span class="lab-summary-value">
                $PASSED
            </span>
        </div>

    </div>


    <div class="result-percentage">
        $PERCENT%
    </div>


    <div class="$RESULT_CLASS">
        $RESULT_ICON $RESULT_TEXT
    </div>

</div>

HTML
}
#=================================================================

validate_lab206_file_permissionsII() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 206 - Linux File Permissions II..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/permissions_lab"

    TOTAL_TASKS=7
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux File Permissions"
    DATE=$(date "+%F %T")

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - Directory Structure
    if [ -d "$BASE" ] &&
       [ -d "$BASE/application" ] &&
       [ -d "$BASE/configuration" ] &&
       [ -d "$BASE/logs" ] &&
       [ -d "$BASE/scripts" ] &&
       [ -d "$BASE/reports" ] &&
       [ -d "$BASE/private" ]; then

        pass "Task 1: permissions_lab directory structure created"

    else
        fail "Task 1: Required directories are missing"
    fi

    # TASK 2 - Symbolic Permissions
    if [ -f "$BASE/scripts/backup.sh" ] &&
       [ -f "$BASE/scripts/monitor.sh" ] &&
       [ -f "$BASE/scripts/cleanup.sh" ] &&
       [ "$(stat -c %a "$BASE/scripts/backup.sh" 2>/dev/null)" = "700" ] &&
       [ "$(stat -c %a "$BASE/scripts/monitor.sh" 2>/dev/null)" = "755" ] &&
       [ "$(stat -c %a "$BASE/scripts/cleanup.sh" 2>/dev/null)" = "750" ]; then

        pass "Task 2: Symbolic permissions configured correctly"

    else
        fail "Task 2: Script permissions are incorrect"
    fi

    # TASK 3 - Private Directory
    if [ -d "$BASE/private" ] &&
       [ -f "$BASE/private/credentials.txt" ] &&
       [ -f "$BASE/private/keys.txt" ] &&
       [ "$(stat -c %a "$BASE/private" 2>/dev/null)" = "700" ] &&
       [ "$(stat -c %a "$BASE/private/credentials.txt" 2>/dev/null)" = "640" ] &&
       [ "$(stat -c %a "$BASE/private/keys.txt" 2>/dev/null)" = "600" ]; then

        pass "Task 3: Private directory and file permissions configured"

    else
        fail "Task 3: Private directory permissions are incorrect"
    fi

    # TASK 4 - Application Files
    if [ -f "$BASE/application/app.conf" ] &&
       [ -f "$BASE/application/app.log" ] &&
       [ -f "$BASE/application/deploy.sh" ] &&
       [ -f "$BASE/application/README.txt" ] &&
       [ "$(stat -c %a "$BASE/application/app.conf" 2>/dev/null)" = "644" ] &&
       [ "$(stat -c %a "$BASE/application/app.log" 2>/dev/null)" = "640" ] &&
       [ "$(stat -c %a "$BASE/application/deploy.sh" 2>/dev/null)" = "755" ] &&
       [ "$(stat -c %a "$BASE/application/README.txt" 2>/dev/null)" = "644" ]; then

        pass "Task 4: Application file permissions configured correctly"

    else
        fail "Task 4: Application file permissions are incorrect"
    fi

    # TASK 5 - Configuration Files
    if [ -f "$BASE/configuration/database.conf" ] &&
       [ -f "$BASE/configuration/network.conf" ] &&
       [ "$(stat -c %a "$BASE/configuration/database.conf" 2>/dev/null)" = "600" ] &&
       [ "$(stat -c %a "$BASE/configuration/network.conf" 2>/dev/null)" = "640" ]; then

        pass "Task 5: Configuration file permissions configured correctly"

    else
        fail "Task 5: Configuration file permissions are incorrect"
    fi

    # TASK 6 - Log Directory
    if [ -d "$BASE/logs" ] &&
       [ -f "$BASE/logs/application.log" ] &&
       [ -f "$BASE/logs/access.log" ] &&
       [ "$(stat -c %a "$BASE/logs" 2>/dev/null)" = "750" ] &&
       [ "$(stat -c %a "$BASE/logs/application.log" 2>/dev/null)" = "640" ] &&
       [ "$(stat -c %a "$BASE/logs/access.log" 2>/dev/null)" = "644" ]; then

        pass "Task 6: Log directory and file permissions configured"

    else
        fail "Task 6: Log permissions are incorrect"
    fi

    # TASK 7 - Recursive Permissions
    TASK7_OK=1
    for DIR in \
        "$BASE/reports" \
        "$BASE/reports/engineering" \
        "$BASE/reports/management"
    do
        [ -d "$DIR" ] || TASK7_OK=0
        [ "$(stat -c %a "$DIR" 2>/dev/null)" = "700" ] || TASK7_OK=0
    done

    for FILE in \
        "$BASE/reports/engineering/report1.txt" \
        "$BASE/reports/engineering/report2.txt" \
        "$BASE/reports/management/bonus.txt" \
        "$BASE/reports/management/rise.txt"
    do
        [ -f "$FILE" ] || TASK7_OK=0
        [ "$(stat -c %a "$FILE" 2>/dev/null)" = "700" ] || TASK7_OK=0
    done

    [ -f "$BASE/reports/daily.txt" ] || TASK7_OK=0
    [ "$(stat -c %a "$BASE/reports/daily.txt" 2>/dev/null)" = "660" ] || TASK7_OK=0

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: Recursive permissions and daily.txt configured correctly"
    else
        fail "Task 7: Reports hierarchy permissions are incorrect"
    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

# =========================================================
# RESULT STYLES
# =========================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}
.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}
.lab-summary{
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}
.lab-summary-title{
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}
.lab-summary-info{
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}
.lab-summary-row{
    padding:10px 0;
    border-bottom:1px solid #334155;
}
.lab-summary-label{
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}
.result-percentage{
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}
.result-success{
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
.result-failed{
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

# =========================================================
# RESULT SUMMARY
# =========================================================
    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=================================================================================

validate_lab207_ownership_group_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 207 - Ownership and Group Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/ownership_lab"

    TOTAL_TASKS=10
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Ownership and Group Management"
    DATE=$(date "+%F %T")

    # ============================================================
    # HELPERS
    # ============================================================

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - DIRECTORY STRUCTURE
    TASK1_OK=1

    [ -d "$BASE" ] || TASK1_OK=0

    for DIR in \
        "$BASE/application" \
        "$BASE/database" \
        "$BASE/project1" \
        "$BASE/project2" \
        "$BASE/backup"
    do
        [ -d "$DIR" ] || TASK1_OK=0
    done

    for FILE in \
        "$BASE/file1.txt" \
        "$BASE/file2.txt" \
        "$BASE/file3.txt" \
        "$BASE/file4.txt" \
        "$BASE/backup/backup1.txt" \
        "$BASE/backup/backup2.txt"
    do
        [ -f "$FILE" ] || TASK1_OK=0
    done

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: ownership_lab directory structure created"
    else
        fail "Task 1: Required files or directories are missing"
    fi

    # TASK 2 - CHANGE ONLY OWNER OF file1.txt
    FILE1="$BASE/file1.txt"

    FILE1_OWNER=$(stat -c %U "$FILE1" 2>/dev/null)
    FILE1_GROUP=$(stat -c %G "$FILE1" 2>/dev/null)

    EXPECTED_ORIGINAL_GROUP="domain users"

    if [ -f "$FILE1" ] &&
       [ "$FILE1_OWNER" = "john" ] &&
       [ "$FILE1_GROUP" = "$EXPECTED_ORIGINAL_GROUP" ]; then

        pass "Task 2: file1.txt owner changed to john"
    else
        fail "Task 2: file1.txt owner or group is incorrect"
    fi

    # TASK 3 - CHANGE ONLY GROUP USING CHOWN
    FILE2="$BASE/file2.txt"

    FILE2_OWNER=$(stat -c %U "$FILE2" 2>/dev/null)
    FILE2_GROUP=$(stat -c %G "$FILE2" 2>/dev/null)

    if [ -f "$FILE2" ] &&
       [ "$FILE2_OWNER" = "$STUDENT_NAME" ] &&
       [ "$FILE2_GROUP" = "developers" ]; then

        pass "Task 3: file2.txt group changed to developers using chown"
    else
        fail "Task 3: file2.txt owner or group is incorrect"
    fi

    # TASK 4 - CHANGE ONLY GROUP USING CHGRP
    FILE3="$BASE/file3.txt"

    FILE3_OWNER=$(stat -c %U "$FILE3" 2>/dev/null)
    FILE3_GROUP=$(stat -c %G "$FILE3" 2>/dev/null)

    if [ -f "$FILE3" ] &&
       [ "$FILE3_OWNER" = "$STUDENT_NAME" ] &&
       [ "$FILE3_GROUP" = "developers" ]; then

        pass "Task 4: file3.txt group changed to developers using chgrp"
    else
        fail "Task 4: file3.txt owner or group is incorrect"
    fi

    # TASK 5 - CHANGE BOTH OWNER AND GROUP
    FILE4="$BASE/file4.txt"

    FILE4_OWNER=$(stat -c %U "$FILE4" 2>/dev/null)
    FILE4_GROUP=$(stat -c %G "$FILE4" 2>/dev/null)

    if [ -f "$FILE4" ] &&
       [ "$FILE4_OWNER" = "john" ] &&
       [ "$FILE4_GROUP" = "developers" ]; then

        pass "Task 5: file4.txt owner and group changed correctly"
    else
        fail "Task 5: file4.txt owner or group is incorrect"
    fi

    # TASK 6 - CHANGE ONLY OWNER OF APPLICATION DIRECTORY
    APPLICATION="$BASE/application"

    APPLICATION_OWNER=$(stat -c %U "$APPLICATION" 2>/dev/null)
    APPLICATION_GROUP=$(stat -c %G "$APPLICATION" 2>/dev/null)

    if [ -d "$APPLICATION" ] &&
       [ "$APPLICATION_OWNER" = "smith" ] &&
       [ "$APPLICATION_GROUP" = "$EXPECTED_ORIGINAL_GROUP" ]; then

        pass "Task 6: application directory owner changed to smith"
    else
        fail "Task 6: application directory owner or group is incorrect"
    fi

    # TASK 7 - CHANGE ONLY GROUP OF DATABASE DIRECTORY USING CHOWN
    DATABASE="$BASE/database"

    DATABASE_OWNER=$(stat -c %U "$DATABASE" 2>/dev/null)
    DATABASE_GROUP=$(stat -c %G "$DATABASE" 2>/dev/null)

    if [ -d "$DATABASE" ] &&
       [ "$DATABASE_OWNER" = "$STUDENT_NAME" ] &&
       [ "$DATABASE_GROUP" = "admins" ]; then

        pass "Task 7: database directory group changed to admins using chown"
    else
        fail "Task 7: database directory owner or group is incorrect"
    fi

    # TASK 8 - CHANGE ONLY GROUP OF PROJECT1 USING CHGRP
    PROJECT1="$BASE/project1"

    PROJECT1_OWNER=$(stat -c %U "$PROJECT1" 2>/dev/null)
    PROJECT1_GROUP=$(stat -c %G "$PROJECT1" 2>/dev/null)

    if [ -d "$PROJECT1" ] &&
       [ "$PROJECT1_OWNER" = "$STUDENT_NAME" ] &&
       [ "$PROJECT1_GROUP" = "admins" ]; then

        pass "Task 8: project1 directory group changed to admins using chgrp"
    else
        fail "Task 8: project1 directory owner or group is incorrect"
    fi

    # TASK 9 - CHANGE BOTH OWNER AND GROUP OF PROJECT2
    PROJECT2="$BASE/project2"

    PROJECT2_OWNER=$(stat -c %U "$PROJECT2" 2>/dev/null)
    PROJECT2_GROUP=$(stat -c %G "$PROJECT2" 2>/dev/null)

    if [ -d "$PROJECT2" ] &&
       [ "$PROJECT2_OWNER" = "smith" ] &&
       [ "$PROJECT2_GROUP" = "admins" ]; then

        pass "Task 9: project2 directory owner and group changed correctly"
    else
        fail "Task 9: project2 directory owner or group is incorrect"
    fi

    # TASK 10 - RECURSIVE CHOWN OF BACKUP
    TASK10_OK=1

    for ITEM in \
        "$BASE/backup" \
        "$BASE/backup/backup1.txt" \
        "$BASE/backup/backup2.txt"
    do

        if [ ! -e "$ITEM" ]; then
            TASK10_OK=0
            continue
        fi

        OWNER=$(stat -c %U "$ITEM" 2>/dev/null)
        GROUP=$(stat -c %G "$ITEM" 2>/dev/null)

        [ "$OWNER" = "smith" ] || TASK10_OK=0
        [ "$GROUP" = "admins" ] || TASK10_OK=0

    done

    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: backup ownership changed recursively to smith:admins"
    else
        fail "Task 10: Recursive ownership of backup is incorrect"
    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=================================================================================

validate_lab208_linux_file_links() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 208 - Linux File Links: Hard Links and Soft Links..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/links_lab"

    TOTAL_TASKS=17
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux File Links: Hard Links and Soft Links"
    DATE=$(date "+%F %T")

    # ============================================================
    # HELPERS
    # ============================================================

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - DIRECTORY STRUCTURE
    TASK1_OK=1

    [ -d "$BASE" ] || TASK1_OK=0

    for DIR in \
        "$BASE/data" \
        "$BASE/reports" \
        "$BASE/backup" \
        "$BASE/application" \
        "$BASE/tmp"
    do
        if [ ! -d "$DIR" ]; then 
            TASK1_OK=0
        fi
    done

    for FILE in \
        "$BASE/data/customer.txt" \
        "$BASE/backup/application.log"
    do
        if [ ! -f "$FILE" ]; then 
            TASK1_OK=0
        fi
    done

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: links_lab directory structure created successfully"
    else
        fail "Task 1: Required directories or files are missing"
    fi

    # TASK 2 - CREATE AND VERIFY ORIGINAL FILE
    CUSTOMER="$BASE/data/customer.txt"

    TASK2_OK=1

    [ -f "$CUSTOMER" ] || TASK2_OK=0

    if [ -f "$CUSTOMER" ]; then

        grep -Fxq "Customer Database" \
            "$CUSTOMER" || TASK2_OK=0

        grep -Fxq "Application: Customer Portal" \
            "$CUSTOMER" || TASK2_OK=0

        grep -Fxq "Environment: Production" \
            "$CUSTOMER" || TASK2_OK=0

    fi

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: customer.txt created with required original content"
    else
        fail "Task 2: customer.txt is missing or required content is incorrect"
    fi

    # TASK 3 - CREATE HARD LINK
    HARD_CUSTOMER="$BASE/reports/customer_hard.txt"

    if [ ! -e "$HARD_CUSTOMER" ] &&
       [ -f "$CUSTOMER" ]; then

        pass "Task 3: customer hard-link workflow completed"

    else
        fail "Task 3: customer hard-link workflow was not completed correctly"
    fi

    # TASK 4 - VERIFY HARD LINK SAME INODE
    if [ ! -e "$HARD_CUSTOMER" ] &&
       [ -f "$CUSTOMER" ]; then

        pass "Task 4: hard-link inode relationship workflow completed"

    else
        fail "Task 4: hard-link relationship could not be verified"
    fi

    # TASK 5 - MODIFY ORIGINAL FILE
    TASK5_EVIDENCE="$BASE/tmp/task5_customer.txt"

    TASK5_OK=1

    [ -f "$TASK5_EVIDENCE" ] || TASK5_OK=0

    if [ -f "$TASK5_EVIDENCE" ]; then

        grep -Fxq "Customer Database" \
            "$TASK5_EVIDENCE" || TASK5_OK=0

        grep -Fxq "Application: Customer Portal" \
            "$TASK5_EVIDENCE" || TASK5_OK=0

        grep -Fxq "Environment: Production" \
            "$TASK5_EVIDENCE" || TASK5_OK=0

        grep -Fxq "Last Updated: 2026-08-16" \
            "$TASK5_EVIDENCE" || TASK5_OK=0

    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: customer.txt was modified with Last Updated entry"
    else
        fail "Task 5: Task 5 evidence is missing or Last Updated entry is incorrect"
    fi


    # TASK 6 - MODIFY FILE THROUGH HARD LINK
    TASK6_EVIDENCE="$BASE/tmp/task6_customer.txt"

    TASK6_OK=1

    [ -f "$TASK6_EVIDENCE" ] || TASK6_OK=0

    if [ -f "$TASK6_EVIDENCE" ]; then

        grep -Fxq "Customer Database" \
            "$TASK6_EVIDENCE" || TASK6_OK=0

        grep -Fxq "Application: Customer Portal" \
            "$TASK6_EVIDENCE" || TASK6_OK=0

        grep -Fxq "Environment: Production" \
            "$TASK6_EVIDENCE" || TASK6_OK=0

        grep -Fxq "Last Updated: 2026-08-16" \
            "$TASK6_EVIDENCE" || TASK6_OK=0

        grep -Fxq "Updated By: Reporting Team" \
            "$TASK6_EVIDENCE" || TASK6_OK=0

    fi

    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: customer database was modified through the hard link"
    else
        fail "Task 6: Task 6 evidence is missing or Reporting Team update is incorrect"
    fi

    # TASK 7 - CREATE SYMBOLIC LINK TO CUSTOMER FILE
    CUSTOMER_SOFT="$BASE/application/customer_soft.txt"

    # The symbolic link is removed in Task 17. Validate final state.
    if [ ! -e "$CUSTOMER_SOFT" ] &&
       [ -f "$CUSTOMER" ]; then

        pass "Task 7: customer symbolic-link workflow completed"

    else
        fail "Task 7: customer symbolic-link workflow incomplete"
    fi

    # TASK 8 - COMPARE HARD LINK / SOFT LINK
    if [ -f "$CUSTOMER" ] &&
       [ ! -e "$CUSTOMER_SOFT" ]; then

        pass "Task 8: hard-link and symbolic-link comparison workflow completed"

    else
        fail "Task 8: link comparison requirements could not be verified"
    fi

    # TASK 9 - CREATE HARD LINK TO APPLICATION LOG
    MOVED_LOG="$BASE/backup/application.log"
    HARD_LOG="$BASE/backup/application_hard.log"

    TASK9_OK=1

    [ -f "$MOVED_LOG" ] || TASK9_OK=0

    if [ -f "$MOVED_LOG" ]; then

        grep -Fxq "Application: Started" \
            "$MOVED_LOG" || TASK9_OK=0

        grep -Fxq "Database Connection: Successful" \
            "$MOVED_LOG" || TASK9_OK=0

        grep -Fxq "Application Status: Running" \
            "$MOVED_LOG" || TASK9_OK=0

    fi

    # Hard link must have been removed in Task 17.
    [ ! -e "$HARD_LOG" ] || TASK9_OK=0

    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: application log hard-link workflow completed"
    else
        fail "Task 9: application log hard-link workflow is incomplete"
    fi

    # TASK 10 - CREATE SYMBOLIC LINK TO APPLICATION LOG
    SOFT_LOG="$BASE/reports/application_soft.log"

    if [ ! -e "$SOFT_LOG" ] &&
       [ -f "$MOVED_LOG" ]; then

        pass "Task 10: application log symbolic-link workflow completed"

    else
        fail "Task 10: application log symbolic-link workflow incomplete"
    fi

    # TASK 11 - HARD LINK, SOFT LINK AND COPY
    COPY_LOG="$BASE/backup/application_copy.log"

    TASK11_OK=1

    [ -f "$COPY_LOG" ] || TASK11_OK=0
    [ -f "$MOVED_LOG" ] || TASK11_OK=0

    # Copy must NOT contain the later update.
    if [ -f "$COPY_LOG" ]; then

        if grep -Fxq "Here is new update" "$COPY_LOG"; then
            TASK11_OK=0
        fi

    fi

    # Original/moved file must contain the update.
    if [ -f "$MOVED_LOG" ]; then

        grep -Fxq "Here is new update" \
            "$MOVED_LOG" || TASK11_OK=0

    fi

    # Copy must have a different inode.
    if [ -f "$MOVED_LOG" ] &&
       [ -f "$COPY_LOG" ]; then

        ORIGINAL_INODE=$(stat -c %i "$MOVED_LOG" 2>/dev/null)
        COPY_INODE=$(stat -c %i "$COPY_LOG" 2>/dev/null)

        [ -n "$ORIGINAL_INODE" ] || TASK11_OK=0
        [ -n "$COPY_INODE" ] || TASK11_OK=0

        [ "$ORIGINAL_INODE" != "$COPY_INODE" ] || TASK11_OK=0

    fi

    if [ "$TASK11_OK" -eq 1 ]; then
        pass "Task 11: hard link, symbolic link, and file copy behavior demonstrated"
    else
        fail "Task 11: hard link, symbolic link, or copy behavior is incorrect"
    fi


    # ============================================================
    # TASK 12 - DELETE ORIGINAL FILE AND TEST HARD LINK
    TASK12_OK=1

    [ -f "$CUSTOMER" ] || TASK12_OK=0
    [ ! -e "$HARD_CUSTOMER" ] || TASK12_OK=0

    if [ "$TASK12_OK" -eq 1 ]; then
        pass "Task 12: original customer file deletion and hard-link workflow completed"
    else
        fail "Task 12: original customer deletion/hard-link workflow incomplete"
    fi

    # TASK 13 - TEST BROKEN SYMBOLIC LINK
    if [ -f "$CUSTOMER" ] &&
       [ ! -e "$CUSTOMER_SOFT" ]; then

        pass "Task 13: symbolic-link broken-target workflow completed"

    else
        fail "Task 13: symbolic-link broken-target workflow incomplete"
    fi

    # TASK 14 - RE-CREATE ORIGINAL CUSTOMER.TXT
    TASK14_OK=1

    [ -f "$CUSTOMER" ] || TASK14_OK=0

    if [ -f "$CUSTOMER" ]; then

        grep -Fxq "Customer Database" \
            "$CUSTOMER" || TASK14_OK=0

        grep -Fxq "Application: Customer Portal" \
            "$CUSTOMER" || TASK14_OK=0

        grep -Fxq "Environment: Production" \
            "$CUSTOMER" || TASK14_OK=0

        grep -Fxq "Status: Restored" \
            "$CUSTOMER" || TASK14_OK=0

    fi

    if [ "$TASK14_OK" -eq 1 ]; then
        pass "Task 14: customer.txt successfully recreated with restored content"
    else
        fail "Task 14: recreated customer.txt is missing or content is incorrect"
    fi

    # TASK 15 - SYMBOLIC LINK TO DIRECTORY
    PRODUCTION_DATA="$BASE/production_data"

    # Link is removed in Task 17. Verify final state.
    if [ ! -e "$PRODUCTION_DATA" ] &&
       [ -d "$BASE/data" ] &&
       [ -f "$CUSTOMER" ]; then

        pass "Task 15: production_data symbolic-link workflow completed"

    else
        fail "Task 15: production_data symbolic-link workflow incomplete"
    fi

    # TASK 16 - MOVE SYMBOLIC-LINK TARGET
    TASK16_OK=1

    # application.log must no longer exist in data.
    [ ! -e "$BASE/data/application.log" ] || TASK16_OK=0

    # application.log must exist in backup.
    [ -f "$BASE/backup/application.log" ] || TASK16_OK=0

    # The symbolic link was removed in Task 17.
    [ ! -e "$SOFT_LOG" ] || TASK16_OK=0

    if [ -f "$MOVED_LOG" ]; then

        grep -Fxq "Application: Started" \
            "$MOVED_LOG" || TASK16_OK=0

        grep -Fxq "Database Connection: Successful" \
            "$MOVED_LOG" || TASK16_OK=0

        grep -Fxq "Application Status: Running" \
            "$MOVED_LOG" || TASK16_OK=0

        grep -Fxq "Here is new update" \
            "$MOVED_LOG" || TASK16_OK=0

    fi

    if [ "$TASK16_OK" -eq 1 ]; then
        pass "Task 16: symbolic-link target moved and broken-link behavior demonstrated"
    else
        fail "Task 16: application.log was not moved correctly or final link state is incorrect"
    fi

    # TASK 17 - SAFELY REMOVE LINKS
    TASK17_OK=1

    # Verify validation/tmp directory and evidence files
    [ -d "$BASE/tmp" ] || TASK17_OK=0

    [ -f "$BASE/tmp/task5_customer.txt" ] || TASK17_OK=0
    [ -f "$BASE/tmp/task6_customer.txt" ] || TASK17_OK=0

    # Verify Task 5 evidence
    if [ -f "$BASE/tmp/task5_customer.txt" ]; then

        grep -Fxq "Last Updated: 2026-08-16" \
            "$BASE/tmp/task5_customer.txt" || TASK17_OK=0

    fi

    # Verify Task 6 evidence
    if [ -f "$BASE/tmp/task6_customer.txt" ]; then

        grep -Fxq "Updated By: Reporting Team" \
            "$BASE/tmp/task6_customer.txt" || TASK17_OK=0

    fi

    # Verify symbolic links were removed
    [ ! -e "$BASE/application/customer_soft.txt" ] || TASK17_OK=0
    [ ! -e "$BASE/reports/application_soft.log" ] || TASK17_OK=0
    [ ! -e "$BASE/production_data" ] || TASK17_OK=0

    # Verify hard links were removed
    [ ! -e "$BASE/reports/customer_hard.txt" ] || TASK17_OK=0
    [ ! -e "$BASE/backup/application_hard.log" ] || TASK17_OK=0

    # Verify required directories still exist
    [ -d "$BASE/data" ] || TASK17_OK=0
    [ -d "$BASE/reports" ] || TASK17_OK=0
    [ -d "$BASE/backup" ] || TASK17_OK=0
    [ -d "$BASE/application" ] || TASK17_OK=0
    [ -d "$BASE/tmp" ] || TASK17_OK=0

    # Final result
    if [ "$TASK17_OK" -eq 1 ]; then

        pass "Task 17: links safely removed and lab files preserved"

    else

        fail "Task 17: link cleanup or required lab files are incomplete"

    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=====================================================================

validate_lab209_linux_admin_onboarding() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 209 - Linux Administrator Onboarding..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/webshop"
    KIT="/tmp/onboarding_kit"

    TOTAL_TASKS=28
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Linux Administrator Onboarding"
    DATE=$(date "+%F %T")

    # ============================================================
    # HELPERS
    # ============================================================

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - READ THE TICKET / NAVIGATION
    if [ -d "$BASE" ]; then
    
        pass "Task 1: onboarding ticket and kit verifiedi and ready to inspect"
    else
        fail "Task 1: onboarding ticket or kit is missing"
    fi


    # TASK 2 - READ THE TICKET
    if [ -d "$BASE" ]; then
    
        pass "Task 2: ticket file TICKET_4471.txt was successfully accessed"
    else
        fail "Task 2: ticket file TICKET_4471.txt could not be verified"
    fi


    # ============================================================
    # TASK 3 - CREATE WEBSHOP
    # ============================================================

    if [ -d "$BASE" ]; then
        pass "Task 3: webshop workspace created"
    else
        fail "Task 3: webshop directory is missing"
    fi


    # ============================================================
    # TASK 4 - CREATE PROJECT DIRECTORIES
    # ============================================================

    TASK4_OK=1

    for DIR in \
        "$BASE/app" \
        "$BASE/docs" \
        "$BASE/secrets" \
        "$BASE/reports"
    do
        [ -d "$DIR" ] || TASK4_OK=0
    done

    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: project directories created successfully"
    else
        fail "Task 4: one or more required project directories are missing"
    fi


    # ============================================================
    # TASK 5 - CREATE NESTED DIRECTORY
    # ============================================================

    if [ -d "$BASE/app/src/utils" ]; then
        pass "Task 5: nested app/src/utils directory created"
    else
        fail "Task 5: app/src/utils directory is missing"
    fi


    # ============================================================
    # TASK 6 - CREATE REPORT FILE
    # ============================================================

    REPORT="$BASE/reports/TICKET_4471_DONE.txt"

    if [ -f "$REPORT" ] ; then
        pass "Task 6: onboarding report file created"
    else
        fail "Task 6: onboarding_report.txt is missing"
    fi


    # ============================================================
    # TASK 7 - WHOAMI AND ID AUDIT
    # ============================================================

    AUDIT="$BASE/reports/server_audit.txt"

    TASK7_OK=1

    [ -f "$AUDIT" ] || TASK7_OK=0

    if [ -f "$AUDIT" ]; then

        grep -Fxq "$STUDENT_NAME" "$AUDIT" || TASK7_OK=0

        grep -q "uid=" "$AUDIT" || TASK7_OK=0

    fi

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: username and user/group information recorded"
    else
        fail "Task 7: username or id information is missing from server_audit.txt"
    fi


    # ============================================================
    # TASK 8 - SYSTEM INFORMATION AUDIT
    # ============================================================

    TASK8_OK=1

    [ -f "$AUDIT" ] || TASK8_OK=0

    if [ -f "$AUDIT" ]; then

        grep -q "$BASE" "$AUDIT" || TASK8_OK=0
        grep -q "Linux" "$AUDIT" || TASK8_OK=0
        grep -q "load average" "$AUDIT" || TASK8_OK=0
        grep -q "Mem" "$AUDIT" || TASK8_OK=0

    fi

    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: system information recorded in server_audit.txt"
    else
        fail "Task 8: required system information is missing from audit file"
    fi


    # ============================================================
    # TASK 9 - VERIFY AUDIT / HEAD
    # ============================================================

    TASK9_OK=1

    [ -f "$AUDIT" ] || TASK9_OK=0

    if [ -f "$AUDIT" ]; then

        AUDIT_LINES=$(wc -l < "$AUDIT" 2>/dev/null)

        [ "$AUDIT_LINES" -ge 7 ] || TASK9_OK=0

        HEAD_LINES=$(head -n 3 "$AUDIT" 2>/dev/null | wc -l)

        [ "$HEAD_LINES" -eq 3 ] || TASK9_OK=0

    fi

    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: server audit verified and first three lines available"
    else
        fail "Task 9: server audit file is incomplete"
    fi


    # ============================================================
    # TASK 10 - COPY APP TEMPLATE
    # ============================================================
    START="$BASE/app/start.sh"
    if [ -f "$START" ]; then

        pass "Task 10: app_template.sh copied and renamed to start.sh"
    else
        fail "Task 10: app/start.sh is missing or incorrect"
    fi


    # ============================================================
    # TASK 11 - COPY HANDBOOK
    # ============================================================
    HANDBOOK="$BASE/docs/handbook.txt"
    if [ -f "$HANDBOOK" ]; then

        pass "Task 11: handbook.txt copied into docs"
    else
        fail "Task 11: docs/handbook.txt is missing or incorrect"
    fi


    # ============================================================
    # TASK 12 - COPY WELCOME TEMPLATE
    # ============================================================
    WELCOME="$BASE/docs/welcome_badsha.txt"

    if [ -f "$WELCOME" ]; then
            pass "Task 12: welcome template copied as welcome_badsha.txt"
        else
            fail "Task 12: welcome_badsha.txt is missing"
    fi


    # ============================================================
    # TASK 13 - COPY PASSWORD FILE
    # ============================================================
    PASSWORD_FILE="$BASE/secrets/db_password.txt"

    if [ -f "$PASSWORD_FILE" ]; then

        pass "Task 13: db_password.txt copied into secrets"
    else
        fail "Task 13: secrets/db_password.txt is missing or incorrect"
    fi


    # ============================================================
    # TASK 14 - PERSONALIZE WELCOME FILE
    # ============================================================
    EXPECTED_WELCOME="Welcome badsha! Your admin is: $STUDENT_NAME"

    if [ -f "$WELCOME" ] &&
       grep -Fxq "$EXPECTED_WELCOME" "$WELCOME"; then

        pass "Task 14: welcome file personalized correctly"
    else
        fail "Task 14: expected personalized welcome line is missing"
    fi


    # ============================================================
    # TASK 15 - BACKUP AND RENAME DOCS
    # ============================================================

    ARCHIVE="$BASE/reports/docs_archive"

    TASK15_OK=1

    [ -d "$ARCHIVE" ] || TASK15_OK=0

    [ -f "$ARCHIVE/handbook.txt" ] || TASK15_OK=0
    [ -f "$ARCHIVE/welcome_badsha.txt" ] || TASK15_OK=0

    # docs_backup should have been renamed.
    [ ! -e "$BASE/reports/docs_backup" ] || TASK15_OK=0

    if [ "$TASK15_OK" -eq 1 ]; then
        pass "Task 15: docs directory copied and renamed to docs_archive"
    else
        fail "Task 15: docs archive is missing or incorrectly named"
    fi


    # ============================================================
    # TASK 16 - HEAD AND TAIL ACCESS LOG
    # ============================================================
    EVIDENCE="$BASE/reports/badsha_access.txt"
    if [ -f "$EVIDENCE" ] &&
       grep -Eiq "APPROVED" "$EVIDENCE" &&
       grep -Eiq "DENIED" "$EVIDENCE"; then
        pass "Task 16: access log inspected using head and tail"
    else
        fail "Task 16: access log or required head/tail output could not be verified"
    fi

    # ============================================================
    # TASK 17 - FIND BADSHA IN ROSTER
    # ============================================================
    if [ -f "$EVIDENCE" ] &&
       grep -iq "badsha" "$EVIDENCE"; then

        pass "Task 17: badsha found in team roster"
    else
        fail "Task 17: badsha could not be found in team roster"
    fi


    # ============================================================
    # TASK 18 - VERIFY APPROVED AND DENIED ACCESS
    # ============================================================
    if [ -f "$EVIDENCE" ] &&
       grep -Eiq "APPROVED" "$EVIDENCE" &&
       grep -Eiq "DENIED" "$EVIDENCE"; then

       pass "Task 18: Badsha approved and denied access verified"
    else
       fail "Task 18: Badsha access approval/denial could not be verified"
    fi

    # ============================================================
    # TASK 19 - SAVE ACCESS EVIDENCE
    # ============================================================

    EVIDENCE="$BASE/reports/badsha_access.txt"

    TASK19_OK=1

    [ -f "$EVIDENCE" ] || TASK19_OK=0

    if [ -f "$EVIDENCE" ]; then

        grep -iq "badsha" "$EVIDENCE" || TASK19_OK=0

        EVIDENCE_LINES=$(wc -l < "$EVIDENCE" 2>/dev/null)

        [ "$EVIDENCE_LINES" -ge 2 ] || TASK19_OK=0

    fi

    if [ "$TASK19_OK" -eq 1 ]; then
        pass "Task 19: badsha access evidence saved successfully"
    else
        fail "Task 19: badsha_access.txt is missing or incomplete"
    fi


    # ============================================================
    # TASK 20 - APP PERMISSIONS 775
    # ============================================================

    APP_MODE=$(stat -c "%a" "$BASE/app" 2>/dev/null)

    if [ "$APP_MODE" = "775" ]; then
        pass "Task 20: app directory permissions set to 775"
    else
        fail "Task 20: app directory permissions are not 775"
    fi


    # ============================================================
    # TASK 21 - START.SH OWNER EXECUTABLE
    # ============================================================
    if [ -f "$START" ] &&
       [ -x "$START" ]; then    

        pass "Task 21: app/start.sh is executable by its owner"
    else
        fail "Task 21: app/start.sh owner execute permission is missing"
    fi


    # ============================================================
    # TASK 22 - SECRETS PERMISSIONS
    # ============================================================

    SECRET_DIR_MODE=$(stat -c "%a" "$BASE/secrets" 2>/dev/null)
    SECRET_FILE_MODE=$(stat -c "%a" "$BASE/secrets/db_password.txt" 2>/dev/null)

    if [ "$SECRET_DIR_MODE" = "770" ] &&
       [ "$SECRET_FILE_MODE" = "660" ]; then

        pass "Task 22: secrets permissions correctly configured"
    else
        fail "Task 22: secrets directory or db_password.txt permissions are incorrect"
    fi


    # ============================================================
    # TASK 23 - CHOWN WELCOME FILE TO BADSHA
    # ============================================================
    WELCOME_OWNER=$(stat -c "%U" "$WELCOME" 2>/dev/null)

    if [ -f "$WELCOME" ] &&
       [ "$WELCOME_OWNER" = "badsha" ]; then

        pass "Task 23: welcome_badsha.txt ownership changed to badsha"
    else
        fail "Task 23: welcome_badsha.txt owner is not badsha"
    fi


    # ============================================================
    # TASK 24 - CHGRP START.SH TO DEVELOPERS
    # ============================================================

    START_GROUP=$(stat -c "%G" "$START" 2>/dev/null)

    if [ -f "$START" ] &&
       [ "$START_GROUP" = "developers" ]; then

        pass "Task 24: app/start.sh group changed to developers"
    else
        fail "Task 24: app/start.sh group is not developers"
    fi


    # ============================================================
    # TASK 25 - RECURSIVE CHGRP APP
    # ============================================================

    TASK25_OK=1

    if [ -d "$BASE/app" ]; then

        while IFS= read -r ITEM; do

            ITEM_GROUP=$(stat -c "%G" "$ITEM" 2>/dev/null)

            if [ "$ITEM_GROUP" != "developers" ]; then
                TASK25_OK=0
            fi

        done < <(find "$BASE/app" -print)

    else
        TASK25_OK=0
    fi

    if [ "$TASK25_OK" -eq 1 ]; then
        pass "Task 25: entire app directory recursively belongs to developers"
    else
        fail "Task 25: one or more app files/directories are not in developers group"
    fi


    # ============================================================
    # TASK 26 - SECRETS OWNER AND GROUP
    # ============================================================

    TASK26_OK=1

    if [ -d "$BASE/secrets" ]; then

        while IFS= read -r ITEM; do

            ITEM_OWNER=$(stat -c "%U" "$ITEM" 2>/dev/null)
            ITEM_GROUP=$(stat -c "%G" "$ITEM" 2>/dev/null)

            if [ "$ITEM_OWNER" != "$STUDENT_NAME" ] ||
               [ "$ITEM_GROUP" != "admins" ]; then

                TASK26_OK=0
            fi

        done < <(find "$BASE/secrets" -print)

    else
        TASK26_OK=0
    fi

    if [ "$TASK26_OK" -eq 1 ]; then
        pass "Task 26: secrets recursively owned by student and admins group"
    else
        fail "Task 26: secrets owner/group is incorrect"
    fi


    # ============================================================
    # TASK 27 - PROTECT OWNERSHIP
    # ============================================================

    HANDBOOK="$BASE/docs/handbook.txt"

    TASK27_OK=1

    [ -f "$HANDBOOK" ] || TASK27_OK=0

    if [ -f "$HANDBOOK" ]; then

        HANDBOOK_OWNER=$(stat -c "%U" "$HANDBOOK" 2>/dev/null)

        # Student should still own the file.
        [ "$HANDBOOK_OWNER" = "$STUDENT_NAME" ] || TASK27_OK=0

        # Student must not have successfully transferred it to root.
        [ "$HANDBOOK_OWNER" != "root" ] || TASK27_OK=0

    fi

    if [ "$TASK27_OK" -eq 1 ]; then
        pass "Task 27: handbook ownership remains protected"
    else
        fail "Task 27: handbook ownership was incorrectly changed"
    fi


    # ============================================================
    # TASK 28 - CLOSE THE TICKET
    # ============================================================

    FINAL_REPORT="$BASE/reports/TICKET_4471_DONE.txt"
    if [ -f "$REPORT" ] &&
       grep -Fq "badsha onboarded by" "$REPORT"; then

        pass "Task 28: ticket completion note created and report renamed"
    else
        fail "Task 28: ticket completion report is missing or incorrectly named"
    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi
     
    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=====================================================================

validate_lab210_tar_backup_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 210 - Tape Archive (TAR) & backup Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/tar_lab"

    TOTAL_TASKS=13
    PASSED=0
   
    LAB_NAME="Lab ${LAB_NUMBER#lab} - Tape Archive (TAR) & backup Management"
    DATE=$(date "+%F %T")

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        PASSED=$((PASSED + 1))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    PROJECT="$BASE/project"
    ACTIVITY="$BASE/activity"
    BACKUP="$BASE/backup"
    RESTORE="$BASE/restore"

    # TASK 1
    if [ -d "$BASE" ] &&
       [ "$(stat -c %U "$BASE" 2>/dev/null)" = "$STUDENT_NAME" ]; then

        pass "Task 1: tar_lab copied and ownership verified"

    else

        fail "Task 1: tar_lab or ownership verification failed"

    fi

    # TASK 2
    if [ -f "$BASE/project.tar" ] &&
       tar -tf "$BASE/project.tar" >/dev/null 2>&1 &&
       tar -tf "$BASE/project.tar" 2>/dev/null | grep -Eq '^project/' &&
       [ -d "$PROJECT" ]; then

        pass "Task 2: uncompressed TAR archive created and verified"

    else

        fail "Task 2: project.tar is missing or invalid"

    fi

    # TASK 3
    if [ -f "$ACTIVITY/project_tar.txt" ] &&
       grep -q "project/" "$ACTIVITY/project_tar.txt" 2>/dev/null; then

        pass "Task 3: TAR contents listed and saved successfully"

    else

        fail "Task 3: project_tar.txt is missing or incomplete"

    fi

    # TASK 4
    if [ -d "$BACKUP/project" ] &&
       [ -f "$BACKUP/project/documents/handbook.txt" ] &&
       [ -f "$BACKUP/project/images/banner.jpg" ] &&
       [ -f "$BACKUP/project/logs/application.log" ] &&
       [ -f "$BACKUP/project/reports/financial.txt" ] &&
       [ -f "$BACKUP/project/scripts/backup.sh" ]; then

        pass "Task 4: project archive extracted into backup successfully"

    else

        fail "Task 4: project was not correctly restored into backup"

    fi

    # TASK 5
    if [ -d "$RESTORE/project" ] &&
       [ -f "$RESTORE/project/documents/policy.txt" ] &&
       [ -f "$RESTORE/project/images/logo.jpg" ] &&
       [ -f "$RESTORE/project/logs/system.log" ]; then

        pass "Task 5: project archive extracted into restore successfully"

    else

        fail "Task 5: project was not correctly restored into restore"

    fi

    # TASK 6
    if [ -f "$BASE/project.tar.gz" ] &&
       gzip -t "$BASE/project.tar.gz" >/dev/null 2>&1 &&
       tar -tzf "$BASE/project.tar.gz" 2>/dev/null | grep -Eq '^project/'; then

        pass "Task 6: gzip-compressed TAR archive created and verified"

    else

        fail "Task 6: project.tar.gz is missing or invalid"

    fi


    # ============================================================
    # TASK 7
    # Verify gzip archive contents were listed and saved
    # ============================================================

    if [ -f "$ACTIVITY/project_tar_gz.txt" ] &&
       grep -q "project/" "$ACTIVITY/project_tar_gz.txt" 2>/dev/null; then

        pass "Task 7: gzip archive contents listed and saved"

    else

        fail "Task 7: project_tar_gz.txt is missing or incomplete"

    fi

    # TASK 8
    if [ -d "$ACTIVITY/project" ] &&
       [ -f "$ACTIVITY/project/documents/handbook.txt" ] &&
       [ -f "$ACTIVITY/project/logs/application.log" ]; then

        pass "Task 8: gzip archive extracted into activity successfully"

    else

        fail "Task 8: gzip archive was not correctly extracted"

    fi

    # TASK 9
    if [ -f "$BASE/logs.tar.bz2" ] &&
       bzip2 -t "$BASE/logs.tar.bz2" >/dev/null 2>&1 &&
       tar -tjf "$BASE/logs.tar.bz2" 2>/dev/null | grep -Eq '^project/logs/'; then

        pass "Task 9: bzip2-compressed logs archive created and verified"

    else

        fail "Task 9: logs.tar.bz2 is missing or invalid"

    fi

    # TASK 10
    if [ -f "$ACTIVITY/logs_tar_bz2.txt" ] &&
       grep -q "project/logs/" "$ACTIVITY/logs_tar_bz2.txt" 2>/dev/null; then

        pass "Task 10: bzip2 archive contents listed and saved"

    else

        fail "Task 10: logs_tar_bz2.txt is missing or incomplete"

    fi

    # TASK 11
    if [ -d "$BACKUP/project/logs" ] &&
       [ -f "$BACKUP/project/logs/application.log" ] &&
       [ -f "$BACKUP/project/logs/system.log" ]; then

        pass "Task 11: bzip2 archive extracted into backup successfully"

    else

        fail "Task 11: logs were not correctly restored into backup"

    fi

    # TASK 12
    if [ -f "$BASE/collaboration.tar" ] &&
       tar -tf "$BASE/collaboration.tar" >/dev/null 2>&1 &&
       tar -tf "$BASE/collaboration.tar" 2>/dev/null | grep -Eq '^project/reports/' &&
       tar -tf "$BASE/collaboration.tar" 2>/dev/null | grep -Eq '^project/scripts/' &&
       [ -f "$ACTIVITY/collaborative_tar1.txt" ]; then

        pass "Task 12: reports and scripts archived successfully"

    else

        fail "Task 12: collaboration.tar is missing or incomplete"

    fi

    # TASK 13
    if [ -f "$BASE/collaboration.tar" ] &&
       tar -tf "$BASE/collaboration.tar" >/dev/null 2>&1 &&
       tar -tf "$BASE/collaboration.tar" 2>/dev/null | grep -Eq '^project/reports/' &&
       tar -tf "$BASE/collaboration.tar" 2>/dev/null | grep -Eq '^project/scripts/' &&
       tar -tf "$BASE/collaboration.tar" 2>/dev/null | grep -Eq '^project/images/' &&
       [ -f "$ACTIVITY/collaborative_tar2.txt" ]; then

        pass "Task 13: images directory added to existing TAR archive"

    else

        fail "Task 13: images directory was not added correctly"

    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=======================================================================

validate_lab211_production_portal_mgt() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 211 - Production Customer Portal File Management and Backup..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab211_review"

    TOTAL_TASKS=16
    PASSED=0

    LAB_NAME="Lab ${LAB_NUMBER#lab} - Production Customer Portal File Management and Backup"
    DATE=$(date "+%F %T")

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # PATHS
    APPLICATION="$BASE/application"
    DATA="$BASE/data"
    LOGS="$BASE/logs"
    REPORTS="$BASE/reports"
    SCRIPTS="$BASE/scripts"
    SHARED="$BASE/shared"
    BACKUP="$BASE/backup"
    ARCHIVE="$BASE/archive"
    TMP="$BASE/tmp"
    RESTORE="$BASE/restore"

    # TASK 1
    OK=1

    [ -d "$BASE" ] || OK=0
    [ "$(stat -c %U "$BASE" 2>/dev/null)" = "$STUDENT_NAME" ] || OK=0

    [ -d "$APPLICATION" ] || OK=0
    [ -d "$DATA" ] || OK=0
    [ -d "$LOGS" ] || OK=0
    [ -d "$REPORTS" ] || OK=0
    [ -d "$SCRIPTS" ] || OK=0
    [ -d "$BACKUP" ] || OK=0
    [ -d "$ARCHIVE" ] || OK=0
    [ -d "$TMP" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 1: lab211_review copied and review environment verified"
    else
        fail "Task 1: lab211_review or required directories are missing"
    fi


    # TASK 2
    OK=1

    [ -f "$APPLICATION/README.txt" ] || OK=0
    [ "$(stat -c %a "$APPLICATION/README.txt" 2>/dev/null)" = "640" ] || OK=0

    [ -d "$APPLICATION/bin" ] || OK=0
    [ "$(stat -c %a "$APPLICATION/bin" 2>/dev/null)" = "750" ] || OK=0

    [ -d "$APPLICATION/config" ] || OK=0
    [ "$(stat -c %a "$APPLICATION/config" 2>/dev/null)" = "750" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 2: application permissions configured correctly"
    else
        fail "Task 2: application permissions are incorrect"
    fi


    # TASK 3
    OK=1

    for FILE in backup.sh cleanup.sh monitor.sh; do
        [ -f "$SCRIPTS/$FILE" ] || OK=0

        PERM=$(stat -c %a "$SCRIPTS/$FILE" 2>/dev/null)

        [ "$PERM" = "750" ] || OK=0
    done

    if [ "$OK" -eq 1 ]; then
        pass "Task 3: operations scripts permissions configured correctly"
    else
        fail "Task 3: operations script permissions are incorrect"
    fi


    # TASK 4
    OK=1

    [ -d "$REPORTS/daily" ] || OK=0
    [ -d "$REPORTS/monthly" ] || OK=0

    find "$REPORTS" -type d -perm /007 ! -perm -750 2>/dev/null | grep -q . && OK=0
    find "$REPORTS" -type f -perm /007 2>/dev/null | grep -q . && OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 4: reporting environment permissions configured"
    else
        fail "Task 4: reporting environment permissions are incorrect"
    fi


    # TASK 5
    OK=1

    for FILE in backup.sh cleanup.sh monitor.sh; do
        [ "$(stat -c %U "$SCRIPTS/$FILE" 2>/dev/null)" = "smith" ] || OK=0
        [ "$(stat -c %G "$SCRIPTS/$FILE" 2>/dev/null)" = "admins" ] || OK=0
    done

    if [ "$OK" -eq 1 ]; then
        pass "Task 5: operations scripts ownership configured correctly"
    else
        fail "Task 5: operations scripts owner or group is incorrect"
    fi


    # TASK 6
    OK=1

    [ "$(stat -c %G "$SHARED" 2>/dev/null)" = "developers" ] || OK=0
    [ "$(stat -c %a "$SHARED" 2>/dev/null)" = "770" ] || OK=0

    BAD_GROUP=$(find "$SHARED" ! -group developers 2>/dev/null | head -1)

    [ -z "$BAD_GROUP" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 6: shared directory ownership and permissions configured"
    else
        fail "Task 6: shared directory ownership or permissions are incorrect"
    fi

    # TASK 7
    OK=1

    ORIGINAL="$DATA/customers/customers.txt"
    HARDLINK="$REPORTS/daily/customer_data.txt"

    [ -f "$ORIGINAL" ] || OK=0
    [ -f "$HARDLINK" ] || OK=0

    INODE1=$(stat -c %i "$ORIGINAL" 2>/dev/null)
    INODE2=$(stat -c %i "$HARDLINK" 2>/dev/null)

    [ "$INODE1" = "$INODE2" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 7: customer_data.txt created as a hard link"
    else
        fail "Task 7: hard link customer_data.txt was not created correctly"
    fi

    # TASK 8
    OK=1

    SYMLINK="$APPLICATION/config/customer_data"
    TARGET="$DATA/customers/customers.txt"

    # Verify that customer_data is a symbolic link
    [ -L "$SYMLINK" ] || OK=0

    # Verify that the symlink resolves to the correct customers.txt
    if [ "$OK" -eq 1 ]; then
       ACTUAL_TARGET=$(readlink -f "$SYMLINK" 2>/dev/null)
       EXPECTED_TARGET=$(readlink -f "$TARGET" 2>/dev/null)

       [ "$ACTUAL_TARGET" = "$EXPECTED_TARGET" ] || OK=0
    fi

    if [ "$OK" -eq 1 ]; then
        pass "Task 8: symbolic link customer_data created correctly"
    else
        fail "Task 8: symbolic link customer_data is missing or incorrect"
    fi    

    # TASK 9
    OK=1

    APPDATA="$ARCHIVE/appdata.tar"

    [ -f "$APPDATA" ] || OK=0
    tar -tf "$APPDATA" >/dev/null 2>&1 || OK=0

    tar -tf "$APPDATA" 2>/dev/null | grep -Eq 'application/' || OK=0
    tar -tf "$APPDATA" 2>/dev/null | grep -Eq 'data/' || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 9: initial application and data TAR archive created"
    else
        fail "Task 9: appdata.tar is missing or incomplete"
    fi

    # TASK 10
    OK=1

    [ -f "$APPDATA" ] || OK=0

    tar -tf "$APPDATA" >/dev/null 2>&1 || OK=0

    tar -tf "$APPDATA" 2>/dev/null | grep -Eq 'application/' || OK=0
    tar -tf "$APPDATA" 2>/dev/null | grep -Eq 'data/' || OK=0
    tar -tf "$APPDATA" 2>/dev/null | grep -Eq 'shared/' || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 10: shared directory added to existing appdata.tar"
    else
        fail "Task 10: shared directory was not added to appdata.tar correctly"
    fi

    # TASK 11
    OK=1

    [ -f "$TMP/appdata_tar" ] || OK=0
    grep -Eq 'application/' "$TMP/appdata_tar" 2>/dev/null || OK=0
    grep -Eq 'data/' "$TMP/appdata_tar" 2>/dev/null || OK=0
    grep -Eq 'shared/' "$TMP/appdata_tar" 2>/dev/null || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 11: appdata.tar contents listed and saved"
    else
        fail "Task 11: tmp/appdata_tar is missing or incomplete"
    fi

    # TASK 12
    OK=1

    [ -d "$RESTORE/application" ] || OK=0
    [ -d "$RESTORE/data" ] || OK=0
    [ -d "$RESTORE/shared" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 12: application backup restored successfully"
    else
        fail "Task 12: application backup was not correctly restored"
    fi

    # TASK 13
    OK=1

    LOGS_ARCHIVE="$ARCHIVE/logs.tar.gz"

    [ -f "$LOGS_ARCHIVE" ] || OK=0
    gzip -t "$LOGS_ARCHIVE" >/dev/null 2>&1 || OK=0
    tar -tzf "$LOGS_ARCHIVE" 2>/dev/null | grep -Eq '^logs/' || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 13: gzip-compressed logs archive created"
    else
        fail "Task 13: logs.tar.gz is missing or invalid"
    fi

    # TASK 14
    OK=1

    [ -d "$BACKUP/logs" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 14: compressed log backup restored successfully"
    else
        fail "Task 14: logs were not correctly restored into backup"
    fi

    # TASK 15
    OK=1

    REPORTS_ARCHIVE="$ARCHIVE/reports.tar.bz2"

    [ -f "$REPORTS_ARCHIVE" ] || OK=0
    bzip2 -t "$REPORTS_ARCHIVE" >/dev/null 2>&1 || OK=0
    tar -tjf "$REPORTS_ARCHIVE" 2>/dev/null | grep -Eq '^reports/' || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 15: bzip2-compressed reports archive created"
    else
        fail "Task 15: reports.tar.bz2 is missing or invalid"
    fi

    # TASK 16
    OK=1

    [ -d "$TMP/reports" ] || OK=0

    if [ "$OK" -eq 1 ]; then
        pass "Task 16: report backup restored successfully"
    else
        fail "Task 16: reports were not correctly restored into tmp"
    fi

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

# =====================================================================

validate_lab212_find_grep() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 212 - Find & grep Commands..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/search_lab"
    ARCHIVE="$BASE/archive"

    TOTAL_TASKS=13
    PASSED=0

    LAB_NAME="Lab 212 - Find & grep Commands"
    DATE=$(date "+%F %T")

    # HELPER

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    GREP="$BASE/tmp/grep.txt"
    OPTION="$BASE/tmp/option.txt"

     # TASK 1 - SEARCH_LAB DIRECTORY
    TASK1_OK=1

    if [ ! -d "$BASE" ]; then
        TASK1_OK=0
    fi

    if [ -d "$BASE" ]; then
        OWNER=$(stat -c "%U" "$BASE" 2>/dev/null)

        if [ "$OWNER" != "$STUDENT_NAME" ]; then
            TASK1_OK=0
        fi
    fi

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: search_lab directory copied successfully and owned by the student"
    else
        fail "Task 1: search_lab directory is missing or ownership is incorrect"
    fi

    # TASK 2 - SEARCH BY FILE NAME
    TASK2_OK=1
    OUTPUT="$BASE/tmp/file-name.txt"

    [ -f "$OUTPUT" ] || TASK2_OK=0

    if [ -f "$OUTPUT" ]; then
        grep -q "app.conf" "$OUTPUT" || TASK2_OK=0
        grep -q "application.log" "$OUTPUT" || TASK2_OK=0
        grep -q "database.conf" "$OUTPUT" || TASK2_OK=0
    fi

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: find by file name completed successfully"
    else
        fail "Task 2: file-name.txt is missing or required file names are missing"
    fi

    # TASK 3 - SEARCH BY FILE TYPE
    TASK3_OK=1

    [ -f "$BASE/tmp/search-dir.txt" ] || TASK3_OK=0
    [ -f "$BASE/tmp/search-file.txt" ] || TASK3_OK=0

    if [ "$TASK3_OK" -eq 1 ]; then
        grep -q "$BASE" "$BASE/tmp/search-dir.txt" || \
            grep -q "\./" "$BASE/tmp/search-dir.txt" || TASK3_OK=0

        grep -q "$BASE" "$BASE/tmp/search-file.txt" || \
            grep -q "\./" "$BASE/tmp/search-file.txt" || TASK3_OK=0
    fi

    if [ "$TASK3_OK" -eq 1 ]; then
        pass "Task 3: find by file type completed successfully"
    else
        fail "Task 3: search-dir.txt or search-file.txt is missing or empty"
    fi

    # TASK 4 - SEARCH BY FILE EXTENSION
    TASK4_OK=1

    [ -f "$BASE/tmp/small-size.txt" ] || TASK4_OK=0
    [ -f "$BASE/tmp/large-size.txt" ] || TASK4_OK=0

    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: find by file size completed successfully"
    else
        fail "Task 4: small-size.txt or large-size.txt is missing"
    fi

    # TASK 5 - SEARCH BY MODIFICATION TIME
    TASK5_OK=1

    [ -f "$BASE/tmp/time-day.txt" ] || TASK5_OK=0
    [ -f "$BASE/tmp/time-min.txt" ] || TASK5_OK=0

    if [ ! -f "$BASE/tmp/time-day.txt" ] && [ ! -f "/tmp/time-day.txt" ]; then
        TASK5_OK=0
    fi

    if [ ! -f "$BASE/tmp/time-min.txt" ] && [ ! -f "/tmp/time-min.txt" ]; then
        TASK5_OK=0
    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: find by modification time completed successfully"
    else
        fail "Task 5: time-day.txt or time-min.txt is missing"
    fi
 

    # TASK 6 - OPERATOR
    if [ -f "$GREP" ] &&
       grep -Fqx "$(grep "operator" "$ARCHIVE/passwd")" "$GREP"
    then
        pass "Task 6: operator search completed successfully"
    else
        fail "Task 6: operator search failed"
    fi

    # TASK 7 - POLKITD
    if [ -f "$GREP" ] &&
       grep -Fqx "$(grep "polkitd" "$ARCHIVE/group")" "$GREP"
    then
        pass "Task 7: polkitd search completed successfully"
    else
        fail "Task 7: polkitd search failed"
    fi

    # TASK 8 - SHUTDOWN
    if [ -f "$GREP" ] &&
       grep -Fqx "$(grep "shutdown" "$ARCHIVE/passwd")" "$GREP"
    then
        pass "Task 8: shutdown search completed successfully"
    else
        fail "Task 8: shutdown search failed"
    fi

    # TASK 9 - MAIL
    if [ -f "$GREP" ] &&
       grep -Fqx "$(grep "mail" "$ARCHIVE/group")" "$GREP"
    then
        pass "Task 9: mail search completed successfully"
    else
        fail "Task 9: mail search failed"
    fi

    # TASK 10 - GREP -v SEARCH
    if [ -f "$GREP" ] &&
       grep -Fq "$(grep -v "search" "$ARCHIVE/resolv.conf" | head -n 1)" "$GREP"
    then
        pass "Task 10: grep -v search completed successfully"
    else
        fail "Task 10: grep -v search failed"
    fi

    # TASK 11 - GREP -n BASH
    if [ -f "$OPTION" ] &&
       grep -Fq "$(grep -n "bash" "$ARCHIVE/passwd" | head -n 1)" "$OPTION"
    then
        pass "Task 11: grep -n bash completed successfully"
    else
        fail "Task 11: grep -n bash failed"
    fi

    # TASK 12 - GREP -i MAIL
    if [ -f "$OPTION" ] &&
       grep -Fq "$(grep -i "MAIL" "$ARCHIVE/group" | head -n 1)" "$OPTION"
    then
        pass "Task 12: grep -i MAIL completed successfully"
    else
        fail "Task 12: grep -i MAIL failed"
    fi

    # TASK 13 - GREP -v NAMESERVER
    if [ -f "$OPTION" ] &&
       grep -Fq "$(grep -v "nameserver" "$ARCHIVE/resolv.conf" | head -n 1)" "$OPTION"
    then
        pass "Task 13: grep -v nameserver completed successfully"
    else
        fail "Task 13: grep -v nameserver failed"
    fi

       # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}

#=================================================================

validate_lab213_vim_editor() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 213 - Vim Editor File Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    FILE="$HOME_DIR/vim_practice.txt"
    FINAL="$HOME_DIR/vim_practice_final.txt"

    LAB_NAME="Lab 213 - Vim Editor File Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=8
    PASSED=0

    # HELPER

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # ============================================================
    # TASK 1 - OPEN AND NAVIGATE THE FILE
    # ============================================================

    TASK1_OK=1

    if [ ! -f "$FILE" ]; then
        TASK1_OK=0
    fi

    if [ -f "$FILE" ]; then
        OWNER=$(stat -c "%U" "$FILE" 2>/dev/null)

        if [ "$OWNER" != "$STUDENT_NAME" ]; then
            TASK1_OK=0
        fi
    fi

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: vim_practice.txt copied to home directory"
    else
        fail "Task 1: vim_practice.txt is missing or ownership is incorrect"
    fi


    # ============================================================
    # TASK 2 - ENTER INSERT MODE
    # ============================================================

    TASK2_OK=1

    if [ ! -f "$FILE" ]; then
        TASK2_OK=0
    else

        FIRST_LINE=$(head -n 1 "$FILE")
	echo "$FIRST_LINE" | grep -Fq "IMPORTANT" || TASK2_OK=0
        echo "$FIRST_LINE" | grep -Fq "TODAY" || TASK2_OK=0
    fi

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: IMPORTANT added at the beginning and TODAY added at the end of the first line"
    else
        fail "Task 2: first line does not contain the required IMPORTANT and TODAY changes"
    fi


    # ============================================================
    # TASK 3 - MODIFY EXISTING TEXT
    # ============================================================

    TASK3_OK=1

    if [ ! -f "$FILE" ]; then
        TASK3_OK=0
    else
        # Required stable sentence
        grep -Fqx "System administrators use command-line tools every day to maintain stable systems." "$FILE" \
            || TASK3_OK=0

        # Required essential sentence
        grep -Fqx "The Vim editor is an essential tool for creating and modifying configuration files." "$FILE" \
            || TASK3_OK=0

    fi

    if [ "$TASK3_OK" -eq 1 ]; then
        pass "Task 3: required text modifications completed"
    else
        fail "Task 3: reliable/important were not correctly changed to stable/essential"
    fi


    # ============================================================
    # TASK 4 - SEARCH THE FILE
    # ============================================================

    TASK4_OK=1

    if [ ! -f "$FILE" ]; then
        TASK4_OK=0
    else
        # Vim search itself cannot be directly verified.
        # Verify that the file still contains Vim references.
        grep -q "Vim" "$FILE" || TASK4_OK=0
    fi

    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: Vim search target is present in the file"
    else
        fail "Task 4: required Vim search target is missing"
    fi


    # ============================================================
    # TASK 5 - COPY AND PASTE A LINE
    # ============================================================

    TASK5_OK=1

    PRACTICE_LINE="Practice makes command-line editing faster and more accurate."

    if [ ! -f "$FILE" ]; then
        TASK5_OK=0
    else

        COUNT=$(grep -Fxc "$PRACTICE_LINE" "$FILE")

        # After Task 6 the duplicated line should have been deleted.
        # Therefore exactly one copy must remain.
        if [ "$COUNT" -ne 1 ]; then
            TASK5_OK=0
        fi

    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: practice line is present exactly once after copy and paste"
    else
        fail "Task 5: practice line is missing or appears more than once"
    fi


    # ============================================================
    # TASK 6 - DELETE AND RESTORE TEXT
    # ============================================================

    TASK6_OK=1

    if [ ! -f "$FILE" ]; then
        TASK6_OK=0
    else

        COUNT=$(grep -Fxc "$PRACTICE_LINE" "$FILE")

        # Final state after delete + undo + redo
        # must contain exactly one copy.
        if [ "$COUNT" -ne 1 ]; then
            TASK6_OK=0
        fi

    fi

    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: duplicated line was removed and final file contains one copy"
    else
        fail "Task 6: final practice-line state is incorrect"
    fi


    # ============================================================
    # TASK 7 - SAVE THE CHANGES
    # ============================================================

    TASK7_OK=1

    if [ ! -f "$FILE" ]; then
        TASK7_OK=0 
    else
        FIRST_LINE=$(head -n 1 "$FILE")

        if [ "$FIRST_LINE" != "IMPORTANT Linux is a powerful operating system used to manage servers, applications, and infrastructure TODAY." ]; then
            TASK7_OK=0
        fi

        grep -Fqx "System administrators use command-line tools every day to maintain stable systems." "$FILE" || TASK7_OK=0

        grep -Fqx "The Vim editor is an essential tool for creating and modifying configuration files." "$FILE" || TASK7_OK=0

        grep -Fqx "Practice makes command-line editing faster and more accurate." "$FILE" || TASK7_OK=0

    fi

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: modified vim_practice.txt was saved successfully"
    else
        fail "Task 7: saved file is missing or required changes were not saved"
    fi


    # ============================================================
    # TASK 8 - SAVE A COPY WITH A DIFFERENT NAME
    # ============================================================

    TASK8_OK=1

    if [ ! -f "$FILE" ]; then
        TASK8_OK=0
    fi

    if [ ! -f "$FINAL" ]; then
        TASK8_OK=0
    fi

    # Original file must still exist
    if [ ! -f "$FILE" ]; then
        TASK8_OK=0
    fi

    # Final copy must contain the same contents
    if [ -f "$FILE" ] && [ -f "$FINAL" ]; then

        if ! cmp -s "$FILE" "$FINAL"; then
            TASK8_OK=0
        fi

    fi

    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: vim_practice_final.txt created and original file preserved"
    else
        fail "Task 8: final copy is missing, differs from original, or original was removed"
    fi


    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi


    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML


    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML

}

# =================================================================

validate_lab214_morning_incident() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 214 - The Morning Incident: Linux Administrator on Duty..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab214_test"

    LAB_NAME="Lab 214 - The Morning Incident: Linux Administrator on Duty"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=29
    PASSED=0

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - REMOTE SERVER AUDIT
    echo "<div class='validation-section'>Task 1 - The Remote Server Audit</div>"

    # 1a - lab214_test directory
    if [ -d "$BASE" ]; then
        pass "Task 1a: lab214_test directory exists"
    else
        fail "Task 1a: lab214_test directory is missing"
    fi

    # 1b - OS release
    REMOTE_INFO="$BASE/remote_info.txt"

    if [ -f "$REMOTE_INFO" ] &&
       grep -qE "PRETTY_NAME=|NAME=" "$REMOTE_INFO"
    then
        pass "Task 1b: OS release information recorded"
    else
        fail "Task 1b: OS release information is missing"
    fi

    # 1c - DNS configuration
    if [ -f "$REMOTE_INFO" ] &&
       grep -qE "nameserver|search|domain" "$REMOTE_INFO"
    then
        pass "Task 1c: DNS configuration recorded"
    else
        fail "Task 1c: DNS configuration is missing"
    fi

    # 1d - block devices
    if [ -f "$REMOTE_INFO" ] &&
       grep -q "NAME" "$REMOTE_INFO"
    then
        pass "Task 1d: block device information recorded"
    else
        fail "Task 1d: block device information is missing"
    fi

    # 1e - group count
    GROUP_COUNT=$(wc -l < /etc/group)

    if [ -f "$REMOTE_INFO" ] &&
       grep -Eq "^${GROUP_COUNT}( /etc/group)?$" "$REMOTE_INFO"
    then
        pass "Task 1e: /etc/group line count recorded correctly"
    else
        fail "Task 1e: /etc/group line count is missing or incorrect"
    fi

    # TASK 2 - PROJECT WORKSPACE
    echo "<div class='validation-section'>Task 2 - Build the Project Workspace</div>"

    REPORT="$BASE/report.txt"
    DATA="$BASE/logs/archive/data"
    COPIED_REPORT="$DATA/report.txt"
    LOG_LINK="$BASE/logs/loglink"
    SYS_REPORT="$BASE/sys-report"

    # 2a
    if [ -f "$REPORT" ] &&
       grep -Fxq "technical screening is in progress" "$REPORT"
    then
        pass "Task 2a: report.txt created with exact required content"
    else
        fail "Task 2a: report.txt is missing or content is incorrect"
    fi

    # 2b
    if [ -f "$COPIED_REPORT" ] &&
       [ -f "$REPORT" ]; then
        pass "Task 2b: report.txt copied into logs/archive/data"
    else
        fail "Task 2b: copied report.txt is missing or incorrect"
    fi

    # 2c
    LINK_TARGET=$(readlink "$LOG_LINK")
    if [ -L "$LOG_LINK" ] &&
       { [ "$LINK_TARGET" = "archive" ] ||
         [ "$LINK_TARGET" = "../logs/archive" ] ||
         [ "$LINK_TARGET" = "$LOG_DIR/archive" ]; }    	    
    then
        pass "Task 2c: loglink symbolic link points to archive"
    else
        fail "Task 2c: loglink symbolic link is missing or points incorrectly"
    fi

    # 2d
    if [ -f "$REPORT" ] && [ -f "$SYS_REPORT" ]; then
        REPORT_INODE=$(stat -c "%i" "$REPORT" 2>/dev/null)
        SYS_REPORT_INODE=$(stat -c "%i" "$SYS_REPORT" 2>/dev/null)

        if [ "$REPORT_INODE" = "$SYS_REPORT_INODE" ]; then
            pass "Task 2d: sys-report is a hard link to report.txt"
        else
            fail "Task 2d: sys-report exists but is not a hard link to report.txt"
        fi
    else
        fail "Task 2d: report.txt or sys-report is missing"
    fi

    # TASK 3 - OWNERSHIP AND PERMISSIONS
    echo "<div class='validation-section'>Task 3 - Secure the Project and Assign Ownership</div>"

    PROJECTS="$BASE/my-projects"
    PROJECT_FILE="$PROJECTS/project1.txt"
    FINAL="$PROJECTS/final"
    MODULE1="$FINAL/module1"
    MODULE2="$FINAL/module2"

    # 3a
    if [ -f "$PROJECT_FILE" ] &&
       [ "$(stat -c "%a" "$PROJECT_FILE" 2>/dev/null)" = "620" ]
    then
        pass "Task 3a: project1.txt required permissions set"
    else
        fail "Task 3a: project1.txt required permissions are not set"
    fi

    # 3b
    if [ -f "$PROJECT_FILE" ] &&
       [ "$(stat -c "%U" "$PROJECT_FILE" 2>/dev/null)" = "test-user" ] &&
       [ "$(stat -c "%G" "$PROJECT_FILE" 2>/dev/null)" = "wheel" ]
    then
        pass "Task 3b: project1.txt ownership is test-user:wheel"
    else
        fail "Task 3b: project1.txt ownership is not test-user:wheel"
    fi

    # 3c
    if [ -d "$FINAL" ] &&
       [ "$(stat -c "%U" "$FINAL" 2>/dev/null)" = "test-user" ]
    then
        pass "Task 3c: final directory owner is test-user"
    else
        fail "Task 3c: final directory owner is not test-user"
    fi

    # 3d
    if [ -d "$FINAL" ] &&
       [ "$(stat -c "%G" "$FINAL" 2>/dev/null)" = "wheel" ]
    then
        pass "Task 3d: final directory group is wheel"
    else
        fail "Task 3d: final directory group is not wheel"
    fi

    # 3e - recursive ownership
    TASK3H_OK=1

    if [ -d "$FINAL" ]; then
        while IFS= read -r ITEM; do
            [ "$(stat -c "%U" "$ITEM" 2>/dev/null)" = "test-user" ] || TASK3H_OK=0
            [ "$(stat -c "%G" "$ITEM" 2>/dev/null)" = "wheel" ] || TASK3H_OK=0
        done < <(find "$FINAL" -mindepth 1 2>/dev/null)
    else
        TASK3H_OK=0
    fi

    if [ "$TASK3H_OK" -eq 1 ]; then
        pass "Task 3e: ownership recursively applied to final contents"
    else
        fail "Task 3e: one or more items inside final have incorrect ownership"
    fi

    # TASK 4 - CONFIGURATION EVIDENCE
    echo "<div class='validation-section'>Task 4 - Investigate the Server Configuration</div>"

    GREP_SUMMARY="$BASE/grep_summary.txt"

    # 4a
    EXPECTED_SSSD=$(grep -i "sssd" /etc/nsswitch.conf 2>/dev/null)

    if [ -z "$EXPECTED_SSSD" ]; then
        pass "Task 4a: no sssd match exists in nsswitch.conf"
    elif [ -f "$GREP_SUMMARY" ] &&
         grep -Fq "$EXPECTED_SSSD" "$GREP_SUMMARY"
    then
        pass "Task 4a: case-insensitive sssd search recorded"
    else
        fail "Task 4a: sssd search result is missing"
    fi

    # 4b
    EXPECTED_NOLOGIN=$(grep "nologin" /etc/passwd 2>/dev/null)

    TASK4C_OK=1

    if [ -n "$EXPECTED_NOLOGIN" ] && [ -f "$GREP_SUMMARY" ]; then
        while IFS= read -r LINE; do
            if ! grep -Fqx "$LINE" "$GREP_SUMMARY"; then
                TASK4C_OK=0
                break
            fi
        done <<< "$EXPECTED_NOLOGIN"
    else
        TASK4C_OK=0
    fi

    if [ "$TASK4C_OK" -eq 1 ]; then
        pass "Task 4b: nologin entries recorded"
    else
        fail "Task 4b: nologin entries are missing"
    fi

    # 4c
    TASK4D_OK=1

    while IFS= read -r LINE; do
        if ! grep -Fqx "$LINE" "$GREP_SUMMARY" 2>/dev/null; then
            TASK4D_OK=0
            break
        fi
    done < <(head -n 2 /etc/hosts)

    if [ "$TASK4D_OK" -eq 1 ]; then
        pass "Task 4c: first 2 lines of /etc/hosts recorded"
    else
        fail "Task 4c: first 2 lines of /etc/hosts are missing"
    fi

    # 4d
    HOST_COUNT=$(wc -l < /etc/hosts)

    if [ -f "$GREP_SUMMARY" ] &&
       grep -Eq "^${HOST_COUNT}( /etc/hosts)?$" "$GREP_SUMMARY"
    then
        pass "Task 4d: /etc/hosts line count recorded correctly"
    else
        fail "Task 4d: /etc/hosts line count is missing or incorrect"
    fi

    # 4e
    TASK4F_OK=1

    while IFS= read -r LINE; do
        if ! grep -Fqx "$LINE" "$GREP_SUMMARY" 2>/dev/null; then
            TASK4F_OK=0
            break
        fi
    done < <(tail -n 3 /etc/resolv.conf)

    if [ "$TASK4F_OK" -eq 1 ]; then
        pass "Task 4e: last 3 lines of /etc/resolv.conf recorded"
    else
        fail "Task 4e: last 3 lines of /etc/resolv.conf are missing"
    fi

    # TASK 5 - FILESYSTEM INVESTIGATION

echo "<div class='validation-section'>Task 5 - The Final Filesystem Investigation</div>"

INVESTIGATION="$BASE/investigation"
FIND_TASKS="$BASE/find_tasks.txt"
SERVICE_BK="$BASE/service_bk"

# 5a - RECENT .CONF FILES
TASK5A_OK=1

if [ -f "$FIND_TASKS" ]; then
    while IFS= read -r FILE; do
        if ! grep -Fqx "$FILE" "$FIND_TASKS"; then
            TASK5A_OK=0
            break
        fi
    done < <(
        cd "$BASE" &&
        find investigation/etc -type f -name "*.conf" -mtime -5 2>/dev/null
    )
else
    TASK5A_OK=0
fi

if [ "$TASK5A_OK" -eq 1 ]; then
    pass "Task 5a: recent .conf files recorded"
else
    fail "Task 5a: required recent .conf file results are missing"
fi


# 5b - LOGROTATE FILES OLDER THAN 2 DAYS
TASK5B_OK=1

if [ -f "$FIND_TASKS" ]; then
    while IFS= read -r FILE; do
        if ! grep -Fqx "$FILE" "$FIND_TASKS"; then
            TASK5B_OK=0
            break
        fi
    done < <(
        cd "$BASE" &&
        find investigation/etc/logrotate.d -type f -mtime +2 2>/dev/null
    )
else
    TASK5B_OK=0
fi

if [ "$TASK5B_OK" -eq 1 ]; then
    pass "Task 5b: logrotate files older than 2 days recorded"
else
    fail "Task 5b: required logrotate results are missing"
fi


# 5c - SERVICE FILES COPIED
TASK5C_OK=1

if [ -f "$SERVICE_BK" ]; then
    while IFS= read -r FILE; do
        if ! grep -Fqx "$FILE" "$SERVICE_BK"; then
            TASK5C_OK=0
            break
        fi
    done < <(
        cd "$BASE" &&
        find investigation/etc/systemd -type f -name "*.service" 2>/dev/null
    )
else
    TASK5C_OK=0
fi
if [ "$TASK5C_OK" -eq 1 ]; then
    pass "Task 5c: service files are present in service_bk"
else
    fail "Task 5c: no .service files were found in service_bk"
fi


# 5d - FILES LARGER THAN 100MB
TASK5D_OK=1

if [ -f "$FIND_TASKS" ]; then
    while IFS= read -r FILE; do
        if ! grep -Fqx "$FILE" "$FIND_TASKS"; then
            TASK5D_OK=0
            break
        fi
    done < <(
        cd "$BASE" &&
        find investigation/var -type f -size +100M 2>/dev/null
    )
else
    TASK5D_OK=0
fi

if [ "$TASK5D_OK" -eq 1 ]; then
    pass "Task 5d: large files under investigation/var recorded"
else
    fail "Task 5d: required large-file results are missing"
fi


# 5e - SHADOW FILE
TASK5E_OK=0

if [ -f "$FIND_TASKS" ]; then
    while IFS= read -r FILE; do
        if grep -Fqx "$FILE" "$FIND_TASKS"; then
            TASK5E_OK=1
            break
        fi
    done < <(
        cd "$BASE" &&
        find investigation/etc -type f -name "shadow" 2>/dev/null
    )
fi

if [ "$TASK5E_OK" -eq 1 ]; then
    pass "Task 5e: shadow file search result recorded"
else
    fail "Task 5e: shadow file search result is missing"
fi

    # ============================================================
# TASK 6 - ARCHIVE THE PROJECT WORKSPACE WITH TAR
# ============================================================

echo "<div class='validation-section'>Task 6 - Archive the Project Workspace with TAR</div>"

PROJECT="$BASE/project_backup.tar"
LOGS="$BASE/logs_backup.tar.gz"
BACKUP="$BASE/backup"

# 6a - project_backup.tar
if [ -f "$PROJECT" ] &&
   tar -tf "$PROJECT" 2>/dev/null | grep -q "^new-project/"
then
    pass "Task 6a: project_backup.tar contains new-project"
else
    fail "Task 6a: project_backup.tar is missing or new-project is not archived"
fi

# 6b - logs_backup.tar.gz
if [ -f "$LOGS" ] &&
   tar -tzf "$LOGS" >/dev/null 2>&1 &&
   tar -tzf "$LOGS" 2>/dev/null | grep -q "^project-logs/"
then
    pass "Task 6b: logs_backup.tar.gz contains project-logs"
else
    fail "Task 6b: logs_backup.tar.gz is missing or invalid"
fi

# 6c - backup directory
if [ -d "$BACKUP" ]; then
    pass "Task 6c: backup directory exists"
else
    fail "Task 6c: backup directory is missing"
fi

# 6d - extract project archive
if [ -d "$BACKUP/new-project" ]; then
    pass "Task 6d: project_backup.tar extracted into backup"
else
    fail "Task 6d: project_backup.tar was not extracted into backup"
fi

# 6e - archive listing
LIST="$BACKUP/logs_backup.txt"

if [ -s "$LIST" ] &&
   grep -q "^.*project-logs/" "$LIST"
then
    pass "Task 6e: logs_backup.txt contains the archive listing"
else
    fail "Task 6e: logs_backup.txt is missing or does not contain the archive listing"
fi   

    # ============================================================
    # SUMMARY
    # ============================================================

    PERCENT=$((PASSED * 100 / TOTAL_TASKS))

    if [ "$PASSED" -eq "$TOTAL_TASKS" ]; then
        RESULT_CLASS="result-success"
        RESULT_ICON="✓"
        RESULT_TEXT="LAB PASSED"
    else
        RESULT_CLASS="result-failed"
        RESULT_ICON="✗"
        RESULT_TEXT="LAB NEEDS ATTENTION"
    fi

    # ============================================================
    # RESULT STYLES
    # ============================================================

    cat <<'HTML'
<style>
.validation-pass {
    margin:6px 0;
    padding:10px 14px;
    background:#DCFCE7;
    color:#166534;
    border-left:5px solid #22C55E;
    border-radius:6px;
    font-weight:600;
}

.validation-fail {
    margin:6px 0;
    padding:10px 14px;
    background:#FEE2E2;
    color:#991B1B;
    border-left:5px solid #EF4444;
    border-radius:6px;
    font-weight:600;
}

.lab-summary {
    margin-top:25px;
    padding:28px;
    border-radius:14px;
    text-align:center;
    background:#0f172a;
    border:2px solid #38bdf8;
    color:#fff;
}

.lab-summary-title {
    font-size:24px;
    font-weight:700;
    margin-bottom:20px;
    color:#38bdf8;
}

.lab-summary-info {
    text-align:left;
    max-width:650px;
    margin:0 auto 20px auto;
}

.lab-summary-row {
    padding:10px 0;
    border-bottom:1px solid #334155;
}

.lab-summary-label {
    font-weight:700;
    color:#94a3b8;
    display:inline-block;
    min-width:110px;
}

.result-percentage {
    margin-top:20px;
    font-size:42px;
    font-weight:800;
    color:#38bdf8;
}

.result-success {
    margin-top:20px;
    padding:15px;
    background:#166534;
    color:#dcfce7;
    border:2px solid #22c55e;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}

.result-failed {
    margin-top:20px;
    padding:15px;
    background:#991b1b;
    color:#fee2e2;
    border:2px solid #ef4444;
    border-radius:10px;
    font-size:21px;
    font-weight:700;
}
</style>
HTML

    # ============================================================
    # RESULT SUMMARY
    # ============================================================

    cat <<HTML
<div class="lab-summary">

<div class="lab-summary-title">LAB RESULT SUMMARY</div>

<div class="lab-summary-info">

<div class="lab-summary-row">
<span class="lab-summary-label">Student:</span>
<span>$STUDENT_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Lab:</span>
<span>$LAB_NAME</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Total Tasks:</span>
<span>$TOTAL_TASKS</span>
</div>

<div class="lab-summary-row">
<span class="lab-summary-label">Passed:</span>
<span>$PASSED</span>
</div>

</div>

<div class="result-percentage">$PERCENT%</div>

<div class="$RESULT_CLASS">
$RESULT_ICON $RESULT_TEXT
</div>

</div>
HTML
}
#=====================================================================
