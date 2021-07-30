function Ignore-SelfSignedCerts
{
    try
    {
        Write-Host "Adding TrustAllCertsPolicy type." -ForegroundColor White
        Add-Type -TypeDefinition  @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy
        {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem)
             {
                 return true;
            }
        }
"@
        Write-Host "TrustAllCertsPolicy type added." -ForegroundColor White
      }
    catch
    {
        Write-Host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

Function SaveData ( $logline, $logfile ) {
	$dateline = Get-Date -Format "yyyy/MM/dd HH:mm:ss "
	Write-Host $dateline -NoNewline
	Write-Host $logline -NoNewline
	Get-Date -Format "yyyy/MM/dd HH:mm:ss " | Out-File -append  -filepath $logfile -NoNewline
	$logline | Out-File -append  -filepath $logfile -NoNewline
}

Function runMethodOnDevice ([string]$root, [string]$user, [string]$pass, $postParams, $method) {
	$pair = "$($user):$($pass)"
	$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

	$basicAuthValue = "Basic $encodedCreds"
	$Headers = @{
		Authorization = $basicAuthValue;
		Accept = '*/*';
	}
	$json = $postParams | ConvertTo-Json -Compress -Depth 50
	$status = 200
	$result = 'empty'
	$contentType = 'application/json'
	try {
		if ( $method -eq "DELETE" ) {
			$result = Invoke-WebRequest -DisableKeepAlive -Uri $root -Method DELETE -Headers $Headers -UseBasicParsing -ErrorVariable RestError
		} elseif ( $method -eq "GET" ) {
			$result = Invoke-WebRequest -DisableKeepAlive -Uri $root -Method GET -Headers $Headers -UseBasicParsing -ErrorVariable RestError
		} elseif ( $method -eq "GET-FILE" ) {
			$result = Invoke-WebRequest -DisableKeepAlive -Uri $root -Method GET -Headers $Headers -UseBasicParsing -ErrorVariable RestError
			$result = $result.Content
		} else {
			$result = Invoke-WebRequest -DisableKeepAlive -Uri $root -Method $method -Headers $Headers -UseBasicParsing -ContentType $contentType -Body $json  -ErrorVariable RestError
		}
	} catch {
		if ($RestError) {
			SaveData "ERROR $newline" $logfile
			SaveData "$RestError $newline" $logfile
			$status = $RestError.ErrorRecord.Exception.Response.StatusCode.value__
			$result = $RestError.ErrorRecord.Exception.Response.StatusDescription
		}
	}
	return $status, $result
}

Function communicationParser ($url, $user, $pass, $postParams, $method) {
	$postParamsString = $postParams | ConvertTo-Json -Depth 50 -Compress | Out-String
	SaveData "$url | $method | $user | $pass | $postParamsString" $logfile
	$status, $result = runMethodOnDevice $url $user $pass $postParams $method
	$result_json = $result
	if ( $method -ne "GET-FILE" ) {
		if ($status -eq 200) {
			$result_json = $result | ConvertFrom-Json
		}
	}
	if ( $method -ne "GET-FILE" ) {
		SaveData "$status | $result_json $newline" $logfile
	}
	SaveData "--------------------- $newline" $logfile
	return $status, $result_json
}

Function Convert-FromUnixDate ($UnixDate) {
   [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
}

Function Convert-APIToCSV ($_csv_import) {
	$_csv = $_csv_import | ForEach-Object {
		$_int = (([UInt64 ][math]::Round($_.timestamp)) / 1000);
		$_date = Convert-FromUnixDate $_int;
		$_date = $_date.ToUniversalTime()
		$_date_string  = $_date.ToString("yyyy-MM-dd HH:mm:ss");
		$_value = $_.value;
		$_.timestamp = $_date_string;
		$_.value = $_value;
		$_
	}
	return $_csv
}
