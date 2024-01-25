<?php

define("SERVICE_NAME",  "yellow");
define("SERVICE_VER",   "1.1");


$seq_counter = 1;
if( apcu_exists('seq_counter' ) ) {
    $seq_counter = apcu_fetch('seq_counter');
} 


$arr = array(
                'service-name'  => SERVICE_NAME,
                'version'       => SERVICE_VER,
                'commit-sha'    => 'xxxxxxx',
                'now'           => date('Y-m-d h:i:s'),
                'seq-counter:'  => $seq_counter
            );


$seq_counter++;
apcu_store('seq_counter', $seq_counter);



echo json_encode($arr);

?>
