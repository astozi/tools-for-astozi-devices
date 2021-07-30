$logfile = "log.txt"
$newline = "`r`n"

$proto = "http"
$user = "admin"
$pass = "admin"


$_ITERATIONS = 5
$_TIMEOUT = 30

$_SENSORS = @( 
							@{ IP = "10.10.10.52"; NAME = "Sensor_01"; },
							@{ IP = "10.10.10.101"; NAME = "Sensor_02"; }
					);
