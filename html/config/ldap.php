<?php

require_once __DIR__ . '/config.php';

function authenticateStudent($username, $password)
{
    $connection = ldap_connect(LDAP_SERVER, LDAP_PORT);

    if (!$connection) {
        return false;
    }

    ldap_set_option($connection, LDAP_OPT_PROTOCOL_VERSION, 3);
    ldap_set_option($connection, LDAP_OPT_REFERRALS, 0);

    $bindUser = $username . '@' . LDAP_DOMAIN;

    $bind = @ldap_bind(
        $connection,
        $bindUser,
        $password
    );

    ldap_unbind($connection);

    return $bind;
}

?>
