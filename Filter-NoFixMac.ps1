Function Filter-NoFixMac{
	$file='ipMacMapListSource.csv'
	$DateStr=Get-Date -Format 'yyyyMMdd'
	If(!(Test-Path logDir\$DateStr\$file)){throw 'Please collect data first'}
	$timeStr=get-date -format 'HHmmss'
	mv logDir\$DateStr\$file logDir\$DateStr\"$timeStr-$file"
	$array=Import-Csv -Path summary.csv -Encoding UTF8|%{$_.mac}
	If($array -eq $null -or $array.count -eq 0){$array=@()}
	$set=New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([string[]]$array,[System.StringComparer]::OrdinalIgnoreCase)
	$tmp=Import-Csv -Path logDir\$DateStr\"$timeStr-$file" -Encoding UTF8|?{$set.add($_.mac)}
	$tmp|Export-Csv -Path logDir\$DateStr\$file -Encoding UTF8	
}
Filter-NoFixMac