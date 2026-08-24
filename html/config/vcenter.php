<?php

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/secrets.php';

function vcenterLogin()
{
    $url = "https://" .
            VCENTER_SERVER .
            "/rest/com/vmware/cis/session";

    $curl = curl_init($url);

    curl_setopt_array($curl, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_USERPWD =>
            VCENTER_USERNAME .
            ":" .
            VCENTER_PASSWORD,
        CURLOPT_POST => true,
        CURLOPT_SSL_VERIFYHOST => false,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_TIMEOUT => 10
    ]);

    $response = curl_exec($curl);

    curl_close($curl);

    $json = json_decode($response, true);

    return $json['value'] ?? null;
}
