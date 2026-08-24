<?php
/*
|--------------------------------------------------------------------------
| Active Directory Configuration
|--------------------------------------------------------------------------
*/

define('LDAP_SERVER', '192.168.111.50');
define('LDAP_PORT', 389);

// Your Active Directory domain
define('LDAP_DOMAIN', 'corp.linoop.us');

// Base DN
define('LDAP_BASE_DN', 'DC=corp,DC=linoop,DC=us');

// Vcenter Server
define('VCENTER_SERVER','192.168.111.253');

// VM_PREFIX
define('VM_PREFIX','vm-');

/*
|--------------------------------------------------------------------------
| SSH Configuration
|--------------------------------------------------------------------------
*/

define('SSH_USERNAME', 'validator');

define('SSH_PRIVATE_KEY', '/home/validator/.ssh/id_rsa');

/*
|--------------------------------------------------------------------------
| Validation Script
|--------------------------------------------------------------------------
*/

define('VALIDATOR_SCRIPT',
'/var/www/private_data/lab/validate_lab.sh');

?>
