<#
.SYNOPSIS
    The script download data from astozi SMART-SENSOR devices.
.DESCRIPTION
    The script download data from astozi SMART-SENSOR devices.
.NOTES
    File Name      : get_CSV_sensor.ps1
    Author         : Tomasz Zieba (tomasz.zieba@astozi.pl)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright 2017 - astozi
.LINK
    Script posted over:
    http://www.github.com
#>

$start_time = Get-Date
$destinationFolder = "c:\temp\"
$wc = New-Object System.Net.WebClient

$sourceData = @(
				@{"sourceIP" = "192.168.0.50"; "sourceFilename" = "LASTDAY.CSV"; "dstFilename" = "192_168_0_50_LASTDAY.CSV" },
				@{"sourceIP" = "192.168.0.51"; "sourceFilename" = "LASTDAY.CSV"; "dstFilename" = "192_168_0_51_LASTDAY.CSV" }
			)

$result = foreach ($entry in $sourceData) {
	$srcUrl = "http://" + $entry.Get_Item("sourceIP") + '/' + $entry.Get_Item("sourceFilename") 
	$dst = $destinationFolder + $entry.Get_Item("dstFilename")
	
	Write-Host ( (Get-Date).ToString() + " | Getting data from: $srcUrl " )
	$status = "UNKNOWN ERROR"
	try {
		$wc.DownloadFile($srcUrl, $dst)
		$status = "DONE"
	}
	catch [Net.WebException] {
		$status = "CONNECTION ERROR"
	}
	$msg = (Get-Date).ToString() + " | Getting data from: $srcUrl and saving to: " + $dst + ' --> ' + $status
	Write-Host ( $msg )
}

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
