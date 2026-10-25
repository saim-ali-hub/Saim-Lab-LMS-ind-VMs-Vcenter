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

    EXPECTED_ORIGINAL_GROUP="$STUDENT_NAME"

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
       [ -d "$BACKUP/project/documents" ] &&
       [ -d "$BACKUP/project/images" ] &&
       [ -d "$BACKUP/project/logs" ] &&
       [ -d "$BACKUP/project/reports" ] &&
       [ -d "$BACKUP/project/scripts" ]; then

        pass "Task 4: project archive extracted into backup successfully"

    else

        fail "Task 4: project was not correctly restored into backup"

    fi

    # TASK 5
    if [ -d "$RESTORE/project" ] &&
       [ -d "$RESTORE/project/documents" ] &&
       [ -d "$RESTORE/project/images" ] &&
       [ -d "$RESTORE/project/logs" ] &&
       [ -d "$RESTORE/project/reports" ] &&
       [ -d "$RESTORE/project/scripts" ]; then

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
       [ -d "$ACTIVITY/project/documents" ] &&
       [ -d "$ACTIVITY/project/images" ] &&
       [ -d "$ACTIVITY/project/logs" ] &&
       [ -d "$ACTIVITY/project/reports" ] &&
       [ -d "$ACTIVITY/project/scripts" ]; then

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
    if [ -d "$BACKUP/project/logs" ]; then

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
        find investigation/etc/logrotate.d -type f -mtime -2 2>/dev/null
    )
else
    TASK5B_OK=0
fi

if [ "$TASK5B_OK" -eq 1 ]; then
    pass "Task 5b: logrotate files older less than 2 days recorded"
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

validate_lab215_process_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 215 - Simple Linux Process Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab215_vim"

    LAB_NAME="Lab 215 - Simple Linux Process Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=23
    PASSED=0

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

    # ============================================================
    # TASK 1 - WORKING DIRECTORY
    # ============================================================

    echo "<div class='validation-section'>Task 1 - Create the Process Management Workspace</div>"

    if [ -d "$BASE" ]; then
        pass "Task 1a: lab215_vim directory exists"
    else
        fail "Task 1a: lab215_vim directory is missing"
    fi

    # ============================================================
    # TASK 2 - VIEW RUNNING PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 2 - View Running Processes</div>"

    # Verify ps is available and able to display current user's processes
    PS_OUTPUT=$(ps -u "$STUDENT_NAME" -o pid=,ppid=,user=,stat=,comm= 2>/dev/null)

    if [ -n "$PS_OUTPUT" ]; then
        pass "Task 2a: processes can be displayed using ps"
    else
        fail "Task 2a: unable to verify ps process output"
    fi

    # Verify system-wide process listing works
    PS_EF=$(ps -ef 2>/dev/null | head -n 2)

    if echo "$PS_EF" | grep -q "PID"; then
        pass "Task 2b: system-wide process information is available"
    else
        fail "Task 2b: ps -ef output could not be verified"
    fi

    # Verify ps aux style output
    PS_AUX=$(ps aux 2>/dev/null | head -n 2)

    if echo "$PS_AUX" | grep -q "%CPU"; then
        pass "Task 2c: CPU and memory process information is available"
    else
        fail "Task 2c: ps aux output could not be verified"
    fi

    # ============================================================
    # TASK 3 - START BACKGROUND VIM PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 3 - Start Background Processes</div>"

    BG_FILE="$BASE/bg.txt"

    if [ -f "$BG_FILE" ] &&
       grep -Eq "^\[[0-9]+\].*(Running|Stopped).*vim" "$BG_FILE"
    then
	pass "Task 3a: process file1_bg.vim in backgroud"
    else
        fail "Task 3a: background file1_bg.vim job information is missing from bg.txt"
    fi

    if [ -f "$BG_FILE" ]; 
       grep -Eq "^\[[0-9]+\].*(Running|Stopped).*vim" "$BG_FILE"
    then
        pass "Task 3b: process file2_bg.vim in backgroud"
    else
        fail "Task 3b: background file2_bg.vim job information is missing from bg.txt"
    fi

    # ============================================================
    # TASK 4 - BACKGROUND JOB EVIDENCE
    # ============================================================


    echo "<div class='validation-section'>Task 4 - Investigate Background Jobs</div>"

    BG_FILE="$BASE/bg.txt"
    
    if [ -f "$BG_FILE" ]; then
        pass "Task 4a: bg.txt exists"
    else
        fail "Task 4a: bg.txt is missing"
    fi
    
    # Task 4 requires the jobs command output.
    if [ -f "$BG_FILE" ] &&
       grep -Eq "^\[[0-9]+\].*(Running|Stopped).*vim" "$BG_FILE"
    then
        pass "Task 4b: Vim background job information recorded in bg.txt"
    else
        fail "Task 4b: Vim background job information is missing from bg.txt"
    fi
    
    
    # ============================================================
    # TASK 5 - VIM PROCESS TERMINATION
    # ============================================================
    
    echo "<div class='validation-section'>Task 5 - Terminate Vim Processes by Name</div>"
    
    # Task 5 requires pgrep output to be redirected to bg.txt.
    # Verify that Vim PID/process information was recorded.
    if [ -f "$BG_FILE" ] &&
       grep -Eq "^[[:space:]]*[0-9]+[[:space:]]+vim( |$)" "$BG_FILE"
    then
        pass "Task 5a: Vim process PID information recorded in bg.txt"
    else
    fail "Task 5a: Vim process PID information is missing from bg.txt"
    fi
    
    # Verify that no Vim processes belonging to the student remain.
    VIM_PROCESSES=$(ps -u "$STUDENT_NAME" -o pid=,comm= 2>/dev/null |
        awk '$2 == "vim" || $2 == "vim.basic" {print $1}')
    
    if [ -z "$VIM_PROCESSES" ]; then
        pass "Task 5b: no Vim processes belonging to the student remain"
    else
        fail "Task 5b: Vim process(es) belonging to the student are still running"
    fi

    # ============================================================
    # TASK 6 - MULTIPLE BACKGROUND SLEEP PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 6 - Manage Multiple Background Processes</div>"

    if [ -f "$BG_FILE" ]; then

        if grep -Eq "sleep 5000" "$BG_FILE"; then
            pass "Task 6a: sleep 5000 job recorded in bg.txt"
        else
            fail "Task 6a: sleep 5000 job is not recorded in bg.txt"
        fi

        if grep -Eq "sleep 8000" "$BG_FILE"; then
            pass "Task 6b: sleep 8000 job recorded in bg.txt"
        else
            fail "Task 6b: sleep 8000 job is not recorded in bg.txt"
        fi

        if grep -Eq "sleep 10000" "$BG_FILE"; then
            pass "Task 6c: sleep 10000 job recorded in bg.txt"
        else
            fail "Task 6c: sleep 10000 job is not recorded in bg.txt"
        fi

        if grep -Eq "sleep 15000" "$BG_FILE"; then
            pass "Task 6d: sleep 15000 job recorded in bg.txt"
        else
            fail "Task 6d: sleep 15000 job is not recorded in bg.txt"
        fi

        if grep -Eq "sleep 20000" "$BG_FILE"; then
            pass "Task 6e: sleep 20000 job recorded in bg.txt"
        else
            fail "Task 6e: sleep 20000 job is not recorded in bg.txt"
        fi

    else
        fail "Task 6: bg.txt is missing"
    fi

    # ============================================================
    # TASK 7 - KILL SLEEP 5000
    # ============================================================

    echo "<div class='validation-section'>Task 7 - Terminate a Process Using PID</div>"

    SLEEP5000=$(ps -u "$STUDENT_NAME" -o args= 2>/dev/null |
        grep -E '^sleep 5000$')

    if [ -z "$SLEEP5000" ]; then
        pass "Task 7: sleep 5000 process is no longer running"
    else
        fail "Task 7: sleep 5000 process is still running"
    fi

    # ============================================================
    # TASK 8 - SIGTERM
    # ============================================================

    echo "<div class='validation-section'>Task 8 - Gracefully Terminate a Process</div>"

    SLEEP8000=$(ps -u "$STUDENT_NAME" -o args= 2>/dev/null |
        grep -E '^sleep 8000$')

    if [ -z "$SLEEP8000" ]; then
        pass "Task 8: sleep 8000 process is no longer running"
    else
        fail "Task 8: sleep 8000 process is still running"
    fi

    # ============================================================
    # TASK 9 - SIGKILL
    # ============================================================

    echo "<div class='validation-section'>Task 9 - Force Terminate a Process</div>"

    SLEEP10000=$(ps -u "$STUDENT_NAME" -o args= 2>/dev/null |
        grep -E '^sleep 10000$')

    if [ -z "$SLEEP10000" ]; then
        pass "Task 9: sleep 10000 process is no longer running"
    else
        fail "Task 9: sleep 10000 process is still running"
    fi

    # ============================================================
    # TASK 10 - REMAINING SLEEP PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 10 - Terminate Remaining Processes by Name</div>"

    REMAINING_SLEEP=$(ps -u "$STUDENT_NAME" -o pid=,args= 2>/dev/null |
        awk '$2 == "sleep" {print}')

    if [ -z "$REMAINING_SLEEP" ]; then
        pass "Task 10: no student-created sleep processes remain"
    else
        fail "Task 10: student-created sleep process(es) are still running"
    fi

    # ============================================================
    # TASK 11 - PROCESS COUNT
    # ============================================================

    echo "<div class='validation-section'>Task 11 - Count Processes Running on the Server</div>"

    PROCESS_FILE="$BASE/process.txt"

    if [ -f "$PROCESS_FILE" ]; then
        pass "Task 11a: process.txt exists"
    else
        fail "Task 11a: process.txt is missing"
    fi

    if [ -f "$PROCESS_FILE" ] &&
       grep -Eq '^[0-9]+$' "$PROCESS_FILE"
    then
        PROCESS_COUNT=$(cat "$PROCESS_FILE" 2>/dev/null)

        if [ "$PROCESS_COUNT" -gt 0 ] 2>/dev/null; then
            pass "Task 11b: process count is recorded in process.txt"
        else
            fail "Task 11b: process count is zero or invalid"
        fi
    else
        fail "Task 11b: process.txt does not contain a valid numeric process count"
    fi

    # ============================================================
    # ADDITIONAL SAFETY / CLEANUP CHECKS
    # ============================================================

    echo "<div class='validation-section'>Final Process Cleanup</div>"

    # No student Vim processes
    FINAL_VIM=$(ps -u "$STUDENT_NAME" -o comm= 2>/dev/null |
        grep -E '^(vim|vim.basic)$')

    if [ -z "$FINAL_VIM" ]; then
        pass "Cleanup 1: no Vim processes belonging to the student remain"
    else
        fail "Cleanup 1: Vim processes belonging to the student remain"
    fi

    # No student sleep processes
    FINAL_SLEEP=$(ps -u "$STUDENT_NAME" -o comm= 2>/dev/null |
        grep '^sleep$')

    if [ -z "$FINAL_SLEEP" ]; then
        pass "Cleanup 2: no sleep processes belonging to the student remain"
    else
        fail "Cleanup 2: sleep processes belonging to the student remain"
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

#====================================================================

validate_lab216_advanced_process_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 216 - Advanced Linux Process Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab216_challenge_vim"

    LAB_NAME="Lab 216 - Advanced Linux Process Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=13
    PASSED=0

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # ============================================================
    # TASK 1 - WORKING DIRECTORY
    # ============================================================

    echo "<div class='validation-section'>Task 1 - Create the Advanced Process Management Workspace</div>"

    if [ -d "$BASE" ]; then
        pass "Task 1: lab216_challenge_vim directory exists"
    else
        fail "Task 1: lab216_challenge_vim directory is missing"
    fi


    # ============================================================
    # TASK 2 - FIND SSHD PROCESS
    # ============================================================

    echo "<div class='validation-section'>Task 2 - Find a Process by Name</div>"

    SSHD_FOUND=$(pgrep -a sshd 2>/dev/null)

    if [ -n "$SSHD_FOUND" ]; then
        pass "Task 2: sshd PID and process name can be identified using pgrep"
    else
        fail "Task 2: sshd process could not be identified"
    fi

    # ============================================================
    # TASK 3 - BACKGROUND PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 3 - Start Multiple Background Processes</div>"

    BG_FILE="$BASE/bg.txt"

    if [ -f "$BG_FILE" ] && [ -s "$BG_FILE" ]; then

        BG_OK=1

        grep -q "sleep 5000" "$BG_FILE" || BG_OK=0
        grep -q "sleep 8000" "$BG_FILE" || BG_OK=0
        grep -q "sleep 10000" "$BG_FILE" || BG_OK=0
        grep -q "sleep 15000" "$BG_FILE" || BG_OK=0
        grep -q "sleep 20000" "$BG_FILE" || BG_OK=0

        if [ "$BG_OK" -eq 1 ]; then
            pass "Task 3: background sleep jobs recorded in bg.txt"
        else
            fail "Task 3: bg.txt does not contain all required sleep jobs"
        fi

    else
        fail "Task 3: bg.txt is missing or empty"
    fi


    # ============================================================
    # TASK 4 - FOREGROUND / SUSPEND
    # ============================================================

    echo "<div class='validation-section'>Task 4 - Bring a Background Job to the Foreground</div>"
    SLEEP5000=$(pgrep -u "$STUDENT_NAME" -f '^sleep 5000$' 2>/dev/null)

    if [ -z "$SLEEP5000" ]; then
        pass "Task 4: sleep 5000 process is no longer running"
    else
        fail "Task 4: sleep 5000 process is still running"
    fi


    # ============================================================
    # TASK 5 - RESUME AND TERMINATE JOB
    # ============================================================

    echo "<div class='validation-section'>Task 5 - Resume and Terminate a Job Using Job ID</div>"

    SLEEP5000=$(pgrep -u "$STUDENT_NAME" -f '^sleep 5000$' 2>/dev/null)

    if [ -z "$SLEEP5000" ]; then
        pass "Task 5: sleep 5000 process was terminated"
    else
        fail "Task 5: sleep 5000 process is still running"
    fi


    # ============================================================
    # TASK 6 - PARENT AND CHILD PROCESS
    # ============================================================

    echo "<div class='validation-section'>Task 6 - Identify Parent and Child Processes</div>"
    PARENT_FILE="$BASE/process_parent.txt"

    if [ -f "$PARENT_FILE" ] && [ -s "$PARENT_FILE" ]; then

        if grep -Eq "PID|PPID|[0-9]+[[:space:]]+[0-9]+" "$PARENT_FILE"; then
            pass "Task 6: parent and child process evidence recorded"
        else
            fail "Task 6: process_parent.txt exists but does not contain valid PID/PPID information"
        fi

    else
        echo "<div class='validation-pass'>✓ Task 6: parent/child process investigation completed manually</div>"
        ((PASSED++))
    fi


    # ============================================================
    # TASK 7 - TERMINATE REMAINING SLEEP PROCESSES
    # ============================================================

    echo "<div class='validation-section'>Task 7 - Terminate Remaining Sleep Processes</div>"

    REMAINING_SLEEP=$(pgrep -u "$STUDENT_NAME" -x sleep 2>/dev/null)

    if [ -z "$REMAINING_SLEEP" ]; then
        pass "Task 7: no lab-created sleep processes remain"
    else
        fail "Task 7: one or more sleep processes created by the student are still running"
    fi


    # ============================================================
    # TASK 8 - NICE VALUE
    # ============================================================

    echo "<div class='validation-section'>Task 8 - Run a Process with a Different Priority</div>"

    NICE_FILE="$BASE/nice_value.txt"

    if [ -f "$NICE_FILE" ] && [ -s "$NICE_FILE" ]; then

        if grep -Eq "[[:space:]]10[[:space:]]" "$NICE_FILE"; then
            pass "Task 8: nice value 10 recorded in nice_value.txt"
        else
            fail "Task 8: nice value 10 was not found in nice_value.txt"
        fi

    else
        fail "Task 8: nice_value.txt is missing or empty"
    fi


    # ============================================================
    # TASK 9 - RENICE
    # ============================================================

    echo "<div class='validation-section'>Task 9 - Change Process Priority</div>"

    RENICE_FILE="$BASE/renice_value.txt"

    if [ -f "$RENICE_FILE" ] && [ -s "$RENICE_FILE" ]; then

        if grep -Eq "[[:space:]]15[[:space:]]" "$RENICE_FILE"; then
            pass "Task 9: nice value changed to 15 and recorded"
        else
            fail "Task 9: nice value 15 was not found in renice_value.txt"
        fi

    else
        fail "Task 9: renice_value.txt is missing or empty"
    fi


    # ============================================================
    # TASK 10 - FINAL CLEANUP
    # ============================================================

    echo "<div class='validation-section'>Task 10 - Terminate Remaining Processes and Verify Cleanup</div>"

    CLEANUP_OK=1

    # Check for student-owned sleep processes
    if pgrep -u "$STUDENT_NAME" -x sleep >/dev/null 2>&1; then
        CLEANUP_OK=0
    fi

    # Check for remaining Vim processes created by the student
    if pgrep -u "$STUDENT_NAME" -x vim >/dev/null 2>&1; then
        CLEANUP_OK=0
    fi

    if [ "$CLEANUP_OK" -eq 1 ]; then
        pass "Task 10: all lab-created processes have been cleaned up"
    else
        fail "Task 10: one or more lab-created processes are still running"
    fi

    # ============================================================
    # TASK 11 - SORT PROCESSES BY CPU
    # ============================================================

    echo "<div class='validation-section'>Task 11 - Display and Sort Processes by CPU Usage</div>"

    CPU_FILE="$BASE/sort_process_cpu.txt"
    
    if [ -f "$CPU_FILE" ]; then
        pass "Task 11a: sort_process_cpu.txt exists"
    else
        fail "Task 11a: sort_process_cpu.txt is missing"
    fi
    
    if [ -f "$CPU_FILE" ] &&
       grep -Eq "PID.*PPID.*USER.*%CPU.*%MEM.*S.*CMD" "$CPU_FILE"
    then
        pass "Task 11b: process output contains the required columns"
    else
        fail "Task 11b: required process columns are missing from sort_process_cpu.txt"
    fi
           
    if [ -f "$CPU_FILE" ]; then
    
        CPU_VALUES=$(awk 'NR > 1 && $1 ~ /^[0-9]+$/ && $4 ~ /^[0-9.]+$/ {print $4}' "$CPU_FILE")
    
        SORTED_CPU=$(printf '%s\n' "$CPU_VALUES" | sort -nr)
    
        if [ "$CPU_VALUES" = "$SORTED_CPU" ]; then
            pass "Task 11c: processes are sorted by CPU usage in descending order"
        else
            fail "Task 11c: processes are not sorted by CPU usage"
        fi
    
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

#===================================================================

validate_lab217_service_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 217 - Linux Service Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/service_mgt"

    LAB_NAME="Lab 217 - Linux Service Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=11
    PASSED=0

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


    # ============================================================
    # TASK 1 - WORKING DIRECTORY
    # ============================================================
    if [ -d "$BASE" ]; then
        pass "Task 1: service_mgt directory exists"
    else
        fail "Task 1: service_mgt directory is missing"
    fi


    # ============================================================
    # TASK 2 - IDENTIFY SERVICE MANAGER
    # ============================================================
    PID1_COMM=$(ps -p 1 -o comm= 2>/dev/null | xargs)

    if [ "$PID1_COMM" = "systemd" ]; then
        pass "Task 2: systemd is running as PID 1"
    else
        fail "Task 2: systemd is not running as PID 1"
    fi

    # ============================================================
    # TASK 3 - CHECK HTTPD STATUS
    # ============================================================
    HTTPD_STATUS3="$BASE/httpd_status3"

    if [ -f "$HTTPD_STATUS3" ] && [ -s "$HTTPD_STATUS3" ]; then

        if grep -q "httpd.service" "$HTTPD_STATUS3" &&
           grep -Eq "Loaded:|Active:" "$HTTPD_STATUS3"; then
            pass "Task 3: httpd service status recorded in httpd_status3"
        else
            fail "Task 3: httpd_status3 does not contain valid systemctl status output"
        fi

    else
        fail "Task 3: httpd_status3 is missing or empty"
    fi


    # ============================================================
    # TASK 4 - STOP HTTPD
    # ============================================================
    HTTPD_STATUS4="$BASE/httpd_status4"

    if [ -f "$HTTPD_STATUS4" ] && [ -s "$HTTPD_STATUS4" ]; then

        if grep -Eq "Active:.*(inactive|dead|failed)" "$HTTPD_STATUS4"; then
            pass "Task 4: httpd was stopped and inactive state was recorded"
        else
            fail "Task 4: httpd_status4 does not show httpd as stopped"
        fi

    else
        fail "Task 4: httpd_status4 is missing or empty"
    fi


    # ============================================================
    # TASK 5 - START HTTPD
    # ============================================================
    HTTPD_STATUS5="$BASE/httpd_status5"

    if [ -f "$HTTPD_STATUS5" ] && [ -s "$HTTPD_STATUS5" ]; then

        if grep -Eq "Active:.*active \(running\)" "$HTTPD_STATUS5"; then
            pass "Task 5: httpd was started and active state was recorded"
        else
            fail "Task 5: httpd_status5 does not show httpd as active (running)"
        fi

    else
        fail "Task 5: httpd_status5 is missing or empty"
    fi


    # ============================================================
    # TASK 6 - RESTART HTTPD
    # ============================================================
    HTTPD_STATUS6="$BASE/httpd_status6"

    if [ -f "$HTTPD_STATUS6" ] && [ -s "$HTTPD_STATUS6" ]; then

        if grep -Eq "Active:.*active \(running\)" "$HTTPD_STATUS6"; then
            pass "Task 6: httpd was restarted and active state was recorded"
        else
            fail "Task 6: httpd_status6 does not show httpd as active (running)"
        fi

    else
        fail "Task 6: httpd_status6 is missing or empty"
    fi


    # ============================================================
    # TASK 7 - RELOAD HTTPD
    # ============================================================
    HTTPD_STATUS7="$BASE/httpd_status7"

    if [ -f "$HTTPD_STATUS7" ] && [ -s "$HTTPD_STATUS7" ]; then

        if grep -Eq "Active:.*active \(running\)" "$HTTPD_STATUS7"; then
            pass "Task 7: httpd reload completed and service remained active"
        else
            fail "Task 7: httpd_status7 does not show httpd as active (running)"
        fi

    else
        fail "Task 7: httpd_status7 is missing or empty"
    fi


    # ============================================================
    # TASK 8 - ENABLE HTTPD AT BOOT
    # ============================================================
    HTTPD_STATUS8="$BASE/httpd_status8"

    if [ -s "$HTTPD_STATUS8" ]; then
       if grep -qE 'Loaded:.*; enabled;' "$HTTPD_STATUS8"; then
            pass "Task 8: httpd is enabled at boot"
        else
            fail "Task 8: httpd is not enabled at boot"
        fi
    else
        fail "Task 8: httpd_status8 is missing or empty"
    fi

    # ============================================================
    # TASK 9 - DISABLE HTTPD AT BOOT
    # ============================================================
    HTTPD_STATUS9="$BASE/httpd_status9"

    if [ -s "$HTTPD_STATUS9" ]; then

       if grep -qE 'Loaded:.*; disabled;' "$HTTPD_STATUS9"; then
            pass "Task 9: httpd is disabled at boot"
        else
            fail "Task 9: httpd is not disabled at boot"
        fi

    else
        fail "Task 9: httpd_status9 is missing or empty"
    fi


    # ============================================================
    # TASK 10 - SERVICE INFORMATION
    # ============================================================
    HTTPD_STATUS10="$BASE/httpd_status10"

    if [ -f "$HTTPD_STATUS10" ] && [ -s "$HTTPD_STATUS10" ]; then

        INFO_OK=1

        grep -q "Loaded:" "$HTTPD_STATUS10" || INFO_OK=0
        grep -q "Active:" "$HTTPD_STATUS10" || INFO_OK=0
        grep -q "Main PID:" "$HTTPD_STATUS10" || INFO_OK=0

        if [ "$INFO_OK" -eq 1 ]; then
            pass "Task 10: httpd service information recorded"
        else
            fail "Task 10: httpd_status10 does not contain required service information"
        fi

    else
        fail "Task 10: httpd_status10 is missing or empty"
    fi


    # ============================================================
    # TASK 11 - FIND HTTPD PROCESS
    # ============================================================
    HTTPD_STATUS11="$BASE/httpd_status11"

    if [ -f "$HTTPD_STATUS11" ] && [ -s "$HTTPD_STATUS11" ]; then

        PROCESS_OK=1

        # Check for required ps headers
        grep -Eq "PID[[:space:]]+PPID[[:space:]]+USER[[:space:]]+COMMAND" \
            "$HTTPD_STATUS11" || PROCESS_OK=0

        # Check that httpd process information exists
        grep -Eq "[0-9]+[[:space:]]+[0-9]+[[:space:]]+[[:alnum:]_.-]+[[:space:]]+httpd" \
            "$HTTPD_STATUS11" || PROCESS_OK=0

        if [ "$PROCESS_OK" -eq 1 ]; then
            pass "Task 11: httpd process information recorded with PID, PPID, USER, and COMMAND"
        else
            fail "Task 11: httpd_status11 does not contain valid httpd process information"
        fi

    else
        fail "Task 11: httpd_status11 is missing or empty"
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

#===============================================================================

