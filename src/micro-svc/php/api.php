<?php

define("SERVICE_VER",   "1.1");

# Load sequence counter
$seq_counter = 1;
if( apcu_exists('seq_counter' ) ) {
    $seq_counter = apcu_fetch('seq_counter');
}

# Try to detect service name from environment or default to 'white'
$service_name = 'white';
if( getenv("SERVICE_NAME") !== false ) {
    $service_name = $_ENV['SERVICE_NAME'];
}

$version_long = '';
if( getenv("SERVICE_VERSION_LONG") !== false ) {
    $version_long = $_ENV['SERVICE_VERSION_LONG'];
}

$arr = array(
                'service-name'  => $service_name,
                'pod-ip-addr'   => $_SERVER['SERVER_ADDR'],
                'pod-hostname'  => $_SERVER['SERVER_NAME'],
                'version'       => SERVICE_VER,
                'version-long'  => $version_long,
                'now'           => date('Y-m-d h:i:s'),
                'seq-counter:'  => $seq_counter
            );


# Increment and store sequence counter
$seq_counter++;
apcu_store('seq_counter', $seq_counter);



echo json_encode($arr, JSON_PRETTY_PRINT);

?>

