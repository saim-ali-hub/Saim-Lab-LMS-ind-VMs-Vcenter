#!/bin/bash
#===============================================================
# Lab 207 - Operation First Day : PROGRESS CHECKER
#
# Students can run this ANY TIME - after one task, after a phase,
# or at the very end. It never changes anything; it only reports.
#
#   bash /tmp/onboarding_kit/check_lab207.sh        -> full report, all phases + score
#   bash /tmp/onboarding_kit/check_lab207.sh 4      -> only Phase 4
#   bash /tmp/onboarding_kit/check_lab207.sh 6 7    -> Phases 6 and 7
#
# Instructor / root use (grade someone else):
#   bash check_lab207.sh --user jsmith              -> full report for that student
#   bash check_lab207.sh --user jsmith --summary    -> one line: user, passed, total, percent
#===============================================================

TARGET_USER=$(whoami)
SUMMARY=0
PHASES=()
while [ $# -gt 0 ]; do
    case "$1" in
        --user)    TARGET_USER="$2"; shift 2 ;;
        --summary) SUMMARY=1; shift ;;
        [1-8])     PHASES+=("$1"); shift ;;
        *)         echo "usage: $0 [phase numbers 1-8] [--user NAME] [--summary]"; exit 1 ;;
    esac
done
[ ${#PHASES[@]} -eq 0 ] && PHASES=(1 2 3 4 5 6 7 8)

HOMEDIR=$(getent passwd "$TARGET_USER" | cut -d: -f6)
[ -z "$HOMEDIR" ] && HOMEDIR="/home/$TARGET_USER"
W="$HOMEDIR/webshop"
ME="$TARGET_USER"

PASS=0; TOTAL=0
PPASS=0; PTOTAL=0
own()  { stat -c '%U' "$1" 2>/dev/null; }
grp()  { stat -c '%G' "$1" 2>/dev/null; }
mode() { stat -c '%a' "$1" 2>/dev/null; }

want() { PHASES_STR=" ${PHASES[*]} "; [[ "$PHASES_STR" == *" $1 "* ]]; }

# t <task#> <description> <condition-command...>
t() {
    local num="$1" desc="$2"; shift 2
    TOTAL=$((TOTAL+1)); PTOTAL=$((PTOTAL+1))
    if "$@" >/dev/null 2>&1; then
        PASS=$((PASS+1)); PPASS=$((PPASS+1))
        [ $SUMMARY -eq 0 ] && printf '   [ OK ] Task %-2s %s\n' "$num" "$desc"
    else
        [ $SUMMARY -eq 0 ] && printf '   [ .. ] Task %-2s %s\n' "$num" "$desc"
    fi
}
phase_start() { PPASS=0; PTOTAL=0; [ $SUMMARY -eq 0 ] && printf '\n Phase %s - %s\n' "$1" "$2"; }
phase_end()   { [ $SUMMARY -eq 0 ] && printf '        -> %s/%s\n' "$PPASS" "$PTOTAL"; }

# --- helper predicates ---
has()      { grep -q "$1" "$2" 2>/dev/null; }
hasi()     { grep -qi "$1" "$2" 2>/dev/null; }
isdir()    { [ -d "$1" ]; }
isfile()   { [ -f "$1" ]; }
nonempty() { [ -s "$1" ]; }
either()   { [ -f "$1" ] || [ -f "$2" ]; }
mode_is()  { [ "$(mode "$1")" = "$2" ]; }
own_is()   { [ "$(own "$1")" = "$2" ]; }
grp_is()   { [ "$(grp "$1")" = "$2" ]; }
uexec()    { [ -x "$1" ] && [ "$(mode "$1" | cut -c1)" -ge 5 ]; }
audit_ok() { has "$ME" "$1" && has "uid=" "$1"; }
sys_ok()   { has "Linux" "$1" && has "load average" "$1" && has "Mem" "$1"; }
app_grp()  { grp_is "$W/app" developers && grp_is "$W/app/start.sh" developers && grp_is "$W/app/src/utils" developers; }
sec_own()  { own_is "$W/secrets" "$ME" && grp_is "$W/secrets" admins && grp_is "$W/secrets/db_password.txt" admins; }
app_mode() { mode_is "$W/app" 775 || mode_is "$W/app" 770; }

[ $SUMMARY -eq 0 ] && {
    echo ""
    echo "================ LAB 207 PROGRESS - $ME ================"
}

if want 1; then
    phase_start 1 "Read the Ticket"
    t 1  "Home directory reachable (nothing to check - navigation)" true
    phase_end
fi
if want 2; then
    phase_start 2 "Build the Project Workspace"
    t 3  "~/webshop exists"                                    isdir "$W"
    t 4  "app, docs, secrets, reports created"                 bash -c "[ -d '$W/app' ] && [ -d '$W/docs' ] && [ -d '$W/secrets' ] && [ -d '$W/reports' ]"
    t 5  "app/src/utils created (mkdir -p)"                    isdir "$W/app/src/utils"
    t 6  "reports/onboarding_report.txt created (touch)"       either "$W/reports/onboarding_report.txt" "$W/reports/TICKET_4471_DONE.txt"
    phase_end
fi
if want 3; then
    phase_start 3 "Audit the Server"
    t 7  "server_audit.txt has whoami + id output"             audit_ok "$W/reports/server_audit.txt"
    t 8  "server_audit.txt has uname, uptime, free output"     sys_ok   "$W/reports/server_audit.txt"
    phase_end
fi
if want 4; then
    phase_start 4 "Stage the Files"
    t 10 "app/start.sh copied + renamed"                       isfile "$W/app/start.sh"
    t 11 "docs/handbook.txt copied"                            isfile "$W/docs/handbook.txt"
    t 12 "docs/welcome_badsha.txt copied (absolute path)"      isfile "$W/docs/welcome_badsha.txt"
    t 13 "secrets/db_password.txt copied"                      isfile "$W/secrets/db_password.txt"
    t 14 "welcome_badsha.txt personalized with echo >>"        has "Your admin is" "$W/docs/welcome_badsha.txt"
    t 15 "docs backed up + renamed to reports/docs_archive"    isdir "$W/reports/docs_archive"
    phase_end
fi
if want 5; then
    phase_start 5 "Investigate the Paperwork"
    t 19 "reports/badsha_access.txt has roster + APPROVED line" bash -c "grep -q developer '$W/reports/badsha_access.txt' && grep -q APPROVED '$W/reports/badsha_access.txt'"
    phase_end
fi
if want 6; then
    phase_start 6 "Set Permissions"
    t 20 "app is 775 (group-writable)"                         app_mode
    t 21 "app/start.sh executable by owner (u+x)"              uexec "$W/app/start.sh"
    t 22 "secrets 770 and db_password.txt 660"                 bash -c "[ \"\$(stat -c %a '$W/secrets')\" = 770 ] && [ \"\$(stat -c %a '$W/secrets/db_password.txt')\" = 660 ]"
    phase_end
fi
if want 7; then
    phase_start 7 "Hand Over Ownership (chown / chgrp)"
    t 23 "welcome_badsha.txt owner is badsha (chown)"          own_is "$W/docs/welcome_badsha.txt" badsha
    t 24 "app/start.sh group is developers (chgrp)"            grp_is "$W/app/start.sh" developers
    t 25 "all of app/ is group developers (chgrp -R)"          app_grp
    t 26 "secrets is $ME:admins recursively (chown user:group -R)" sec_own
    phase_end
fi
if want 8; then
    phase_start 8 "Close the Ticket"
    t 28 "reports/TICKET_4471_DONE.txt filed, mentions badsha" hasi badsha "$W/reports/TICKET_4471_DONE.txt"
    phase_end
fi

PCT=0; [ $TOTAL -gt 0 ] && PCT=$(( PASS * 100 / TOTAL ))

if [ $SUMMARY -eq 1 ]; then
    printf '%s,%s,%s,%s\n' "$ME" "$PASS" "$TOTAL" "$PCT"
    exit 0
fi

echo ""
echo "---------------------------------------------------------"
printf '  CHECKED: %s/%s tasks passed  (%s%%)\n' "$PASS" "$TOTAL" "$PCT"
if [ ${#PHASES[@]} -eq 8 ]; then
    if   [ $PCT -eq 100 ]; then echo "  GRADE:   A+  - ticket closed, flawless."
    elif [ $PCT -ge 90 ];  then echo "  GRADE:   A   - excellent, one small thing left."
    elif [ $PCT -ge 75 ];  then echo "  GRADE:   B   - solid; finish the [ .. ] items."
    elif [ $PCT -ge 50 ];  then echo "  GRADE:   C   - halfway there, keep going."
    else                        echo "  GRADE:   in progress - keep working, re-run me anytime."
    fi
fi
echo "---------------------------------------------------------"

if [ ${#PHASES[@]} -eq 8 ] && [ $PASS -eq $TOTAL ]; then
cat << 'BANNER'

  _______ _____ _____ _  ________ _______    _____ _      ____   _____ ______ _____
 |__   __|_   _/ ____| |/ /  ____|__   __|  / ____| |    / __ \ / ____|  ____|  __ \
    | |    | || |    | ' /| |__     | |    | |    | |   | |  | | (___ | |__  | |  | |
    | |    | || |    |  < |  __|    | |    | |    | |   | |  | |\___ \|  __| | |  | |
    | |   _| || |____| . \| |____   | |    | |____| |___| |__| |____) | |____| |__| |
    |_|  |_____\_____|_|\_\______|  |_|     \_____|______\____/|_____/|______|_____/

   Ticket #4471 resolved. Badsha is onboarded:
     - workspace built and server audited
     - his welcome package is HIS (chown)
     - the code is shared with the developers group (chgrp -R + 775)
     - the secrets are locked to admins only (chown user:group + 770/660)

   Onboarding users, handing over files, sharing directories with
   teams and locking down secrets - this is what Linux admins do
   EVERY week. You just did all of it. Nicely done, admin.
BANNER
elif [ $PASS -lt $TOTAL ]; then
    echo "  [ .. ] = not done yet (or done differently). Fix and re-run:"
    echo "         bash /tmp/onboarding_kit/check_lab207.sh ${PHASES[*]}"
fi
echo ""