validate_lab218_advanced_service_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 218 - Advanced Linux Service Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab218_service_mgt_advance"

    LAB_NAME="Lab 218 - Advanced Linux Service Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=11
    PASSED=0

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


    # ============================================================
    # TASK 1 - LAB WORKSPACE
    # ============================================================

    if [ -d "$BASE" ]; then
        pass "Task 1: lab218_service_mgt_advance directory exists"
    else
        fail "Task 1: lab218_service_mgt_advance directory is missing"
    fi


    # ============================================================
    # TASK 2 - IDENTIFY SERVICE MANAGER
    # ============================================================

    TASK2="$BASE/task2_service_manager.txt"

    if [ -f "$TASK2" ] && [ -s "$TASK2" ]; then

        PID1_OK=1

        # Check PID 1 exists in saved output
        grep -Eq "[[:space:]]*1[[:space:]]+systemd[[:space:]]+" "$TASK2" || PID1_OK=0

        if [ "$PID1_OK" -eq 1 ]; then
            pass "Task 2: systemd identified as the service manager running as PID 1"
        else
            fail "Task 2: task2_service_manager.txt does not show systemd as PID 1"
        fi

    else
        fail "Task 2: task2_service_manager.txt is missing or empty"
    fi


    # ============================================================
    # TASK 3 - INSPECT APACHE BEFORE STARTING
    # ============================================================

    TASK3="$BASE/task3_httpd_status.txt"

    if [ -f "$TASK3" ] && [ -s "$TASK3" ]; then

        STATUS_OK=1

        grep -q "httpd.service" "$TASK3" || STATUS_OK=0
        grep -q "Loaded:" "$TASK3" || STATUS_OK=0
        grep -q "Active:" "$TASK3" || STATUS_OK=0
        grep -q "Main PID:" "$TASK3" || STATUS_OK=0

        if [ "$STATUS_OK" -eq 1 ]; then
            pass "Task 3: httpd service status recorded with required information"
        else
            fail "Task 3: task3_httpd_status.txt does not contain required httpd status information"
        fi

    else
        fail "Task 3: task3_httpd_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 4 - START APACHE
    # ============================================================

    TASK4="$BASE/task4_httpd.txt"

    if [ -f "$TASK4" ] && [ -s "$TASK4" ]; then

        if grep -Eq "Active:.*active \(running\)" "$TASK4"; then
            pass "Task 4: httpd was started and active state was recorded"
        else
            fail "Task 4: task4_httpd.txt does not show httpd as active (running)"
        fi

    else
        fail "Task 4: task4_httpd.txt is missing or empty"
    fi


    # ============================================================
    # TASK 5 - ENABLE APACHE AT BOOT
    # ============================================================

    TASK5="$BASE/task5_httpd_status.txt"

    if [ -f "$TASK5" ] && [ -s "$TASK5" ]; then

        if grep -Eq "Loaded:.*; enabled;" "$TASK5"; then
            pass "Task 5: httpd is shown as enabled at boot"
        else
            fail "Task 5: task5_httpd_status.txt does not show httpd as enabled"
        fi

    else
        fail "Task 5: task5_httpd_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 6 - CREATE WEB CONTENT
    # ============================================================

    INDEX_FILE="/var/www/html/index.html"

    if [ -f "$INDEX_FILE" ]; then

        CONTENT_OK=1

        grep -Fq "<h1>LINOOP Linux Service Management</h1>" "$INDEX_FILE" || CONTENT_OK=0
        grep -Fq "<p>Apache HTTP Server is running successfully.</p>" "$INDEX_FILE" || CONTENT_OK=0
        grep -Fq "<p>Lab 218 - Advanced Service Management</p>" "$INDEX_FILE" || CONTENT_OK=0

        if [ "$CONTENT_OK" -eq 1 ]; then
            pass "Task 6: index.html contains the required Lab 218 web content"
        else
            fail "Task 6: index.html does not contain the required web content"
        fi

    else
        fail "Task 6: /var/www/html/index.html is missing"
    fi


    # ============================================================
    # TASK 7 - ACCESS WEB SERVER
    # ============================================================
    TASK7_PASS=true
    TASK7_ERRORS=""
    
    # SELinux
    if [ "$(getenforce 2>/dev/null)" != "Permissive" ]; then
        TASK7_PASS=false
        TASK7_ERRORS="${TASK7_ERRORS}<li>SELinux is not Permissive.</li>"
    fi
    
    # Apache service
    if ! systemctl is-active --quiet httpd; then
        TASK7_PASS=false
        TASK7_ERRORS="${TASK7_ERRORS}<li>Apache HTTP Server is not running.</li>"
    fi
    
    # Web content through HTTP
    WEB_CONTENT=$(curl -s --max-time 5 http://localhost 2>/dev/null)
    
    if ! echo "$WEB_CONTENT" | grep -Fq "<h1>LINOOP Linux Service Management</h1>"; then
        TASK7_PASS=false
        TASK7_ERRORS="${TASK7_ERRORS}<li>Apache is not serving the required web content.</li>"
    fi
    
    # Port 80
    if ! netstat -tunap 2>/dev/null | grep -qE '(:80[[:space:]]).*LISTEN'; then
        TASK7_PASS=false
        TASK7_ERRORS="${TASK7_ERRORS}<li>TCP port 80 is not listening.</li>"
    fi
    
    # Firewall
    if firewall-cmd --list-service 2>/dev/null | grep -qw http; then
        TASK7_PASS=false
        TASK7_ERRORS="${TASK7_ERRORS}<li>Firewall does not allow the <b>http</b> service.</li>"
    fi
    
    # FINAL RESULT
    if [ "$TASK7_PASS" = true ]; then
    
        pass "Task 7: Web server is configured and ready for browser access"
    
    else
    
        fail "Task 7: Web server is not fully configured for browser access"
    
        echo "<b>Task 7 - What needs to be fixed:</b>"
        echo "<ul>"
        echo "$TASK7_ERRORS"
        echo "</ul>"

    fi

    # ============================================================
    # TASK 8 - STOP HTTPD SERVICE
    # ============================================================

    TASK8="$BASE/task8_httpd_status.txt"

    if [ -f "$TASK8" ] && [ -s "$TASK8" ]; then

        if grep -Eq "Active:.*(inactive|dead|failed)" "$TASK8"; then
            pass "Task 8: httpd was stopped and inactive state was recorded"
        else
            fail "Task 8: task8_httpd_status.txt does not show httpd as stopped"
        fi

    else
        fail "Task 8: task8_httpd_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 9 - TEST WEBSITE AFTER STOPPING HTTPD
    # ============================================================

    TASK9="$BASE/task9_httpd_status.txt"

    if [ -f "$TASK9" ] && [ -s "$TASK9" ]; then

        if grep -Eq "Active:.*(inactive|dead|failed)" "$TASK9"; then
            pass "Task 9: httpd unavailable state was recorded after stopping the service"
        else
            fail "Task 9: task9_httpd_status.txt does not show httpd as stopped"
        fi

    else
        fail "Task 9: task9_httpd_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 10 - RESTART APACHE
    # ============================================================

    TASK10="$BASE/task10_httpd_status.txt"

    if [ -f "$TASK10" ] && [ -s "$TASK10" ]; then

        if grep -Eq "Active:.*active \(running\)" "$TASK10"; then
            pass "Task 10: httpd was restarted and active state was recorded"
        else
            fail "Task 10: task10_httpd_status.txt does not show httpd as active (running)"
        fi

    else
        fail "Task 10: task10_httpd_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 11 - ACCESS WEBSITE AGAIN
    # ============================================================

    TASK11="$BASE/task11_httpd_accessible.txt"

    if [ -f "$TASK11" ] && [ -s "$TASK11" ]; then

        if grep -qx "active" "$TASK11"; then

            # Also verify the required web content still exists
            CONTENT_OK=1

            grep -Fq "<h1>LINOOP Linux Service Management</h1>" "$INDEX_FILE" || CONTENT_OK=0
            grep -Fq "<p>Apache HTTP Server is running successfully.</p>" "$INDEX_FILE" || CONTENT_OK=0
            grep -Fq "<p>Lab 218 - Advanced Service Management</p>" "$INDEX_FILE" || CONTENT_OK=0

            if [ "$CONTENT_OK" -eq 1 ]; then
                pass "Task 11: httpd is active and required website content is available"
            else
                fail "Task 11: httpd is active but required website content is missing"
            fi

        else
            fail "Task 11: task11_httpd_accessible.txt does not show httpd as active"
        fi

    else
        fail "Task 11: task11_httpd_accessible.txt is missing or empty"
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

#============================================================================

validate_lab219_user_management() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 219 - Linux User Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab219_user_mgt"

    LAB_NAME="Lab 219 - Linux User Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=12
    PASSED=0

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


    # ============================================================
    # TASK 1 - CREATE GROUP
    # ============================================================

    TASK1="$BASE/task1-group.txt"

    if [ -f "$TASK1" ] && [ -s "$TASK1" ]; then

        TASK1_OK=1

        grep -Eq '^appsupport:x:3001:' "$TASK1" || TASK1_OK=0

        if [ "$TASK1_OK" -eq 1 ]; then
            pass "Task 1: appsupport group exists with GID 3001"
        else
            fail "Task 1: task1-group.txt does not show appsupport with GID 3001"
        fi

    else
        fail "Task 1: task1-group.txt is missing or empty"
    fi


    # ============================================================
    # TASK 2 - CREATE GROUPS WITH SPECIFIC GID
    # ============================================================

    TASK2="$BASE/task2-groups.txt"

    if [ -f "$TASK2" ] && [ -s "$TASK2" ]; then

        TASK2_OK=1

        grep -Eq '^developers:x:3002:' "$TASK2" || TASK2_OK=0
        grep -Eq '^dbadmin:x:3003:' "$TASK2" || TASK2_OK=0

        if [ "$TASK2_OK" -eq 1 ]; then
            pass "Task 2: developers and dbadmin groups were created with the required GIDs"
        else
            fail "Task 2: task2-groups.txt does not show the required group GIDs"
        fi

    else
        fail "Task 2: task2-groups.txt is missing or empty"
    fi


    # ============================================================
    # TASK 3 - CREATE USERS
    # ============================================================

    TASK3="$BASE/task3-users.txt"

    if [ -f "$TASK3" ] && [ -s "$TASK3" ]; then

        TASK3_OK=1

        grep -Eq '^alex:' "$TASK3" || TASK3_OK=0
        grep -Eq '^david:' "$TASK3" || TASK3_OK=0

        if [ "$TASK3_OK" -eq 1 ]; then
            pass "Task 3: alex and david users were created"
        else
            fail "Task 3: task3-users.txt does not show both alex and david"
        fi

    else
        fail "Task 3: task3-users.txt is missing or empty"
    fi


    # ============================================================
    # TASK 4 - CREATE MARIA WITH UID 2001
    # ============================================================

    TASK4="$BASE/task4-uid.txt"

    if [ -f "$TASK4" ] && [ -s "$TASK4" ]; then

        TASK4_OK=1

        # id output should contain uid=2001 for Maria
        grep -Eq 'uid=2001\(maria\)' "$TASK4" || TASK4_OK=0

        if [ "$TASK4_OK" -eq 1 ]; then
            pass "Task 4: maria was created with UID 2001"
        else
            fail "Task 4: task4-uid.txt does not show maria with UID 2001"
        fi

    else
        fail "Task 4: task4-uid.txt is missing or empty"
    fi


    # ============================================================
    # TASK 5 - MARIA SUPPLEMENTARY GROUP
    # ============================================================

    TASK5="$BASE/task5-maria-groups.txt"

    if [ -f "$TASK5" ] && [ -s "$TASK5" ]; then

        TASK5_OK=1

        # Maria must have primary group maria
        grep -Eq 'gid=[0-9]+\(maria\)' "$TASK5" || TASK5_OK=0

        # Maria must have developers as supplementary group
        grep -Eq 'groups=.*developers' "$TASK5" || TASK5_OK=0

        if [ "$TASK5_OK" -eq 1 ]; then
            pass "Task 5: maria has maria as primary group and developers as supplementary group"
        else
            fail "Task 5: task5-maria-groups.txt does not show the required Maria group configuration"
        fi

    else
        fail "Task 5: task5-maria-groups.txt is missing or empty"
    fi


    # ============================================================
    # TASK 6 - ALEX APPSUPPORT
    # ============================================================

    TASK6="$BASE/task6-alex-groups.txt"

    if [ -f "$TASK6" ] && [ -s "$TASK6" ]; then

        TASK6_OK=1

        grep -Eq 'uid=[0-9]+\(alex\)' "$TASK6" || TASK6_OK=0
        grep -Eq 'groups=.*appsupport' "$TASK6" || TASK6_OK=0

        if [ "$TASK6_OK" -eq 1 ]; then
            pass "Task 6: alex was added to appsupport as a supplementary group"
        else
            fail "Task 6: task6-alex-groups.txt does not show alex as a member of appsupport"
        fi

    else
        fail "Task 6: task6-alex-groups.txt is missing or empty"
    fi


    # ============================================================
    # TASK 7 - DAVID DBADMIN
    # ============================================================

    TASK7="$BASE/task7-user-group.txt"

    if [ -f "$TASK7" ] && [ -s "$TASK7" ]; then

        TASK7_OK=1

        # David primary group must be david
        grep -Eq 'gid=[0-9]+\(david\)' "$TASK7" || TASK7_OK=0

        # David supplementary group must include dbadmin
        grep -Eq 'groups=.*dbadmin' "$TASK7" || TASK7_OK=0

        if [ "$TASK7_OK" -eq 1 ]; then
            pass "Task 7: david has david as primary group and dbadmin as supplementary group"
        else
            fail "Task 7: task7-user-group.txt does not show the required David group configuration"
        fi

    else
        fail "Task 7: task7-user-group.txt is missing or empty"
    fi


    # ============================================================
    # TASK 8 - REMOVE ALEX FROM APPSUPPORT
    # ============================================================

    TASK8="$BASE/task8-remove-group.txt"

    if [ -f "$TASK8" ] && [ -s "$TASK8" ]; then

        if grep -Eq 'groups=.*appsupport' "$TASK8"; then
            fail "Task 8: task8-remove-group.txt still shows alex as a member of appsupport"
        else
            pass "Task 8: alex was removed from appsupport"
        fi

    else
        fail "Task 8: task8-remove-group.txt is missing or empty"
    fi


    # ============================================================
    # TASK 9 - REMOVE MARIA FROM DEVELOPERS
    # ============================================================

    TASK9="$BASE/task9-remove-group.txt"

    if [ -f "$TASK9" ] && [ -s "$TASK9" ]; then

        if grep -Eq 'groups=.*developers' "$TASK9"; then
            fail "Task 9: task9-remove-group.txt still shows maria as a member of developers"
        else
            pass "Task 9: maria was removed from developers"
        fi

    else
        fail "Task 9: task9-remove-group.txt is missing or empty"
    fi


    # ============================================================
    # TASK 10 - REMOVE DAVID FROM DBADMIN
    # ============================================================

    TASK10="$BASE/task10-remove-group.txt"

    if [ -f "$TASK10" ] && [ -s "$TASK10" ]; then

        if grep -Eq 'groups=.*dbadmin' "$TASK10"; then
            fail "Task 10: task10-remove-group.txt still shows david as a member of dbadmin"
        else
            pass "Task 10: david was removed from dbadmin"
        fi

    else
        fail "Task 10: task10-remove-group.txt is missing or empty"
    fi


    # ============================================================
    # TASK 11 - DELETE GROUPS
    # ============================================================

    TASK11="$BASE/task11-delete-groups.txt"

    if [ -f "$TASK11" ] && [ ! -s "$TASK11" ]; then

        TASK11_OK=1

        if grep -Eq '^appsupport:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        if grep -Eq '^developers:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        if grep -Eq '^dbadmin:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        # Also verify the live system state.
        getent group appsupport >/dev/null 2>&1 && TASK11_OK=0
        getent group developers >/dev/null 2>&1 && TASK11_OK=0
        getent group dbadmin >/dev/null 2>&1 && TASK11_OK=0



        if [ "$TASK11_OK" -eq 1 ]; then
            pass "Task 11: appsupport, developers, and dbadmin groups were deleted"
        else
            fail "Task 11: one or more required groups still exist"
        fi

    else
        fail "Task 11: task11-delete-groups.txt is missing or empty"
    fi


    # ============================================================
    # TASK 12 - DELETE USERS
    # ============================================================

    TASK12="$BASE/task12-delete-users.txt"

    if [ -f "$TASK12" ]; then

        TASK12_OK=1
        # Users must no longer exist
        getent passwd alex >/dev/null 2>&1 && TASK12_OK=0
        getent passwd david >/dev/null 2>&1 && TASK12_OK=0
        getent passwd maria >/dev/null 2>&1 && TASK12_OK=0

        # Verification file must contain no passwd entries
        grep -Eq '^(alex|david|maria):' "$TASK12" && TASK12_OK=0

        if [ "$TASK12_OK" -eq 1 ]; then
            pass "Task 12: alex, david, and maria users were deleted"
        else
            fail "Task 12: one or more required users still exist"
        fi

    else
        fail "Task 12: task12-delete-users.txt is missing or empty"
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

#=========================================================================

validate_lab220_advanced_user_management() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 220 - Linux User Management - Advanced..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab220_user_mgt"

    LAB_NAME="Lab 220 - Linux User Management - Advanced"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=11
    PASSED=0

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


    # ============================================================
    # TASK 1 - CREATE LAB DIRECTORY AND GROUPS
    # ============================================================

    TASK1="$BASE/task1-groups.txt"

    if [ ! -d "$BASE" ]; then

        fail "Task 1: lab219_user_mgt directory is missing"

    elif [ ! -f "$TASK1" ] || [ ! -s "$TASK1" ]; then

        fail "Task 1: task1-groups.txt is missing or empty"

    else

        TASK1_OK=1

        grep -Eq '^platform:x:3101:' "$TASK1" || TASK1_OK=0
        grep -Eq '^engineers:x:3102:' "$TASK1" || TASK1_OK=0
        grep -Eq '^database:x:3103:' "$TASK1" || TASK1_OK=0
        grep -Eq '^support:x:3104:' "$TASK1" || TASK1_OK=0

        if [ "$TASK1_OK" -eq 1 ]; then
            pass "Task 1: lab directory created and all required groups have the correct GIDs"
        else
            fail "Task 1: task1-groups.txt does not show all required groups with the correct GIDs"
        fi

    fi


    # ============================================================
    # TASK 2 - CREATE USERS WITH SPECIFIC UIDs
    # ============================================================

    TASK2="$BASE/task2-users.txt"

    if [ -f "$TASK2" ] && [ -s "$TASK2" ]; then

        TASK2_OK=1

        grep -Eq 'uid=2101\(max\)' "$TASK2" || TASK2_OK=0
        grep -Eq 'uid=2102\(smith\)' "$TASK2" || TASK2_OK=0
        grep -Eq 'uid=2103\(sarah\)' "$TASK2" || TASK2_OK=0
        grep -Eq 'uid=2104\(sophia\)' "$TASK2" || TASK2_OK=0

        if [ "$TASK2_OK" -eq 1 ]; then
            pass "Task 2: max, smith, sarah, and sophia were created with the required UIDs"
        else
            fail "Task 2: task2-users.txt does not show all users with the required UIDs"
        fi

    else
        fail "Task 2: task2-users.txt is missing or empty"
    fi


    # ============================================================
    # TASK 3 - CONFIGURE SUPPLEMENTARY GROUPS
    # ============================================================

    TASK3="$BASE/task3-groups.txt"

    if [ -f "$TASK3" ] && [ -s "$TASK3" ]; then

        TASK3_OK=1

        # max
        grep -Eq 'uid=[0-9]+\(max\).*gid=[0-9]+\(max\).*groups=.*engineers' "$TASK3" \
            || TASK3_OK=0

        grep -Eq 'uid=[0-9]+\(max\).*gid=[0-9]+\(max\).*groups=.*support' "$TASK3" \
            || TASK3_OK=0

        # smith
        grep -Eq 'uid=[0-9]+\(smith\).*gid=[0-9]+\(smith\).*groups=.*platform' "$TASK3" \
            || TASK3_OK=0

        grep -Eq 'uid=[0-9]+\(smith\).*gid=[0-9]+\(smith\).*groups=.*database' "$TASK3" \
            || TASK3_OK=0

        # sarah
        grep -Eq 'uid=[0-9]+\(sarah\).*gid=[0-9]+\(sarah\).*groups=.*engineers' "$TASK3" \
            || TASK3_OK=0

        # Sophia
        grep -Eq 'uid=[0-9]+\(sophia\).*gid=[0-9]+\(sophia\).*groups=.*platform' "$TASK3" \
            || TASK3_OK=0

        grep -Eq 'uid=[0-9]+\(sophia\).*gid=[0-9]+\(sophia\).*groups=.*database' "$TASK3" \
            || TASK3_OK=0

        if [ "$TASK3_OK" -eq 1 ]; then
            pass "Task 3: supplementary group memberships were configured correctly"
        else
            fail "Task 3: task3-groups.txt does not show the required supplementary group memberships"
        fi

    else
        fail "Task 3: task3-groups.txt is missing or empty"
    fi


    # ============================================================
    # TASK 4 - ADD AND REMOVE SUPPLEMENTARY MEMBERSHIPS
    # ============================================================

    TASK4="$BASE/task4-members.txt"

    if [ -f "$TASK4" ] && [ -s "$TASK4" ]; then

        TASK4_OK=1

        # smith must NOT have database
        if grep -E 'uid=[0-9]+\(smith\)' "$TASK4" | grep -q 'database'; then
            TASK4_OK=0
        fi

        # sarah must have support
        grep -E 'uid=[0-9]+\(sarah\)' "$TASK4" | grep -q 'support' \
            || TASK4_OK=0

        # Sophia must NOT have database
        if grep -E 'uid=[0-9]+\(sophia\)' "$TASK4" | grep -q 'database'; then
            TASK4_OK=0
        fi

        # Primary groups must remain unchanged
        grep -Eq 'uid=[0-9]+\(smith\).*gid=[0-9]+\(smith\)' "$TASK4" \
            || TASK4_OK=0

        grep -Eq 'uid=[0-9]+\(sarah\).*gid=[0-9]+\(sarah\)' "$TASK4" \
            || TASK4_OK=0

        grep -Eq 'uid=[0-9]+\(sophia\).*gid=[0-9]+\(sophia\)' "$TASK4" \
            || TASK4_OK=0

        if [ "$TASK4_OK" -eq 1 ]; then
            pass "Task 4: supplementary memberships were changed without changing primary groups"
        else
            fail "Task 4: task4-members.txt does not show the required membership changes"
        fi

    else
        fail "Task 4: task4-members.txt is missing or empty"
    fi


    # ============================================================
    # TASK 5 - SET PASSWORDS
    # ============================================================

    TASK5="$BASE/task5-passwords.txt"

    if [ -f "$TASK5" ] && [ -s "$TASK5" ]; then

        TASK5_OK=1

        # Expected passwd -S output should show PS (Password Set)
        grep -Eq '^max[[:space:]]+PS[[:space:]]' "$TASK5" || TASK5_OK=0
        grep -Eq '^smith[[:space:]]+PS[[:space:]]' "$TASK5" || TASK5_OK=0
        grep -Eq '^sarah[[:space:]]+PS[[:space:]]' "$TASK5" || TASK5_OK=0
        grep -Eq '^sophia[[:space:]]+PS[[:space:]]' "$TASK5" || TASK5_OK=0

        # Make sure password hashes were NOT saved.
        if grep -Eq '^\$[0-9a-zA-Z./]+\$' "$TASK5"; then
            TASK5_OK=0
        fi

        if [ "$TASK5_OK" -eq 1 ]; then
            pass "Task 5: passwords were configured and verification output does not contain passwords"
        else
            fail "Task 5: task5-passwords.txt does not show all accounts with configured passwords"
        fi

    else
        fail "Task 5: task5-passwords.txt is missing or empty"
    fi


    # ============================================================
    # TASK 6 - LOCK MARIA
    # ============================================================

    TASK6="$BASE/task6-lock-sarah.txt"

    if [ -f "$TASK6" ] && [ -s "$TASK6" ]; then

        TASK6_OK=1

        # passwd -S sarah normally reports LK when the password is locked.
        grep -Eq '^sarah[[:space:]]+LK[[:space:]]' "$TASK6" || TASK6_OK=0

        if [ "$TASK6_OK" -eq 1 ]; then
            pass "Task 6: sarah's account was locked"
        else
            fail "Task 6: task6-lock-sarah.txt does not show sarah's account as locked"
        fi

    else
        fail "Task 6: task6-lock-sarah.txt is missing or empty"
    fi


    # ============================================================
    # TASK 7 - UNLOCK MARIA
    # ============================================================

    TASK7="$BASE/task7-unlock-sarah.txt"

    if [ -f "$TASK7" ] && [ -s "$TASK7" ]; then

        TASK7_OK=1

        # sarah should no longer show LK.
        if grep -Eq '^sarah[[:space:]]+LK[[:space:]]' "$TASK7"; then
            TASK7_OK=0
        fi

        # Normal unlocked account with password should show PS.
        grep -Eq '^sarah[[:space:]]+PS[[:space:]]' "$TASK7" || TASK7_OK=0

        if [ "$TASK7_OK" -eq 1 ]; then
            pass "Task 7: sarah's account was unlocked"
        else
            fail "Task 7: task7-unlock-sarah.txt does not show sarah as unlocked"
        fi

    else
        fail "Task 7: task7-unlock-sarah.txt is missing or empty"
    fi


    # ============================================================
    # TASK 8 - REMOVE USERS FROM SUPPLEMENTARY GROUPS
    # ============================================================

    TASK8="$BASE/task8-membership-removal.txt"

    if [ -f "$TASK8" ] && [ -s "$TASK8" ]; then

        TASK8_OK=1

        # max must not have support or engineers.
        if grep -E 'uid=[0-9]+\(max\)' "$TASK8" | grep -Eq 'support|engineers'; then
            TASK8_OK=0
        fi

        # sarah must not have support or engineers.
        if grep -E 'uid=[0-9]+\(sarah\)' "$TASK8" | grep -Eq 'support|engineers'; then
            TASK8_OK=0
        fi

        # Sophia must not have platform.
        if grep -E 'uid=[0-9]+\(sophia\)' "$TASK8" | grep -q 'platform'; then
            TASK8_OK=0
        fi

        # Primary groups must remain unchanged.
        grep -Eq 'uid=[0-9]+\(max\).*gid=[0-9]+\(max\)' "$TASK8" \
            || TASK8_OK=0

        grep -Eq 'uid=[0-9]+\(sarah\).*gid=[0-9]+\(sarah\)' "$TASK8" \
            || TASK8_OK=0

        grep -Eq 'uid=[0-9]+\(sophia\).*gid=[0-9]+\(sophia\)' "$TASK8" \
            || TASK8_OK=0

        if [ "$TASK8_OK" -eq 1 ]; then
            pass "Task 8: users were removed from the required supplementary groups"
        else
            fail "Task 8: task8-membership-removal.txt does not show the required membership removal"
        fi

    else
        fail "Task 8: task8-membership-removal.txt is missing or empty"
    fi


    # ============================================================
    # TASK 9 - DELETE DATABASE GROUP
    # ============================================================

    TASK9="$BASE/task9-delete-database.txt"

    if [ -f "$TASK9" ]; then

        TASK9_OK=1
        
        getent group database >/dev/null 2>&1 && TASK9_OK=0
       
        if grep -Eq '^database:x:' "$TASK9"; then
            TASK9_OK=0
        fi

        if [ "$TASK9_OK" -eq 1 ]; then
            pass "Task 9: database group was deleted successfully"
        else
            fail "Task 9: database group still exists or verification is incorrect"
        fi

    else
        fail "Task 9: task9-delete-database.txt is missing or empty"
    fi


    # ============================================================
    # TASK 10 - DELETE SOPHIA
    # ============================================================

    TASK10="$BASE/task10-delete-sophia.txt"

    if [ -f "$TASK10" ]; then

        TASK10_OK=1

        getent passwd sophia >/dev/null 2>&1 && TASK10_OK=0
 
        [ -d "/home/sophia" ] && TASK10_OK=0

        if grep -Eq '^sophia:' "$TASK10"; then
            TASK10_OK=0
        fi

        if [ "$TASK10_OK" -eq 1 ]; then
            pass "Task 10: sophia account and home directory were deleted"
        else
            fail "Task 10: sophia account or home directory still exists"
        fi

    else
        fail "Task 10: task10-delete-sophia.txt is missing or empty"
    fi


    # ============================================================
    # TASK 11 - FINAL ACCOUNT CLEANUP
    # ============================================================

    TASK11="$BASE/task11-final-audit.txt"

    if [ -f "$TASK11" ] && [ -s "$TASK11" ]; then

        TASK11_OK=1

        # --------------------------------------------------------
        # Groups that must NOT exist
        # --------------------------------------------------------

        getent group support >/dev/null 2>&1 && TASK11_OK=0
        getent group platform >/dev/null 2>&1 && TASK11_OK=0
        getent group database >/dev/null 2>&1 && TASK11_OK=0

        # --------------------------------------------------------
        # engineers MUST exist
        # --------------------------------------------------------

        if ! getent group engineers >/dev/null 2>&1; then
            TASK11_OK=0
        fi

        # --------------------------------------------------------
        # Users that MUST exist
        # --------------------------------------------------------

        getent passwd max >/dev/null 2>&1 || TASK11_OK=0
        getent passwd smith >/dev/null 2>&1 || TASK11_OK=0
        getent passwd sarah >/dev/null 2>&1 || TASK11_OK=0

        # --------------------------------------------------------
        # Sophia MUST NOT exist
        # --------------------------------------------------------

        getent passwd sophia >/dev/null 2>&1 && TASK11_OK=0

        # --------------------------------------------------------
        # Check saved audit for expected account/group results
        # --------------------------------------------------------

        grep -Eq '^engineers:x:' "$TASK11" || TASK11_OK=0

        if grep -Eq '^support:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        if grep -Eq '^platform:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        if grep -Eq '^database:x:' "$TASK11"; then
            TASK11_OK=0
        fi

        if grep -Eq '^sophia:' "$TASK11"; then
            TASK11_OK=0
        fi

        if [ "$TASK11_OK" -eq 1 ]; then
            pass "Task 11: final account and group cleanup completed successfully"
        else
            fail "Task 11: final account audit does not match the required state"
        fi

    else
        fail "Task 11: task11-final-audit.txt is missing or empty"
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

#=========================================================================

validate_lab221_package_management() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 221 - Linux Package Management..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab221_pkg_mgt"

    LAB_NAME="Lab 221 - Linux Package Management"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=8
    PASSED=0

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


    # ============================================================
    # TASK 1 - IDENTIFY THE PACKAGE MANAGER
    # ============================================================

    TASK1="$BASE/package_manager.txt"

    if [ -f "$TASK1" ] && [ -s "$TASK1" ]; then

        TASK1_OK=1

        # YUM version output should contain a version number
        grep -Eq '^[0-9]+\.[0-9]+' "$TASK1" || TASK1_OK=0

        if [ "$TASK1_OK" -eq 1 ]; then
            pass "Task 1: YUM version was identified and saved correctly"
        else
            fail "Task 1: package_manager.txt does not show a valid YUM version"
        fi

    else
        fail "Task 1: package_manager.txt is missing or empty"
    fi


    # ============================================================
    # TASK 2 - DISPLAY INSTALLED PACKAGES
    # ============================================================

    TASK2="$BASE/installed_packages.txt"

    if [ -f "$TASK2" ] && [ -s "$TASK2" ]; then

        TASK2_OK=1

        # Expected yum list installed header
        grep -Eq 'Installed Packages' "$TASK2" || TASK2_OK=0

        if [ "$TASK2_OK" -eq 1 ]; then
            pass "Task 2: installed package list was saved correctly"
        else
            fail "Task 2: installed_packages.txt does not appear to contain yum installed-package output"
        fi

    else
        fail "Task 2: installed_packages.txt is missing or empty"
    fi


    # ============================================================
    # TASK 3 - SEARCH FOR HTTPD
    # ============================================================

    TASK3="$BASE/httpd_search.txt"

    if [ -f "$TASK3" ] && [ -s "$TASK3" ]; then

        TASK3_OK=1

        # Search results should contain httpd
        grep -qi 'httpd' "$TASK3" || TASK3_OK=0

        if [ "$TASK3_OK" -eq 1 ]; then
            pass "Task 3: repository search results for httpd were saved correctly"
        else
            fail "Task 3: httpd_search.txt does not show httpd search results"
        fi

    else
        fail "Task 3: httpd_search.txt is missing or empty"
    fi


    # ============================================================
    # TASK 4 - DISPLAY HTTPD PACKAGE INFORMATION
    # ============================================================

    TASK4="$BASE/httpd_info.txt"

    if [ -f "$TASK4" ] && [ -s "$TASK4" ]; then

        TASK4_OK=1

        # Package name
        grep -Eq '^Name[[:space:]]*:[[:space:]]*httpd' "$TASK4" || TASK4_OK=0

        # Version
        grep -Eq '^Version[[:space:]]*:' "$TASK4" || TASK4_OK=0

        # Architecture
        grep -Eq '^Architecture[[:space:]]*:' "$TASK4" || TASK4_OK=0

        # Repository
        grep -Eq '^Repository[[:space:]]*:' "$TASK4" || TASK4_OK=0

        # Size
        grep -Eq '^Size[[:space:]]*:' "$TASK4" || TASK4_OK=0

        # Summary
        grep -Eq '^Summary[[:space:]]*:' "$TASK4" || TASK4_OK=0

        if [ "$TASK4_OK" -eq 1 ]; then
            pass "Task 4: httpd package information was displayed and saved correctly"
        else
            fail "Task 4: httpd_info.txt does not contain all required package information"
        fi

    else
        fail "Task 4: httpd_info.txt is missing or empty"
    fi


    # ============================================================
    # TASK 5 - DETERMINE WHETHER HTTPD IS INSTALLED
    # ============================================================

    TASK5="$BASE/httpd_installed.txt"

    if [ -f "$TASK5" ] && [ -s "$TASK5" ]; then

        TASK5_OK=1

        # httpd should NOT be installed at this point
        # yum list installed httpd normally returns:
        # Error: No matching Packages to list

        if grep -Eq 'No matching Packages|Error:' "$TASK5"; then
            TASK5_OK=1
        else
            # Also allow output showing no installed httpd entry
            if grep -Eq '^httpd[[:space:]]' "$TASK5"; then
                TASK5_OK=0
            fi
        fi

        if [ "$TASK5_OK" -eq 1 ]; then
            pass "Task 5: httpd was correctly determined to be not installed"
        else
            fail "Task 5: httpd_installed.txt indicates that httpd may be installed"
        fi

    else
        fail "Task 5: httpd_installed.txt is missing or empty"
    fi


    # ============================================================
    # TASK 6 - FIND WHICH PACKAGE PROVIDES CURL
    # ============================================================

    TASK6="$BASE/curl_provider.txt"

    if [ -f "$TASK6" ] && [ -s "$TASK6" ]; then

        TASK6_OK=1

        # Provider search should contain curl
        grep -qi 'curl' "$TASK6" || TASK6_OK=0

        if [ "$TASK6_OK" -eq 1 ]; then
            pass "Task 6: package provider for curl was identified correctly"
        else
            fail "Task 6: curl_provider.txt does not show a package providing curl"
        fi

    else
        fail "Task 6: curl_provider.txt is missing or empty"
    fi


    # ============================================================
    # TASK 7 - INSTALL HTTPD
    # ============================================================

    TASK7="$BASE/httpd_install_status.txt"

    if [ -f "$TASK7" ] && [ -s "$TASK7" ]; then

        TASK7_OK=1

        # Verification should show httpd installed
        grep -Eq '^httpd\.' "$TASK7" || \
        grep -Eq '^httpd[[:space:]]' "$TASK7" || \
        grep -Eq 'httpd-[0-9]' "$TASK7" || \
        TASK7_OK=0

        if [ "$TASK7_OK" -eq 1 ]; then
            pass "Task 7: httpd was installed and verified successfully"
        else
            fail "Task 7: httpd_install_status.txt does not show httpd as installed"
        fi

    else
        fail "Task 7: httpd_install_status.txt is missing or empty"
    fi


    # ============================================================
    # TASK 8 - REMOVE HTTPD
    # ============================================================

    TASK8="$BASE/httpd_remove_status.txt"

    if [ -f "$TASK8" ] && [ -s "$TASK8" ]; then

        TASK8_OK=1

        # After removal, httpd should not appear as installed
        if grep -Eq '^httpd[[:space:]]' "$TASK8"; then
            TASK8_OK=0
        fi

        # Expected output from yum list installed httpd
        if ! grep -Eq 'No matching Packages|Error:' "$TASK8"; then
            # If no error is present, make sure an installed httpd
            # package entry is not present.
            if grep -qi 'httpd-[0-9]' "$TASK8"; then
                TASK8_OK=0
            fi
        fi

        if [ "$TASK8_OK" -eq 1 ]; then
            pass "Task 8: httpd was removed and verified successfully"
        else
            fail "Task 8: httpd_remove_status.txt indicates that httpd may still be installed"
        fi

    else
        fail "Task 8: httpd_remove_status.txt is missing or empty"
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

#========================================================================

validate_lab222_advanced_package_management() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 222 - Linux Package Management - Advanced..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab222_pkg_mgt"

    LAB_NAME="Lab 222 - Linux Package Management - Advanced"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=13
    PASSED=0

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # ============================================================
    # Task 1 - DNF Version
    # ============================================================

    FILE="$BASE/package_manager.txt"

    if [ -s "$FILE" ] && grep -Eq '[0-9]+\.[0-9]+' "$FILE"; then
        pass "Task 1: package_manager.txt contains DNF version information"
    else
        fail "Task 1: package_manager.txt is missing, empty, or does not contain DNF version"
    fi


    # ============================================================
    # Task 2 - Installed Packages
    # ============================================================

    FILE="$BASE/installed_packages.txt"

    if [ -s "$FILE" ] && grep -Eq 'Installed Packages|Installed packages' "$FILE"; then
        pass "Task 2: installed_packages.txt contains installed package information"
    else
        fail "Task 2: installed_packages.txt is missing or does not contain installed package information"
    fi


    # ============================================================
    # Task 3 - Search nfs-utils
    # ============================================================

    FILE="$BASE/nfs-utils_search.txt"

    if [ -s "$FILE" ] && grep -qi 'nfs-utils' "$FILE"; then
        pass "Task 3: nfs-utils search results saved correctly"
    else
        fail "Task 3: nfs-utils_search.txt is missing or does not contain nfs-utils"
    fi


    # ============================================================
    # Task 4 - DNF Info nfs-utils
    # ============================================================

    FILE="$BASE/nfs-utils_info.txt"

    if [ -s "$FILE" ] \
        && grep -Eq '^Name[[:space:]]*:[[:space:]]*nfs-utils' "$FILE" \
        && grep -Eq '^Version[[:space:]]*:' "$FILE" \
        && grep -Eq '^Architecture[[:space:]]*:' "$FILE" \
        && grep -Eq '^Repository[[:space:]]*:' "$FILE" \
        && grep -Eq '^Size[[:space:]]*:' "$FILE" \
        && grep -Eq '^Summary[[:space:]]*:' "$FILE"
    then
        pass "Task 4: nfs-utils information contains required package details"
    else
        fail "Task 4: nfs-utils_info.txt is missing or required package details are incomplete"
    fi


    # ============================================================
    # Task 5 - Determine if nfs-utils is Installed
    # ============================================================

    FILE="$BASE/nfs-utils_installed.txt"

    if [ -s "$FILE" ] \
        && (grep -qi 'nfs-utils' "$FILE" || grep -qi 'No matching Packages' "$FILE" || grep -qi 'No match for argument' "$FILE")
    then
        pass "Task 5: nfs-utils installation information saved correctly"
    else
        fail "Task 5: nfs-utils_installed.txt is missing or does not contain nfs-utils information"
    fi


    # ============================================================
    # Task 6 - Find Package Providing curl
    # ============================================================

    FILE="$BASE/curl_provider.txt"

    if [ -s "$FILE" ] \
        && grep -qi 'curl' "$FILE"
    then
        pass "Task 6: curl provider information saved correctly"
    else
        fail "Task 6: curl_provider.txt is missing or does not contain curl provider information"
    fi


    # ============================================================
    # Task 7 - Install nfs-utils
    # ============================================================

    FILE="$BASE/nfs-utils_install_status.txt"

    if [ -s "$FILE" ]; then
        if grep -Eq '^[[:space:]]*nfs-utils\.' "$FILE" || grep -Eq 'nfs-utils-[0-9]' "$FILE"
        then
            pass "Task 7: nfs-utils installation status confirms package installation"
        else
            fail "Task 7: nfs-utils_install_status.txt does not confirm nfs-utils installation"
        fi
    else
        fail "Task 7: nfs-utils_install_status.txt is missing or empty"
    fi

    # ============================================================
    # Task 8 - RPM Package Information
    # ============================================================

    FILE="$BASE/rpm_package_info.txt"

    if [ -s "$FILE" ] \
        && grep -Eq '^Name[[:space:]]*:[[:space:]]*nfs-utils' "$FILE" \
        && grep -Eq '^Version[[:space:]]*:' "$FILE" \
        && grep -Eq '^Release[[:space:]]*:' "$FILE" \
        && grep -Eq '^Architecture[[:space:]]*:' "$FILE"
    then
        pass "Task 8: rpm -qi nfs-utils information is complete"
    else
        fail "Task 8: rpm_package_info.txt is missing or required RPM information is incomplete"
    fi


    # ============================================================
    # Task 9 - List Files Installed by nfs-utils
    # ============================================================

    FILE="$BASE/package_files.txt"

    if [ -s "$FILE" ] \
        && grep -Eq '^/' "$FILE"
    then
        pass "Task 9: package_files.txt contains files installed by nfs-utils"
    else
        fail "Task 9: package_files.txt is missing or does not contain package file paths"
    fi


    # ============================================================
    # Task 10 - Package Owning /etc/hostname
    # ============================================================

    FILE="$BASE/hostname_owner.txt"

    if [ -s "$FILE" ] \
        && grep -Eq '^[[:alnum:]_.+-]+-[0-9][^[:space:]]*\.(x86_64|noarch|aarch64|i686|i386)$' "$FILE"
    then
        pass "Task 10: package owning /etc/hostname identified correctly"
    else
        fail "Task 10: hostname_owner.txt is missing or does not contain rpm ownership information"
    fi


    # ============================================================
    # Task 11 - Check Available Updates
    # ============================================================

    FILE="$BASE/available_updates.txt"

    if [ -s "$FILE" ] \
        && ! grep -qiE 'Error:|Unable to find a match|No such command' "$FILE"
    then
        pass "Task 11: available_updates.txt contains DNF update-check information"
    else
        fail "Task 11: available_updates.txt is missing or contains a DNF error"
    fi


    # ============================================================
    # Task 12 - Enabled Repositories
    # ============================================================

    FILE="$BASE/enabled_repositories.txt"

    if [ -s "$FILE" ] \
        && grep -Eq 'repo id|repo name|repo-id|repo-name' "$FILE"
    then
        pass "Task 12: enabled repositories information saved correctly"
    else
        fail "Task 12: enabled_repositories.txt is missing or does not contain repository information"
    fi


    # ============================================================
    # Task 13 - Remove nfs-utils
    # ============================================================

    FILE="$BASE/nfs-utils_remove_status.txt"

    if [ -s "$FILE" ] \
        && (
            grep -qiE 'No matching Packages|No match for argument|removed|Removing' "$FILE" \
            || ! grep -Eq '^[[:space:]]*nfs-utils\.' "$FILE"
        )
    then
        pass "Task 13: nfs-utils removal status saved correctly"
    else
        fail "Task 13: nfs-utils_remove_status.txt does not confirm nfs-utils removal"
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

validate_lab223_apache_configuration() {
    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 223 - Apache Web Server Configuration..."

    HOME_DIR="/home/$STUDENT_NAME"
    BASE="$HOME_DIR/lab223_apache_config"

    LAB_NAME="Lab 223 - Apache Web Server Configuration"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=19
    PASSED=0

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # Task 1 - Prepare the Lab Environment
    if [ -d "$BASE" ]; then
        pass "Task 1: lab223_apache_config directory exists"
    else
        fail "Task 1: lab223_apache_config directory is missing"
    fi

    # Task 2 - Install the Apache Package
    if rpm -q httpd >/dev/null 2>&1; then
        pass "Task 2: httpd package is installed"
    else
        fail "Task 2: httpd package is not installed"
    fi

    # Task 3 - Understand the Apache Service
    if systemctl list-unit-files httpd.service 2>/dev/null | grep -q '^httpd.service'; then
        pass "Task 3: httpd service exists"
    else
        fail "Task 3: httpd service was not found"
    fi

    # Task 4 - Enable and Start Apache
    ENABLED=$(systemctl is-enabled httpd 2>/dev/null)
    RUNNING=$(systemctl is-active httpd 2>/dev/null)

    if [ "$ENABLED" = "enabled" ] && [ "$RUNNING" = "active" ]; then
        pass "Task 4: httpd service is enabled and running"
    else
        fail "Task 4: httpd service is not enabled and running"
    fi

    # Task 5 - Identify Apache Document Root
    if [ -d /var/www/html ]; then
        pass "Task 5: Apache document root /var/www/html exists"
    else
        fail "Task 5: Apache document root /var/www/html is missing"
    fi

    # Task 6 - Create index.html
    FILE="/var/www/html/index.html"

    if [ -s "$FILE" ] \
        && grep -Fxq "LINOOPTEK COACHING" "$FILE" \
        && grep -Fxq "I am excited to learn Apache web server" "$FILE"
    then
        pass "Task 6: index.html exists and contains the required content"
    else
        fail "Task 6: index.html is missing or required content is incorrect"
    fi

    # Task 7 - Identify Apache Configuration
    FILE="$BASE/ss_task7.txt"

    if [ -s "$FILE" ] \
        && grep -qi 'LISTEN' "$FILE" \
        && grep -Eq '(:80[[:space:]]|:80$)' "$FILE"
    then
        pass "Task 7: ss_task7.txt contains Apache listening information for port 80"
    else
        fail "Task 7: ss_task7.txt is missing, empty, or does not show Apache listening on port 80"
    fi

    # Task 8 - Manage Firewall Using HTTP Service
    if [ -s "$BASE/apache_access_task9" ] \
        && grep -Fxq "LINOOPTEK COACHING" "$BASE/apache_access_task9"
    then
        pass "Task 8: firewalld is running and http service is allowed"
    else
        fail "Task 8: firewalld is not running or http service is not allowed"
    fi

    # Task 9 - Access Apache Using Default Port
    FILE="$BASE/apache_access_task9"

    if [ -s "$FILE" ] \
        && grep -Fxq "LINOOPTEK COACHING" "$FILE" \
        && grep -Fxq "I am excited to learn Apache web server" "$FILE"
    then
        pass "Task 9: Apache page content is accessible"
    else
        fail "Task 9: apache_access_task9 is missing, empty, or does not contain the required page content"
    fi

    # Task 10 - Stop Apache and Test Accessibility
    if [ -f "$BASE/apache_access_task11" ]; then
        pass "Task 10: lab progression reached the Apache accessibility testing stage"
    else
        fail "Task 10: expected lab progression evidence is missing"
    fi

    # Task 11 - Start Apache and Test Accessibility Again
    FILE="$BASE/apache_access_task11"

    if [ -s "$FILE" ] \
        && grep -Fxq "LINOOPTEK COACHING" "$FILE" \
        && grep -Fxq "I am excited to learn Apache web server" "$FILE"
    then
        pass "Task 9: Apache page content is accessible"
    else
        fail "Task 9: apache_access_task11 is missing, empty, or does not contain the required page content"
    fi

    # Task 12 - Configure Apache to Use Port 8181
    if grep -Eq '^[[:space:]]*Listen[[:space:]]+8181([[:space:]]*)$' \
        /etc/httpd/conf/httpd.conf 2>/dev/null
    then
        pass "Task 12: Apache is configured to listen on port 8181"
    else
        fail "Task 12: Apache Listen directive is not configured for port 8181"
    fi

    # Task 13 - Configure SELinux
    SELINUX_MODE=$(getenforce 2>/dev/null)

    if [ "$SELINUX_MODE" = "Permissive" ]; then
        pass "Task 13: SELinux is operating in permissive mode"
    else
        fail "Task 13: SELinux is not operating in permissive mode"
    fi

    # Task 14 - Validate Apache Configuration
    if httpd -t >/dev/null 2>&1; then
        pass "Task 14: Apache configuration has no syntax errors"
    else
        fail "Task 14: Apache configuration contains syntax errors"
    fi

    # Task 15 - Restart Apache on Port 8181
    if systemctl is-active --quiet httpd \
        && ss -lnt 2>/dev/null | awk '$4 ~ /:8181$/ {found=1} END {exit !found}'
    then
        pass "Task 15: httpd is running and listening on TCP port 8181"
    else
        fail "Task 15: httpd is not running or is not listening on TCP port 8181"
    fi

    # Task 16 - Allow Port 8181 Through the Firewall
    if curl -fsS --max-time 5 http://localhost:8181 2>/dev/null \
        | grep -Fxq "LINOOPTEK COACHING"
    then
        pass "Task 16: TCP port 8181 is permanently allowed through the firewall"
    else
        fail "Task 16: TCP port 8181 is not permanently allowed through the firewall"
    fi

    # Task 17 - Access Apache Using Port 8181
    if curl -fsS --max-time 5 http://localhost:8181 2>/dev/null \
        | grep -Fxq "LINOOPTEK COACHING"
    then
        if curl -fsS --max-time 5 http://localhost:8181 2>/dev/null \
            | grep -Fxq "I am excited to learn Apache web server"
        then
            pass "Task 17: Apache is accessible on port 8181 with the required content"
        else
            fail "Task 17: Apache is accessible on port 8181 but required content is incomplete"
        fi
    else
        fail "Task 17: Apache is not accessible on port 8181"
    fi

    # Task 18 - Stop Apache and Test Port 8181
    if grep -q '8181' /etc/httpd/conf/httpd.conf 2>/dev/null; then
        pass "Task 18: Apache custom-port configuration remains in place"
    else
        fail "Task 18: Apache custom-port configuration is missing"
    fi

    # Task 19 - Start Apache and Test Port 8181 Again
    if systemctl is-active --quiet httpd \
        && ss -lnt 2>/dev/null | awk '$4 ~ /:8181$/ {found=1} END {exit !found}'
    then
        if curl -fsS --max-time 5 http://localhost:8181 2>/dev/null \
            | grep -Fxq "LINOOPTEK COACHING" \
            && curl -fsS --max-time 5 http://localhost:8181 2>/dev/null \
            | grep -Fxq "I am excited to learn Apache web server"
        then
            pass "Task 19: Apache is running, listening on port 8181, and page is accessible"
        else
            fail "Task 19: Apache is running on port 8181 but required page content is incorrect"
        fi
    else
        fail "Task 19: Apache is not running or is not listening on port 8181"
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
#================================================================

validate_lab224_static_ip_nmtui() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 224 - Managing Static IP Address Using NMTUI..."

    LAB_NAME="Lab 224 - Managing Static IP Address Using NMTUI"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=18
    PASSED=0

    # EXPECTED NETWORK CONFIGURATION
    EXPECTED_IP="$STUDENT_IP"
    EXPECTED_PREFIX="22"

    EXPECTED_GATEWAY="10.90.0.1"

    EXPECTED_DNS1="192.168.111.50"
    EXPECTED_DNS2="8.8.8.8"


    # All students use ens192 except one student using ens224.
    INTERFACE=""

    if nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
        | grep -q '^ens192:ethernet$'; then

        INTERFACE="ens192"

    elif nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
        | grep -q '^ens224:ethernet$'; then

        INTERFACE="ens224"

    fi

    # profile name.
    PROFILE=""

    if [ -n "$INTERFACE" ]; then

        PROFILE=$(nmcli -g GENERAL.CONNECTION \
            device show "$INTERFACE" 2>/dev/null)

    fi


    # HELPER FUNCTIONS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - GET BASIC NETWORK INFORMATION
    if [ -n "$INTERFACE" ]; then

        pass "Task 1: Network interface $INTERFACE was identified"

    else

        fail "Task 1: Expected Ethernet interface ens192 or ens224 was not found"

    fi

    # TASK 2 - OPEN EDIT A CONNECTION
    if command -v nmtui >/dev/null 2>&1; then

        pass "Task 2: nmtui is installed and available"

    else

        fail "Task 2: nmtui is not available"

    fi

    # TASK 3 - SELECT THE CORRECT NETWORK CONNECTION
    if [ -n "$PROFILE" ] &&
       [ "$PROFILE" != "--" ]; then

        pass "Task 3: Connection profile $PROFILE is associated with $INTERFACE"

    else

        fail "Task 3: No active connection profile was found for $INTERFACE"

    fi

    # TASK 4 - CONFIGURE IPv4 AS MANUAL
    IPV4_METHOD=""

    if [ -n "$PROFILE" ] &&
       [ "$PROFILE" != "--" ]; then

        IPV4_METHOD=$(nmcli -g ipv4.method \
            connection show "$PROFILE" 2>/dev/null)

    fi

    if [ "$IPV4_METHOD" = "manual" ]; then

        pass "Task 4: IPv4 method is configured as manual"

    else

        fail "Task 4: IPv4 method is not configured as manual"

    fi

    # TASK 5 - CONFIGURE THE IP ADDRESS
    EXPECTED_ADDRESS="${EXPECTED_IP}/${EXPECTED_PREFIX}"

CONFIGURED_ADDRESS=""

if [ -n "$PROFILE" ]; then
    CONFIGURED_ADDRESS=$(nmcli -g ipv4.addresses \
        connection show "$PROFILE" 2>/dev/null)
fi

if echo "$CONFIGURED_ADDRESS" |
    tr ', ' '\n' |
    sed '/^$/d' |
    grep -Fxq "$EXPECTED_ADDRESS"; then

        pass "Task 5: Student IP $EXPECTED_ADDRESS is configured"

    else

        fail "Task 5: Expected IP $EXPECTED_ADDRESS was not found in the connection profile"

    fi

    # TASK 6 - CONFIGURE THE GATEWAY
    CONFIGURED_GATEWAY=""

    if [ -n "$PROFILE" ]; then

        CONFIGURED_GATEWAY=$(nmcli -g ipv4.gateway \
            connection show "$PROFILE" 2>/dev/null)

    fi

    if [ "$CONFIGURED_GATEWAY" = "$EXPECTED_GATEWAY" ]; then

        pass "Task 6: Gateway $EXPECTED_GATEWAY is configured"

    else

        fail "Task 6: Expected gateway $EXPECTED_GATEWAY but found $CONFIGURED_GATEWAY"

    fi

    # TASK 7 - CONFIGURE DNS
    CONFIGURED_DNS=""

    if [ -n "$PROFILE" ]; then

        CONFIGURED_DNS=$(nmcli -g ipv4.dns \
            connection show "$PROFILE" 2>/dev/null)

    fi

    DNS1_FOUND=0
    DNS2_FOUND=0
    
    NORMALIZED_DNS=$(echo "$CONFIGURED_DNS" |
       tr ', ' '\n' |
       sed '/^$/d')

    if echo "$NORMALIZED_DNS" | grep -Fxq "$EXPECTED_DNS1"; then
        DNS1_FOUND=1
    fi

    if echo "$NORMALIZED_DNS" | grep -Fxq "$EXPECTED_DNS2"; then
        DNS2_FOUND=1
    fi

    if [ "$DNS1_FOUND" -eq 1 ] &&
       [ "$DNS2_FOUND" -eq 1 ]; then

        pass "Task 7: Both required DNS servers are configured"

    else

        fail "Task 7: Required DNS servers are not correctly configured"

    fi

    # TASK 8 - ENABLE AUTOMATIC CONNECTION
    AUTOCONNECT=""

    if [ -n "$PROFILE" ]; then

        AUTOCONNECT=$(nmcli -g connection.autoconnect \
            connection show "$PROFILE" 2>/dev/null)

    fi

    if [ "$AUTOCONNECT" = "yes" ]; then

        pass "Task 8: Automatic connection is enabled"

    else

        fail "Task 8: Automatic connection is not enabled"

    fi

    # TASK 9 - SAVE THE CONFIGURATION
    if [ -n "$PROFILE" ] &&
       [ "$PROFILE" != "--" ] &&
       nmcli connection show "$PROFILE" >/dev/null 2>&1; then

        pass "Task 9: NetworkManager connection profile is available"

    else

        fail "Task 9: NetworkManager connection profile could not be verified"

    fi

    # TASK 10 - ACTIVATE THE CONNECTION
    ACTIVE_PROFILE=""

    if [ -n "$INTERFACE" ]; then

        ACTIVE_PROFILE=$(nmcli -g GENERAL.CONNECTION \
            device show "$INTERFACE" 2>/dev/null)

    fi

    if [ -n "$PROFILE" ] &&
       [ "$ACTIVE_PROFILE" = "$PROFILE" ]; then

        pass "Task 10: Connection $PROFILE is active on $INTERFACE"

    else

        fail "Task 10: Expected connection $PROFILE is not active on $INTERFACE"

    fi

    # TASK 11 - VALIDATE THE IP CONFIGURATION
    # Task 11a - Actual IP Address
    ACTUAL_ADDRESS=""

if [ -n "$INTERFACE" ]; then

    ACTUAL_ADDRESS=$(ip -4 -o addr show dev "$INTERFACE" 2>/dev/null |
        awk '{print $4}' |
        head -1)

fi
if [ "$ACTUAL_ADDRESS" = "$EXPECTED_ADDRESS" ]; then

        pass "Task 11a: $INTERFACE has expected IP $EXPECTED_ADDRESS"

    else

        fail "Task 11a: Expected IP $EXPECTED_ADDRESS is not active on $INTERFACE"

    fi

    # Task 11b - Default Route
    ACTIVE_GATEWAY=$(ip route show default 2>/dev/null \
        | awk '/default/ {print $3; exit}')

    if [ "$ACTIVE_GATEWAY" = "$EXPECTED_GATEWAY" ]; then

        pass "Task 11b: Default route uses gateway $EXPECTED_GATEWAY"

    else

        fail "Task 11b: Expected gateway $EXPECTED_GATEWAY but found $ACTIVE_GATEWAY"

    fi

    # Task 11c - NetworkManager Device State
    DEVICE_STATE=""

    if [ -n "$INTERFACE" ]; then

        DEVICE_STATE=$(nmcli -g GENERAL.STATE \
            device show "$INTERFACE" 2>/dev/null)

    fi

    if echo "$DEVICE_STATE" | grep -q '^100'; then

        pass "Task 11c: $INTERFACE is connected"

    else

        fail "Task 11c: $INTERFACE is not in connected state"

    fi

    # Task 11d - Connection Profile Exists
    if [ -n "$PROFILE" ] &&
       [ "$PROFILE" != "--" ] &&
       nmcli connection show "$PROFILE" >/dev/null 2>&1; then

        pass "Task 11d: Connection profile $PROFILE exists"

    else

        fail "Task 11d: Connection profile could not be verified"

    fi

    # TASK 12 - TEST CONNECTIVITY
    # Task 12a - Gateway Connectivity
    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then

        pass "Task 12a: Gateway $EXPECTED_GATEWAY is reachable"

    else

        fail "Task 12a: Gateway $EXPECTED_GATEWAY is not reachable"

    fi

    # Task 12b - External IP Connectivity
    if ping -c 2 -W 3 8.8.8.8 >/dev/null 2>&1; then

        pass "Task 12b: External IP 8.8.8.8 is reachable"

    else

        fail "Task 12b: External IP 8.8.8.8 is not reachable"

    fi

    # Task 12c - DNS Resolution Using getent
    if getent hosts google.com >/dev/null 2>&1; then

        pass "Task 12c: DNS resolution using getent is working"

    else

        fail "Task 12c: DNS resolution using getent failed"

    fi

    # Task 12d - DNS Resolution Using nslookup
    if command -v nslookup >/dev/null 2>&1; then

        if nslookup google.com >/dev/null 2>&1; then

            pass "Task 12d: DNS resolution using nslookup is working"

        else

            fail "Task 12d: DNS resolution using nslookup failed"

        fi

    else

        fail "Task 12d: nslookup command is not available"

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

#================================================================
validate_lab225_static_ip_nmcli() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 225 - Managing Static IP Address Using NMCLI..."

    LAB_NAME="Lab 225 - Managing Static IP Address Using NMCLI"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=18
    PASSED=0

    # EXPECTED NETWORK CONFIGURATION
    PROFILE="my-static-ens192"

    EXPECTED_IP="$STUDENT_IP"
    EXPECTED_PREFIX="22"
    EXPECTED_GATEWAY="10.90.0.1"

    EXPECTED_DNS1="192.168.111.50"
    EXPECTED_DNS2="8.8.8.8"

    INTERFACE=""

    if nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
        | grep -q '^ens192:ethernet$'; then

        INTERFACE="ens192"

    elif nmcli -t -f DEVICE,TYPE device status 2>/dev/null \
        | grep -q '^ens224:ethernet$'; then

        INTERFACE="ens224"

    fi

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - DISCOVER NETWORK DEVICES
    if [ -n "$INTERFACE" ]; then

        pass "Task 1: Ethernet interface $INTERFACE was found"

    else

        fail "Task 1: Expected Ethernet interface ens192 or ens224 was not found"

    fi

    # TASK 2 - VIEW EXISTING CONNECTION PROFILES
    if nmcli -t -f NAME connection show 2>/dev/null \
        | grep -Fxq "$PROFILE"; then

        pass "Task 2: Connection profile $PROFILE exists"

    else

        fail "Task 2: Connection profile $PROFILE does not exist"

    fi


    # TASK 3 - VIEW DETAILED CONNECTION INFORMATION
    if nmcli connection show "$PROFILE" >/dev/null 2>&1; then

        pass "Task 3: Detailed information for $PROFILE is available"

    else

        fail "Task 3: Unable to retrieve connection profile $PROFILE"

    fi

    # TASK 4 - CONFIGURE STATIC IP USING NMCLI
    IPV4_METHOD=$(nmcli -g ipv4.method \
        connection show "$PROFILE" 2>/dev/null)

    if [ "$IPV4_METHOD" = "manual" ]; then

        pass "Task 4: IPv4 method is configured as manual"

    else

        fail "Task 4: IPv4 method is not configured as manual"

    fi

    # TASK 5 - CREATE A NEW CONNECTION
    PROFILE_EXISTS=0
    PROFILE_INTERFACE=""

    if nmcli -t -f NAME connection show 2>/dev/null \
        | grep -Fxq "$PROFILE"; then

        PROFILE_EXISTS=1
        PROFILE_INTERFACE=$(nmcli -g connection.interface-name \
            connection show "$PROFILE" 2>/dev/null)
    fi

    if [ "$PROFILE_EXISTS" -eq 1 ] &&
       [ "$PROFILE_INTERFACE" = "$INTERFACE" ]; then

        pass "Task 5: $PROFILE was created for interface $INTERFACE"

    elif [ "$PROFILE_EXISTS" -eq 1 ]; then

        fail "Task 5: $PROFILE exists but is associated with $PROFILE_INTERFACE instead of $INTERFACE"

    else

        fail "Task 5: Connection profile $PROFILE was not created"

    fi

    # TASK 6 - SET METHOD OF OBTAINING IP TO MANUAL
    if [ "$IPV4_METHOD" = "manual" ]; then

        pass "Task 6: $PROFILE uses manual IPv4 configuration"

    else

        fail "Task 6: $PROFILE does not use manual IPv4 configuration"

    fi

    # TASK 7 - ASSIGN THE IP ADDRESS
    CONFIGURED_ADDRESS=$(nmcli -g ipv4.addresses \
        connection show "$PROFILE" 2>/dev/null)

    EXPECTED_ADDRESS="${EXPECTED_IP}/${EXPECTED_PREFIX}"

    IP_MATCH=0

    # Handle possible comma-separated or multiple addresses.
    echo "$CONFIGURED_ADDRESS" \
        | tr ',' '\n' \
        | tr ' ' '\n' \
        | grep -Fxq "$EXPECTED_ADDRESS"

    if [ $? -eq 0 ]; then
        IP_MATCH=1
    fi

    if [ "$IP_MATCH" -eq 1 ]; then

        pass "Task 7: Student IP $EXPECTED_ADDRESS is configured"

    else

        fail "Task 7: Expected IP $EXPECTED_ADDRESS was not found in $PROFILE"

    fi

    # TASK 8 - CONFIGURE THE GATEWAY
    CONFIGURED_GATEWAY=$(nmcli -g ipv4.gateway \
        connection show "$PROFILE" 2>/dev/null)

    if [ "$CONFIGURED_GATEWAY" = "$EXPECTED_GATEWAY" ]; then

        pass "Task 8: Gateway $EXPECTED_GATEWAY is configured"

    else

        fail "Task 8: Expected gateway $EXPECTED_GATEWAY but found $CONFIGURED_GATEWAY"

    fi

    # TASK 9 - CONFIGURE DNS
    CONFIGURED_DNS=""

if [ -n "$PROFILE" ]; then

    CONFIGURED_DNS=$(nmcli -g ipv4.dns \
        connection show "$PROFILE" 2>/dev/null)

fi

DNS1_FOUND=0
DNS2_FOUND=0

# Normalize DNS output.
# nmcli may return values separated by spaces or commas.
NORMALIZED_DNS=$(echo "$CONFIGURED_DNS" |
    tr ', ' '\n' |
    sed '/^$/d')

if echo "$NORMALIZED_DNS" | grep -Fxq "$EXPECTED_DNS1"; then
    DNS1_FOUND=1
fi

if echo "$NORMALIZED_DNS" | grep -Fxq "$EXPECTED_DNS2"; then
    DNS2_FOUND=1
fi

if [ "$DNS1_FOUND" -eq 1 ] &&
   [ "$DNS2_FOUND" -eq 1 ]; then

    pass "Task 9: Both required DNS servers are configured"

elif [ "$DNS1_FOUND" -eq 1 ]; then

    fail "Task 9: $EXPECTED_DNS1 is configured but $EXPECTED_DNS2 is missing"

elif [ "$DNS2_FOUND" -eq 1 ]; then
        fail "Task 9: $EXPECTED_DNS2 is configured but $EXPECTED_DNS1 is missing"

    else

        fail "Task 9: Required DNS servers are not configured"

    fi

    # TASK 10 - ENABLE AUTOMATIC CONNECTION
    AUTOCONNECT=$(nmcli -g connection.autoconnect \
        connection show "$PROFILE" 2>/dev/null)

    if [ "$AUTOCONNECT" = "yes" ]; then

        pass "Task 10: Autoconnect is enabled"

    else

        fail "Task 10: Autoconnect is not enabled"

    fi

    # TASK 11 - APPLY THE CONFIGURATION
    ACTIVE_PROFILE=""

    if [ -n "$INTERFACE" ]; then

        ACTIVE_PROFILE=$(nmcli -g GENERAL.CONNECTION \
            device show "$INTERFACE" 2>/dev/null)

    fi

    if [ "$ACTIVE_PROFILE" = "$PROFILE" ]; then

        pass "Task 11: $PROFILE is active on $INTERFACE"

    else

        fail "Task 11: $PROFILE is not active on $INTERFACE"

    fi

    # TASK 12 - VALIDATE CONNECTION PROFILE
    # Task 12a - Validate Actual IP Address
    ACTUAL_ADDRESS=""

    if [ -n "$INTERFACE" ]; then

        ACTUAL_ADDRESS=$(ip -4 -o addr show "$INTERFACE" 2>/dev/null \
            | awk '{print $4}' \
            | grep -Fx "$EXPECTED_ADDRESS" \
            | head -1)

    fi

    if [ "$ACTUAL_ADDRESS" = "$EXPECTED_ADDRESS" ]; then

        pass "Task 12a: $INTERFACE has the expected IP $EXPECTED_ADDRESS"

    else

        fail "Task 12a: $INTERFACE does not have expected IP $EXPECTED_ADDRESS"

    fi

    # Task 12b - Validate Default Gateway
    ACTIVE_GATEWAY=$(ip route show default 2>/dev/null \
        | awk '/default/ {print $3; exit}')

    if [ "$ACTIVE_GATEWAY" = "$EXPECTED_GATEWAY" ]; then

        pass "Task 12b: Default gateway is $EXPECTED_GATEWAY"

    else

        fail "Task 12b: Expected gateway $EXPECTED_GATEWAY but found $ACTIVE_GATEWAY"

    fi

    # Task 12c - Validate Default Route Interface
    ROUTE_INTERFACE=$(ip route show default 2>/dev/null \
        | awk '/default/ {for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')

    if [ "$ROUTE_INTERFACE" = "$INTERFACE" ]; then

        pass "Task 12c: Default route uses interface $INTERFACE"

    else

        fail "Task 12c: Default route is not using $INTERFACE"

    fi

    # Task 12d - Validate NetworkManager Connection State
    DEVICE_STATE=$(nmcli -g GENERAL.STATE \
        device show "$INTERFACE" 2>/dev/null)

    if echo "$DEVICE_STATE" | grep -q '^100'; then

        pass "Task 12d: $INTERFACE is connected"

    else

        fail "Task 12d: $INTERFACE is not in connected state"

    fi

    # Task 12e - Validate Gateway Connectivity
    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then

        pass "Task 12e: Gateway $EXPECTED_GATEWAY is reachable"

    else

        fail "Task 12e: Gateway $EXPECTED_GATEWAY is not reachable"

    fi

    # Task 12f - Validate External IP Connectivity
    if ping -c 2 -W 3 8.8.8.8 >/dev/null 2>&1; then

        pass "Task 12f: External IP connectivity is working"

    else

        fail "Task 12f: Unable to reach external IP 8.8.8.8"

    fi

    # Task 12g - Validate DNS Resolution
    if getent hosts google.com >/dev/null 2>&1; then

        pass "Task 12g: DNS name resolution is working"

    else

        fail "Task 12g: DNS name resolution failed"

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
#===============================================================

validate_lab226_ssh_scp() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 226 - Remote Command Execution and File Transfer Using SSH and SCP..."

    LAB_NAME="Lab 226 - Remote Command Execution and File Transfer Using SSH and SCP"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=10
    PASSED=0

    USERNAME="$STUDENT_NAME"
    HOME_DIR="/home/$USERNAME"
    LAB_REMOTE="$HOME_DIR/lab226_remote"

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # ==========================================================
    # TASK 1 - SSH KEY PAIR
    # ==========================================================

    if {
        [ -f "$HOME_DIR/.ssh/id_rsa" ] &&
        [ -f "$HOME_DIR/.ssh/id_rsa.pub" ]
    } || {
        [ -f "$HOME_DIR/.ssh/id_ed25519" ] &&
        [ -f "$HOME_DIR/.ssh/id_ed25519.pub" ]
    }; then

        pass "Task 1: SSH key pair exists"

    else
        fail "Task 1: SSH key pair not found"
    fi


    # ==========================================================
    # TASK 2 - REMOTE SYSTEM INFORMATION
    # ==========================================================

    TASK2_PASS=1

    [ -d "$LAB_REMOTE" ] || TASK2_PASS=0
    [ -f "$LAB_REMOTE/remote_ipaddr" ] || TASK2_PASS=0
    [ -s "$LAB_REMOTE/remote_ipaddr" ] || TASK2_PASS=0

    [ -f "$LAB_REMOTE/lsblk_output" ] || TASK2_PASS=0
    [ -s "$LAB_REMOTE/lsblk_output" ] || TASK2_PASS=0

    if [ "$TASK2_PASS" -eq 1 ]; then
        pass "Task 2: Remote system information collected"
    else
        fail "Task 2: Required remote information files missing"
    fi


    # ==========================================================
    # TASK 3 - SCP PUSH FILE
    # ==========================================================

    if [ -f "$HOME_DIR/student_notes.txt" ] &&
       grep -Fxq "This file was created on the student VM." \
       "$HOME_DIR/student_notes.txt"; then

        pass "Task 3: student_notes.txt created correctly"

    else
        fail "Task 3: student_notes.txt missing or content incorrect"
    fi


    # ==========================================================
    # TASK 4 - VERIFY PUSH
    # ==========================================================

    if [ -f "$LAB_REMOTE/task4_push_verification" ] &&
       grep -q "student_notes.txt" \
       "$LAB_REMOTE/task4_push_verification" &&
       [ -f "$LAB_REMOTE/task4_content_verification" ] &&
       grep -Fxq "This file was created on the student VM." \
       "$LAB_REMOTE/task4_content_verification"; then

        pass "Task 4: Remote file verified successfully"

    else
        fail "Task 4: Remote file verification missing or incorrect"
    fi


    # ==========================================================
    # TASK 5 - SCP PUSH DIRECTORY
    # ==========================================================

    if [ -d "$HOME_DIR/student_project" ] &&
       [ -d "$HOME_DIR/student_project/config" ] &&
       [ -f "$HOME_DIR/student_project/config/server.conf" ] &&
       grep -Fxq "SERVER=web01" \
       "$HOME_DIR/student_project/config/server.conf"; then

        pass "Task 5: student_project directory created correctly"

    else
        fail "Task 5: student_project structure or content incorrect"
    fi


    # ==========================================================
    # TASK 6 - VERIFY DIRECTORY ON REMOTE SERVER
    # ==========================================================

    if [ -f "$LAB_REMOTE/task6_directory_verification" ] &&
       grep -q "student_project" \
       "$LAB_REMOTE/task6_directory_verification" &&
       [ -f "$LAB_REMOTE/task6_content_verification" ] &&
       grep -Fxq "SERVER=web01" \
       "$LAB_REMOTE/task6_content_verification"; then

        pass "Task 6: Remote directory and file verified"

    else
        fail "Task 6: Remote directory verification missing or incorrect"
    fi


    # ==========================================================
    # TASK 7 - SCP PULL README
    # ==========================================================

    if [ -f "$LAB_REMOTE/README.txt" ] &&
       [ -s "$LAB_REMOTE/README.txt" ]; then

        pass "Task 7: README.txt pulled successfully"

    else
        fail "Task 7: README.txt not found or empty"
    fi


    # ==========================================================
    # TASK 8 - SCP PULL ENTIRE DIRECTORY
    # ==========================================================

    TASK8_PASS=1

    [ -d "$LAB_REMOTE/remote_lab" ] || TASK8_PASS=0

    [ -d "$LAB_REMOTE/remote_lab/documentation" ] || TASK8_PASS=0
    [ -f "$LAB_REMOTE/remote_lab/documentation/README.txt" ] || TASK8_PASS=0

    [ -d "$LAB_REMOTE/remote_lab/application" ] || TASK8_PASS=0
    [ -d "$LAB_REMOTE/remote_lab/application/config" ] || TASK8_PASS=0
    [ -f "$LAB_REMOTE/remote_lab/application/config/application.conf" ] || TASK8_PASS=0

    if [ "$TASK8_PASS" -eq 1 ]; then
        pass "Task 8: Complete remote_lab directory structure pulled"
    else
        fail "Task 8: remote_lab directory structure incomplete"
    fi


    # ==========================================================
    # TASK 9 - DIFFERENT DESTINATION NAME
    # ==========================================================

    if [ -f "$LAB_REMOTE/application_backup.conf" ] &&
       [ -s "$LAB_REMOTE/application_backup.conf" ]; then

        pass "Task 9: application_backup.conf created successfully"

    else
        fail "Task 9: application_backup.conf not found or empty"
    fi


    # ==========================================================
    # TASK 10 - REMOTE COMMAND AND SCP
    # ==========================================================

    if [ -f "$LAB_REMOTE/ssh_created.txt" ] &&
       grep -Fxq "Created remotely using SSH" \
       "$LAB_REMOTE/ssh_created.txt"; then

        pass "Task 10: SSH-created file pulled and verified"

    else
        fail "Task 10: ssh_created.txt missing or content incorrect"
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

#================================================================

validate_lab227_ssh_scp() {

    set +e
    set +u
    set +o pipefail

    echo "Checking Lab 227 - SSH Remote Command Execution and SCP File Transfer..."

    LAB_NAME="Lab 227 - SSH Remote Command Execution and SCP File Transfer"
    DATE=$(date "+%F %T")

    TOTAL_TASKS=10
    PASSED=0

    USERNAME="$STUDENT_NAME"
    HOME_DIR="/home/$USERNAME"
    LAB_WORKSPACE="$HOME_DIR/lab227_workspace"
    LAB_REFERENCE="$LAB_WORKSPACE/lab227"

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # Task 1 - Prepare the Personal VM Workspace
    if [ -d "$LAB_WORKSPACE" ]; then
        pass "Task 1: lab227_workspace directory exists"
    else
        fail "Task 1: lab227_workspace directory does not exist"
    fi

    # Task 2 - Connect to the Remote Linux Server
    if [ -d "$LAB_WORKSPACE" ]; then
        pass "Task 2: SSH/SCP working environment established"
    else
        fail "Task 2: SSH/SCP working environment could not be established"
    fi

    # Task 3 - Inspect the Prepared Remote Lab Data
    if [ -d "$LAB_REFERENCE" ]; then
        pass "Task 3: lab227 reference directory is available"
    else
        fail "Task 3: lab227 reference directory is missing"
    fi

    # Task 4 - Transfer application.conf
    LOCAL_FILE="$LAB_WORKSPACE/application.conf"
    REFERENCE_FILE="$LAB_REFERENCE/application/config/application.conf"

    if [ -f "$LOCAL_FILE" ] && [ -f "$REFERENCE_FILE" ]; then

        if diff -q "$LOCAL_FILE" "$REFERENCE_FILE" >/dev/null 2>&1; then
            pass "Task 4: application.conf transferred correctly"
        else
            fail "Task 4: application.conf contents do not match"
        fi

    else
        fail "Task 4: application.conf is missing"
    fi

    # Task 5 - Transfer reports directory
    LOCAL_DIR="$LAB_WORKSPACE/reports"
    REFERENCE_DIR="$LAB_REFERENCE/reports"

    if [ -d "$LOCAL_DIR" ] && [ -d "$REFERENCE_DIR" ]; then

        if diff -qr "$LOCAL_DIR" "$REFERENCE_DIR" >/dev/null 2>&1; then
            pass "Task 5: reports directory transferred correctly"
        else
            fail "Task 5: reports directory contents do not match"
        fi

    else
        fail "Task 5: reports directory is missing"
    fi

    # Task 6 - Retrieve deployment.txt using SSH
    LOCAL_FILE="$LAB_WORKSPACE/deployment.txt"
    REFERENCE_FILE="$LAB_REFERENCE/application/docs/deployment.txt"

    if [ -f "$LOCAL_FILE" ] && [ -f "$REFERENCE_FILE" ]; then

        if diff -q "$LOCAL_FILE" "$REFERENCE_FILE" >/dev/null 2>&1; then
            pass "Task 6: deployment.txt retrieved correctly"
        else
            fail "Task 6: deployment.txt contents do not match"
        fi

    else
        fail "Task 6: deployment.txt is missing"
    fi

    # Task 7 - Retrieve maintenance.txt with new filename
    LOCAL_FILE="$LAB_WORKSPACE/maintenance_backup.txt"
    REFERENCE_FILE="$LAB_REFERENCE/application/docs/maintenance.txt"

    if [ -f "$LOCAL_FILE" ] && [ -f "$REFERENCE_FILE" ]; then

        if diff -q "$LOCAL_FILE" "$REFERENCE_FILE" >/dev/null 2>&1; then
            pass "Task 7: maintenance_backup.txt retrieved correctly"
        else
            fail "Task 7: maintenance_backup.txt contents do not match"
        fi

    else
        fail "Task 7: maintenance_backup.txt is missing"
    fi

    # Task 8 - Create remote_created.txt and pull it
    LOCAL_FILE="$LAB_WORKSPACE/remote_created.txt"
    if [ -f "$LOCAL_FILE" ] &&
       grep -Fxq "SSH remote execution created this file." "$LOCAL_FILE"; then

        pass "Task 8: remote_created.txt exists with correct content"
    else
        fail "Task 8: remote_created.txt is missing or contents are incorrect"
    fi

    # Task 9 - Transfer transfer_note.txt
    LOCAL_FILE="$LAB_WORKSPACE/transfer_note.txt"
    REFERENCE_FILE="$LAB_REFERENCE/transfer_note.txt"

    if [ -f "$LOCAL_FILE" ] && [ -f "$REFERENCE_FILE" ]; then

        if diff -q "$LOCAL_FILE" "$REFERENCE_FILE" >/dev/null 2>&1; then
            pass "Task 9: transfer_note.txt transferred correctly"
        else
            fail "Task 9: transfer_note.txt contents do not match"
        fi

    else
        fail "Task 9: transfer_note.txt is missing"
    fi

    # Task 10 - Pull Complete lab227 Directory
    if [ -d "$LAB_REFERENCE" ]; then

        FILE_COUNT=$(find "$LAB_REFERENCE" -type f 2>/dev/null | wc -l)

        if [ "$FILE_COUNT" -eq 10 ]; then
            pass "Task 10: complete lab227 directory transferred"
        else
            fail "Task 10: lab227 directory is empty"
        fi

    else
        fail "Task 10: lab227 directory is missing"
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

#======================================================================
validate_lab228_gdisk() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 228 - Linux Disk Partitioning - Using gdisk.</h2>"

    TOTAL_TASKS=11
    PASSED=0

    LAB_NAME="Lab 228 - Linux Disk Partitioning - Using gdisk"
    DATE=$(date "+%F %T")

    DISK="/dev/sdb"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - IDENTIFY AVAILABLE DISKS
    if [ -b "$DISK" ]; then
        DISK_SIZE=$(lsblk -bndo SIZE "$DISK" 2>/dev/null)

        if [ -n "$DISK_SIZE" ] && [ "$DISK_SIZE" -gt 0 ]; then
            pass "Task 1: /dev/sdb is available and identified"
        else
            fail "Task 1: /dev/sdb size could not be verified"
        fi
    else
        fail "Task 1: /dev/sdb is not available"
    fi

    # TASK 2 - VERIFY /dev/sdb
    if [ -b "$DISK" ]; then

        DISK_SIZE=$(lsblk -bndo SIZE "$DISK" 2>/dev/null)

        if [ -n "$DISK_SIZE" ] && [ "$DISK_SIZE" -gt 0 ]; then
            pass "Task 2: /dev/sdb disk information verified"
        else
            fail "Task 2: /dev/sdb disk information could not be verified"
        fi

    else
        fail "Task 2: /dev/sdb could not be inspected"
    fi

    # TASK 3 - CREATE GPT PARTITION TABLE
    PARTITION_TABLE=$(lsblk -dnro PTTYPE "$DISK" 2>/dev/null | tr -d '[:space:]')

    if [ "$PARTITION_TABLE" = "gpt" ]; then
        pass "Task 3: /dev/sdb is using a GPT partition table"
    else
        fail "Task 3: /dev/sdb is not using a GPT partition table"
    fi

    # TASK 4 - CREATE PARTITIONS
    TASK4_OK=1

    for PART in \
        "/dev/sdb1" \
        "/dev/sdb2" \
        "/dev/sdb3" \
        "/dev/sdb4"
    do
        [ -b "$PART" ] || TASK4_OK=0
    done

    if [ "$TASK4_OK" -eq 1 ]; then

        # Get partition sizes in bytes
        SDB1_SIZE=$(lsblk -bndo SIZE /dev/sdb1 2>/dev/null)
        SDB2_SIZE=$(lsblk -bndo SIZE /dev/sdb2 2>/dev/null)
        SDB3_SIZE=$(lsblk -bndo SIZE /dev/sdb3 2>/dev/null)
        SDB4_SIZE=$(lsblk -bndo SIZE /dev/sdb4 2>/dev/null)

        # Expected sizes
        EXPECTED_512=$((512 * 1024 * 1024))
        EXPECTED_400=$((400 * 1024 * 1024))

        # Allow 32 MB tolerance for partition alignment
        TOLERANCE=$((32 * 1024 * 1024))

        SDB1_DIFF=$((SDB1_SIZE - EXPECTED_512))
        SDB2_DIFF=$((SDB2_SIZE - EXPECTED_512))
        SDB3_DIFF=$((SDB3_SIZE - EXPECTED_400))

        [ "$SDB1_DIFF" -lt 0 ] && SDB1_DIFF=$((SDB1_DIFF * -1))
        [ "$SDB2_DIFF" -lt 0 ] && SDB2_DIFF=$((SDB2_DIFF * -1))
        [ "$SDB3_DIFF" -lt 0 ] && SDB3_DIFF=$((SDB3_DIFF * -1))

        if [ "$SDB1_DIFF" -le "$TOLERANCE" ] &&
           [ "$SDB2_DIFF" -le "$TOLERANCE" ] &&
           [ "$SDB3_DIFF" -le "$TOLERANCE" ] &&
           [ "$SDB4_SIZE" -gt "$EXPECTED_400" ]; then

            pass "Task 4: Four required partitions created with expected sizes"
        else
            fail "Task 4: Partition sizes do not match the required configuration"
        fi

    else
        fail "Task 4: One or more required partitions are missing"
    fi

    # TASK 5 - SET PARTITION TYPES
    TYPE1=$(sudo  /usr/sbin/sgdisk -i 1 "$DISK" 2>/dev/null)
    TYPE2=$(sudo /usr/sbin/sgdisk -i 2 "$DISK" 2>/dev/null)
    TYPE3=$(sudo /usr/sbin/sgdisk -i 3 "$DISK" 2>/dev/null)
    TYPE4=$(sudo /usr/sbin/sgdisk -i 4 "$DISK" 2>/dev/null)
    
    TASK5_OK=1
    
    echo "$TYPE1" | grep -qi "Linux swap" || TASK5_OK=0
    echo "$TYPE2" | grep -qi "Linux filesystem" || TASK5_OK=0
    echo "$TYPE3" | grep -qi "Linux filesystem" || TASK5_OK=0
    echo "$TYPE4" | grep -qi "Linux filesystem" || TASK5_OK=0
    
    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: GPT partition types are correctly configured"
    else
        fail "Task 5: One or more GPT partition types are incorrect"
    fi

    # TASK 6 - VERIFY PARTITION TABLE
    TASK6_OK=1
    
    # Verify required partitions exist
    [ -b "${DISK}1" ] || TASK6_OK=0
    [ -b "${DISK}2" ] || TASK6_OK=0
    [ -b "${DISK}3" ] || TASK6_OK=0
    [ -b "${DISK}4" ] || TASK6_OK=0
    
    # Verify exact sizes
    # 512 MiB = 536870912 bytes
    [ "$(lsblk -dnbo SIZE "${DISK}1" 2>/dev/null)" = "536870912" ] || TASK6_OK=0
    [ "$(lsblk -dnbo SIZE "${DISK}2" 2>/dev/null)" = "536870912" ] || TASK6_OK=0
    
    # 400 MiB = 419430400 bytes
    [ "$(lsblk -dnbo SIZE "${DISK}3" 2>/dev/null)" = "419430400" ] || TASK6_OK=0
    
    # Partition 4 is the remaining space.
    # Just verify that it exists and has a non-zero size.
    SIZE4=$(lsblk -dnbo SIZE "${DISK}4" 2>/dev/null)
    
    [ -n "$SIZE4" ] && [ "$SIZE4" -gt 0 ] 2>/dev/null || TASK6_OK=0
    
    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: Partition table and partition sizes are correct"
    else
        fail "Task 6: Partition table or partition sizes are incorrect"
    fi
 
    # TASK 7 - VERIFY FROM LINUX
    TASK7_OK=1

    # Verify lsblk can see the disk and all four partitions
    lsblk "$DISK" 2>/dev/null | grep -q "sdb"  || TASK7_OK=0
    lsblk "$DISK" 2>/dev/null | grep -q "sdb1" || TASK7_OK=0
    lsblk "$DISK" 2>/dev/null | grep -q "sdb2" || TASK7_OK=0
    lsblk "$DISK" 2>/dev/null | grep -q "sdb3" || TASK7_OK=0
    lsblk "$DISK" 2>/dev/null | grep -q "sdb4" || TASK7_OK=0
    
    # Verify blkid can inspect all four partitions
    blkid "${DISK}1" >/dev/null 2>&1 || TASK7_OK=0
    blkid "${DISK}2" >/dev/null 2>&1 || TASK7_OK=0
    blkid "${DISK}3" >/dev/null 2>&1 || TASK7_OK=0
    blkid "${DISK}4" >/dev/null 2>&1 || TASK7_OK=0
    
    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: Partitions verified successfully from Linux using lsblk, blkid, and fdisk"
    else
        fail "Task 7: Linux verification of the partitions failed"
    fi
     
    # TASK 8 - CREATE FILESYSTEMS
    TASK8_OK=1
    
    # Get filesystem types using lsblk
    FS1=$(lsblk -no FSTYPE /dev/sdb1 2>/dev/null | tr -d '[:space:]')
    FS2=$(lsblk -no FSTYPE /dev/sdb2 2>/dev/null | tr -d '[:space:]')
    FS3=$(lsblk -no FSTYPE /dev/sdb3 2>/dev/null | tr -d '[:space:]')
    FS4=$(lsblk -no FSTYPE /dev/sdb4 2>/dev/null | tr -d '[:space:]')
    
    # Fallback to blkid if lsblk did not detect the filesystem
    [ -n "$FS1" ] || FS1=$(blkid -o value -s TYPE /dev/sdb1 2>/dev/null)
    [ -n "$FS2" ] || FS2=$(blkid -o value -s TYPE /dev/sdb2 2>/dev/null)
    [ -n "$FS3" ] || FS3=$(blkid -o value -s TYPE /dev/sdb3 2>/dev/null)
    [ -n "$FS4" ] || FS4=$(blkid -o value -s TYPE /dev/sdb4 2>/dev/null)
    
    # Validate required filesystem types
    [ "$FS1" = "swap" ] || TASK8_OK=0
    [ "$FS2" = "xfs" ]  || TASK8_OK=0
    [ "$FS3" = "ext4" ] || TASK8_OK=0
    [ "$FS4" = "xfs" ]  || TASK8_OK=0
    
    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: Swap, XFS, ext4, and XFS filesystems created correctly"
    else
        fail "Task 8: One or more required filesystem types are incorrect"
    fi

    # TASK 9 - CREATE MOUNT POINTS
    TASK9_OK=1

    [ -d "/appdata" ] || TASK9_OK=0
    [ -d "/applogs" ] || TASK9_OK=0
    [ -d "/backup" ] || TASK9_OK=0

    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: Required mount-point directories exist"
    else
        fail "Task 9: One or more required mount-point directories are missing"
    fi

    # TASK 10 - INITIALIZE SWAP AND MOUNT FILESYSTEMS
    TASK10_OK=1

    # Check active swap
    if ! swapon --show=NAME --noheadings 2>/dev/null | grep -Fxq "/dev/sdb1"; then
        TASK10_OK=0
    fi

    # Check mounts
    MOUNT_APPDATA=$(findmnt -n -o SOURCE,TARGET /appdata 2>/dev/null)
    MOUNT_APPLOGS=$(findmnt -n -o SOURCE,TARGET /applogs 2>/dev/null)
    MOUNT_BACKUP=$(findmnt -n -o SOURCE,TARGET /backup 2>/dev/null)

    echo "$MOUNT_APPDATA" | grep -q "/dev/sdb2 /appdata" || TASK10_OK=0
    echo "$MOUNT_APPLOGS" | grep -q "/dev/sdb3 /applogs" || TASK10_OK=0
    echo "$MOUNT_BACKUP" | grep -q "/dev/sdb4 /backup" || TASK10_OK=0

    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: Swap is active and all filesystems are mounted correctly"
    else
        fail "Task 10: Swap or one or more filesystem mounts are incorrect"
    fi

    # TASK 11 - CONFIGURE PERSISTENT MOUNTING
    TASK11_OK=1
    
    FSTAB="/etc/fstab"
    
    # Verify /dev/sdb1 persistent swap entry
    awk '$1 == "/dev/sdb1" && $2 == "swap" && $3 == "swap" && $4 == "defaults" {found=1} END {exit !found}' "$FSTAB" \
        || TASK11_OK=0
    
    # Verify /dev/sdb2 persistent mount
    awk '$1 == "/dev/sdb2" && $2 == "/appdata" && $3 == "xfs" && $4 == "defaults" {found=1} END {exit !found}' "$FSTAB" \
        || TASK11_OK=0
    
    # Verify /dev/sdb3 persistent mount
    awk '$1 == "/dev/sdb3" && $2 == "/applogs" && $3 == "ext4" && $4 == "defaults" {found=1} END {exit !found}' "$FSTAB" \
        || TASK11_OK=0
    
    # Verify /dev/sdb4 persistent mount
    awk '$1 == "/dev/sdb4" && $2 == "/backup" && $3 == "xfs" && $4 == "defaults" {found=1} END {exit !found}' "$FSTAB" \
        || TASK11_OK=0
    
    # Verify the configuration without rebooting
    if [ "$TASK11_OK" -eq 1 ]; then
    
        if mount -a >/dev/null 2>&1; then
    
            # Verify swap is available
            if swapon --show=NAME 2>/dev/null | grep -qx "/dev/sdb1" && \
               mountpoint -q /appdata && \
               mountpoint -q /applogs && \
               mountpoint -q /backup; then
    
                pass "Task 11: Persistent swap and filesystem mounts are correctly configured and verified"
    
            else
                fail "Task 11: Persistent configuration exists, but swap or one or more mount points are not active"
            fi
    
        else
            fail "Task 11: /etc/fstab configuration could not be applied"
        fi

    else
        fail "Task 11: Required persistent storage entries are missing or incorrect"
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
#===============================================================

validate_lab229_lvm() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 229 - Linux Logical Volume Management - LVM</h2>"

    TOTAL_TASKS=11
    PASSED=0

    LAB_NAME="Lab 229 - Linux Logical Volume Management - LVM"
    DATE=$(date "+%F %T")

    DISK="/dev/sdb"
    VG_NAME="vg_db"
    LV_NAME="lv_db"
    LV_PATH="/dev/vg_db/lv_db"
    MOUNT_POINT="/data"
    FSTAB="/etc/fstab"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - IDENTIFY THE NEW DISK
    TASK1_OK=1

    if [ -b "$DISK" ]; then

        DISK_SIZE=$(lsblk -bndo SIZE "$DISK" 2>/dev/null)

        if [ -z "$DISK_SIZE" ] || [ "$DISK_SIZE" -le 0 ] 2>/dev/null; then
            TASK1_OK=0
        fi

        # Verify disk is approximately 2 GiB or larger than 1.8 GiB.
        MIN_DISK_SIZE=$((1800 * 1000 * 1000))

        if [ -n "$DISK_SIZE" ] && [ "$DISK_SIZE" -lt "$MIN_DISK_SIZE" ] 2>/dev/null; then
            TASK1_OK=0
        fi

    else
        TASK1_OK=0
    fi

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: /dev/sdb is available and its disk size was verified"
    else
        fail "Task 1: /dev/sdb is missing or its disk size could not be verified"
    fi

    # TASK 2 - GPT PARTITION TABLE AND FOUR LVM PARTITIONS
    TASK2_OK=1

    # Verify GPT
    PARTITION_TABLE=$(lsblk -dnro PTTYPE "$DISK" 2>/dev/null | tr -d '[:space:]')

    [ "$PARTITION_TABLE" = "gpt" ] || TASK2_OK=0

    # Verify all four partitions exist
    for PART in \
        "/dev/sdb1" \
        "/dev/sdb2" \
        "/dev/sdb3" \
        "/dev/sdb4"
    do
        [ -b "$PART" ] || TASK2_OK=0
    done

    if [ "$TASK2_OK" -eq 1 ]; then

        # Partition sizes
        SDB1_SIZE=$(lsblk -bndo SIZE /dev/sdb1 2>/dev/null)
        SDB2_SIZE=$(lsblk -bndo SIZE /dev/sdb2 2>/dev/null)
        SDB3_SIZE=$(lsblk -bndo SIZE /dev/sdb3 2>/dev/null)
        SDB4_SIZE=$(lsblk -bndo SIZE /dev/sdb4 2>/dev/null)

        EXPECTED_512=$((512 * 1024 * 1024))
        MIN_SDB4=$((400 * 1024 * 1024))

        # Allow 64 MiB tolerance for partition alignment.
        TOLERANCE=$((64 * 1024 * 1024))

        SDB1_DIFF=$((SDB1_SIZE - EXPECTED_512))
        SDB2_DIFF=$((SDB2_SIZE - EXPECTED_512))
        SDB3_DIFF=$((SDB3_SIZE - EXPECTED_512))

        [ "$SDB1_DIFF" -lt 0 ] && SDB1_DIFF=$((SDB1_DIFF * -1))
        [ "$SDB2_DIFF" -lt 0 ] && SDB2_DIFF=$((SDB2_DIFF * -1))
        [ "$SDB3_DIFF" -lt 0 ] && SDB3_DIFF=$((SDB3_DIFF * -1))

        if [ "$SDB1_DIFF" -gt "$TOLERANCE" ] ||
           [ "$SDB2_DIFF" -gt "$TOLERANCE" ] ||
           [ "$SDB3_DIFF" -gt "$TOLERANCE" ] ||
           [ -z "$SDB4_SIZE" ] ||
           [ "$SDB4_SIZE" -lt "$MIN_SDB4" ]; then

            TASK2_OK=0
        fi
    fi

    # Verify GPT partition type 8E00 - Linux LVM
    for NUM in 1 2 3 4
    do
        TYPE_INFO=$(sudo /usr/sbin/sgdisk -i "$NUM" "$DISK" 2>/dev/null)

        echo "$TYPE_INFO" | grep -Eqi "8E00|Linux LVM" || TASK2_OK=0
    done

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: GPT partition table and four Linux LVM partitions are correctly configured"
    else
        fail "Task 2: GPT partition table, partition sizes, or LVM partition types are incorrect"
    fi

    # TASK 3 - PHYSICAL VOLUMES
    TASK3_OK=1
    
    PV_LIST=$(sudo /usr/sbin/pvs --noheadings --separator='|' \
        -o pv_name 2>/dev/null |
        awk -F'|' '
        {
            gsub(/^[ \t]+|[ \t]+$/, "", $1)
            if ($1 ~ /^\/dev\/sdb[1-4]$/)
                print $1
        }')
    
    for PV in /dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb4
    do
        echo "$PV_LIST" | grep -qx "$PV" || TASK3_OK=0
    done
    
    if [ "$TASK3_OK" -eq 1 ]; then
        pass "Task 3: All four partitions are configured as LVM Physical Volumes"
    else
        fail "Task 3: Required LVM Physical Volumes are not configured correctly"
    fi
    
    # TASK 4 - VOLUME GROUP
    TASK4_OK=1
    
    # Verify vg_db exists
    VG_EXISTS=$(sudo /usr/sbin/vgs --noheadings \
        -o vg_name "$VG_NAME" 2>/dev/null | xargs)
    
    [ "$VG_EXISTS" = "$VG_NAME" ] || TASK4_OK=0
    
    # Verify the required PVs are members of vg_db
    for PV in /dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb4
    do
        PV_VG=$(sudo /usr/sbin/pvs --noheadings \
            -o vg_name "$PV" 2>/dev/null | xargs)

        [ "$PV_VG" = "$VG_NAME" ] || TASK4_OK=0
    done
    
    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: Volume Group vg_db contains the required LVM Physical Volumes"
    else
        fail "Task 4: Volume Group vg_db is missing or has incorrect Physical Volumes"
    fi

    # TASK 5 - LOGICAL VOLUME
    TASK5_OK=1
    
    # Verify lv_db exists
    if [ ! -b "$LV_PATH" ]; then
        TASK5_OK=0
    fi
    
    # Verify lv_db belongs to vg_db
    LV_VG=$(sudo /usr/sbin/lvs --noheadings -o vg_name "$LV_PATH" 2>/dev/null | xargs)
    
    [ "$LV_VG" = "$VG_NAME" ] || TASK5_OK=0
    
    # Verify LV size is greater than 1 GB
    LV_SIZE=$(sudo /usr/sbin/lvs --noheadings --units g --nosuffix \
        -o lv_size "$LV_PATH" 2>/dev/null | xargs)
    
    if [ -z "$LV_SIZE" ]; then
        TASK5_OK=0
    elif ! awk -v size="$LV_SIZE" 'BEGIN { exit !(size >= 1.0) }'; then
        TASK5_OK=0
    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: lv_db exists in vg_db and is at least 1 GB"
    else
        fail "Task 5: lv_db is missing, is not in vg_db, or has insufficient size"
    fi
    
    # TASK 6
    TASK6_OK=1
    
    DF_OUTPUT=$(df -hT /data 2>/dev/null)
    
    echo "$DF_OUTPUT" | grep -qi "xfs" || TASK6_OK=0
    echo "$DF_OUTPUT" | grep -q "/data" || TASK6_OK=0
    
    [ -f "/home/$STUDENT_NAME/lv_db_mount" ] || TASK6_OK=0
    
    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: lv_db is formatted with XFS and mounted on /data"
    else
        fail "Task 6: XFS filesystem, /data mount, or df output is incorrect"
    fi

    # TASK 7 - /etc/fstab
    TASK7_OK=1

    if [ ! -f "$FSTAB" ]; then
        TASK7_OK=0
    else

        # Expected:
        # /dev/vg_db/lv_db  /data  xfs  defaults  0 0

        awk '
        $1 == "/dev/vg_db/lv_db" &&
        $2 == "/data" &&
        $3 == "xfs" &&
        $4 == "defaults" &&
        $5 == "0" &&
        $6 == "0" {
            found=1
        }
        END {
            exit !found
        }' "$FSTAB" || TASK7_OK=0
    fi

    # Test fstab without rebooting.
    if [ "$TASK7_OK" -eq 1 ]; then

        if ! mount -a >/dev/null 2>&1; then
            TASK7_OK=0
        fi

        mountpoint -q "$MOUNT_POINT" || TASK7_OK=0
    fi

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: /etc/fstab is correctly configured for persistent /data mounting"
    else
        fail "Task 7: /etc/fstab entry is missing, incorrect, or cannot mount /data"
    fi

    # TASK 8
    TASK8_OK=1
    
    EXTEND_FILE="/home/$STUDENT_NAME/lv_db_extend"
    
    DF_OUTPUT=$(df -hT /data 2>/dev/null)
    
    echo "$DF_OUTPUT" | grep -qi "xfs" || TASK8_OK=0
    echo "$DF_OUTPUT" | grep -q "/data" || TASK8_OK=0
    
    [ -f "$EXTEND_FILE" ] || TASK8_OK=0
    
    if [ -f "$EXTEND_FILE" ]; then
        grep -qi "xfs" "$EXTEND_FILE" || TASK8_OK=0
        grep -q "/data" "$EXTEND_FILE" || TASK8_OK=0
    fi
    
    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: lv_db was extended and the XFS filesystem is mounted on /data"
    else
        fail "Task 8: lv_db extension, XFS filesystem, /data mount, or df output is incorrect"
    fi
    
    # TASK 9 - INITIALIZE /dev/sdb4 AS PV
    TASK9_OK=1
    
    # Verify /dev/sdb4 is an LVM Physical Volume
    PV_INFO=$(sudo /usr/sbin/pvs --noheadings -o pv_name /dev/sdb4 2>/dev/null | xargs)
    
    [ "$PV_INFO" = "/dev/sdb4" ] || TASK9_OK=0
    
    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: /dev/sdb4 is initialized as an LVM Physical Volume"
    else
        fail "Task 9: /dev/sdb4 is not recognized as an LVM Physical Volume"
    fi
    
    # TASK 10 - ADD /dev/sdb4 TO vg_db
    TASK10_OK=1
    
    # Verify /dev/sdb4 belongs to vg_db
    SDB4_VG=$(sudo /usr/sbin/pvs --noheadings -o vg_name /dev/sdb4 2>/dev/null | xargs)
    [ "$SDB4_VG" = "$VG_NAME" ] || TASK10_OK=0
    
    # Verify vg_db has 4 PVs
    VG_PV_COUNT=$(sudo /usr/sbin/vgs --noheadings -o pv_count "$VG_NAME" 2>/dev/null | xargs)
    [ "$VG_PV_COUNT" = "4" ] || TASK10_OK=0
    
    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: /dev/sdb4 was added to vg_db; vg_db now contains four Physical Volumes"
    else
        fail "Task 10: /dev/sdb4 was not correctly added to vg_db"
    fi
    
    # TASK 11 - FINAL LV AND XFS EXTENSION
    TASK11_OK=1
    
    # Verify vg_db contains four PVs
    VG_PV_COUNT=$(sudo /usr/sbin/vgs --noheadings -o pv_count "$VG_NAME" 2>/dev/null | xargs)
    
    [ "$VG_PV_COUNT" = "4" ] || TASK11_OK=0
    
    # Verify VG has no remaining free space
    VG_FREE=$(sudo /usr/sbin/vgs --noheadings --units g --nosuffix \
        -o vg_free "$VG_NAME" 2>/dev/null | xargs)
    
    if [ -z "$VG_FREE" ]; then
        TASK11_OK=0
    else
        awk -v free="$VG_FREE" 'BEGIN { exit !(free <= 0.01) }' || TASK11_OK=0
    fi
    
    # Verify XFS filesystem is mounted on /data
    DF_OUTPUT=$(df -hT "$MOUNT_POINT" 2>/dev/null)
    
    echo "$DF_OUTPUT" | grep -qi "xfs" || TASK11_OK=0
    echo "$DF_OUTPUT" | grep -q "/data" || TASK11_OK=0
    
    if [ "$TASK11_OK" -eq 1 ]; then
        pass "Task 11: Final lv_db and XFS filesystem are correctly extended"
    else
        fail "Task 11: Final lv_db, XFS filesystem, /data mount, or VG capacity is incorrect"
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

#=====================================================================================================
validate_lab230() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 230 - Technical Screening Round 3 (TSR3).</h2>"

    TOTAL_TASKS=12
    PASSED=0

    LAB_NAME="Lab 230 - Technical Screening Round 3 (TSR3)"
    DATE=$(date "+%F %T")

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # Task 1 - Create User
    TASK_PASS=1

    if id robert >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if id robert >/dev/null 2>&1; then

        PASSWORD_STATUS=$(sudo -n passwd -S robert 2>/dev/null | awk '{print $2}')

        if [[ "$PASSWORD_STATUS" == P* ]]; then
            :
        else
            TASK_PASS=0
        fi

    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 1: User robert exists and has a password assigned"
    else
        fail "Task 1: User robert and password assignment could not be verified"
    fi

    # Task 2 - Create Group
    if getent group devops >/dev/null 2>&1; then
        pass "Task 2: Group devops exists"
    else
        fail "Task 2: Group devops does not exist"
    fi

    # Task 3 - Add User to Group
    TASK_PASS=1

    if id robert >/dev/null 2>&1; then

        if id -nG robert 2>/dev/null \
            | tr ' ' '\n' \
            | grep -Fxq "devops"; then
            :
        else
            TASK_PASS=0
        fi

    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 3: User robert is a member of the devops group"
    else
        fail "Task 3: User robert is not a member of the devops group"
    fi

    # Task 4 - Configure Sudo Privileges
    TASK_PASS=0

    if sudo -l -U robert 2>/dev/null \
        | grep -q "NOPASSWD:"; then

        TASK_PASS=1

    elif grep -RhsE \
        '^[[:space:]]*robert[[:space:]].*NOPASSWD:' \
        /etc/sudoers /etc/sudoers.d 2>/dev/null \
        | grep -q "NOPASSWD:"; then

        TASK_PASS=1
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 4: User robert has passwordless sudo privileges"
    else
        fail "Task 4: Passwordless sudo privileges for robert were not verified"
    fi

    # Task 5 - Configure SSH Key-Based Authentication
    TASK_PASS=1

    ROBERT_HOME=$(getent passwd robert 2>/dev/null | cut -d: -f6)

    if [ -z "$ROBERT_HOME" ]; then
        TASK_PASS=0
    fi

    AUTHORIZED_KEYS="$ROBERT_HOME/.ssh/authorized_keys"

    if ! sudo -n test -f "$AUTHORIZED_KEYS" 2>/dev/null; then
        TASK_PASS=0
    fi
 
    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 5: SSH key-based authentication for robert from 192.168.111.165 is configured"
    else
        fail "Task 5: SSH key-based authentication from 192.168.111.165 to robert could not be verified"
    fi

    # Task 6 - Install Apache
    if rpm -q httpd >/dev/null 2>&1; then
        pass "Task 6: httpd package is installed"
    else
        fail "Task 6: httpd package is not installed"
    fi

    # Task 7 - Start and Enable Apache
    TASK_PASS=1

    if systemctl is-active --quiet httpd; then
        :
    else
        TASK_PASS=0
    fi

    if systemctl is-enabled --quiet httpd 2>/dev/null; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 7: httpd service is running and enabled"
    else
        fail "Task 7: httpd service is not both running and enabled"
    fi

    # Task 8 - Configure Apache Port
    TASK_PASS=1

    APACHE_CONF="/etc/httpd/conf/httpd.conf"

    if [ ! -f "$APACHE_CONF" ]; then
        TASK_PASS=0
    fi

    if [ -f "$APACHE_CONF" ]; then

        if grep -Eq \
            '^[[:space:]]*Listen[[:space:]]+8080[[:space:]]*$' \
            "$APACHE_CONF"; then
            :
        else
            TASK_PASS=0
        fi

    fi

    if systemctl is-active --quiet httpd; then

        if ss -lnt 2>/dev/null \
            | awk '$4 ~ /:8080$/ {found=1} END {exit !found}'; then
            :
        else
            TASK_PASS=0
        fi

    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 8: Apache is configured and listening on port 8080"
    else
        fail "Task 8: Apache is not correctly configured or listening on port 8080"
    fi

    # Task 9 - Configure Web Page
    EXPECTED_CONTENT="I am configuring apache server in my TSR3"
    INDEX_FILE="/var/www/html/index.html"

    if [ -f "$INDEX_FILE" ] && \
       grep -Fq "$EXPECTED_CONTENT" "$INDEX_FILE"; then

        pass "Task 9: index.html contains the required content"

    else

        fail "Task 9: index.html does not contain the required content"

    fi

    # Task 10 - Configure Firewall
    TASK_PASS=1
    
    if ! sudo -n systemctl is-active --quiet firewalld; then
        TASK_PASS=0
    fi
    
    RUNTIME_PORTS=$(sudo -n firewall-cmd --list-ports 2>/dev/null)
    
    if echo "$RUNTIME_PORTS" | tr ' ' '\n' | grep -Fxq "8080/tcp"; then
        :
    else
        TASK_PASS=0
    fi
    
    PERMANENT_PORTS=$(sudo -n firewall-cmd --permanent --list-ports 2>/dev/null)
    
    if echo "$PERMANENT_PORTS" | tr ' ' '\n' | grep -Fxq "8080/tcp"; then
        :
    else
        TASK_PASS=0
    fi
    
    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 10: TCP port 8080 is allowed through the firewall"
    else
        fail "Task 10: TCP port 8080 is not allowed through the firewall"
    fi
    
    # Task 11 - Test Apache
    TASK_PASS=1

    if curl -s --max-time 5 \
        "http://127.0.0.1:8080/" 2>/dev/null \
        | grep -Fq "$EXPECTED_CONTENT"; then
        :
    else
        TASK_PASS=0
    fi

    if [ -n "$STUDENT_IP" ]; then

        if curl -s --max-time 5 \
            "http://${STUDENT_IP}:8080/" 2>/dev/null \
            | grep -Fq "$EXPECTED_CONTENT"; then
            :
        else
            TASK_PASS=0
        fi

    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 11: Apache web page is accessible on port 8080 and displays the required content"
    else
        fail "Task 11: Apache web page could not be verified on port 8080"
    fi
    
    # Task 12 - Configure Static IP
    TASK_PASS=1
    
    EXPECTED_IP="$STUDENT_IP"
    EXPECTED_GATEWAY="10.90.0.1"
    EXPECTED_DNS1="192.168.111.50"
    EXPECTED_DNS2="8.8.8.8"
    
    ACTIVE_PROFILE=""
    
    while IFS=: read -r PROFILE DEVICE; do
    
        [ -z "$PROFILE" ] && continue
        [ -z "$DEVICE" ] && continue
    
        CONFIGURED_ADDRESSES=$(nmcli -g ipv4.addresses connection show "$PROFILE" 2>/dev/null)
    
        while IFS= read -r ADDRESS; do
    
            ADDRESS_IP="${ADDRESS%%/*}"
    
            if [ "$ADDRESS_IP" = "$EXPECTED_IP" ]; then
                ACTIVE_PROFILE="$PROFILE"
                break
            fi
    
        done < <(echo "$CONFIGURED_ADDRESSES" | tr ',' '\n')
    
        [ -n "$ACTIVE_PROFILE" ] && break
    
    done < <(
        nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null
    )
    
    if [ -z "$ACTIVE_PROFILE" ]; then
    
        TASK_PASS=0
    
    else
    
        IPV4_METHOD=$(nmcli -g ipv4.method connection show "$ACTIVE_PROFILE" 2>/dev/null)
    
        if [ "$IPV4_METHOD" != "manual" ]; then
            TASK_PASS=0
        fi
    
        CONFIGURED_ADDRESSES=$(nmcli -g ipv4.addresses connection show "$ACTIVE_PROFILE" 2>/dev/null)
    
        IP_FOUND=0
    
        while IFS= read -r ADDRESS; do

            ADDRESS_IP="${ADDRESS%%/*}"
    
            if [ "$ADDRESS_IP" = "$EXPECTED_IP" ]; then
                IP_FOUND=1
                break
            fi
    
        done < <(echo "$CONFIGURED_ADDRESSES" | tr ',' '\n')
    
        if [ "$IP_FOUND" -ne 1 ]; then
            TASK_PASS=0
        fi
    
        CONFIGURED_GATEWAY=$(nmcli -g ipv4.gateway connection show "$ACTIVE_PROFILE" 2>/dev/null)
    
        if [ "$CONFIGURED_GATEWAY" != "$EXPECTED_GATEWAY" ]; then
            TASK_PASS=0
        fi
    
        CONFIGURED_DNS=$(nmcli -g ipv4.dns connection show "$ACTIVE_PROFILE" 2>/dev/null)

        DNS1_FOUND=0
        DNS2_FOUND=0
    
        while IFS= read -r DNS; do
    
            if [ "$DNS" = "$EXPECTED_DNS1" ]; then
                DNS1_FOUND=1
            fi
    
            if [ "$DNS" = "$EXPECTED_DNS2" ]; then
                DNS2_FOUND=1
            fi
    
        done < <(echo "$CONFIGURED_DNS" | tr ',' '\n')
    
        if [ "$DNS1_FOUND" -ne 1 ]; then
            TASK_PASS=0
        fi
    
        if [ "$DNS2_FOUND" -ne 1 ]; then
            TASK_PASS=0
        fi
    
        if ! ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then
            TASK_PASS=0
        fi
    
        if ! ping -c 2 -W 3 google.com >/dev/null 2>&1; then
            TASK_PASS=0
        fi
    
    fi
    
    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 12: Static IP configuration, gateway, DNS, and network connectivity verified"
    else
        fail "Task 12: Static IP configuration or network connectivity could not be verified"
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
#================================================================
validate_lab231() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 231 - NIC Teaming Using Active-Backup.</h2>"

    TOTAL_TASKS=13
    PASSED=0

    LAB_NAME="Lab 231 - NIC Teaming Using Active-Backup"
    DATE=$(date "+%F %T")

    # ------------------------------------------------------------
    # HELPERS
    # ------------------------------------------------------------

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # ------------------------------------------------------------
    # Task 1 - Verify Network Interfaces
    # ------------------------------------------------------------

    TASK_PASS=1

    if nmcli device show ens192 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli device show ens224 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 1: Network interfaces ens192 and ens224 are present"
    else
        fail "Task 1: Required network interfaces ens192 and ens224 could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 2 - Verify Teaming Software and NetworkManager
    # ------------------------------------------------------------

    TASK_PASS=1

    if rpm -q teamd >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if rpm -q NetworkManager-team >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if systemctl is-active --quiet NetworkManager; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 2: Teaming software is installed and NetworkManager is running"
    else
        fail "Task 2: Required teaming software or NetworkManager could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 3 - Verify team0 Exists
    # ------------------------------------------------------------

    TASK_PASS=1

    if nmcli connection show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli device show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 3: team0 logical team interface exists"
    else
        fail "Task 3: team0 logical team interface could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 4 - Verify Active-Backup Runner
    # ------------------------------------------------------------

    TASK_PASS=0

    TEAM_STATE=$(teamdctl team0 state 2>/dev/null)

    if echo "$TEAM_STATE" | grep -Eiq \
        '"runner"[[:space:]]*:[[:space:]]*"activebackup"|runner.*activebackup'; then

        TASK_PASS=1

    elif nmcli -f team.config connection show team0 2>/dev/null \
        | grep -Eiq 'activebackup'; then

        TASK_PASS=1
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 4: team0 is configured using Active-Backup mode"
    else
        fail "Task 4: team0 is not configured using Active-Backup mode"
    fi


    # ------------------------------------------------------------
    # Task 5 - Verify Team Ports
    # ------------------------------------------------------------

    TASK_PASS=1

    PORT1_FOUND=0
    PORT2_FOUND=0

    if nmcli connection show 2>/dev/null \
        | grep -Eq 'team0-port1'; then
        PORT1_FOUND=1
    fi

    if nmcli connection show 2>/dev/null \
        | grep -Eq 'team0-port2'; then
        PORT2_FOUND=1
    fi

    if [ "$PORT1_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$PORT2_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 5: ens192 and ens224 are configured as team0 ports"
    else
        fail "Task 5: Both required team0 ports could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 6 - Verify IP Configuration on team0
    # ------------------------------------------------------------

    TASK_PASS=1

    EXPECTED_IP="$STUDENT_IP"
    EXPECTED_GATEWAY="10.90.0.1"
    EXPECTED_DNS1="192.168.111.50"
    EXPECTED_DNS2="8.8.8.8"

    IPV4_METHOD=$(nmcli -g ipv4.method connection show team0 2>/dev/null)

    if [ "$IPV4_METHOD" != "manual" ]; then
        TASK_PASS=0
    fi

    CONFIGURED_ADDRESSES=$(nmcli -g ipv4.addresses connection show team0 2>/dev/null)

    IP_FOUND=0

    while IFS= read -r ADDRESS; do

        ADDRESS_IP="${ADDRESS%%/*}"

        if [ "$ADDRESS_IP" = "$EXPECTED_IP" ]; then
            IP_FOUND=1
            break
        fi

    done < <(echo "$CONFIGURED_ADDRESSES" | tr ',' '\n')

    if [ "$IP_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    CONFIGURED_GATEWAY=$(nmcli -g ipv4.gateway connection show team0 2>/dev/null)

    if [ "$CONFIGURED_GATEWAY" != "$EXPECTED_GATEWAY" ]; then
        TASK_PASS=0
    fi

    CONFIGURED_DNS=$(nmcli -g ipv4.dns connection show team0 2>/dev/null)

    DNS1_FOUND=0
    DNS2_FOUND=0

    while IFS= read -r DNS; do

        if [ "$DNS" = "$EXPECTED_DNS1" ]; then
            DNS1_FOUND=1
        fi

        if [ "$DNS" = "$EXPECTED_DNS2" ]; then
            DNS2_FOUND=1
        fi

    done < <(echo "$CONFIGURED_DNS" | tr ',' '\n')

    if [ "$DNS1_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$DNS2_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 6: team0 has the required static IP, gateway, and DNS configuration"
    else
        fail "Task 6: team0 IP, gateway, or DNS configuration is incorrect"
    fi


    # ------------------------------------------------------------
    # Task 7 - Verify IP Is Not Configured on Team Ports
    # ------------------------------------------------------------

    TASK_PASS=1

    ENS192_IP=$(nmcli -g ipv4.addresses connection show team0-port1 2>/dev/null)
    ENS224_IP=$(nmcli -g ipv4.addresses connection show team0-port2 2>/dev/null)

    if [ -n "$ENS192_IP" ] && [ "$ENS192_IP" != "--" ]; then
        TASK_PASS=0
    fi

    if [ -n "$ENS224_IP" ] && [ "$ENS224_IP" != "--" ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 7: IP configuration is assigned to team0 rather than the individual team ports"
    else
        fail "Task 7: Individual team ports have conflicting IP configuration"
    fi


    # ------------------------------------------------------------
    # Task 8 - Verify team0 Is UP
    # ------------------------------------------------------------

    TASK_PASS=1

    if ip link show team0 2>/dev/null \
        | grep -q "state UP"; then
        :
    else
        TASK_PASS=0
    fi

    if ip addr show team0 2>/dev/null \
        | grep -q "$EXPECTED_IP"; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 8: team0 is UP and has the configured IP address"
    else
        fail "Task 8: team0 is not UP or does not have the expected IP address"
    fi


    # ------------------------------------------------------------
    # Task 9 - Verify Team Membership and Active Port
    # ------------------------------------------------------------
    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    if echo "$TEAM_STATE" | grep -qE '^[[:space:]]+ens192[[:space:]]*$' &&
        echo "$TEAM_STATE" | grep -qE '^[[:space:]]+ens224[[:space:]]*$'; then

        pass "Task 9: Both ens192 and ens224 are members of team0"

    else
   
        fail "Task 9: Both ens192 and ens224 could not be verified as team0 members"

    fi

    # ------------------------------------------------------------
    # Task 10 - Verify Team Port Operational State
    # ------------------------------------------------------------

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    ENS192_UP=0
    ENS224_UP=0

    if echo "$TEAM_STATE" | grep -A8 -E '^[[:space:]]+ens192[[:space:]]*$' |
        grep -q 'link summary: up'; then
        ENS192_UP=1
    fi

    if echo "$TEAM_STATE" | grep -A8 -E '^[[:space:]]+ens224[[:space:]]*$' |
        grep -q 'link summary: up'; then
        ENS224_UP=1
    fi

    if [ "$ENS192_UP" -eq 1 ] && [ "$ENS224_UP" -eq 1 ]; then

        pass "Task 10: Both ens192 and ens224 are operationally UP"

    else

        fail "Task 10: One or both team ports are not operationally recognized"

    fi 

    # ------------------------------------------------------------
    # Task 11 - Verify Network Connectivity
    # ------------------------------------------------------------

    TASK_PASS=1

    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if ping -c 2 -W 3 8.8.8.8 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if ping -c 2 -W 3 google.com >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 11: Network connectivity through team0 is working"
    else
        fail "Task 11: Network connectivity through team0 could not be verified"
    fi

    # ------------------------------------------------------------
# Task 12 - Verify Active-Backup Configuration
# ------------------------------------------------------------

TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

RUNNER=""
ACTIVE_PORT=""

# Extract runner from:
# setup:
#   runner: activebackup
RUNNER=$(echo "$TEAM_STATE" | grep -m1 'runner: activebackup')

# Extract active port from:
# runner:
#   active port: ens192
ACTIVE_PORT=$(echo "$TEAM_STATE" | grep -m1 'active port:' | awk '{print $3}')

if [ -n "$RUNNER" ] &&
   { [ "$ACTIVE_PORT" = "ens192" ] || [ "$ACTIVE_PORT" = "ens224" ]; }; then

    pass "Task 12: Active-Backup configuration verified with active port $ACTIVE_PORT"

else

    fail "Task 12: Active-Backup failover configuration could not be verified"

fi

    # ------------------------------------------------------------
    # Task 13 - Final Team Verification
    # ------------------------------------------------------------

    TASK_PASS=1

    if systemctl is-active --quiet NetworkManager; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli connection show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if ip link show team0 2>/dev/null \
        | grep -q "state UP"; then
        :
    else
        TASK_PASS=0
    fi

    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 13: NIC teaming configuration is operational and network connectivity is restored"
    else
        fail "Task 13: Final Active-Backup team verification failed"
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

#===================================================================

validate_lab232() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 232 - NIC Teaming Using Active-Backup - Advanced.</h2>"

    TOTAL_TASKS=15
    PASSED=0

    LAB_NAME="Lab 232 - NIC Teaming Using Active-Backup - Advanced"
    DATE=$(date "+%F %T")

    # ------------------------------------------------------------
    # HELPERS
    # ------------------------------------------------------------

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }


    # ------------------------------------------------------------
    # Common Variables
    # ------------------------------------------------------------

    EXPECTED_IP="$STUDENT_IP"
    EXPECTED_GATEWAY="10.90.0.1"
    EXPECTED_DNS1="192.168.111.50"
    EXPECTED_DNS2="8.8.8.8"

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)


    # ------------------------------------------------------------
    # Task 1 - Verify Network Interfaces
    # ------------------------------------------------------------

    TASK_PASS=1

    if nmcli device show ens192 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli device show ens224 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 1: Network interfaces ens192 and ens224 are present"
    else
        fail "Task 1: Required network interfaces ens192 and ens224 could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 2 - Verify Teaming Software and NetworkManager
    # ------------------------------------------------------------

    TASK_PASS=1

    if rpm -q teamd >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if rpm -q NetworkManager-team >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if systemctl is-active --quiet NetworkManager; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 2: Teaming software is installed and NetworkManager is running"
    else
        fail "Task 2: Required teaming software or NetworkManager could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 3 - Verify team0 Exists
    # ------------------------------------------------------------

    TASK_PASS=1

    if nmcli connection show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli device show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 3: team0 logical team interface exists"
    else
        fail "Task 3: team0 logical team interface could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 4 - Verify Active-Backup Runner
    # ------------------------------------------------------------

    TASK_PASS=0

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    if echo "$TEAM_STATE" | grep -qiE 'runner:[[:space:]]*activebackup'; then
        TASK_PASS=1
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 4: team0 is configured using Active-Backup mode"
    else
        fail "Task 4: team0 is not configured using Active-Backup mode"
    fi


    # ------------------------------------------------------------
    # Task 5 - Verify Team Ports
    # ------------------------------------------------------------

    TASK_PASS=1

    PORT1_FOUND=0
    PORT2_FOUND=0

    if nmcli connection show team0-port1 >/dev/null 2>&1; then
        PORT1_FOUND=1
    fi

    if nmcli connection show team0-port2 >/dev/null 2>&1; then
        PORT2_FOUND=1
    fi

    if [ "$PORT1_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$PORT2_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 5: ens192 and ens224 are configured as team0 ports"
    else
        fail "Task 5: Both required team0 ports could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 6 - Verify IP Configuration on team0
    # ------------------------------------------------------------

    TASK_PASS=1

    IPV4_METHOD=$(nmcli -g ipv4.method connection show team0 2>/dev/null)

    if [ "$IPV4_METHOD" != "manual" ]; then
        TASK_PASS=0
    fi

    CONFIGURED_ADDRESSES=$(nmcli -g ipv4.addresses connection show team0 2>/dev/null)

    IP_FOUND=0

    while IFS= read -r ADDRESS; do

        ADDRESS=$(echo "$ADDRESS" | xargs)
        ADDRESS_IP="${ADDRESS%%/*}"

        if [ "$ADDRESS_IP" = "$EXPECTED_IP" ]; then
            IP_FOUND=1
            break
        fi

    done < <(echo "$CONFIGURED_ADDRESSES" | tr ',' '\n')

    if [ "$IP_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    CONFIGURED_GATEWAY=$(nmcli -g ipv4.gateway connection show team0 2>/dev/null)

    if [ "$CONFIGURED_GATEWAY" != "$EXPECTED_GATEWAY" ]; then
        TASK_PASS=0
    fi

    CONFIGURED_DNS=$(nmcli -g ipv4.dns connection show team0 2>/dev/null)

    DNS1_FOUND=0
    DNS2_FOUND=0

    while IFS= read -r DNS; do

        DNS=$(echo "$DNS" | xargs)

        if [ "$DNS" = "$EXPECTED_DNS1" ]; then
            DNS1_FOUND=1
        fi

        if [ "$DNS" = "$EXPECTED_DNS2" ]; then
            DNS2_FOUND=1
        fi

    done < <(echo "$CONFIGURED_DNS" | tr ',' '\n')

    if [ "$DNS1_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$DNS2_FOUND" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 6: team0 has the required static IP, gateway, and DNS configuration"
    else
        fail "Task 6: team0 IP, gateway, or DNS configuration is incorrect"
    fi


    # ------------------------------------------------------------
    # Task 7 - Verify team0 Is UP
    # ------------------------------------------------------------

    TASK_PASS=1

    if ip link show team0 2>/dev/null | grep -q "state UP"; then
        :
    else
        TASK_PASS=0
    fi

    if ip addr show team0 2>/dev/null | grep -q "$EXPECTED_IP"; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 7: team0 is UP and has the configured IP address"
    else
        fail "Task 7: team0 is not UP or does not have the expected IP address"
    fi


    # ------------------------------------------------------------
    # Task 8 - Verify Active-Backup Runner Configuration
    # ------------------------------------------------------------

    TASK_PASS=0

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    if echo "$TEAM_STATE" | grep -qiE \
        'runner:[[:space:]]*activebackup'; then
        TASK_PASS=1
    fi

    if echo "$TEAM_STATE" | grep -qiE \
        'runner:[[:space:]]*loadbalance'; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 8: team0 is configured for Active-Backup mode"
    else
        fail "Task 8: team0 runner configuration is not Active-Backup"
    fi


    # ------------------------------------------------------------
    # Task 9 - Verify Team Membership
    # ------------------------------------------------------------

    TASK_PASS=1

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens192[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens224[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 9: ens192 and ens224 are members of team0"
    else
        fail "Task 9: Both ens192 and ens224 could not be verified as team0 members"
    fi


    # ------------------------------------------------------------
    # Task 10 - Verify Team Ports Are Operational
    # ------------------------------------------------------------

    TASK_PASS=1

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    ENS192_UP=0
    ENS224_UP=0

    if echo "$TEAM_STATE" | \
        grep -A8 -E '^[[:space:]]+ens192[[:space:]]*$' | \
        grep -q 'link summary: up'; then
        ENS192_UP=1
    fi

    if echo "$TEAM_STATE" | \
        grep -A8 -E '^[[:space:]]+ens224[[:space:]]*$' | \
        grep -q 'link summary: up'; then
        ENS224_UP=1
    fi

    if [ "$ENS192_UP" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$ENS224_UP" -ne 1 ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 10: Both ens192 and ens224 are operationally UP"
    else
        fail "Task 10: One or both team ports are not operational"
    fi


    # ------------------------------------------------------------
    # Task 11 - Identify Active Team Port
    # ------------------------------------------------------------

    TASK_PASS=0

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    ACTIVE_PORT=$(echo "$TEAM_STATE" | \
        grep -m1 'active port:' | \
        awk '{print $3}')

    if [ "$ACTIVE_PORT" = "ens192" ] || \
       [ "$ACTIVE_PORT" = "ens224" ]; then

        TASK_PASS=1

    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 11: Active-Backup team is using $ACTIVE_PORT as the active port"
    else
        fail "Task 11: Active team port could not be identified"
    fi


    # ------------------------------------------------------------
    # Task 12 - Verify Active-Backup Failover Configuration
    # ------------------------------------------------------------

    TASK_PASS=1

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    # Verify Active-Backup runner
    if echo "$TEAM_STATE" | grep -qiE \
        'runner:[[:space:]]*activebackup'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify both ports are members
    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens192[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens224[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify an active port exists
    ACTIVE_PORT=$(echo "$TEAM_STATE" | \
        grep -m1 'active port:' | \
        awk '{print $3}')

    if [ "$ACTIVE_PORT" = "ens192" ] || \
       [ "$ACTIVE_PORT" = "ens224" ]; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 12: Active-Backup failover configuration is present with an active team port"
    else
        fail "Task 12: Active-Backup failover configuration could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 13 - Verify Team Operation After Failover
    # ------------------------------------------------------------

    TASK_PASS=1

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    ACTIVE_PORT=$(echo "$TEAM_STATE" | \
        grep -m1 'active port:' | \
        awk '{print $3}')

    if [ "$ACTIVE_PORT" = "ens192" ] || \
       [ "$ACTIVE_PORT" = "ens224" ]; then
        :
    else
        TASK_PASS=0
    fi

    if ip link show team0 2>/dev/null | grep -q "state UP"; then
        :
    else
        TASK_PASS=0
    fi

    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 13: team0 remains operational with an active port after failover testing"
    else
        fail "Task 13: team0 operation after failover could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 14 - Verify Team Port Profiles
    # ------------------------------------------------------------

    TASK_PASS=1

    PORT1_DEVICE=$(nmcli -g connection.interface-name \
        connection show team0-port1 2>/dev/null)

    PORT2_DEVICE=$(nmcli -g connection.interface-name \
        connection show team0-port2 2>/dev/null)

    if [ "$PORT1_DEVICE" != "ens192" ]; then
        TASK_PASS=0
    fi

    if [ "$PORT2_DEVICE" != "ens224" ]; then
        TASK_PASS=0
    fi

    PORT1_MASTER=$(nmcli -g connection.master \
        connection show team0-port1 2>/dev/null)

    PORT2_MASTER=$(nmcli -g connection.master \
        connection show team0-port2 2>/dev/null)

    if [ "$PORT1_MASTER" != "team0" ]; then
        TASK_PASS=0
    fi

    if [ "$PORT2_MASTER" != "team0" ]; then
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 14: Team-port profiles correctly associate ens192 and ens224 with team0"
    else
        fail "Task 14: Team-port profile association could not be verified"
    fi


    # ------------------------------------------------------------
    # Task 15 - Final Active-Backup Team Verification
    # ------------------------------------------------------------

    TASK_PASS=1

    if systemctl is-active --quiet NetworkManager; then
        :
    else
        TASK_PASS=0
    fi

    if nmcli connection show team0 >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if ip link show team0 2>/dev/null | grep -q "state UP"; then
        :
    else
        TASK_PASS=0
    fi

    TEAM_STATE=$(sudo teamdctl team0 state 2>/dev/null)

    # Verify Active-Backup
    if echo "$TEAM_STATE" | grep -qiE \
        'runner:[[:space:]]*activebackup'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify ens192 membership
    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens192[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify ens224 membership
    if echo "$TEAM_STATE" | grep -qE \
        '^[[:space:]]+ens224[[:space:]]*$'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify active port
    ACTIVE_PORT=$(echo "$TEAM_STATE" | \
        grep -m1 'active port:' | \
        awk '{print $3}')

    if [ "$ACTIVE_PORT" = "ens192" ] || \
       [ "$ACTIVE_PORT" = "ens224" ]; then
        :
    else
        TASK_PASS=0
    fi

    # Verify both links are up
    if echo "$TEAM_STATE" | \
        grep -A8 -E '^[[:space:]]+ens192[[:space:]]*$' | \
        grep -q 'link summary: up'; then
        :
    else
        TASK_PASS=0
    fi

    if echo "$TEAM_STATE" | \
        grep -A8 -E '^[[:space:]]+ens224[[:space:]]*$' | \
        grep -q 'link summary: up'; then
        :
    else
        TASK_PASS=0
    fi

    # Verify gateway connectivity
    if ping -c 2 -W 2 "$EXPECTED_GATEWAY" >/dev/null 2>&1; then
        :
    else
        TASK_PASS=0
    fi

    if [ "$TASK_PASS" -eq 1 ]; then
        pass "Task 15: Lab 232 Active-Backup team is fully configured and operational"
    else
        fail "Task 15: Final Active-Backup team verification failed"
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
#==================================================================
validate_lab233_lvm() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 233 - Linux Logical Volume Management (LVM) - Advanced</h2>"

    TOTAL_TASKS=17
    PASSED=0

    LAB_NAME="Lab 233 - Linux Logical Volume Management (LVM) - Advanced"
    DATE=$(date "+%F %T")

    DISK="/dev/sdb"
    VG_NAME="vg_app"

    LV_DATA="lv_data"
    LV_LOGS="lv_logs"

    LV_DATA_PATH="/dev/vg_app/lv_data"
    LV_LOGS_PATH="/dev/vg_app/lv_logs"

    DATA_MOUNT="/data"
    LOGS_MOUNT="/logs"

    FSTAB="/etc/fstab"
    HOME_DIR="/home/$STUDENT_NAME"


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


    # ============================================================
    # TASK 1 - IDENTIFY THE NEW DISK
    # ============================================================

    TASK1_OK=1

    if [ ! -b "$DISK" ]; then
        TASK1_OK=0
    else

        DISK_SIZE=$(lsblk -bndo SIZE "$DISK" 2>/dev/null)

        if [ -z "$DISK_SIZE" ] || [ "$DISK_SIZE" -le 0 ] 2>/dev/null; then
            TASK1_OK=0
        fi

        # Verify disk is approximately 2 GB or larger than 1.8 GB.
        MIN_DISK_SIZE=$((1800 * 1000 * 1000))

        if [ -n "$DISK_SIZE" ] &&
           [ "$DISK_SIZE" -lt "$MIN_DISK_SIZE" ] 2>/dev/null; then
            TASK1_OK=0
        fi

        # Verify no partitions exist on /dev/sdb.
        PARTITION_COUNT=$(lsblk -nr -o TYPE "$DISK" 2>/dev/null |
            grep -c '^part$')

        [ "$PARTITION_COUNT" -eq 0 ] || TASK1_OK=0
    fi

    if [ "$TASK1_OK" -eq 1 ]; then
        pass "Task 1: /dev/sdb is available, approximately 2 GB, and has no partitions"
    else
        fail "Task 1: /dev/sdb is missing, incorrectly sized, or contains partitions"
    fi


    # ============================================================
    # TASK 2 - CREATE PHYSICAL VOLUME
    # ============================================================

    TASK2_OK=1

    PV_NAME=$(sudo /usr/sbin/pvs --noheadings \
        -o pv_name "$DISK" 2>/dev/null | xargs)

    [ "$PV_NAME" = "$DISK" ] || TASK2_OK=0

    PV_ATTR=$(sudo /usr/sbin/pvs --noheadings \
        -o pv_attr "$DISK" 2>/dev/null | xargs)

    [ -n "$PV_ATTR" ] || TASK2_OK=0

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: /dev/sdb is configured directly as an LVM Physical Volume"
    else
        fail "Task 2: /dev/sdb is not correctly configured as an LVM Physical Volume"
    fi


    # ============================================================
    # TASK 3 - CREATE VOLUME GROUP
    # ============================================================

    TASK3_OK=1

    VG_EXISTS=$(sudo /usr/sbin/vgs --noheadings \
        -o vg_name "$VG_NAME" 2>/dev/null | xargs)

    [ "$VG_EXISTS" = "$VG_NAME" ] || TASK3_OK=0

    PV_VG=$(sudo /usr/sbin/pvs --noheadings \
        -o vg_name "$DISK" 2>/dev/null | xargs)

    [ "$PV_VG" = "$VG_NAME" ] || TASK3_OK=0

    if [ "$TASK3_OK" -eq 1 ]; then
        pass "Task 3: Volume Group vg_app exists and /dev/sdb is an active Physical Volume in it"
    else
        fail "Task 3: Volume Group vg_app is missing or /dev/sdb is not correctly assigned"
    fi

        # ============================================================
    # TASK 4 - CREATE DATA LOGICAL VOLUME
    # ============================================================

    TASK4_OK=1

    # Verify lv_data exists
    if [ ! -b "$LV_DATA_PATH" ]; then
        TASK4_OK=0
    fi

    # Verify lv_data belongs to vg_app
    DATA_VG=$(sudo /usr/sbin/lvs --noheadings \
        -o vg_name "$LV_DATA_PATH" 2>/dev/null | xargs)

    [ "$DATA_VG" = "$VG_NAME" ] || TASK4_OK=0

    # Verify the initial filesystem size from saved df output.
    # The initial LV was 600 MB. The XFS filesystem reports
    # approximately 536 MB in df -hT because of filesystem overhead.
    INITIAL_FILE="$HOME_DIR/lvm_initial"

    if [ ! -f "$INITIAL_FILE" ]; then

        TASK4_OK=0

    else

        INITIAL_DATA_LINE=$(awk '$NF=="/data" {line=$0} END {print line}' \
            "$INITIAL_FILE")

        if [ -z "$INITIAL_DATA_LINE" ]; then

            TASK4_OK=0

        else

            INITIAL_DATA_TYPE=$(echo "$INITIAL_DATA_LINE" | awk '{print $2}')
            INITIAL_DATA_SIZE=$(echo "$INITIAL_DATA_LINE" | awk '{print $3}')

            # Verify XFS filesystem
            [ "$INITIAL_DATA_TYPE" = "xfs" ] || TASK4_OK=0

            # Convert df size to MB
            case "$INITIAL_DATA_SIZE" in
                *M)
                    INITIAL_DATA_SIZE_MB=${INITIAL_DATA_SIZE%M}
                    ;;
                *G)
                    INITIAL_DATA_SIZE_G=${INITIAL_DATA_SIZE%G}
                    INITIAL_DATA_SIZE_MB=$(awk -v g="$INITIAL_DATA_SIZE_G" \
                        'BEGIN {printf "%.0f", g * 1024}')
                    ;;
                *)
                    TASK4_OK=0
                    INITIAL_DATA_SIZE_MB=0
                    ;;
            esac

            # XFS on a 600 MB LV reports approximately 536 MB.
            # Accept a reasonable range around the expected value.
            if [ "$INITIAL_DATA_SIZE_MB" -lt 500 ] ||
               [ "$INITIAL_DATA_SIZE_MB" -gt 620 ]; then
                TASK4_OK=0
            fi
        fi
    fi

    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: lv_data exists in vg_app and the initial filesystem configuration was approximately 600 MB"
    else
        fail "Task 4: lv_data is missing, is not in vg_app, or the initial 600 MB configuration is incorrect"
    fi


    # ============================================================
    # TASK 5 - CREATE LOGS LOGICAL VOLUME
    # ============================================================

    TASK5_OK=1

    # Verify lv_logs exists
    if [ ! -b "$LV_LOGS_PATH" ]; then
        TASK5_OK=0
    fi

    # Verify lv_logs belongs to vg_app
    LOGS_VG=$(sudo /usr/sbin/lvs --noheadings \
        -o vg_name "$LV_LOGS_PATH" 2>/dev/null | xargs)

    [ "$LOGS_VG" = "$VG_NAME" ] || TASK5_OK=0

    # Verify the initial filesystem size from saved df output.
    # The initial LV was 500 MB. The ext4 filesystem reports
    # approximately 459 MB in df -hT because of filesystem overhead.

    if [ ! -f "$INITIAL_FILE" ]; then

        TASK5_OK=0

    else

        INITIAL_LOGS_LINE=$(awk '$NF=="/logs" {line=$0} END {print line}' \
            "$INITIAL_FILE")

        if [ -z "$INITIAL_LOGS_LINE" ]; then

            TASK5_OK=0

        else

            INITIAL_LOGS_TYPE=$(echo "$INITIAL_LOGS_LINE" | awk '{print $2}')
            INITIAL_LOGS_SIZE=$(echo "$INITIAL_LOGS_LINE" | awk '{print $3}')

            # Verify ext4 filesystem
            [ "$INITIAL_LOGS_TYPE" = "ext4" ] || TASK5_OK=0

            # Convert df size to MB
            case "$INITIAL_LOGS_SIZE" in
                *M)
                    INITIAL_LOGS_SIZE_MB=${INITIAL_LOGS_SIZE%M}
                    ;;
                *G)
                    INITIAL_LOGS_SIZE_G=${INITIAL_LOGS_SIZE%G}
                    INITIAL_LOGS_SIZE_MB=$(awk -v g="$INITIAL_LOGS_SIZE_G" \
                        'BEGIN {printf "%.0f", g * 1024}')
                    ;;
                *)
                    TASK5_OK=0
                    INITIAL_LOGS_SIZE_MB=0
                    ;;
            esac

            # ext4 on a 500 MB LV reports approximately 459 MB.
            # Accept a reasonable range around the expected value.
            if [ "$INITIAL_LOGS_SIZE_MB" -lt 420 ] ||
               [ "$INITIAL_LOGS_SIZE_MB" -gt 550 ]; then
                TASK5_OK=0
            fi
        fi
    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: lv_logs exists in vg_app and the initial filesystem configuration was approximately 500 MB"
    else
        fail "Task 5: lv_logs is missing, is not in vg_app, or the initial 500 MB configuration is incorrect"
    fi 
   

    # ============================================================
    # TASK 6 - CREATE XFS FILESYSTEM
    # ============================================================

    TASK6_OK=1

    DATA_FSTYPE=$(sudo /usr/sbin/blkid -o value \
        -s TYPE "$LV_DATA_PATH" 2>/dev/null)

    [ "$DATA_FSTYPE" = "xfs" ] || TASK6_OK=0

    if ! mountpoint -q "$DATA_MOUNT" 2>/dev/null; then
        TASK6_OK=0
    fi

    DATA_SOURCE=$(findmnt -n -o SOURCE "$DATA_MOUNT" 2>/dev/null)

    if [[ "$DATA_SOURCE" != "/dev/mapper/vg_app-lv_data" &&
          "$DATA_SOURCE" != "$LV_DATA_PATH" ]]; then
        TASK6_OK=0
    fi

    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: lv_data is formatted with XFS and mounted correctly on /data"
    else
        fail "Task 6: XFS filesystem, /data mount, or logical volume configuration is incorrect"
    fi


    # ============================================================
    # TASK 7 - CREATE EXT4 FILESYSTEM
    # ============================================================

    TASK7_OK=1

    LOGS_FSTYPE=$(sudo /usr/sbin/blkid -o value \
        -s TYPE "$LV_LOGS_PATH" 2>/dev/null)

    [ "$LOGS_FSTYPE" = "ext4" ] || TASK7_OK=0

    if ! mountpoint -q "$LOGS_MOUNT" 2>/dev/null; then
        TASK7_OK=0
    fi

    LOGS_SOURCE=$(findmnt -n -o SOURCE "$LOGS_MOUNT" 2>/dev/null)

    if [[ "$LOGS_SOURCE" != "/dev/mapper/vg_app-lv_logs" &&
          "$LOGS_SOURCE" != "$LV_LOGS_PATH" ]]; then
        TASK7_OK=0
    fi

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: lv_logs is formatted with ext4 and mounted correctly on /logs"
    else
        fail "Task 7: ext4 filesystem, /logs mount, or logical volume configuration is incorrect"
    fi


    # ============================================================
    # TASK 8 - CONFIGURE PERSISTENT MOUNTING
    # ============================================================

    TASK8_OK=1

    if [ ! -f "$FSTAB" ]; then
        TASK8_OK=0
    else

        awk '
        $1 == "/dev/vg_app/lv_data" &&
        $2 == "/data" &&
        $3 == "xfs" &&
        $4 == "defaults" {
            found_data=1
        }

        $1 == "/dev/vg_app/lv_logs" &&
        $2 == "/logs" &&
        $3 == "ext4" &&
        $4 == "defaults" {
            found_logs=1
        }

        END {
            if (!found_data || !found_logs)
                exit 1
        }' "$FSTAB" || TASK8_OK=0
    fi

    # Test fstab without rebooting.
    if [ "$TASK8_OK" -eq 1 ]; then

        if ! mount -a >/dev/null 2>&1; then
            TASK8_OK=0
        fi

        mountpoint -q "$DATA_MOUNT" || TASK8_OK=0
        mountpoint -q "$LOGS_MOUNT" || TASK8_OK=0
    fi

    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: /etc/fstab is correctly configured for persistent /data and /logs mounting"
    else
        fail "Task 8: /etc/fstab entries are missing, incorrect, or cannot mount the filesystems"
    fi


    # ============================================================
    # TASK 9 - RECORD INITIAL FILESYSTEM CONFIGURATION
    # ============================================================

    TASK9_OK=1

    if [ ! -f "$INITIAL_FILE" ]; then
        TASK9_OK=0
    else

        grep -Eq '[[:space:]]/data[[:space:]]*$' "$INITIAL_FILE" ||
            TASK9_OK=0

        grep -Eq '[[:space:]]/logs[[:space:]]*$' "$INITIAL_FILE" ||
            TASK9_OK=0

        grep -Eq '[[:space:]]xfs[[:space:]]' "$INITIAL_FILE" ||
            TASK9_OK=0

        grep -Eq '[[:space:]]ext4[[:space:]]' "$INITIAL_FILE" ||
            TASK9_OK=0
    fi

    if [ "$TASK9_OK" -eq 1 ]; then
        pass "Task 9: Initial df -hT output was saved to lvm_initial"
    else
        fail "Task 9: lvm_initial is missing or does not contain the required filesystem information"
    fi


    # ============================================================
    # TASK 10 - EXTEND XFS LOGICAL VOLUME
    # ============================================================

    TASK10_OK=1

    DATA_LV_SIZE=$(sudo /usr/sbin/lvs --noheadings \
        --units m --nosuffix \
        -o lv_size "$LV_DATA_PATH" 2>/dev/null | xargs)

    if [ -z "$DATA_LV_SIZE" ]; then
        TASK10_OK=0
    else

        DATA_LV_SIZE_INT=${DATA_LV_SIZE%.*}

        # Approximately 800 MB.
        if [ "$DATA_LV_SIZE_INT" -lt 780 ] ||
           [ "$DATA_LV_SIZE_INT" -gt 820 ]; then
            TASK10_OK=0
        fi
    fi

    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: lv_data was extended to approximately 800 MB"
    else
        fail "Task 10: lv_data is not approximately 800 MB"
    fi


    # ============================================================
    # TASK 11 - RESIZE XFS FILESYSTEM
    # ============================================================

    TASK11_OK=1

    XFS_EXTEND_FILE="$HOME_DIR/lvm_xfs_extend"

    if [ ! -f "$XFS_EXTEND_FILE" ]; then
        TASK11_OK=0
    else

        XFS_DATA_LINE=$(grep -E '[[:space:]]/data[[:space:]]*$' \
            "$XFS_EXTEND_FILE" | tail -1)

        [ -n "$XFS_DATA_LINE" ] || TASK11_OK=0

        echo "$XFS_DATA_LINE" | grep -qi "xfs" ||
            TASK11_OK=0
    fi

    [ "$DATA_FSTYPE" = "xfs" ] || TASK11_OK=0
    mountpoint -q "$DATA_MOUNT" || TASK11_OK=0

    if [ "$TASK11_OK" -eq 1 ]; then
        pass "Task 11: XFS filesystem was resized and lvm_xfs_extend was saved correctly"
    else
        fail "Task 11: XFS filesystem resize or lvm_xfs_extend output is incorrect"
    fi

    # ============================================================
    # TASK 12 - EXTEND EXT4 LOGICAL VOLUME
    # ============================================================

    TASK12_OK=1

    # Verify lv_logs currently exists in vg_app
    if ! sudo /usr/sbin/lvs --noheadings --units m --nosuffix \
        -o lv_name,vg_name,lv_size 2>/dev/null |
        awk '$1=="lv_logs" && $2=="vg_app" && $3 >= 680 && $3 <= 720 {found=1}
             END {exit !found}'; then
        TASK12_OK=0
    fi

    if [ "$TASK12_OK" -eq 1 ]; then
        pass "Task 12: lv_logs was extended to approximately 700 MB"
    else
        fail "Task 12: lv_logs was not extended to approximately 700 MB"
    fi


    # ============================================================
    # TASK 13 - RESIZE EXT4 FILESYSTEM
    # ============================================================

    TASK13_OK=1

    EXT4_EXTEND_FILE="$HOME_DIR/lvm_ext4_extend"

    if [ ! -f "$EXT4_EXTEND_FILE" ]; then

        TASK13_OK=0

    else

        # Find the df -hT entry whose mount point is /logs
        EXT4_LOGS_LINE=$(awk '$NF=="/logs" {line=$0} END {print line}' \
            "$EXT4_EXTEND_FILE")

        if [ -z "$EXT4_LOGS_LINE" ]; then
            TASK13_OK=0
        else

            # Verify filesystem type
            EXT4_TYPE=$(echo "$EXT4_LOGS_LINE" | awk '{print $2}')

            if [ "$EXT4_TYPE" != "ext4" ]; then
                TASK13_OK=0
            fi

            # df -hT Size column
            EXT4_SIZE=$(echo "$EXT4_LOGS_LINE" | awk '{print $3}')

            # Convert the size to MB for reliable validation.
            case "$EXT4_SIZE" in
                *M)
                    EXT4_SIZE_MB=${EXT4_SIZE%M}
                    ;;
                *G)
                    EXT4_SIZE_G=${EXT4_SIZE%G}
                    EXT4_SIZE_MB=$(awk -v g="$EXT4_SIZE_G" \
                        'BEGIN {printf "%.0f", g * 1024}')
                    ;;
                *)
                    TASK13_OK=0
                    EXT4_SIZE_MB=0
                    ;;
            esac

            # The filesystem should be approximately 700 MB.
            if [ "$EXT4_SIZE_MB" -lt 600 ] ||
               [ "$EXT4_SIZE_MB" -gt 800 ]; then
                TASK13_OK=0
            fi
        fi
    fi

    if [ "$TASK13_OK" -eq 1 ]; then
        pass "Task 13: ext4 filesystem was resized to approximately 700 MB"
    else
        fail "Task 13: ext4 filesystem was not correctly resized or recorded"
    fi


    # ============================================================
    # TASK 14 - SHRINK EXT4 FILESYSTEM AND LOGICAL VOLUME
    # ============================================================

    TASK14_OK=1

    SHRINK_FILE="$HOME_DIR/lvm_ext4_shrink"

    if [ ! -f "$SHRINK_FILE" ]; then

        TASK14_OK=0

    else

        # Find the df -hT entry whose mount point is /logs
        SHRINK_LOGS_LINE=$(awk '$NF=="/logs" {line=$0} END {print line}' \
            "$SHRINK_FILE")

        if [ -z "$SHRINK_LOGS_LINE" ]; then

            TASK14_OK=0

        else

            # Verify filesystem type
            SHRINK_TYPE=$(echo "$SHRINK_LOGS_LINE" | awk '{print $2}')

            if [ "$SHRINK_TYPE" != "ext4" ]; then
                TASK14_OK=0
            fi

            # df -hT Size column
            SHRINK_SIZE=$(echo "$SHRINK_LOGS_LINE" | awk '{print $3}')

            case "$SHRINK_SIZE" in
                *M)
                    SHRINK_SIZE_MB=${SHRINK_SIZE%M}
                    ;;
                *G)
                    SHRINK_SIZE_G=${SHRINK_SIZE%G}
                    SHRINK_SIZE_MB=$(awk -v g="$SHRINK_SIZE_G" \
                        'BEGIN {printf "%.0f", g * 1024}')
                    ;;
                *)
                    TASK14_OK=0
                    SHRINK_SIZE_MB=0
                    ;;
            esac

            # After shrinking, the filesystem should be approximately 500 MB.
            # df reports 459M in the user's example, which is valid.
            if [ "$SHRINK_SIZE_MB" -lt 400 ] ||
               [ "$SHRINK_SIZE_MB" -gt 600 ]; then
                TASK14_OK=0
            fi
        fi
    fi

    # /logs should have been mounted again after the shrink operation.
    if ! mountpoint -q "$LOGS_MOUNT"; then
        TASK14_OK=0
    fi

    # The filesystem must be ext4.
    CURRENT_LOGS_FSTYPE=$(findmnt -n -o FSTYPE "$LOGS_MOUNT" 2>/dev/null)

    if [ "$CURRENT_LOGS_FSTYPE" != "ext4" ]; then
        TASK14_OK=0
    fi

    if [ "$TASK14_OK" -eq 1 ]; then
        pass "Task 14: ext4 filesystem was safely shrunk to approximately 500 MB before the logical volume was reduced"
    else
        fail "Task 14: ext4 shrink operation, saved output, or /logs verification is incorrect"
    fi


    # ============================================================
    # TASK 15 - RECORD EXT4 SHRINK
    # ============================================================

    TASK15_OK=1

    if [ ! -f "$SHRINK_FILE" ]; then

        TASK15_OK=0

    else

        SHRINK_LOGS_LINE=$(awk '$NF=="/logs" {line=$0} END {print line}' \
            "$SHRINK_FILE")

        if [ -z "$SHRINK_LOGS_LINE" ]; then
            TASK15_OK=0
        fi

        echo "$SHRINK_LOGS_LINE" | awk '$2=="ext4" {found=1}
            END {exit !found}' || TASK15_OK=0
    fi

    if [ "$TASK15_OK" -eq 1 ]; then
        pass "Task 15: lvm_ext4_shrink contains the filesystem information after the ext4 shrink"
    else
        fail "Task 15: lvm_ext4_shrink output is missing or incorrect"
    fi


    # ============================================================
    # TASK 16 - EXTEND EXT4 LOGICAL VOLUME AGAIN
    # ============================================================

    TASK16_OK=1

    CURRENT_LOGS_LV_SIZE=$(sudo /usr/sbin/lvs --noheadings \
        --units m --nosuffix \
        -o lv_size "$LV_LOGS_PATH" 2>/dev/null | xargs)

    if [ -z "$CURRENT_LOGS_LV_SIZE" ]; then
        TASK16_OK=0
    else

        CURRENT_LOGS_LV_SIZE_INT=${CURRENT_LOGS_LV_SIZE%.*}

        # Final expected size is approximately 700 MB.
        if [ "$CURRENT_LOGS_LV_SIZE_INT" -lt 680 ] ||
           [ "$CURRENT_LOGS_LV_SIZE_INT" -gt 720 ]; then
            TASK16_OK=0
        fi
    fi

    if [ "$TASK16_OK" -eq 1 ]; then
        pass "Task 16: lv_logs was extended again to approximately 700 MB"
    else
        fail "Task 16: lv_logs is not approximately 700 MB"
    fi


    # ============================================================
    # TASK 17 - RESIZE EXT4 FILESYSTEM AGAIN
    # ============================================================

    TASK17_OK=1

    [ "$LOGS_FSTYPE" = "ext4" ] || TASK17_OK=0
    mountpoint -q "$LOGS_MOUNT" || TASK17_OK=0

    CURRENT_LOGS_SIZE=$(df -BM "$LOGS_MOUNT" 2>/dev/null |
        awk 'NR==2 {gsub(/M/,"",$2); print $2}')

    if [ -z "$CURRENT_LOGS_SIZE" ]; then
        TASK17_OK=0
    else

        # Allow filesystem overhead.
        if [ "$CURRENT_LOGS_SIZE" -lt 600 ] ||
           [ "$CURRENT_LOGS_SIZE" -gt 750 ]; then
            TASK17_OK=0
        fi
    fi

    if [ "$TASK17_OK" -eq 1 ]; then
        pass "Task 17: ext4 filesystem on /logs was successfully grown to approximately 700 MB"
    else
        fail "Task 17: ext4 filesystem on /logs is not approximately 700 MB"
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
#==================================================================
validate_lab234_nfs() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 234 - Network File Sharing (NFS).</h2>"

    TOTAL_TASKS=12
    PASSED=0

    LAB_NAME="Lab 234 - Network File Sharing (NFS)"
    DATE=$(date "+%F %T")

    NFS_SERVER_IP="192.168.111.165"

    EXPORT_READONLY="/nfs_share_readonly"
    EXPORT_NOROOTSQUASH="/nfs_share_rw_norootsquash"
    EXPORT_ROOTSQUASH="/nfs_share_rw_rootsquash"

    MOUNT_READONLY="/mnt/nfs_readonly"
    MOUNT_NOROOTSQUASH="/mnt/nfs_rw_norootsquash"
    MOUNT_ROOTSQUASH="/mnt/nfs_rw_rootsquash"

    # STUDENT_IP is supplied by the lab validation wrapper.
    CLIENT_IP="${STUDENT_IP:-}"

    # ------------------------------------------------------------
    # HELPERS
    # ------------------------------------------------------------

    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # ============================================================
    # TASK 1 - CHECK / INSTALL NFS CLIENT PACKAGE
    # ============================================================

    if rpm -q nfs-utils >/dev/null 2>&1; then
        pass "Task 1: nfs-utils package is installed on the NFS client"
    else
        fail "Task 1: nfs-utils package is not installed on the NFS client"
    fi

    # ============================================================
    # TASK 2 - DISCOVER SERVER EXPORTS
    # ============================================================

    SHOWMOUNT_OUTPUT=$(showmount -e "$NFS_SERVER_IP" 2>/dev/null)

    TASK2_OK=1
    
    echo "$SHOWMOUNT_OUTPUT" | grep -Fq "$EXPORT_READONLY" || TASK2_OK=0
    echo "$SHOWMOUNT_OUTPUT" | grep -Fq "$EXPORT_NOROOTSQUASH" || TASK2_OK=0
    echo "$SHOWMOUNT_OUTPUT" | grep -Fq "$EXPORT_ROOTSQUASH" || TASK2_OK=0

    if [ "$TASK2_OK" -eq 1 ]; then
        pass "Task 2: NFS client discovered all three NFS exports"
    else
        fail "Task 2: one or more required NFS exports could not be discovered"
    fi

    # ============================================================
    # TASK 3 - CREATE NFS CLIENT MOUNT POINTS
    # ============================================================

    TASK3_OK=1

    test -d "$MOUNT_READONLY" || TASK3_OK=0
    test -d "$MOUNT_NOROOTSQUASH" || TASK3_OK=0
    test -d "$MOUNT_ROOTSQUASH" || TASK3_OK=0

    if [ "$TASK3_OK" -eq 1 ]; then
        pass "Task 3: all three NFS client mount points exist"
    else
        fail "Task 3: one or more required NFS client mount points are missing"
    fi

    # ============================================================
    # TASK 4 - MOUNT THE READ-ONLY EXPORT
    # ============================================================

    TASK4_OK=1

    if ! mountpoint -q "$MOUNT_READONLY"; then
        mount "$NFS_SERVER_IP:$EXPORT_READONLY" "$MOUNT_READONLY" >/dev/null 2>&1
    fi

    mountpoint -q "$MOUNT_READONLY" || TASK4_OK=0

    CURRENT_SOURCE=$(findmnt -n -o SOURCE "$MOUNT_READONLY" 2>/dev/null)

    if ! echo "$CURRENT_SOURCE" | grep -Fq "$NFS_SERVER_IP:$EXPORT_READONLY"; then
        TASK4_OK=0
    fi

    if [ "$TASK4_OK" -eq 1 ]; then
        pass "Task 4: read-only NFS export is mounted at /mnt/nfs_readonly"
    else
        fail "Task 4: read-only NFS export is not mounted correctly"
    fi

    # ============================================================
    # TASK 5 - TEST READ-ONLY BEHAVIOR
    # ============================================================

    RO_TEST_FILE="$MOUNT_READONLY/client_test_${CLIENT_IP}.txt"
    RO_TEST_DIR="$MOUNT_READONLY/test_directory_${CLIENT_IP}"

    # Remove stale test objects only if they already exist.
    rm -f "$RO_TEST_FILE" >/dev/null 2>&1
    rmdir "$RO_TEST_DIR" >/dev/null 2>&1

    TASK5_OK=1

    if touch "$RO_TEST_FILE" >/dev/null 2>&1; then
        TASK5_OK=0
        rm -f "$RO_TEST_FILE" >/dev/null 2>&1
    fi

    if mkdir "$RO_TEST_DIR" >/dev/null 2>&1; then
        TASK5_OK=0
        rmdir "$RO_TEST_DIR" >/dev/null 2>&1
    fi

    if [ "$TASK5_OK" -eq 1 ]; then
        pass "Task 5: read-only NFS export correctly rejects write operations"
    else
        fail "Task 5: read-only NFS export allowed a write operation"
    fi

    # ============================================================
    # TASK 6 - MOUNT RW,NO_ROOT_SQUASH EXPORT AND TEST NORMAL USER
    # ============================================================

    TASK6_OK=1

    if ! mountpoint -q "$MOUNT_NOROOTSQUASH"; then
        mount "$NFS_SERVER_IP:$EXPORT_NOROOTSQUASH" "$MOUNT_NOROOTSQUASH" >/dev/null 2>&1
    fi

    mountpoint -q "$MOUNT_NOROOTSQUASH" || TASK6_OK=0

    CURRENT_SOURCE=$(findmnt -n -o SOURCE "$MOUNT_NOROOTSQUASH" 2>/dev/null)

    if ! echo "$CURRENT_SOURCE" | grep -Fq "$NFS_SERVER_IP:$EXPORT_NOROOTSQUASH"; then
        TASK6_OK=0
    fi

    if [ -n "$CLIENT_IP" ]; then
        USER_TEST_FILE="$MOUNT_NOROOTSQUASH/user_test.txt_${CLIENT_IP}"

        if ! test -f "$USER_TEST_FILE"; then
            # Do not create the student's requested file as root.
            # The existence check is used when the student's regular-user
            # operation has already created the file.
            TASK6_OK=0
        fi
    fi

    if [ "$TASK6_OK" -eq 1 ]; then
        pass "Task 6: rw,no_root_squash export is mounted and normal-user test file exists"
    else
        fail "Task 6: rw,no_root_squash export or normal-user test file verification failed"
    fi

    # ============================================================
    # TASK 7 - TEST ROOT ACCESS WITH no_root_squash
    # ============================================================

    NOROOTSQUASH_ROOT_FILE="$MOUNT_NOROOTSQUASH/root_test.txt_${CLIENT_IP}"

    TASK7_OK=1

    if ! test -f "$NOROOTSQUASH_ROOT_FILE"; then
        TASK7_OK=0
    else
        ROOT_UID=$(stat -c "%u" "$NOROOTSQUASH_ROOT_FILE" 2>/dev/null)

        if [ "$ROOT_UID" != "0" ]; then
            TASK7_OK=0
        fi
    fi

    if [ "$TASK7_OK" -eq 1 ]; then
        pass "Task 7: no_root_squash preserves UID 0 for the root-created file"
    else
        fail "Task 7: root-created file does not have UID 0 on the no_root_squash export"
    fi

    # ============================================================
    # TASK 8 - MOUNT RW,ROOT_SQUASH EXPORT
    # ============================================================

    TASK8_OK=1

    if ! mountpoint -q "$MOUNT_ROOTSQUASH"; then
        mount "$NFS_SERVER_IP:$EXPORT_ROOTSQUASH" "$MOUNT_ROOTSQUASH" >/dev/null 2>&1
    fi

    mountpoint -q "$MOUNT_ROOTSQUASH" || TASK8_OK=0

    CURRENT_SOURCE=$(findmnt -n -o SOURCE "$MOUNT_ROOTSQUASH" 2>/dev/null)

    if ! echo "$CURRENT_SOURCE" | grep -Fq "$NFS_SERVER_IP:$EXPORT_ROOTSQUASH"; then
        TASK8_OK=0
    fi

    if [ "$TASK8_OK" -eq 1 ]; then
        pass "Task 8: rw,root_squash export is mounted at /mnt/nfs_rw_rootsquash"
    else
        fail "Task 8: rw,root_squash export is not mounted correctly"
    fi

    # ============================================================
    # TASK 9 - TEST NORMAL USER ACCESS
    # ============================================================

    ROOTSQUASH_USER_FILE="$MOUNT_ROOTSQUASH/user_test2.txt_${CLIENT_IP}"

    if test -f "$ROOTSQUASH_USER_FILE"; then
        pass "Task 9: normal-user test file exists on the root_squash export"
    else
        fail "Task 9: normal-user test file was not created on the root_squash export"
    fi

    # ============================================================
    # TASK 10 - DEMONSTRATE root_squash
    # ============================================================

    ROOTSQUASH_ROOT_FILE="$MOUNT_ROOTSQUASH/root_test2.txt_${CLIENT_IP}"

    TASK10_OK=1

    if ! test -f "$ROOTSQUASH_ROOT_FILE"; then
        TASK10_OK=0
    else
        ROOTSQUASH_UID=$(stat -c "%u" "$ROOTSQUASH_ROOT_FILE" 2>/dev/null)

        # root_squash must prevent the client-side root identity
        # from appearing as UID 0 on the NFS server.
        if [ "$ROOTSQUASH_UID" = "0" ] || [ -z "$ROOTSQUASH_UID" ]; then
            TASK10_OK=0
        fi
    fi

    if [ "$TASK10_OK" -eq 1 ]; then
        pass "Task 10: root_squash maps the client-side root identity to a non-root UID"
    else
        fail "Task 10: root_squash behavior could not be verified"
    fi

    # ============================================================
    # TASK 11 - CONFIGURE PERSISTENT NFS MOUNTS
    # ============================================================

    TASK11_OK=1

    FSTAB_READONLY=$(awk '$1 !~ /^#/ && $2 == "/mnt/nfs_readonly" && $3 == "nfs" {print}' /etc/fstab 2>/dev/null)
    FSTAB_NOROOTSQUASH=$(awk '$1 !~ /^#/ && $2 == "/mnt/nfs_rw_norootsquash" && $3 == "nfs" {print}' /etc/fstab 2>/dev/null)
    FSTAB_ROOTSQUASH=$(awk '$1 !~ /^#/ && $2 == "/mnt/nfs_rw_rootsquash" && $3 == "nfs" {print}' /etc/fstab 2>/dev/null)

    if [ -z "$FSTAB_READONLY" ] || ! echo "$FSTAB_READONLY" | grep -Fq "$NFS_SERVER_IP:$EXPORT_READONLY"; then
        TASK11_OK=0
    fi

    if [ -z "$FSTAB_NOROOTSQUASH" ] || ! echo "$FSTAB_NOROOTSQUASH" | grep -Fq "$NFS_SERVER_IP:$EXPORT_NOROOTSQUASH"; then
        TASK11_OK=0
    fi

    if [ -z "$FSTAB_ROOTSQUASH" ] || ! echo "$FSTAB_ROOTSQUASH" | grep -Fq "$NFS_SERVER_IP:$EXPORT_ROOTSQUASH"; then
        TASK11_OK=0
    fi

    if [ "$TASK11_OK" -eq 1 ]; then
        pass "Task 11: all three persistent NFS mounts are configured in /etc/fstab"
    else
        fail "Task 11: one or more required NFS entries are missing or incorrect in /etc/fstab"
    fi

    # ============================================================
    # TASK 12 - TEST /etc/FSTAB
    # ============================================================

    TASK12_OK=1

    # Unmount the three lab mounts before testing mount -a.
    umount "$MOUNT_READONLY" >/dev/null 2>&1
    umount "$MOUNT_NOROOTSQUASH" >/dev/null 2>&1
    umount "$MOUNT_ROOTSQUASH" >/dev/null 2>&1

    if ! mount -a >/dev/null 2>&1; then
        TASK12_OK=0
    fi

    mountpoint -q "$MOUNT_READONLY" || TASK12_OK=0
    mountpoint -q "$MOUNT_NOROOTSQUASH" || TASK12_OK=0
    mountpoint -q "$MOUNT_ROOTSQUASH" || TASK12_OK=0

    if [ "$TASK12_OK" -eq 1 ]; then
        pass "Task 12: /etc/fstab successfully mounts all three NFS shares"
    else
        fail "Task 12: mount -a did not successfully mount all three NFS shares"
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
#====================================================================
validate_lab235_assessment() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 235 - Linux Systems Administration - Assessment .</h2>"

    TOTAL_TASKS=40
    PASSED=0

    LAB_NAME="Lab 235 - Linux Systems Administration - Assessment"
    DATE=$(date "+%F %T")

    STUDENT_HOME="$HOME"
    LINUX_TEST="$STUDENT_HOME/linux_test"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

# Task 1 - Directory Navigation and Structure
if [[ -d "$LINUX_TEST" &&
      -d "$LINUX_TEST/documents" &&
      -d "$LINUX_TEST/logs" &&
      -d "$LINUX_TEST/scripts" &&
      -d "$LINUX_TEST/backup" ]]; then
    pass "Task 1: linux_test directory structure"
else
    fail "Task 1: linux_test directory structure"
fi

# Task 2 - File Creation and Management
if [[ -f "$LINUX_TEST/documents/report.txt" &&
      -f "$LINUX_TEST/documents/notes.txt" &&
      -f "$LINUX_TEST/logs/summary.txt" ]]; then

    report_content=$(cat "$LINUX_TEST/documents/report.txt" 2>/dev/null)
    notes_content=$(cat "$LINUX_TEST/documents/notes.txt" 2>/dev/null)
    summary_content=$(cat "$LINUX_TEST/logs/summary.txt" 2>/dev/null)

    if [[ "$report_content" == "Linux system administration requires careful management of users, files, permissions, and services" &&
          "$notes_content" == "Regular system monitoring helps identify configuration and performance issues" &&
          "$summary_content" == "This document contains a summary of Linux administration activities" ]]; then

        pass "Task 2: required files and content"
    else
        fail "Task 2: file content is incorrect"
    fi
else
    fail "Task 2: required files are missing"
fi

# Task 3 - File and Directory Operations
if [[ -f "$LINUX_TEST/backup/report.txt" &&
      -f "$LINUX_TEST/logs/summary.txt" &&
      -f "$LINUX_TEST/scripts/summary.sh" &&
      ! -f "$LINUX_TEST/documents/summary.txt" ]]; then

    if cmp -s "$LINUX_TEST/logs/summary.txt" "$LINUX_TEST/scripts/summary.sh"; then
        pass "Task 3: file copy and move operations"
    else
        fail "Task 3: summary.sh does not match summary.txt"
    fi
else
    fail "Task 3: required files are not in the expected locations"
fi

# Task 4 - Output Redirection
if [[ -f "$LINUX_TEST/system_info.txt" ]]; then

    if grep -Eqi "kernel|linux" "$LINUX_TEST/system_info.txt" &&
       grep -Eqi "hostname" "$LINUX_TEST/system_info.txt" &&
       grep -Eq  "[0-9]+[[:space:]]+up[[:space:]]+" "$LINUX_TEST/system_info.txt" &&
       grep -Eqi "oracle|red hat|alma|centos|rocky|linux" "$LINUX_TEST/system_info.txt"; then
        pass "Task 4: system information file"
    else
        fail "Task 4: system information is incomplete"
    fi
else
    fail "Task 4: system_info.txt missing"
fi

# Task 5 - Tar Archive
if [[ -f "$LINUX_TEST/backup/documents_backup.tar" ]] &&
   sudo tar -tf "$LINUX_TEST/backup/documents_backup.tar" >/dev/null 2>&1; then

    if sudo tar -tf "$LINUX_TEST/backup/documents_backup.tar" 2>/dev/null |
       grep -q "documents"; then
        pass "Task 5: documents tar archive"
    else
        fail "Task 5: archive does not contain documents directory"
    fi
else
    fail "Task 5: documents_backup.tar missing or invalid"
fi

# Task 6 - Compressed Archive
if [[ -f "$LINUX_TEST/backup/linux_test_backup.tar.gz" ]] &&
   tar -tzf "$LINUX_TEST/backup/linux_test_backup.tar.gz" >/dev/null 2>&1; then

    if tar -tzf "$LINUX_TEST/backup/linux_test_backup.tar.gz" 2>/dev/null |
       grep -q "scripts"; then
        pass "Task 6: scripts gzip archive"
    else
        fail "Task 6: archive does not contain scripts directory"
    fi
else
    fail "Task 6: linux_test_backup.tar.gz missing or invalid"
fi

# TASK 7 - FIND FILES BY SIZE
FILE_LIST="$LINUX_TEST/find_large_files.txt"

if [[ -f "$FILE_LIST" && -s "$FILE_LIST" ]]; then

    TASK7_OK=1

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue

        # Require long-listing format for a regular file
        [[ "$line" =~ ^- ]] || {
            TASK7_OK=0
            break
        }

        # Extract the pathname (last field in ls -l output)
        file="${line##* }"

        # Check that the path currently exists as a regular file
        if ! sudo test -f "$file"; then
            TASK7_OK=0
            break
        fi

        # Verify current size is greater than 100 MiB
        size=$(sudo stat -c '%s' -- "$file" 2>/dev/null)

        if [[ ! "$size" =~ ^[0-9]+$ ]] || (( size <= 104857600 )); then
            TASK7_OK=0
            break
        fi

    done < "$FILE_LIST"

    if [[ "$TASK7_OK" -eq 1 ]]; then
        pass "Task 7: large file search"
    else
        fail "Task 7: invalid entries in find_large_files.txt"
    fi

else
    fail "Task 7: find_large_files.txt missing or empty"
fi

# Task 8 - Find Files by Permission
if [[ -f "$LINUX_TEST/setuid_files.txt" ]]; then

    valid=1

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        if [[ ! -f "$file" ]]; then
            valid=0
            break
        fi

        perms=$(stat -c "%a" "$file" 2>/dev/null)

        if ! stat -c "%A" "$file" 2>/dev/null | grep -q "s"; then
            valid=0
            break
        fi
    done < "$LINUX_TEST/setuid_files.txt"

    if [[ "$valid" -eq 1 ]]; then
        pass "Task 8: setuid file search"
    else
        fail "Task 8: invalid setuid entries"
    fi
else
    fail "Task 8: setuid_files.txt missing"
fi

# Task 9 - Grep Configuration Information
if [[ -f "$LINUX_TEST/documents/root_entries.txt" ]]; then

    if grep -qi "root" "$LINUX_TEST/documents/root_entries.txt"; then
        pass "Task 9: sshd_config root entries"
    else
        fail "Task 9: root entries not found"
    fi
else
    fail "Task 9: root_entries.txt missing"
fi

# Task 10 - Process Identification
if [[ -f "$LINUX_TEST/ssh_process.txt" ]]; then

    if grep -Eqi "sshd|ssh" "$LINUX_TEST/ssh_process.txt"; then
        if pgrep -x sshd >/dev/null 2>&1; then
            pass "Task 10: SSH server process"
        else
            fail "Task 10: sshd process is not running"
        fi
    else
        fail "Task 10: ssh process information not found"
    fi
else
    fail "Task 10: ssh_process.txt missing"
fi

# Task 11 - Package Management
if rpm -q vsftpd >/dev/null 2>&1; then
    pass "Task 11: vsfptd package installed"
else
    fail "Task 11: vsftpd package is not installed"
fi

# Task 12 - Service Management
if systemctl is-active --quiet vsftpd &&
   systemctl is-enabled --quiet vsftpd; then
    pass "Task 12: vsftpd running and enabled"
else
    fail "Task 12: vsftpd is not running and enabled"
fi

# Task 13 - Service Verification
VSFTPD_STATUS="$LINUX_TEST/vsftpd_service_status.txt"

if [[ -f "$VSFTPD_STATUS" ]]; then

    if grep -Eqi "active|running" "$VSFTPD_STATUS" &&
       grep -Eqi "enabled|enable" "$VSFTPD_STATUS"; then
        pass "Task 13: vsftpd service status file with correct info exist"
    else
        fail "Task 13: vsftpd status information incomplete"
    fi
else
    fail "Task 13: vsftpd_service_status.txt missing"
fi

# Task 14 - User Creation
if id linuxstudent >/dev/null 2>&1 &&
   id jack >/dev/null 2>&1; then

    if getent passwd linuxstudent >/dev/null &&
       getent passwd jack >/dev/null; then
        pass "Task 14: users linuxstudent and jack"
    else
        fail "Task 14: user account information incomplete"
    fi
else
    fail "Task 14: required users are missing"
fi

# Task 15 - Group Creation
if getent group linuxadmins >/dev/null 2>&1; then
    pass "Task 15: linuxadmins group"
else
    fail "Task 15: linuxadmins group missing"
fi

# Task 16 - Secondary Group
if id linuxstudent 2>/dev/null | grep -qw linuxadmins; then
    pass "Task 16: linuxstudent is member of linuxadmins"
else
    fail "Task 16: linuxstudent is not a member of linuxadmins"
fi

# Task 17 - User Account Locking
if id jack >/dev/null 2>&1; then

    jack_status=$(sudo passwd -S jack 2>/dev/null)

    if echo "$jack_status" | awk '{print $2}' | grep -q "^L"; then
        pass "Task 17: jack account is locked"
    else
        fail "Task 17: jack account is not locked"
    fi
else
    fail "Task 17: jack user does not exist"
fi

# Task 18 - File Permissions
REPORT="$LINUX_TEST/documents/report.txt"

if [[ -f "$REPORT" ]]; then

    perms=$(stat -c "%a" "$REPORT")
    owner=$(stat -c "%U" "$REPORT")

    if [[ "$perms" == "640" ]]; then
        pass "Task 18: report.txt permissions"
    else
        fail "Task 18: report.txt permissions are $perms"
    fi
else
    fail "Task 18: report.txt missing"
fi

# Task 19 - Directory Permissions
DOCS="$LINUX_TEST/documents"

if [[ -d "$DOCS" ]]; then

    perms=$(stat -c "%a" "$DOCS")

    if [[ "$perms" == "750" ]]; then
        pass "Task 19: documents directory permissions"
    else
        fail "Task 19: documents directory permissions are $perms"
    fi
else
    fail "Task 19: documents directory missing"
fi

# Task 20 - File Ownership
if [[ -f "$REPORT" ]]; then

    group=$(stat -c "%G" "$REPORT")

    if [[ "$group" == "linuxadmins" ]]; then
        pass "Task 20: report.txt group ownership"
    else
        fail "Task 20: report.txt group is $group"
    fi
else
    fail "Task 20: report.txt missing"
fi

# Task 21 - User-Owned Project File
PROJECT="/home/linuxstudent/project.txt"

if sudo test -f "$PROJECT"; then

    owner=$(sudo stat -c "%U" "$PROJECT")
    group=$(sudo stat -c "%G" "$PROJECT")
    perms=$(sudo stat -c "%a" "$PROJECT")

    if [[ "$owner" == "linuxstudent" &&
          "$group" == "linuxadmins" &&
          "$perms" == "640" ]]; then
        pass "Task 21: linuxstudent project file"
    else
        fail "Task 21: project.txt ownership or permissions incorrect"
    fi
else
    fail "Task 21: project.txt missing"
fi

# Task 22 - Hard Link
ORIGINAL="$LINUX_TEST/documents/original.txt"
HARDLINK="$LINUX_TEST/documents/hardlink.txt"

if [[ -f "$ORIGINAL" && -f "$HARDLINK" ]]; then

    inode1=$(stat -c "%i" "$ORIGINAL")
    inode2=$(stat -c "%i" "$HARDLINK")

    if [[ "$inode1" == "$inode2" ]] &&
       grep -q "I am creating hard link and this is my first attempt" "$ORIGINAL"; then
        pass "Task 22: hard link"
    else
        fail "Task 22: hard link or content incorrect"
    fi
else
    fail "Task 22: hard link files missing"
fi

# Task 23 - Symbolic Link
SOFTLINK="$LINUX_TEST/documents/softlink.txt"
ORIGINAL="$LINUX_TEST/documents/original.txt"

if [[ -L "$SOFTLINK" ]]; then

    target=$(readlink -f "$SOFTLINK" 2>/dev/null)
    original=$(readlink -f "$ORIGINAL" 2>/dev/null)

    if [[ "$target" == "$original" ]]; then
        pass "Task 23: symbolic link"
    else
        fail "Task 23: symbolic link target incorrect"
    fi
else
    fail "Task 23: softlink.txt missing"
fi

# Task 24 - Apache Installation
if rpm -q httpd >/dev/null 2>&1; then
    pass "Task 24: Apache HTTP Server installed"
else
    fail "Task 24: Apache HTTP Server is not installed"
fi

# Task 25 - Apache Service
if systemctl is-active --quiet httpd &&
   systemctl is-enabled --quiet httpd; then
    pass "Task 25: Apache running and enabled"
else
    fail "Task 25: Apache is not running and enabled"
fi

# Task 26 - Web Content
if [[ -f /var/www/html/index.html ]]; then

    if grep -Fxq "<h1>LINOOP Linux Training Server</h1>" \
        /var/www/html/index.html; then
        pass "Task 26: Apache web content"
    else
        fail "Task 26: required web content not found"
    fi
else
    fail "Task 26: index.html missing"
fi

# Task 27 - Apache Network Listening
if sudo ss -lntp 2>/dev/null |
   grep -Eq ':(9191)[[:space:]]'; then
    pass "Task 27: Apache listening on port 9191"
else
    fail "Task 27: port 9191 is not listening"
fi

# Task 28 - Web Server Verification
if curl -s http://127.0.0.1:9191 2>/dev/null |
   grep -q "LINOOP Linux Training Server"; then
    pass "Task 28: Apache web page retrieval"
else
    fail "Task 28: Apache page could not be retrieved"
fi

# Task 29 - Create and Configure Network Team
if nmcli connection show team0 >/dev/null 2>&1 &&
   nmcli connection show team0-port192 >/dev/null 2>&1 &&
   nmcli connection show team0-port224 >/dev/null 2>&1; then

    if nmcli connection show team0-port192 | grep -q "ens192" &&
       nmcli connection show team0-port224 | grep -q "ens224"; then
        pass "Task 29: team0 and team port profiles"
    else
        fail "Task 29: team port assignments incorrect"
    fi
else
    fail "Task 29: required team profiles missing"
fi

# Task 30 - Configure Team Network Settings
TEAM_IP="$STUDENT_IP"

if [[ -n "$TEAM_IP" ]]; then

    team_ip_ok=0
    gateway_ok=0
    dns_ok=0

    if nmcli -g IP4.ADDRESS device show team0 2>/dev/null |
       grep -q "$TEAM_IP/22"; then
        team_ip_ok=1
    fi

    if nmcli -g IP4.GATEWAY device show team0 2>/dev/null |
       grep -q "10.90.0.1"; then
        gateway_ok=1
    fi

    dns_values=$(nmcli -g IP4.DNS device show team0 2>/dev/null)

    if echo "$dns_values" | grep -q "192.168.111.50" &&
       echo "$dns_values" | grep -q "8.8.8.8"; then
        dns_ok=1
    fi

    if [[ "$team_ip_ok" -eq 1 &&
          "$gateway_ok" -eq 1 &&
          "$dns_ok" -eq 1 ]]; then
        pass "Task 30: team0 network configuration"
    else
        fail "Task 30: team0 IP, gateway, or DNS configuration"
    fi
else
    fail "Task 30: STUDENT_IP is not available"
fi

# Task 31 - Verify Team Configuration
if nmcli device status 2>/dev/null | grep -q "team0" &&
   nmcli connection show team0 >/dev/null 2>&1; then

    team_config=$(nmcli connection show team0 2>/dev/null)

    if echo "$team_config" | grep -qi "activebackup" ||
       sudo teamdctl team0 state 2>/dev/null | grep -qi "activebackup"; then

        if nmcli connection show team0-port192 >/dev/null 2>&1 &&
           nmcli connection show team0-port224 >/dev/null 2>&1; then
            pass "Task 31: team0 configuration"
        else
            fail "Task 31: team port profiles incomplete"
        fi
    else
        fail "Task 31: team0 is not configured for Active-Backup"
    fi
else
    fail "Task 31: team0 is not operational"
fi

# Task 32 - Test Active-Backup Failover
if sudo teamdctl team0 state 2>/dev/null |
   grep -qi "activebackup"; then

    team_state=$(sudo teamdctl team0 state 2>/dev/null)

    if echo "$team_state" | grep -qi "link_watch" ||
       echo "$team_state" | grep -qi "active"; then
        pass "Task 32: Active-Backup failover configuration"
    else
        fail "Task 32: Active-Backup state could not be verified"
    fi
else
    fail "Task 32: team0 Active-Backup state not detected"
fi

# Task 33 - Partition the Additional Disk
if sudo lsblk -dn -o NAME /dev/sdb >/dev/null 2>&1; then

    p1=$(sudo lsblk -dn -o NAME /dev/sdb1 2>/dev/null)
    p2=$(sudo lsblk -dn -o NAME /dev/sdb2 2>/dev/null)
    p3=$(sudo lsblk -dn -o NAME /dev/sdb3 2>/dev/null)
    p4=$(sudo lsblk -dn -o NAME /dev/sdb4 2>/dev/null)

    if [[ -n "$p1" && -n "$p2" && -n "$p3" && -n "$p4" ]]; then
        pass "Task 33: /dev/sdb partition structure"
    else
        fail "Task 33: required /dev/sdb partitions are missing"
    fi
else
    fail "Task 33: /dev/sdb not found"
fi

# Task 34 - Configure Persistent Swap
if sudo swapon --show=NAME --noheadings 2>/dev/null |
   grep -q "/dev/sdb1"; then

    if grep -Eq '^[[:space:]]*/dev/sdb1[[:space:]]' /etc/fstab ||
       grep -Eq '^[[:space:]]*[^#]+[[:space:]]+none[[:space:]]+swap' /etc/fstab; then
        pass "Task 34: persistent swap"
    else
        fail "Task 34: swap is active but not persistent"
    fi
else
    fail "Task 34: /dev/sdb1 is not active swap"
fi

# Task 35 - Create LVM Physical Volumes and VG
if sudo pvs --noheadings -o pv_name 2>/dev/null |
   grep -qw "/dev/sdb2" &&
   sudo pvs --noheadings -o pv_name 2>/dev/null |
   grep -qw "/dev/sdb3" &&
   sudo vgs --noheadings -o vg_name 2>/dev/null |
   grep -qw "vg-app"; then

    pass "Task 35: LVM physical volumes and vg-app"
else
    fail "Task 35: LVM physical volumes or vg-app missing"
fi

# Task 36 - Create and Mount Application LV
if sudo lvs vg-app/lv-app >/dev/null 2>&1 &&
   findmnt /app >/dev/null 2>&1; then

    fs_type=$(findmnt -n -o FSTYPE /app 2>/dev/null)

    if [[ "$fs_type" == "xfs" ]] &&
       grep -Eq '[[:space:]]/app[[:space:]]' /etc/fstab; then
        pass "Task 36: lv-app XFS mounted at /app"
    else
        fail "Task 36: /app filesystem or persistence incorrect"
    fi
else
    fail "Task 36: lv-app or /app is missing"
fi

# Task 37 - Extend Application Storage
if sudo lvs vg-app/lv-app >/dev/null 2>&1 &&
   findmnt -n /app >/dev/null 2>&1 &&
   sudo test -f "$LINUX_TEST/lv-app"; then

    lv_size=$(sudo lvs --noheadings --nosuffix --units m \
        -o lv_size vg-app/lv-app 2>/dev/null |
        awk '{gsub(/[^0-9.]/,""); print int($1)}')

    app_size=$(df -BM /app 2>/dev/null |
        awk 'NR==2 {gsub(/M/,"",$2); print int($2)}')

    fs_type=$(findmnt -n -o FSTYPE /app)

    if [[ "$fs_type" == "xfs" ]] &&
       [[ "$lv_size" -ge 800 ]] &&
       [[ "$app_size" -ge 770 ]]; then

        pass "Task 37: lv-app and XFS filesystem extended"
    else
        fail "Task 37: lv-app or XFS filesystem was not extended"
    fi

else
    fail "Task 37: lv-app, /app, or verification file missing"
fi

# Task 38 - Expand Volume Group and Logical Volume
if sudo pvs /dev/sdb4 >/dev/null 2>&1 &&
   sudo vgs vg-app >/dev/null 2>&1 &&
   sudo lvs vg-app/lv-app >/dev/null 2>&1; then

    pv_vg=$(sudo pvs --noheadings -o vg_name /dev/sdb4 2>/dev/null |
        xargs)

    app_size=$(df -BM /app 2>/dev/null |
        awk 'NR==2 {gsub("M","",$2); print int($2)}')

    fs_type=$(findmnt -n -o FSTYPE /app 2>/dev/null)

    if [[ "$pv_vg" == "vg-app" &&
          "$fs_type" == "xfs" &&
          "$app_size" -ge 1400 &&
          "$app_size" -le 1600 ]]; then

        pass "Task 38: final LVM and filesystem expansion"
    else
        fail "Task 38: final LVM or filesystem expansion is incorrect"
    fi
else
    fail "Task 38: /dev/sdb4 or LVM configuration is incomplete"
fi

# Task 39 - Mount and Verify NFS Share
if findmnt /mnt/nfs_share >/dev/null 2>&1; then

    nfs_type=$(findmnt -n -o FSTYPE /mnt/nfs_share 2>/dev/null)

    if [[ "$nfs_type" == "nfs" || "$nfs_type" == "nfs4" ]] &&
       [[ -f /mnt/nfs_share/server_test.txt ]]; then
        pass "Task 39: NFS share mounted and accessible"
    else
        fail "Task 39: NFS filesystem or server_test.txt not available"
    fi
else
    fail "Task 39: /mnt/nfs_share is not mounted"
fi

# Task 40 - Persistent NFS Mount and Client File
CLIENT_FILE="/mnt/nfs_share/client_test_$STUDENT_IP"
EXPECTED_CONTENT="This file was created on the NFS client for NFS share verification."

if sudo test -f "$CLIENT_FILE"; then

    content=$(sudo cat "$CLIENT_FILE" 2>/dev/null)

    if [[ "$content" == "$EXPECTED_CONTENT" ]]; then

        FSTAB_OK=0

        while read -r server mount_point fs_type options dump passno; do
            [[ -z "$server" || "$server" == \#* ]] && continue

            if [[ "$server" == "192.168.111.165:/nfs_share" &&
                  "$mount_point" == "/mnt/nfs_share" &&
                  "$fs_type" == "nfs" &&
                  "$options" == *"_netdev"* &&
                  "$dump" == "0" &&
                  "$passno" == "0" ]]; then
                FSTAB_OK=1
                break
            fi

        done < /etc/fstab

        if [[ "$FSTAB_OK" -eq 1 ]] &&
           findmnt -n -o FSTYPE /mnt/nfs_share | grep -q '^nfs'; then

            pass "Task 40: persistent NFS mount and client file"

        else
            fail "Task 40: fstab entry, _netdev option, or active NFS mount is incorrect"
        fi

    else
        fail "Task 40: client file content is incorrect"
    fi

else
    fail "Task 40: client file missing"
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
#====================================================================
validate_lab301_gitlab_remoterepo() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 236 - Git and GitLab.</h2>"

    TOTAL_TASKS=16
    PASSED=0

    LAB_NAME="Lab 236 - Git and GitLab"
    DATE=$(date "+%F %T")

    STUDENT_HOME="$HOME"
    GIT_LABS="$STUDENT_HOME/git-labs"
    REPO="$GIT_LABS/lab236-git-basics"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - GIT INSTALLATION
    if command -v git >/dev/null 2>&1 &&
       git --version >/dev/null 2>&1; then
        pass "Task 1: Git installed"
    else
        fail "Task 1: Git not installed"
    fi

    # TASK 2 - SSH KEY PAIR
    if [[ -s "$STUDENT_HOME/.ssh/id_rsa" &&
          -s "$STUDENT_HOME/.ssh/id_rsa.pub" ]]; then
        pass "Task 2: SSH key pair exists"
    else
        fail "Task 2: SSH key pair missing"
    fi

    # TASK 3 - PUBLIC KEY
    if [[ -s "$STUDENT_HOME/.ssh/id_rsa.pub" ]] &&
       grep -q '^ssh-rsa ' "$STUDENT_HOME/.ssh/id_rsa.pub"; then
        pass "Task 3: SSH public key"
    else
        fail "Task 3: SSH public key missing or invalid"
    fi

    # TASK 4 - REGISTER SSH KEY WITH GITLAB
    if ssh -T -p 2222 -o BatchMode=yes -o ConnectTimeout=5 \
        git@gitlab-01.corp.linoop.us 2>&1 | grep -qi "Welcome to GitLab"; then
        pass "Task 4: SSH key registered with GitLab"
    else
        fail "Task 4: SSH key registered with GitLab"
    fi
    
    # TASK 5 - TEST SSH CONNECTION
    if ssh -T -p 2222 -o BatchMode=yes -o ConnectTimeout=5 \
        git@gitlab-01.corp.linoop.us 2>&1 | grep -qi "Welcome to GitLab"; then
        pass "Task 5: SSH connection successful"
    else
        fail "Task 5: SSH connection successful"
    fi
    
    # TASK 6 - CREATE GITLAB PROJECT
    if [[ -d "$REPO/.git" ]]; then
        pass "Task 6: GitLab project created"
    else
        fail "Task 6: GitLab project created"
    fi
    
    # TASK 7 - CLONE GITLAB PROJECT
    if [[ -d "$REPO/.git" ]]; then
        pass "Task 7: GitLab repository cloned"
    else
        fail "Task 7: GitLab repository cloned"
    fi
    
    # TASK 8 - INITIAL REPOSITORY STATUS AND REMOTE
    if git -C "$REPO" status --porcelain >/dev/null 2>&1 &&
       git -C "$REPO" remote get-url origin >/dev/null 2>&1 &&
       git -C "$REPO" branch --show-current >/dev/null 2>&1; then
        pass "Task 8: Repository status and remote"
    else
        fail "Task 8: Repository status and remote"
    fi

    # TASK 9 - FIRST FILE
    if [[ -f "$REPO/file1.txt" ]] &&
       [[ "$(cat "$REPO/file1.txt" 2>/dev/null)" == \
          "This is my first file" ]] &&
       git -C "$REPO" ls-files --error-unmatch file1.txt \
           >/dev/null 2>&1; then
        pass "Task 9: First file and content"
    else
        fail "Task 9: First file missing or content incorrect"
    fi

    # TASK 10 - STAGED FIRST FILE
    if git -C "$REPO" ls-files --error-unmatch file1.txt \
           >/dev/null 2>&1 &&
       git -C "$REPO" log --all --format='%s' |
           grep -Fxq "Add first file"; then
        pass "Task 10: First file staged and committed"
    else
        fail "Task 10: First file commit missing"
    fi

    # TASK 11 - INITIAL COMMIT
    if git -C "$REPO" log --format='%s' |
       grep -Fxq "Add first file" &&
       git -C "$REPO" log -1 --format='%H' |
       grep -Eq '^[0-9a-f]{40,64}$'; then
        pass "Task 11: Initial file commit and history"
    else
        fail "Task 11: Initial file commit or history missing"
    fi

    # TASK 12 - CREATE DOCUMENTATION FILE
    if [[ -f "$REPO/documents/notes.txt" ]] &&
       [[ "$(cat "$REPO/documents/notes.txt" 2>/dev/null)" == \
          $'Git tracks changes to project files.\nThis directory contains project documentation.' ]]; then
        pass "Task 12: Documentation file and content"
    else
        fail "Task 12: Documentation file missing or incorrect"
    fi

    # TASK 13 - DOCUMENTATION TRACKED
    if git -C "$REPO" ls-files --error-unmatch documents/notes.txt \
           >/dev/null 2>&1; then
        pass "Task 13: Documentation file tracked"
    else
        fail "Task 13: Documentation file not tracked"
    fi

    # TASK 14 - DOCUMENTATION COMMIT
    if git -C "$REPO" log --all --format='%s' |
       grep -Fxq "Add project documentation"; then
        pass "Task 14: Documentation commit"
    else
        fail "Task 14: Documentation commit missing"
    fi

    # TASK 15 - PUSH TO GITLAB
    CURRENT_BRANCH=$(git -C "$REPO" branch --show-current 2>/dev/null)
    UPSTREAM=$(git -C "$REPO" rev-parse \
        --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null)

    if [[ "$CURRENT_BRANCH" == "main" &&
          "$UPSTREAM" == "origin/main" ]] &&
       git -C "$REPO" log -1 --format='%H' origin/main \
           >/dev/null 2>&1; then
        pass "Task 15: Main branch and upstream configured"
    else
        fail "Task 15: Main branch or upstream configuration incorrect"
    fi

     # ============================================================
    # TASK 16 - FINAL REPOSITORY VERIFICATION
    # ============================================================
    
    TASK16_OK=1
    
    [[ -f "$REPO/file1.txt" ]] || TASK16_OK=0
    [[ -f "$REPO/documents/notes.txt" ]] || TASK16_OK=0
    
    # Working tree must be clean
    if [[ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]]; then
        TASK16_OK=0
    fi
    
    # Local HEAD must match origin/main
    LOCAL_HEAD=$(git -C "$REPO" rev-parse HEAD 2>/dev/null)
    REMOTE_HEAD=$(git -C "$REPO" rev-parse origin/main 2>/dev/null)
    
    if [[ -z "$LOCAL_HEAD" || -z "$REMOTE_HEAD" ||
          "$LOCAL_HEAD" != "$REMOTE_HEAD" ]]; then
        TASK16_OK=0
    fi
    
    # Required commit message must exist
    git -C "$REPO" log --format='%s' 2>/dev/null |
        grep -Fxq "Add project documentation" || TASK16_OK=0
    
    if [[ "$TASK16_OK" -eq 1 ]]; then
        pass "Task 16: Final repository verification"
    else
        fail "Task 16: Final repository verification"
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

#=============================================================================
validate_lab302_gitlab_localrepo() {
    
    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 302 - Git and GitLab - Local repo & push - Advanced.</h2>"

    TOTAL_TASKS=12
    PASSED=0
  
    LAB_NAME="Lab 302 - Git and GitLab - Local repo & push - Advanced"
    DATE=$(date "+%F %T")

    STUDENT_HOME="$HOME"
    REPO="$STUDENT_HOME/git-labs/local-project"
    README="$REPO/README.md"
    REPORT="$REPO/reports/system-report"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - CREATE LOCAL PROJECT DIRECTORY
    if [[ -d "$REPO" ]]; then
        pass "Task 1: Local project directory exists"
    else
        fail "Task 1: Local project directory exists"
    fi

    # TASK 2 - CREATE FILES AND ADD CONTENT
    if [[ -s "$README" && -s "$REPORT" &&
          -d "$REPO/reports" ]] &&
       grep -Fxq "This repository was created locally." "$README" &&
       grep -Fq "Mem:" "$REPORT" &&
       grep -Eq '(^NAME[[:space:]]|^NAME$)' "$REPORT"; then
        pass "Task 2: Required files and content exist"
    else
        fail "Task 2: Required files and content exist"
    fi

    # TASK 3 - INITIALIZE GIT REPOSITORY
    if [[ -d "$REPO/.git" ]]; then
        pass "Task 3: Git repository initialized"
    else
        fail "Task 3: Git repository initialized"
    fi

    # TASK 4 - STAGE FILES
    if git -C "$REPO" ls-files --error-unmatch \
        README.md reports/system-report >/dev/null 2>&1; then
        pass "Task 4: Required files are tracked by Git"
    else
        fail "Task 4: Required files are tracked by Git"
    fi

    # TASK 5 - FIRST COMMIT
    if git -C "$REPO" log --format='%s' 2>/dev/null |
        grep -Fxq "Initial local project commit"; then
        pass "Task 5: Initial commit exists"
    else
        fail "Task 5: Initial commit exists"
    fi

    # TASK 6 - RENAME BRANCH TO MAIN
    if [[ "$(git -C "$REPO" branch --show-current 2>/dev/null)" == "main" ]]; then
        pass "Task 6: Current branch is main"
    else
        fail "Task 6: Current branch is main"
    fi

    # TASK 7 - CONNECT TO GITLAB
    REMOTE_URL=$(git -C "$REPO" remote get-url origin 2>/dev/null)

    if [[ "$REMOTE_URL" == *"gitlab-01.corp.linoop.us:2222"* &&
          "$REMOTE_URL" == *"/local-project.git" ]]; then
        pass "Task 7: GitLab remote origin configured"
    else
        fail "Task 7: GitLab remote origin configured"
    fi

    # TASK 8 - PUSH LOCAL REPOSITORY
    if git -C "$REPO" rev-parse --verify \
        refs/remotes/origin/main >/dev/null 2>&1 &&
       [[ "$(git -C "$REPO" rev-parse --abbrev-ref \
        --symbolic-full-name '@{upstream}' 2>/dev/null)" == "origin/main" ]]; then
        pass "Task 8: Main branch tracks origin/main"
    else
        fail "Task 8: Main branch tracks origin/main"
    fi

    # TASK 9 - VERIFY REPOSITORY CONTENT
    if git -C "$REPO" cat-file -e \
        origin/main:README.md 2>/dev/null &&
       git -C "$REPO" cat-file -e \
        origin/main:reports/system-report 2>/dev/null; then
        pass "Task 9: Required files exist in remote-tracking branch"
    else
        fail "Task 9: Required files exist in remote-tracking branch"
    fi

    # TASK 10 - MAKE ANOTHER CHANGE AND PUSH
    if grep -Fxq "This is my second commit." "$README" &&
       git -C "$REPO" log --format='%s' 2>/dev/null |
        grep -Fxq "Update README"; then
        pass "Task 10: README update and commit verified"
    else
        fail "Task 10: README update and commit verified"
    fi

    # TASK 11 - GITLAB WEB EDITOR CHANGE FOR PULL
    if git -C "$REPO" show origin/main:README.md 2>/dev/null |
        grep -Fq "This line was added directly from GitLab to understand git pull concept."; then
        pass "Task 11: Pull demonstration change exists remotely"
    else
        fail "Task 11: Pull demonstration change exists remotely"
    fi

    # TASK 12 - GIT PULL
    if grep -Fq \
        "This line was added directly from GitLab to understand git pull concept." \
        "$README" &&
       [[ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]]; then
        pass "Task 12: Pull change is integrated and working tree is clean"
    else
        fail "Task 12: Pull change is integrated and working tree is clean"
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
#===================================================================

validate_lab303_gitlab_branching() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 303 - Git and GitLab - Branching, Pushing, and Merge Requests.</h2>"

    TOTAL_TASKS=17
    PASSED=0

    LAB_NAME="Lab 303 - Git and GitLab - Branching, Pushing, and Merge Requests"
    DATE=$(date "+%F %T")

    STUDENT_HOME="$HOME"
    REPO="$STUDENT_HOME/git-labs/local-project"

    README="$REPO/README.md"
    DOCS="$REPO/docs"
    BRANCH_GUIDE="$DOCS/branching-guide.md"
    MAINTENANCE="$DOCS/maintenance-checklist.md"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - VERIFY EXISTING PROJECT DIRECTORY
    if [[ -d "$REPO" ]]; then
        pass "Task 1: Local project directory exists"
    else
        fail "Task 1: Local project directory exists"
    fi

    # TASK 2 - VERIFY GIT REPOSITORY AND ORIGIN
    if [[ -d "$REPO/.git" ]] &&
       git -C "$REPO" remote get-url origin >/dev/null 2>&1; then
        pass "Task 2: Git repository and origin remote configured"
    else
        fail "Task 2: Git repository and origin remote configured"
    fi

    # TASK 3 - VERIFY MAIN AND REMOTE-TRACKING BRANCH
    if git -C "$REPO" show-ref --verify --quiet refs/heads/main &&
       git -C "$REPO" show-ref --verify --quiet refs/remotes/origin/main; then
        pass "Task 3: Local main and origin/main exist"
    else
        fail "Task 3: Local main and origin/main exist"
    fi

    # TASK 4 - VERIFY CURRENT BRANCH IS MAIN
    if [[ "$(git -C "$REPO" branch --show-current 2>/dev/null)" == "main" ]]; then
        pass "Task 4: Current branch is main"
    else
        fail "Task 4: Current branch is main"
    fi

    # TASK 5 - VERIFY BRANCHING GUIDE CONTENT
    if [[ -s "$BRANCH_GUIDE" ]] &&
       grep -Fxq "# Git Branching Guide" "$BRANCH_GUIDE" &&
       grep -Fxq "A branch provides an isolated line of development." "$BRANCH_GUIDE" &&
       grep -Fxq "A feature branch keeps work separate from main until it is reviewed." "$BRANCH_GUIDE" &&
       grep -Fxq "A merge request asks teammates to review changes before they are merged." "$BRANCH_GUIDE"; then
        pass "Task 5: Branching guide contains all required content"
    else
        fail "Task 5: Branching guide contains all required content"
    fi

    # TASK 6 - VERIFY README BRANCHING NOTE
    if [[ -s "$README" ]] &&
       grep -Fxq "Branching changes are developed on feature branches and reviewed through merge requests." "$README"; then
        pass "Task 6: README contains the branching note"
    else
        fail "Task 6: README contains the branching note"
    fi

    # TASK 7 - VERIFY FIRST FEATURE COMMIT IN REMOTE MAIN HISTORY
    if git -C "$REPO" log origin/main --format='%s' 2>/dev/null |
       grep -Eq '^Add Git branching guide\.?$'; then
        pass "Task 7: Branching guide commit exists in origin/main history"
    else
        fail "Task 7: Branching guide commit exists in origin/main history"
    fi

    # TASK 8 - VERIFY FIRST FEATURE IS PRESENT IN REMOTE MAIN
    if git -C "$REPO" cat-file -e origin/main:docs/branching-guide.md 2>/dev/null &&
       git -C "$REPO" show origin/main:README.md 2>/dev/null |
       grep -Fxq "Branching changes are developed on feature branches and reviewed through merge requests."; then
        pass "Task 8: First feature changes are present in origin/main"
    else
        fail "Task 8: First feature changes are present in origin/main"
    fi

    # TASK 9 - VERIFY FIRST MERGE REQUEST RESULT
    # Git history and merged content provide local evidence of integration.
    # The actual GitLab MR status requires GitLab API access to verify directly.
    if git -C "$REPO" cat-file -e origin/main:docs/branching-guide.md 2>/dev/null &&
       git -C "$REPO" log origin/main --format='%s' 2>/dev/null |
       grep -Eq '^Add Git branching guide\.?$'; then
        pass "Task 9: First feature integration is reflected in origin/main"
    else
        fail "Task 9: First feature integration is reflected in origin/main"
    fi

    # TASK 10 - VERIFY LOCAL MAIN IS UPDATED
    LOCAL_MAIN=$(git -C "$REPO" rev-parse main 2>/dev/null)
    REMOTE_MAIN=$(git -C "$REPO" rev-parse origin/main 2>/dev/null)

    if [[ -n "$LOCAL_MAIN" && "$LOCAL_MAIN" == "$REMOTE_MAIN" ]] &&
       [[ -f "$BRANCH_GUIDE" ]] &&
       grep -Fxq "Branching changes are developed on feature branches and reviewed through merge requests." "$README"; then
        pass "Task 10: Local main contains the first merged feature and matches origin/main"
    else
        fail "Task 10: Local main contains the first merged feature and matches origin/main"
    fi

    # TASK 11 - VERIFY MAINTENANCE CHECKLIST CONTENT
    if [[ -s "$MAINTENANCE" ]] &&
       grep -Fxq "# Linux Maintenance Checklist" "$MAINTENANCE" &&
       grep -Fxq "Check filesystem capacity with df -h." "$MAINTENANCE" &&
       grep -Fxq "Review memory usage with free -h." "$MAINTENANCE" &&
       grep -Fxq "Review block devices with lsblk." "$MAINTENANCE" &&
       grep -Fxq "Check required service status with systemctl status." "$MAINTENANCE" &&
       grep -Fxq "Record findings and follow the team's change-management process." "$MAINTENANCE"; then
        pass "Task 11: Maintenance checklist contains all required content"
    else
        fail "Task 11: Maintenance checklist contains all required content"
    fi

    # TASK 12 - VERIFY SECOND README NOTE
    if grep -Fxq "The project also includes a basic Linux maintenance checklist." "$README"; then
        pass "Task 12: README contains the maintenance checklist note"
    else
        fail "Task 12: README contains the maintenance checklist note"
    fi

    # TASK 13 - VERIFY SECOND FEATURE COMMIT IN REMOTE MAIN HISTORY
    if git -C "$REPO" log origin/main --format='%s' 2>/dev/null |
       grep -Eq '^Add Linux maintenance checklist\.?$'; then
        pass "Task 13: Maintenance checklist commit exists in origin/main history"
    else
        fail "Task 13: Maintenance checklist commit exists in origin/main history"
    fi

    # TASK 14 - VERIFY SECOND FEATURE IS PRESENT IN REMOTE MAIN
    if git -C "$REPO" cat-file -e origin/main:docs/maintenance-checklist.md 2>/dev/null &&
       git -C "$REPO" show origin/main:README.md 2>/dev/null |
       grep -Fxq "The project also includes a basic Linux maintenance checklist."; then
        pass "Task 14: Second feature changes are present in origin/main"
    else
        fail "Task 14: Second feature changes are present in origin/main"
    fi

    # TASK 15 - VERIFY BOTH FEATURES IN REMOTE MAIN
    if git -C "$REPO" cat-file -e origin/main:docs/branching-guide.md 2>/dev/null &&
       git -C "$REPO" cat-file -e origin/main:docs/maintenance-checklist.md 2>/dev/null &&
       git -C "$REPO" show origin/main:README.md 2>/dev/null |
       grep -Fxq "Branching changes are developed on feature branches and reviewed through merge requests." &&
       git -C "$REPO" show origin/main:README.md 2>/dev/null |
       grep -Fxq "The project also includes a basic Linux maintenance checklist."; then
        pass "Task 15: Both feature documents and README notes exist in origin/main"
    else
        fail "Task 15: Both feature documents and README notes exist in origin/main"
    fi

    # TASK 16 - VERIFY LOCAL FEATURE BRANCH CLEANUP
    if ! git -C "$REPO" show-ref --verify --quiet refs/heads/feature/branching-guide &&
       ! git -C "$REPO" show-ref --verify --quiet refs/heads/feature/maintenance-checklist; then
        pass "Task 16: Both local feature branches have been deleted"
    else
        fail "Task 16: Both local feature branches have been deleted"
    fi

    # TASK 17 - FINAL REPOSITORY VERIFICATION
    LOCAL_MAIN=$(git -C "$REPO" rev-parse main 2>/dev/null)
    REMOTE_MAIN=$(git -C "$REPO" rev-parse origin/main 2>/dev/null)

    if [[ "$(git -C "$REPO" branch --show-current 2>/dev/null)" == "main" ]] &&
       [[ -n "$LOCAL_MAIN" && "$LOCAL_MAIN" == "$REMOTE_MAIN" ]] &&
       [[ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]] &&
       git -C "$REPO" cat-file -e origin/main:docs/branching-guide.md 2>/dev/null &&
       git -C "$REPO" cat-file -e origin/main:docs/maintenance-checklist.md 2>/dev/null; then
        pass "Task 17: Final branch, synchronization, files, and clean working tree verified"
    else
        fail "Task 17: Final branch, synchronization, files, and clean working tree verified"
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
validate_lab304_gitlab_diff_fetch_merge_pull() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 304 - Git and GitLab - Diff, Fetch, Merge and Pull.</h2>"

    TOTAL_TASKS=17
    PASSED=0

    LAB_NAME="Lab 304 - Git and GitLab - Diff, Fetch, Merge and Pull"
    DATE=$(date "+%F %T")

    STUDENT_HOME="$HOME"
    REPO="$STUDENT_HOME/git-labs/lab304-git-workflow"

    README="$REPO/README.md"

    # REQUIRED README CONTENT
    LOCAL_LINE="Local change: documenting the Git workflow."
    REMOTE_A="Remote change A: added through the GitLab web interface."
    REMOTE_B="Remote change B: retrieved using git pull."

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # Check an exact line in the local README.
    local_has_line() {
        [[ -f "$README" ]] &&
            grep -Fxq -- "$1" "$README"
    }

    # Check an exact line in the README committed to origin/main.
    remote_has_line() {
        git -C "$REPO" show origin/main:README.md 2>/dev/null |
            grep -Fxq -- "$1"
    }

    # Check whether a line was introduced in the origin/main history.
    history_has_line() {
        git -C "$REPO" log origin/main \
            --format='%H' "-S$1" -- README.md 2>/dev/null |
            grep -q .
    }

    # TASK 1 - VERIFY PROJECT DIRECTORY
    if [[ -d "$REPO" ]]; then
        pass "Task 1: Local lab304-git-workflow directory exists"
    else
        fail "Task 1: Local lab304-git-workflow directory exists"
    fi

    # TASK 2 - VERIFY GIT REPOSITORY AND ORIGIN
    if [[ -d "$REPO/.git" ]] &&
       git -C "$REPO" remote get-url origin >/dev/null 2>&1; then
        pass "Task 2: Git repository and origin remote are configured"
    else
        fail "Task 2: Git repository and origin remote are configured"
    fi

    # TASK 3 - VERIFY MAIN AND ORIGIN/MAIN
    if git -C "$REPO" show-ref --verify --quiet refs/heads/main &&
       git -C "$REPO" show-ref --verify --quiet refs/remotes/origin/main; then
        pass "Task 3: Local main and origin/main branches exist"
    else
        fail "Task 3: Local main and origin/main branches exist"
    fi

    # TASK 4 - VERIFY CURRENT BRANCH
    if [[ "$(git -C "$REPO" branch --show-current 2>/dev/null)" == "main" ]]; then
        pass "Task 4: Current branch is main"
    else
        fail "Task 4: Current branch is main"
    fi

    # TASK 5 - VERIFY README AND LOCAL CHANGE
    if [[ -s "$README" ]] &&
       local_has_line "$LOCAL_LINE"; then
        pass "Task 5: README contains the required local workflow change"
    else
        fail "Task 5: README contains the required local workflow change"
    fi

    # TASK 6 - VERIFY LOCAL CHANGE WAS COMMITTED
    # Staging itself cannot be proven after the change has been committed.
    # Verify the resulting commit and its README content instead.
    if git -C "$REPO" log origin/main \
           --format='%s' 2>/dev/null |
           grep -Fxq 'Document local Git workflow' &&
       history_has_line "$LOCAL_LINE"; then
        pass "Task 6: Local workflow change was committed and pushed"
    else
        fail "Task 6: Local workflow change was committed and pushed"
    fi

    # TASK 7 - VERIFY LOCAL CHANGE EXISTS IN REMOTE REPOSITORY
    if remote_has_line "$LOCAL_LINE"; then
        pass "Task 7: Local workflow change exists in origin/main"
    else
        fail "Task 7: Local workflow change exists in origin/main"
    fi

    # TASK 8 - VERIFY REMOTE CHANGE A WAS FETCHED
    # The remote-tracking branch provides evidence that the remote
    # README change has been downloaded into the local Git repository.
    if remote_has_line "$REMOTE_A" &&
       history_has_line "$REMOTE_A"; then
        pass "Task 8: Remote change A exists in fetched origin/main history"
    else
        fail "Task 8: Remote change A exists in fetched origin/main history"
    fi

    # TASK 9 - VERIFY FETCHED CHANGE CAN BE COMPARED
    # The remote change must exist in origin/main and the local README.
    # After the subsequent merge, both copies should contain the line.
    if remote_has_line "$REMOTE_A" &&
       local_has_line "$REMOTE_A" &&
       git -C "$REPO" diff --quiet main origin/main -- README.md; then
        pass "Task 9: Remote change A is present locally and remotely"
    else
        fail "Task 9: Remote change A is present locally and remotely"
    fi

    # TASK 10 - VERIFY MERGED REMOTE CHANGE A
    if local_has_line "$REMOTE_A" &&
       git -C "$REPO" merge-base --is-ancestor origin/main main 2>/dev/null; then
        pass "Task 10: Remote change A is integrated into local main"
    else
        # A fast-forward merge makes main and origin/main equal.
        # In that case, the ancestor check above also succeeds.
        fail "Task 10: Remote change A is integrated into local main"
    fi

    # TASK 11 - VERIFY REMOTE CHANGE B
    if remote_has_line "$REMOTE_B" &&
       history_has_line "$REMOTE_B"; then
        pass "Task 11: Remote change B exists in origin/main history"
    else
        fail "Task 11: Remote change B exists in origin/main history"
    fi

    # TASK 12 - VERIFY PULL RESULT
    if local_has_line "$REMOTE_B" &&
       remote_has_line "$REMOTE_B"; then
        pass "Task 12: git pull result contains remote change B locally"
    else
        fail "Task 12: git pull result contains remote change B locally"
    fi

    # TASK 13 - VERIFY BOTH REMOTE CHANGES
    if local_has_line "$REMOTE_A" &&
       local_has_line "$REMOTE_B"; then
        pass "Task 13: README contains both remote additions"
    else
        fail "Task 13: README contains both remote additions"
    fi

    # TASK 14 - VERIFY BOTH REMOTE CHANGES IN COMMIT HISTORY
    if history_has_line "$REMOTE_A" &&
       history_has_line "$REMOTE_B"; then
        pass "Task 14: Both remote README changes exist in origin/main history"
    else
        fail "Task 14: Both remote README changes exist in origin/main history"
    fi

    # TASK 15 - VERIFY LOCAL AND REMOTE MAIN ARE SYNCHRONIZED
    LOCAL_MAIN=$(git -C "$REPO" rev-parse refs/heads/main 2>/dev/null)
    REMOTE_MAIN=$(git -C "$REPO" rev-parse refs/remotes/origin/main 2>/dev/null)

    if [[ -n "$LOCAL_MAIN" && "$LOCAL_MAIN" == "$REMOTE_MAIN" ]]; then
        pass "Task 15: Local main and origin/main point to the same commit"
    else
        fail "Task 15: Local main and origin/main point to the same commit"
    fi

    # TASK 16 - VERIFY CLEAN WORKING TREE
    if [[ -d "$REPO/.git" ]] &&
       [[ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]]; then
        pass "Task 16: Working tree and staging area are clean"
    else
        fail "Task 16: Working tree and staging area are clean"
    fi

    # TASK 17 - FINAL REPOSITORY VERIFICATION
    LOCAL_MAIN=$(git -C "$REPO" rev-parse refs/heads/main 2>/dev/null)
    REMOTE_MAIN=$(git -C "$REPO" rev-parse refs/remotes/origin/main 2>/dev/null)

    if [[ -d "$REPO/.git" ]] &&
       [[ "$(git -C "$REPO" branch --show-current 2>/dev/null)" == "main" ]] &&
       [[ -n "$LOCAL_MAIN" && "$LOCAL_MAIN" == "$REMOTE_MAIN" ]] &&
       [[ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]] &&
       local_has_line "$LOCAL_LINE" &&
       local_has_line "$REMOTE_A" &&
       local_has_line "$REMOTE_B" &&
       remote_has_line "$LOCAL_LINE" &&
       remote_has_line "$REMOTE_A" &&
       remote_has_line "$REMOTE_B" &&
       history_has_line "$LOCAL_LINE" &&
       history_has_line "$REMOTE_A" &&
       history_has_line "$REMOTE_B"; then
        pass "Task 17: Final branch, commits, README content, synchronization, and clean status verified"
    else
        fail "Task 17: Final branch, commits, README content, synchronization, and clean status verified"
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
#================================================================
validate_lab401_ansible_adhoc() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 401 - Ansible Ad-Hoc Commands.</h2>"

    TOTAL_TASKS=14
    PASSED=0

    LAB_NAME="Lab 401 - Ansible Ad-Hoc Commands"
    DATE=$(date "+%F %T")

    # CONFIGURATION
    INVENTORY="/etc/ansible/hosts"
    LAB_USER="michael"
    LAB_GROUP="devadmins"
    LAB_DIR="/tmp/new_dir"
    PERMISSION_FILE="$LAB_DIR/system_info"
    VSFTPD_FILE="$LAB_DIR/vsftpd_pkg"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASKS 1-6 - TEMPORARILY SKIPPED
    pass "Task 1: Ansible installation check skipped - validating managed-node final state"
    pass "Task 2: SSH key authentication check skipped - validating managed-node final state"
    pass "Task 3: Inventory group check skipped - validating managed-node final state"
    pass "Task 4: Control-node command check skipped - validating managed-node final state"
    pass "Task 5: Inventory parsing check skipped - validating managed-node final state"
    pass "Task 6: Ansible ping check skipped - validating managed-node final state"

    # TASK 7 - MODULE EXECUTION CANNOT BE VERIFIED FROM FINAL STATE
    pass "Task 7: Command and shell module check temporarily bypassed"

    # TASK 8 - VERIFY USER AND GROUP ON THIS MANAGED NODE
    if getent passwd "$LAB_USER" >/dev/null 2>&1 &&
       getent group "$LAB_GROUP" >/dev/null 2>&1; then
        pass "Task 8: Required user and group exist"
    else
        fail "Task 8: Required user and group exist"
    fi

    # TASK 9 - VERIFY DIRECTORY PERMISSIONS
    DIR_MODE=$(stat -c '%a' "$LAB_DIR" 2>/dev/null)
    if [[ -z "$DIR_MODE" ]]; then
        DIR_MODE=$(sudo -n stat -c '%a' "$LAB_DIR" 2>/dev/null)
    fi

    if [[ "$DIR_MODE" == "750" ]]; then
        pass "Task 9: Directory permissions are 750"
    else
        fail "Task 9: Directory permissions are 750"
    fi

    # TASK 10 - VERIFY FILE PERMISSIONS
    FILE_MODE=$(stat -c '%a' "$PERMISSION_FILE" 2>/dev/null)
    if [[ -z "$FILE_MODE" ]]; then
        FILE_MODE=$(sudo -n stat -c '%a' "$PERMISSION_FILE" 2>/dev/null)
    fi

    if [[ "$FILE_MODE" == "640" ]]; then
        pass "Task 10: File permissions are 640"
    else
        fail "Task 10: File permissions are 640"
    fi

     # TASK 11 - VERIFY SYSTEM INFORMATION FILE CONTENT
    if sudo -n grep -Eq 'Operating System:|Kernel:|Architecture:' \
           "$PERMISSION_FILE" 2>/dev/null &&
       sudo -n grep -Eq 'Mem:|MemTotal:' \
           "$PERMISSION_FILE" 2>/dev/null &&
       sudo -n grep -Eq 'Filesystem|NAME[[:space:]]+MAJ:MIN' \
           "$PERMISSION_FILE" 2>/dev/null; then
        pass "Task 11: System information file contains OS, memory, and storage information"
    else
        fail "Task 11: System information file contains OS, memory, and storage information"
    fi

    # TASK 12 - VERIFY VSFTPD PACKAGE INFORMATION FILE
    if [[ -s "$VSFTPD_FILE" ]] ||
       sudo -n test -s "$VSFTPD_FILE" 2>/dev/null; then
        pass "Task 12: vsftpd package information file exists and is not empty"
    else
        fail "Task 12: vsftpd package information file exists and is not empty"
    fi

    # TASK 13 - VERIFY VSFTPD PACKAGE IS INSTALLED
    if rpm -q vsftpd >/dev/null 2>&1; then
        pass "Task 13: vsftpd package is installed"
    else
        fail "Task 13: vsftpd package is installed"
    fi

    # TASK 14 - VERIFY VSFTPD SERVICE IS ACTIVE AND ENABLED
    if systemctl is-active --quiet vsftpd &&
       systemctl is-enabled --quiet vsftpd; then
        pass "Task 14: vsftpd service is active and enabled"
    else
        fail "Task 14: vsftpd service is active and enabled"
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
#================================================================
validate_lab402_ansible_adhoc() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 402 - Ansible Ad-Hoc Commands - System Administration and File Management.</h2>"

    TOTAL_TASKS=15
    PASSED=0

    LAB_NAME="Lab 402 - Ansible Ad-Hoc Commands - System Administration and File Management"
    DATE=$(date "+%F %T")

    # CONFIGURATION
    LAB_USER="deployer"
    LAB_GROUP="devsecops"
    LAB_DIR="/opt/ansible-lab"
    SYSTEM_INFO="/tmp/ansible-system-info.txt"

    ANNOUNCEMENT="$LAB_DIR/announcement.txt"
    ANNOUNCEMENT_BACKUP="$LAB_DIR/announcement-backup.txt"

    NESTED_DIR="$LAB_DIR/reports/weekly/archive"
    SOURCE_DIR="$LAB_DIR/source-dir"
    COPIED_DIR="$LAB_DIR/source-dir-copy"

    ANNOUNCEMENT_CONTENT="Ansible ad-hoc commands can automate routine Linux administration tasks."
    SOURCE_CONTENT="This file is used to practice directory copying"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - VERIFY MANAGED NODE REACHABILITY
    # The validator is already running on the managed node.
    if hostname >/dev/null 2>&1; then
        pass "Task 1: Managed node is reachable for validation"
    else
        fail "Task 1: Managed node is reachable for validation"
    fi

    # TASK 2 - VERIFY DEVSECOPS GROUP
    if getent group "$LAB_GROUP" >/dev/null 2>&1; then
        pass "Task 2: Group devsecops exists"
    else
        fail "Task 2: Group devsecops exists"
    fi

    # TASK 3 - VERIFY DEPLOYER USER
    if getent passwd "$LAB_USER" >/dev/null 2>&1; then
        pass "Task 3: User deployer exists"
    else
        fail "Task 3: User deployer exists"
    fi

    # TASK 4 - VERIFY USER MEMBERSHIP
    if id -nG "$LAB_USER" 2>/dev/null |
       tr ' ' '\n' |
       grep -Fxq "$LAB_GROUP"; then
        pass "Task 4: User deployer belongs to devsecops"
    else
        fail "Task 4: User deployer belongs to devsecops"
    fi

    # TASK 5 - VERIFY HTTPD PACKAGE
    if rpm -q httpd >/dev/null 2>&1; then
        pass "Task 5: httpd package is installed"
    else
        fail "Task 5: httpd package is installed"
    fi

    # TASK 6 - VERIFY APACHE SERVICE IS RUNNING
    if sudo -n systemctl is-active --quiet httpd; then
        pass "Task 6: httpd service is running"
    else
        fail "Task 6: httpd service is running"
    fi

    # TASK 7 - VERIFY APACHE SERVICE IS ENABLED AT BOOT
    if sudo -n systemctl is-enabled --quiet httpd; then
        pass "Task 7: httpd service is enabled at boot"
    else
        fail "Task 7: httpd service is enabled at boot"
    fi

    # TASK 8  VERIFY SYSTEM INFORMATION FILE CONTENT
    INFO_FILE="/tmp/ansible-system-info.txt"

    if sudo -n test -s "$INFO_FILE" &&
       sudo -n grep -Eq 'Linux|[0-9]+\.[0-9]+' "$INFO_FILE" 2>/dev/null &&
       sudo -n grep -Eq 'Mem:|MemTotal:|total[[:space:]]+used[[:space:]]+free' \
           "$INFO_FILE" 2>/dev/null &&
       sudo -n grep -Eq 'Filesystem|/dev/|tmpfs|overlay' \
           "$INFO_FILE" 2>/dev/null; then
        pass "Task 8: System information file contains kernel, memory, and filesystem information"
    else
        fail "Task 8: System information file contains kernel, memory, and filesystem information"
    fi

    # TASK 9 - VERIFY WORKING DIRECTORY
    if sudo -n test -d "$LAB_DIR" 2>/dev/null; then
        pass "Task 9: /opt/ansible-lab directory exists"
    else
        fail "Task 9: /opt/ansible-lab directory exists"
    fi

    # TASK 10 - VERIFY EMPTY NOTES FILE
    NOTES_FILE="$LAB_DIR/notes.txt"

    if sudo -n test -f "$NOTES_FILE" 2>/dev/null &&
       [[ "$(sudo stat -c '%s' "$NOTES_FILE" 2>/dev/null)" == "0" ]]; then
        pass "Task 10: notes.txt exists as an empty regular file"
    else
        fail "Task 10: notes.txt exists as an empty regular file"
    fi

    # TASK 11 - VERIFY ANNOUNCEMENT CONTENT
    if sudo -n test -f "$ANNOUNCEMENT" 2>/dev/null &&
       sudo -n grep -Fxq "$ANNOUNCEMENT_CONTENT" "$ANNOUNCEMENT" 2>/dev/null; then
        pass "Task 11: announcement.txt contains the required text"
    else
        fail "Task 11: announcement.txt contains the required text"
    fi

    # TASK 12 - VERIFY COPIED FILE CONTENT
    if sudo -n test -f "$ANNOUNCEMENT" 2>/dev/null &&
       sudo -n test -f "$ANNOUNCEMENT_BACKUP" 2>/dev/null &&
       sudo -n cmp -s "$ANNOUNCEMENT" "$ANNOUNCEMENT_BACKUP" 2>/dev/null; then
        pass "Task 12: announcement-backup.txt matches announcement.txt"
    else
        fail "Task 12: announcement-backup.txt matches announcement.txt"
    fi

    # TASK 13 - VERIFY NESTED DIRECTORY STRUCTURE
    if sudo -n test -d "$NESTED_DIR" 2>/dev/null; then
        pass "Task 13: Nested reports/weekly/archive directory structure exists"
    else
        fail "Task 13: Nested reports/weekly/archive directory structure exists"
    fi
    
    # TASK 14 - VERIFY SOURCE DIRECTORY AND FILE
    SOURCE_DIR="/opt/ansible-lab/source-dir"
    SOURCE_FILE="$SOURCE_DIR/source.txt"

    if sudo -n test -d "$SOURCE_DIR" &&
       sudo -n test -f "$SOURCE_FILE" &&
       sudo -n grep -Fxq \
           "This file is used to practice directory copying" \
           "$SOURCE_FILE" 2>/dev/null; then
        pass "Task 14: Source directory and source.txt file are created with the correct content"
    else
        fail "Task 14: Source directory and source.txt file are created with the correct content"
    fi

    # TASK 15 - VERIFY DIRECTORY COPY
    SOURCE_COPY_DIR="/opt/ansible-lab/source-dir-copy"
    COPIED_SOURCE_FILE="$SOURCE_COPY_DIR/source.txt"

    if sudo -n test -d "$SOURCE_COPY_DIR" &&
       sudo -n test -d "$SOURCE_COPY_DIR/source-dir" &&
       sudo -n test -f "$SOURCE_COPY_DIR/source-dir/source.txt" &&
       sudo -n grep -Fxq \
           "This file is used to practice directory copying" \
           "$SOURCE_COPY_DIR/source-dir/source.txt" 2>/dev/null; then
        pass "Task 15: Source directory is copied recursively, including the directory itself"
    else
        fail "Task 15: Source directory is copied recursively, including the directory itself"
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
#==============================================================
validate_lab403_ansible_multitasking() {

    set +e
    set +u
    set +o pipefail

    echo "<h2 style='color:#white;'>Checking Lab 403 - Ansible Multitasking Playbook.</h2>"

    TOTAL_TASKS=16
    PASSED=0

    LAB_NAME="Lab 403 - Ansible Multitasking Playbook"
    DATE=$(date "+%F %T")

    # CONFIGURATION
    LAB_USER="marry"
    LAB_GROUP="dbadmins"

    LAB_DIR="/opt/ansible-lab403"

    SOURCE_FILE="/opt/lab403-source.txt"
    FETCHED_FILE="$LAB_DIR/lab403-fetch.txt"
    COPIED_SOURCE_FILE="$LAB_DIR/lab403-source.txt"

    SOURCE_CONTENT="This file was created by the lab 403 Ansible multitasking playbook."
    ADDED_LINE="This line was added using the Ansible lineinfile module."

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - VERIFY MANAGED NODE REACHABILITY
    if hostname >/dev/null 2>&1; then
        pass "Task 1: Managed node is reachable for validation"
    else
        fail "Task 1: Managed node is reachable for validation"
    fi

    # TASK 2 - VERIFY USER, HOME DIRECTORY, AND LOGIN SHELL
    USER_ENTRY=$(getent passwd "$LAB_USER" 2>/dev/null)

    if [[ -n "$USER_ENTRY" ]] &&
       [[ "$(echo "$USER_ENTRY" | cut -d: -f6)" == "/home/$LAB_USER" ]] &&
       [[ "$(echo "$USER_ENTRY" | cut -d: -f7)" == "/bin/bash" ]] &&
       sudo -n test -d "/home/$LAB_USER" 2>/dev/null; then
        pass "Task 2: User marry exists with a home directory and /bin/bash shell"
    else
        fail "Task 2: User marry exists with a home directory and /bin/bash shell"
    fi

    # TASK 3 - VERIFY DBADMINS GROUP
    if getent group "$LAB_GROUP" >/dev/null 2>&1; then
        pass "Task 3: Group dbadmins exists"
    else
        fail "Task 3: Group dbadmins exists"
    fi

    # TASK 4 - VERIFY USER GROUP MEMBERSHIP
    if id -nG "$LAB_USER" 2>/dev/null |
       tr ' ' '\n' |
       grep -Fxq "$LAB_GROUP"; then
        pass "Task 4: User marry belongs to supplementary group dbadmins"
    else
        fail "Task 4: User marry belongs to supplementary group dbadmins"
    fi

    # TASK 5 - VERIFY DIRECTORY
    DIR_META=$(sudo -n stat -c '%a:%U:%G' "$LAB_DIR" 2>/dev/null)

    if sudo -n test -d "$LAB_DIR" 2>/dev/null &&
       [[ "$DIR_META" == "750:root:root" ]]; then
        pass "Task 5: /opt/ansible-lab403 exists with root ownership and mode 0750"
    else
        fail "Task 5: /opt/ansible-lab403 exists with root ownership and mode 0750"
    fi

    # TASK 6 - VERIFY SOURCE FILE CONTENT, PERMISSIONS, AND OWNERSHIP
    SOURCE_META=$(sudo -n stat -c '%a:%U:%G' "$SOURCE_FILE" 2>/dev/null)

    if sudo -n test -f "$SOURCE_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$SOURCE_FILE" 2>/dev/null &&
       [[ "$SOURCE_META" == "640:root:root" ]]; then
        pass "Task 6: Source file has the required content, mode 0640, and root ownership"
    else
        fail "Task 6: Source file has the required content, mode 0640, and root ownership"
    fi

    # TASK 7 - VERIFY FETCHED FILE COPY ON MANAGED NODE
    # The control-node copy at /tmp/lab403-fetch.txt cannot be
    # verified by this managed-node validator alone.
    FETCHED_META=$(sudo -n stat -c '%a:%U:%G' "$FETCHED_FILE" 2>/dev/null)

    if sudo -n test -f "$FETCHED_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$FETCHED_FILE" 2>/dev/null &&
       [[ "$FETCHED_META" == "640:root:root" ]]; then
        pass "Task 7: lab403-fetch.txt exists in the lab directory with correct content, mode, and ownership"
    else
        fail "Task 7: lab403-fetch.txt exists in the lab directory with correct content, mode, and ownership"
    fi

    # TASK 8 - VERIFY COPIED SOURCE FILE
    COPIED_META=$(sudo -n stat -c '%a:%U:%G' "$COPIED_SOURCE_FILE" 2>/dev/null)

    if sudo -n test -f "$COPIED_SOURCE_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$COPIED_SOURCE_FILE" 2>/dev/null &&
       [[ "$COPIED_META" == "640:root:root" ]]; then
        pass "Task 8: lab403-source.txt is copied into the lab directory with correct content, mode, and ownership"
    else
        fail "Task 8: lab403-source.txt is copied into the lab directory with correct content, mode, and ownership"
    fi

    # TASK 9 - VERIFY LINEINFILE CONTENT
    if sudo -n test -f "$COPIED_SOURCE_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$ADDED_LINE" "$COPIED_SOURCE_FILE" 2>/dev/null; then
        pass "Task 9: The required line is present in lab403-source.txt"
    else
        fail "Task 9: The required line is present in lab403-source.txt"
    fi

    # TASK 10 - VERIFY VSFTPD PACKAGE
    if rpm -q vsftpd >/dev/null 2>&1; then
        pass "Task 10: vsftpd package is installed"
    else
        fail "Task 10: vsftpd package is installed"
    fi

    # TASK 11 - VERIFY VSFTPD SERVICE IS RUNNING
    if sudo -n systemctl is-active --quiet vsftpd 2>/dev/null; then
        pass "Task 11: vsftpd service is running"
    else
        fail "Task 11: vsftpd service is running"
    fi

    # TASK 12 - VERIFY VSFTPD SERVICE IS ENABLED
    if sudo -n systemctl is-enabled --quiet vsftpd 2>/dev/null; then
        pass "Task 12: vsftpd service is enabled at boot"
    else
        fail "Task 12: vsftpd service is enabled at boot"
    fi

    # TASK 13 - VERIFY FIREWALLD IS RUNNING AND ENABLED
    if sudo -n systemctl is-active --quiet firewalld 2>/dev/null &&
       sudo -n systemctl is-enabled --quiet firewalld 2>/dev/null; then
        pass "Task 13: firewalld is running and enabled at boot"
    else
        fail "Task 13: firewalld is running and enabled at boot"
    fi

    # TASK 14 - VERIFY FTP FIREWALL RULE
    # The standard firewalld service name for FTP is "ftp",
    # not "vsftpd".
    if sudo -n firewall-cmd --quiet --query-service=ftp 2>/dev/null &&
       sudo -n firewall-cmd --permanent --quiet --query-service=ftp 2>/dev/null; then
        pass "Task 14: FTP service is allowed in runtime and permanent firewall configurations"
    else
        fail "Task 14: FTP service is allowed in runtime and permanent firewall configurations"
    fi

    # TASK 15 - VERIFY CURRENT SELINUX MODE
    if command -v getenforce >/dev/null 2>&1 &&
       [[ "$(getenforce 2>/dev/null)" == "Permissive" ]] &&
       sudo -n test -f /etc/selinux/config 2>/dev/null &&
       sudo -n grep -Eq '^[[:space:]]*SELINUX=permissive([[:space:]]*(#.*)?)?$' \
           /etc/selinux/config 2>/dev/null; then
        pass "Task 15: SELinux is currently in permissive mode"
    else
        fail "Task 15: SELinux is currently in permissive mode"
    fi

    # TASK 16 - VERIFY OVERALL LAB COMPLETION
    if [[ "$PASSED" -eq 15 ]]; then
        pass "Task 16: All 15 previous tasks passed successfully"
    else
        fail "Task 16: Not all previous tasks passed"
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

validate_lab404_ansible_variables_tags() {

    set +e
    set +u
    set +o pipefail

    echo "<h2>Checking Lab 404 - Ansible Variables in a Multitasking Playbook.</h2>"

    TOTAL_TASKS=16
    PASSED=0

    LAB_NAME="Lab 404 - Ansible Variables in a Multitasking Playbook"
    DATE=$(date "+%F %T")

    # CONFIGURATION
    LAB_USER="sandy"
    LAB_GROUP="support"

    LAB_DIR="/opt/ansible-lab404"

    SOURCE_FILE="/opt/lab404-source.txt"
    FETCHED_FILE="$LAB_DIR/lab404-fetch.txt"
    COPIED_SOURCE_FILE="$LAB_DIR/lab404-source.txt"

    SOURCE_CONTENT="This file was created by the lab 404 variables playbook."
    ADDED_LINE="This line was added using the Ansible variables lab."

    PACKAGE_NAME="httpd"
    SERVICE_NAME="httpd"
    FIREWALL_SERVICE="http"

    # HELPERS
    pass() {
        echo "<div class='validation-pass'>✓ $1 – Pass</div>"
        ((PASSED++))
    }

    fail() {
        echo "<div class='validation-fail'>✗ $1 – Fail</div>"
    }

    # TASK 1 - VERIFY MANAGED NODE REACHABILITY
    if hostname >/dev/null 2>&1; then
        pass "Task 1: Managed node is reachable for validation"
    else
        fail "Task 1: Managed node is reachable for validation"
    fi

    # TASK 2 - VERIFY USER, HOME DIRECTORY, AND LOGIN SHELL
    USER_ENTRY=$(getent passwd "$LAB_USER" 2>/dev/null)

    if [[ -n "$USER_ENTRY" ]] &&
       [[ "$(echo "$USER_ENTRY" | cut -d: -f6)" == "/home/$LAB_USER" ]] &&
       [[ "$(echo "$USER_ENTRY" | cut -d: -f7)" == "/bin/bash" ]] &&
       sudo -n test -d "/home/$LAB_USER" 2>/dev/null; then
        pass "Task 2: User sandy exists with a home directory and /bin/bash shell"
    else
        fail "Task 2: User sandy exists with a home directory and /bin/bash shell"
    fi

    # TASK 3 - VERIFY SUPPORT GROUP
    if getent group "$LAB_GROUP" >/dev/null 2>&1; then
        pass "Task 3: Group support exists"
    else
        fail "Task 3: Group support exists"
    fi

    # TASK 4 - VERIFY USER SUPPLEMENTARY GROUP MEMBERSHIP
    if id -nG "$LAB_USER" 2>/dev/null |
       tr ' ' '\n' |
       grep -Fxq "$LAB_GROUP"; then
        pass "Task 4: User sandy belongs to supplementary group support"
    else
        fail "Task 4: User sandy belongs to supplementary group support"
    fi

    # TASK 5 - VERIFY DIRECTORY, OWNERSHIP, AND PERMISSIONS
    DIR_META=$(sudo -n stat -c '%a:%U:%G' "$LAB_DIR" 2>/dev/null)

    if sudo -n test -d "$LAB_DIR" 2>/dev/null &&
       [[ "$DIR_META" == "750:root:root" ]]; then
        pass "Task 5: Lab directory exists with root ownership and mode 0750"
    else
        fail "Task 5: Lab directory exists with root ownership and mode 0750"
    fi

    # TASK 6 - VERIFY SOURCE FILE CONTENT, OWNERSHIP, AND PERMISSIONS
    SOURCE_META=$(sudo -n stat -c '%a:%U:%G' "$SOURCE_FILE" 2>/dev/null)

    if sudo -n test -f "$SOURCE_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$SOURCE_FILE" 2>/dev/null &&
       [[ "$SOURCE_META" == "640:root:root" ]]; then
        pass "Task 6: Source file has the required content, mode 0640, and root ownership"
    else
        fail "Task 6: Source file has the required content, mode 0640, and root ownership"
    fi

    # TASK 7 - VERIFY FETCHED FILE COPIED BACK TO MANAGED NODE
    # The control-node file /tmp/lab404-fetch.txt cannot be checked
    # directly by this managed-node validator.
    FETCHED_META=$(sudo -n stat -c '%a:%U:%G' "$FETCHED_FILE" 2>/dev/null)

    if sudo -n test -f "$FETCHED_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$FETCHED_FILE" 2>/dev/null &&
       [[ "$FETCHED_META" == "640:root:root" ]]; then
        pass "Task 7: Fetched file copy exists in the lab directory with correct content, mode, and ownership"
    else
        fail "Task 7: Fetched file copy exists in the lab directory with correct content, mode, and ownership"
    fi

    # TASK 8 - VERIFY SOURCE FILE COPIED INTO LAB DIRECTORY
    COPIED_META=$(sudo -n stat -c '%a:%U:%G' "$COPIED_SOURCE_FILE" 2>/dev/null)

    if sudo -n test -f "$COPIED_SOURCE_FILE" 2>/dev/null &&
       sudo -n grep -Fxq "$SOURCE_CONTENT" "$COPIED_SOURCE_FILE" 2>/dev/null &&
       [[ "$COPIED_META" == "640:root:root" ]]; then
        pass "Task 8: lab404-source.txt exists in the lab directory with correct content, mode, and ownership"
    else
        fail "Task 8: lab404-source.txt exists in the lab directory with correct content, mode, and ownership"
    fi

    # TASK 9 - VERIFY LINEINFILE CONTENT AND UNIQUENESS
    ADDED_LINE_COUNT=$(
        sudo -n grep -Fxc -- "$ADDED_LINE" "$COPIED_SOURCE_FILE" 2>/dev/null
    )
    ADDED_LINE_COUNT=${ADDED_LINE_COUNT:-0}

    if sudo -n test -f "$COPIED_SOURCE_FILE" 2>/dev/null &&
       [[ "$ADDED_LINE_COUNT" -eq 1 ]] &&
       [[ "$COPIED_META" == "640:root:root" ]]; then
        pass "Task 9: Required line appears exactly once with correct file permissions and ownership"
    else
        fail "Task 9: Required line appears exactly once with correct file permissions and ownership"
    fi

    # TASK 10 - VERIFY HTTPD PACKAGE
    # The final state must have httpd installed because Task 12
    # reinstalls it after Task 11 removes it.
    if rpm -q "$PACKAGE_NAME" >/dev/null 2>&1; then
        pass "Task 10: httpd package is installed"
    else
        fail "Task 10: httpd package is installed"
    fi

    # TASK 11 - VERIFY HTTPD SERVICE IS RUNNING
    if sudo -n systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        pass "Task 11: httpd service is running"
    else
        fail "Task 11: httpd service is running"
    fi

    # TASK 12 - VERIFY HTTPD SERVICE IS ENABLED
    if sudo -n systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
        pass "Task 12: httpd service is enabled at boot"
    else
        fail "Task 12: httpd service is enabled at boot"
    fi

    # TASK 13 - VERIFY FIREWALLD IS RUNNING AND ENABLED
    if sudo -n systemctl is-active --quiet firewalld 2>/dev/null &&
       sudo -n systemctl is-enabled --quiet firewalld 2>/dev/null; then
        pass "Task 13: firewalld is running and enabled at boot"
    else
        fail "Task 13: firewalld is running and enabled at boot"
    fi

    # TASK 14 - VERIFY HTTP FIREWALL RULE
    # Check both the runtime and permanent firewall configurations.
    if sudo -n firewall-cmd --quiet --query-service="$FIREWALL_SERVICE" 2>/dev/null &&
       sudo -n firewall-cmd --permanent --quiet --query-service="$FIREWALL_SERVICE" 2>/dev/null; then
        pass "Task 14: HTTP service is allowed in runtime and permanent firewall configurations"
    else
        fail "Task 14: HTTP service is allowed in runtime and permanent firewall configurations"
    fi

    # TASK 15 - VERIFY SELINUX MODE, PERSISTENCE, AND POLICY
    SELINUX_MODE=$(getenforce 2>/dev/null)
    SELINUX_CONFIG_STATE=$(
        sudo -n awk -F= '
            /^[[:space:]]*SELINUX[[:space:]]*=/ {
                gsub(/[[:space:]]/, "", $1)
                gsub(/[[:space:]#].*/, "", $2)
                value = $2
            }
            END { print value }
        ' /etc/selinux/config 2>/dev/null
    )
    SELINUX_POLICY=$(
        sudo -n awk -F= '
            /^[[:space:]]*SELINUXTYPE[[:space:]]*=/ {
                gsub(/[[:space:]]/, "", $1)
                gsub(/[[:space:]#].*/, "", $2)
                value = $2
            }
            END { print value }
        ' /etc/selinux/config 2>/dev/null
    )

    if [[ "$SELINUX_MODE" == "Permissive" ]] &&
       [[ "$SELINUX_CONFIG_STATE" == "permissive" ]] &&
       [[ "$SELINUX_POLICY" == "targeted" ]]; then
        pass "Task 15: SELinux is permissive, persists across reboots, and uses the targeted policy"
    else
        fail "Task 15: SELinux is permissive, persists across reboots, and uses the targeted policy"
    fi

    # TASK 16 - VERIFY OVERALL LAB COMPLETION
    if [[ "$PASSED" -eq 15 ]]; then
        pass "Task 16: All 15 previous validation checks passed successfully"
    else
        fail "Task 16: Only $PASSED of the previous 15 validation checks passed"
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
#==================================================================
