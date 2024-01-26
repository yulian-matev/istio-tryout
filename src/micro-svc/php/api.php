<?php

define("SERVICE_VER",   "1.1");

# Load sequence counter
$seq_counter = 1;
if( apcu_exists('seq_counter' ) ) {
    $seq_counter = apcu_fetch('seq_counter');
}

# Try to detect service name from environment or default to 'black'
$service_name = 'black';
if( getenv("SERVICE_NAME") !== false ) {
    $service_name = $_ENV['SERVICE_NAME'];
}


$arr = array(
                'service-name'  => $service_name,
                'version'       => SERVICE_VER,
                'commit-sha'    => 'xxxxxxx',
                'now'           => date('Y-m-d h:i:s'),
                'seq-counter:'  => $seq_counter
            );


# Increment and store sequence counter
$seq_counter++;
apcu_store('seq_counter', $seq_counter);



echo json_encode($arr, JSON_PRETTY_PRINT);

?>
