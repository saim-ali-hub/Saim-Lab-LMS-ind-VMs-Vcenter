#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo
    echo "=========================================="
    echo " ERROR: This script must be run as root."
    echo "=========================================="
    echo
    exit 1
fi

echo
echo "=========================================="
echo "LINOOP Setup Starts now ......."
echo "=========================================="
echo

# Configure Student Passwordless Sudo
echo
read -rp "Enter your VPN/LDAP username: " VPN_USER

if [ -z "$VPN_USER" ]; then
    echo "Username cannot be empty."
    exit 1
fi

# Verify the user exists
if ! id "$VPN_USER" >/dev/null 2>&1; then
    echo "User '$VPN_USER' does not exist on this machine."
    exit 1
fi

gpasswd -d "$VPN_USER" wheel 2>/dev/null || true

SUDO_FILE="/etc/sudoers.d/linoop-student"

cat > "$SUDO_FILE" <<EOF
$VPN_USER ALL=(ALL) NOPASSWD: ALL
EOF

chmod 440 "$SUDO_FILE"

# Validate sudoers syntax
if visudo -cf "$SUDO_FILE" >/dev/null 2>&1; then
    echo "Passwordless sudo configured for $VPN_USER." 2>&1
else
    echo "Invalid sudoers configuration."
    rm -f "$SUDO_FILE"
    exit 1
fi

# Remove firewall port 8080
if command -v firewall-cmd >/dev/null 2>&1; then

    firewall-cmd --remove-port=8080/tcp >/dev/null 2>&1

    firewall-cmd --permanent \
        --remove-port=8080/tcp >/dev/null 2>&1

    firewall-cmd --reload >/dev/null 2>&1

fi

# Remove Lab 230 web page
INDEX_FILE="/var/www/html/index.html"

if [ -f "$INDEX_FILE" ]; then

    if grep -Fq "I am configuring apache server in my TSR3" "$INDEX_FILE" 2>/dev/null; then
        rm -f "$INDEX_FILE" >/dev/null 2>&1
    fi

fi


# Restore Apache configuration
HTTPD_CONF="/etc/httpd/conf/httpd.conf"

if [ -f "$HTTPD_CONF" ]; then

    # Restore Apache default HTTP port if it was changed to 8080.
    sed -i \
        -E 's/^[[:space:]]*Listen[[:space:]]+8080[[:space:]]*$/Listen 80/' \
        "$HTTPD_CONF" >/dev/null 2>&1

fi


# Restore SELinux enforcing mode if available
if command -v getenforce >/dev/null 2>&1; then

    setenforce 1 >/dev/null 2>&1

fi


# Stop and disable Apache
if command -v systemctl >/dev/null 2>&1; then

    systemctl stop httpd >/dev/null 2>&1
    systemctl disable httpd >/dev/null 2>&1

fi


# Remove Apache
if command -v dnf >/dev/null 2>&1; then

    dnf remove -y httpd >/dev/null 2>&1

elif command -v yum >/dev/null 2>&1; then

    yum remove -y httpd >/dev/null 2>&1

fi


# Remove Robert's SSH authorized_keys
ROBERT_HOME=$(getent passwd robert 2>/dev/null | cut -d: -f6)

if [ -n "$ROBERT_HOME" ]; then

    rm -f "$ROBERT_HOME/.ssh/authorized_keys" >/dev/null 2>&1

    # Remove .ssh directory if it is now empty.
    rmdir "$ROBERT_HOME/.ssh" >/dev/null 2>&1

fi


# Remove Robert sudo privilege
rm -f /etc/sudoers.d/robert >/dev/null 2>&1

# Validate/reload sudoers configuration if possible.
if command -v visudo >/dev/null 2>&1; then
    visudo -c >/dev/null 2>&1
fi


# Remove Robert from devops group
if getent passwd robert >/dev/null 2>&1 &&
   getent group devops >/dev/null 2>&1; then

    gpasswd -d robert devops >/dev/null 2>&1

fi


# Remove devops group
if getent group devops >/dev/null 2>&1; then

    groupdel devops >/dev/null 2>&1

fi


# Remove Robert user
if id robert >/dev/null 2>&1; then

    userdel -r robert >/dev/null 2>&1

fi


# Task 12 - Restore network configuration

# Find active connection containing the current IP.
CURRENT_IP=""

CURRENT_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

ACTIVE_PROFILE=""

while IFS=: read -r PROFILE DEVICE; do

    [ -z "$PROFILE" ] && continue
    [ -z "$DEVICE" ] && continue

    CONFIGURED_IP=$(nmcli -g ipv4.addresses connection show "$PROFILE" 2>/dev/null)

    if echo "$CONFIGURED_IP" \
        | tr ',' '\n' \
        | grep -Fq "$CURRENT_IP"; then

        ACTIVE_PROFILE="$PROFILE"
        break

    fi

done < <(
    nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null
)


if [ -n "$ACTIVE_PROFILE" ]; then

    # Restore DHCP/default network configuration.
    nmcli connection modify "$ACTIVE_PROFILE" \
        ipv4.method auto \
        ipv4.addresses "" \
        ipv4.gateway "" \
        ipv4.dns "" \
        >/dev/null 2>&1

    nmcli connection up "$ACTIVE_PROFILE" >/dev/null 2>&1

fi

echo
echo "=========================================="
echo " LINOOP Set completed successfully."
echo "=========================================="
echo
echo


exit 0
