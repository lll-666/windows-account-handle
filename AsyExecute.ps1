Param(
	[Parameter(Mandatory=$True)][int]$segs,
	[Parameter(Mandatory=$True)][String]$account,
	[Parameter(Mandatory=$True)][String[]]$passes
)
$jobs=@()
Foreach($seg in 0..($segs-1)){
	$job=[powershell]::Create().AddScript({
		Param($arr)
		$DateStr=Get-Date -Format 'yyyyMMdd'
		$ipMacList=Import-Csv -Path "$($arr[3])\logDir\$DateStr\ipMacList$($arr[0]).csv" -Encoding UTF8
		iex ". $($arr[3])\Set-PasswordExpire.ps1"
		Set-PasswordExpiresForIpMacList -ipMacList $ipMacList -verifiedAccount $arr[1] -passes $arr[2] -modifyAccount 'Nodemanager' -expire 'false' -executePath $arr[3]
	}).AddArgument(@($seg,$account,$passes,$pwd.path))
	$jobs+=$job.BeginInvoke()
	sleep 2
}

Write-Host "Waiting.." -NoNewline
Do{
   Write-Host "." -NoNewline
   Start-Sleep -Seconds 1
}While($Jobs.IsCompleted -contains $false)
Write-Host "All jobs completed!"