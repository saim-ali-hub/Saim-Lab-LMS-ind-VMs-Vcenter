<?php
require_once __DIR__."/config.php";

function getVmName($student)
{
    return VM_PREFIX . strtolower($student);
}

function getVmID($sessionId, $vmName)
{
    $url =
        "https://" .
        VCENTER_SERVER .
        "/rest/vcenter/vm?filter.names=" .
        urlencode($vmName);

    $curl = curl_init($url);

    curl_setopt_array($curl,[

        CURLOPT_RETURNTRANSFER=>true,

        CURLOPT_HTTPHEADER=>[
            "vmware-api-session-id: ".$sessionId
        ],

        CURLOPT_SSL_VERIFYHOST=>false,

        CURLOPT_SSL_VERIFYPEER=>false

    ]);

    $response=curl_exec($curl);

    curl_close($curl);
  
    $json = json_decode($response, true);

    if (!isset($json['value'])) {
        error_log("Unexpected response: " . $response);
        return null;
    }

    if (!is_array($json['value'])) {
        error_log("Invalid value field: " . $response);
        return null;
    }

    if (!isset($json['value'][0]['vm'])) {
        return null;
    }

    return $json['value'][0]['vm'];

}

function getGuestIP($sessionId, $vmId)
{
    $url =
        "https://" .
        VCENTER_SERVER .
        "/api/vcenter/vm/" .
        $vmId .
        "/guest/networking/interfaces";

    $curl = curl_init($url);

    curl_setopt_array($curl, [

        CURLOPT_RETURNTRANSFER => true,

        CURLOPT_HTTPHEADER => [
            "vmware-api-session-id: " . $sessionId
        ],

        CURLOPT_SSL_VERIFYHOST => false,

        CURLOPT_SSL_VERIFYPEER => false,

        CURLOPT_TIMEOUT => 10

    ]);

    $response = curl_exec($curl);

    if ($response === false) {

        error_log(
            "getGuestIP curl error: " .
            curl_error($curl)
        );

        curl_close($curl);

        return null;
    }

    $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);

    curl_close($curl);

    error_log(
        "GUEST IP URL: " . $url . "\n" .
        "GUEST IP VM ID: " . $vmId . "\n" .
        "GUEST IP HTTP CODE: " . $httpCode . "\n" .
        "GUEST IP RESPONSE: " . $response
    );

    $json = json_decode($response, true);

    if (!is_array($json)) {

        error_log(
            "getGuestIP invalid JSON: " .
            $response
        );

        return null;
    }

    /*
     * vCenter response structure:
     *
     * [
     *   {
     *     "ip": {
     *       "ip_addresses": [
     *         {
     *           "ip_address": "192.168.111.188"
     *         }
     *       ]
     *     }
     *   }
     * ]
     */

    foreach ($json as $interface) {

        if (
            !isset($interface['ip']['ip_addresses']) ||
            !is_array($interface['ip']['ip_addresses'])
        ) {
            continue;
        }

        foreach (
            $interface['ip']['ip_addresses']
            as $ipInfo
        ) {

            $ip = $ipInfo['ip_address'] ?? '';

            if (
                filter_var(
                    $ip,
                    FILTER_VALIDATE_IP,
                    FILTER_FLAG_IPV4
                )
            ) {

                return $ip;
            }
        }
    }

    error_log(
        "getGuestIP: No IPv4 address found. Response: " .
        $response
    );

    return null;
}
