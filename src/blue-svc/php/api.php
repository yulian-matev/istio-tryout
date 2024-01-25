<?php

define("SERVICE_NAME",  "blue");
define("SERVICE_VER",   "1.0");




$arr = array(
                'service-name'  => SERVICE_NAME,
                'version'       => SERVICE_VER,
                'commit-sha'    => 'xxxxxxx',
                'now'           => date('Y-m-d h:i:s') 
            );


echo json_encode($arr);


?>
