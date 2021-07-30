# loading helper methods
. ../__ENGINE__/SMART_Base_Functions.ps1
. ../__ENGINE__/SMART_Object_Functions.ps1

. ./SMART_00_Base_Variables.ps1

"Start script" | Out-File -filepath $logfile 
Ignore-SelfSignedCerts


For ($j=0; $j -lt $_ITERATIONS; $j++) {

	For ($i=0; $i -lt $_SENSORS.Length; $i++) {
		$_sensor 				= $($_SENSORS[$i]);
		$_sensor_ip 			= $($_sensor)['IP'];
		$_sensor_name 			= $($_sensor)['NAME'];
		
		$_TEMP = get_temp ($_sensor_ip);
		$_HUM = get_hum ($_sensor_ip);
		$datafile = "data_$_sensor_name.txt"
		SaveData "$_sensor_ip;$_sensor_name;$_TEMP;$_HUM $newline" $datafile
	}
	Start-Sleep -Seconds $_TIMEOUT
}
