Function get_temp ($_IP) {
	$_odczyt = 'error';
	$url = $proto + "://" + $_IP + "/DATA.GET";
	$status, $result = communicationParser $url $user $pass '' "GET";
	if ( $status -eq 200 ) {$_odczyt = $result[0].snsr[0].v }
	
	return $_odczyt
}

Function get_hum ($_IP) {
	$_odczyt = 'error';
	$url = $proto + "://" + $_IP + "/DATA.GET";
	$status, $result = communicationParser $url $user $pass '' "GET";
	if ( $status -eq 200 ) {$_odczyt = $result[0].snsr[1].v }
	
	return $_odczyt
}
