#!/bin/bash
# Lab 207 - Operation First Day : onboarding completion check
# Students run:  bash /tmp/onboarding_kit/check_onboarding.sh

W="$HOME/webshop"
ME=$(whoami)
PASS=0
TOTAL=10

ok()   { printf '  [PASS] %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  [FIX ] %s\n' "$1"; }
own()  { stat -c '%U' "$1" 2>/dev/null; }
grp()  { stat -c '%G' "$1" 2>/dev/null; }
mode() { stat -c '%a' "$1" 2>/dev/null; }

echo ""
echo "=========== TICKET #4471 - ONBOARDING CHECK ==========="

# 1 structure
if [ -d "$W/app/src/utils" ] && [ -d "$W/docs" ] && [ -d "$W/secrets" ] && [ -d "$W/reports" ]; then
    ok "Workspace structure (app/src/utils, docs, secrets, reports)"
else
    fail "Structure incomplete: need ~/webshop with app/src/utils, docs, secrets, reports"
fi

# 2 server audit
if [ -s "$W/reports/server_audit.txt" ]; then
    ok "Server audit recorded (reports/server_audit.txt)"
else
    fail "reports/server_audit.txt missing or empty"
fi

# 3 files copied / renamed
if [ -f "$W/app/start.sh" ] && [ -f "$W/docs/handbook.txt" ] && [ -f "$W/docs/welcome_badsha.txt" ] && [ -f "$W/secrets/db_password.txt" ]; then
    ok "Files staged: app/start.sh, docs/handbook.txt, docs/welcome_badsha.txt, secrets/db_password.txt"
else
    fail "Missing one of: app/start.sh, docs/handbook.txt, docs/welcome_badsha.txt, secrets/db_password.txt"
fi

# 4 grep evidence
if grep -q "developers" "$W/reports/badsha_access.txt" 2>/dev/null; then
    ok "Access approvals extracted with grep (reports/badsha_access.txt)"
else
    fail "reports/badsha_access.txt missing or does not contain badsha's group approval"
fi

# 5 welcome file owned by badsha
if [ "$(own "$W/docs/welcome_badsha.txt")" = "badsha" ]; then
    ok "Welcome package handed over: owner is badsha (chown)"
else
    fail "docs/welcome_badsha.txt owner is '$(own "$W/docs/welcome_badsha.txt")', expected badsha (sudo chown badsha ...)"
fail_hint=1
fi

# 6 app dir group developers, recursive
if [ "$(grp "$W/app")" = "developers" ] && [ "$(grp "$W/app/start.sh")" = "developers" ] && [ "$(grp "$W/app/src/utils")" = "developers" ]; then
    ok "Shared code belongs to group developers, recursively (chgrp -R)"
else
    fail "app/ and everything inside must have group developers (sudo chgrp -R developers app)"
fi

# 7 app dir group-writable
if [ "$(mode "$W/app")" = "775" ] || [ "$(mode "$W/app")" = "770" ]; then
    ok "Shared code directory is group-writable (app is $(mode "$W/app"))"
else
    fail "app/ should be group-writable, e.g. chmod 775 app (now: $(mode "$W/app"))"
fi

# 8 secrets: owner me, group admins
if [ "$(own "$W/secrets")" = "$ME" ] && [ "$(grp "$W/secrets")" = "admins" ] && [ "$(grp "$W/secrets/db_password.txt")" = "admins" ]; then
    ok "Secrets belong to $ME:admins, recursively (chown user:group)"
else
    fail "secrets/ (and inside) must be owner=$ME group=admins (sudo chown -R $ME:admins secrets)"
fi

# 9 secrets locked: dir 770, file 660 -> owner+group only, others nothing
sm=$(mode "$W/secrets"); fm=$(mode "$W/secrets/db_password.txt")
if [ "$sm" = "770" ] && [ "$fm" = "660" ]; then
    ok "Secrets locked to owner+admins only (dir 770, file 660)"
else
    fail "secrets/ must be 770 and secrets/db_password.txt 660 (now: ${sm:-none}/${fm:-none})"
fi

# 10 completion report
if grep -qi "badsha" "$W/reports/TICKET_4471_DONE.txt" 2>/dev/null; then
    ok "Completion report filed (reports/TICKET_4471_DONE.txt)"
else
    fail "reports/TICKET_4471_DONE.txt missing or does not mention badsha"
fi

echo "-------------------------------------------------------"
echo "  SCORE: $PASS / $TOTAL"
echo "======================================================="

if [ "$PASS" -eq "$TOTAL" ]; then
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
else
    echo ""
    echo "  Not closed yet. Fix the [FIX] items above and re-run:"
    echo "  bash /tmp/onboarding_kit/check_onboarding.sh"
fi
echo ""
