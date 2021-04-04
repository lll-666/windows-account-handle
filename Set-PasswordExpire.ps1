Function getPSCredential($acc,$pass){New-Object System.Management.Automation.PSCredential $acc,(ConvertTo-SecureString $pass -AsPlainText -Force)}
Function WriteLog($isSuccess,$command,$msg,[Hashtable]$table){
	If($table -eq $null){$table=@{}}
	New-Object PSObject -Property @{ip=$ip;
		mac=$mac;isSuccess=$isSuccess;pass=$pass
		command=$command;msg=($msg -join ';')
		date="$((Get-Date).tostring())"
		ipsStr=$table.ipsStr;
		enabledMacs=$table.enabledMacs;
		enabledNoVMMacs=$table.enabledNoVMMacs;
		OSID=$table.MachineGUID;
		CPUID=$table.CPUID;
		ProductId=$table.ProductId;
		BIOSID=$table.BIOSID
	}|select date,ip,pass,isSuccess,OSID,BIOSID,CPUID,ProductId,mac,ipsStr,enabledMacs,enabledNoVMMacs,command,msg|
		ConvertTo-Csv|
			select -Skip 2|
				Out-File "${tmp}_acc.csv" -Encoding UTF8 -Append
}

Function Set-PasswordExpiresForIpMacList([Object[]]$ipMacList,[String]$verifiedAccount,[String[]]$passes,[String] $modifyAccount,[ValidateSet('false','true')]$expire,[String]$executePath){
	$ipMacMap=@{}
	Foreach($ipMac in $ipMacList){
		$ip=$ipMac.ip
		$mac=$ipMac.mac
		$val=$ipMacMap.$ip
		if($val){$mac="$val,$mac"}
		$ipMacMap.$ip=$mac
	}
	Set-PasswordExpiresForIpMacMap $ipMacMap $verifiedAccount $passes $modifyAccount $expire $executePath
}

Function Set-PasswordExpiresForIpMacMap([Hashtable]$ipMacMap,[String]$verifiedAccount,[String[]]$passes,[String] $modifyAccount,[ValidateSet('false','true')]$expire,[String] $executePath){
	If([String]::IsNullOrEmpty($executePath)){$executePath=$pwd.path}
	$logDir=Join-Path $executePath "logDir\$(Get-Date -Format 'yyyyMMdd')"
	If(!(Test-Path $logDir)){$null=mkdir $logDir}
	$tmp="$logDir\$(Get-Date -Format 'HHmmss')"
	'"date","ip","pass","isSuccess","OSID","BIOSID","CPUID","ProductId","mac","ipsStr","enabledMacs","enabledNoVMMacs","command","msg"'|Out-File "${tmp}_acc.csv" -Encoding UTF8 -Append
	$ipList=$ipMacMap.keys
	Foreach($ip in $ipList){
		$mac=$ipMacMap.$ip
		$pass=$null
		$null=Test-Wsman $ip -ErrorAction SilentlyContinue
		If(!$?){WriteLog "false" "Test-Wsman $ip" "the exception is $($error[0])";Continue}
		Foreach($pass in $passes){
			if($session -and 'Opened' -eq $session.state){Remove-PSSession $session}
			$session=New-PSSession $ip -Authentication Default -Credential (getPSCredential $verifiedAccount $pass) -SessionOption (New-PSSessionOption -OpenTimeout 8) -ErrorAction SilentlyContinue
			If(!$? -or ($session -eq $null)){WriteLog "false" "New-PSSession $ip -Authentication Default -Credential (getPSCredential $verifiedAccount $pass)" "the exception is $($error[0])";Continue}
			$ret=Invoke-Command -Session $session{
				Function Set-PasswordExpires([String]$acc, [String]$expire){
					Function Set-PE($acc,$expire){
						$null=cmd.exe /c "wmic.exe UserAccount Where Name=`"$acc`" Set PasswordExpires=`"$expire`""
						If(!$?){Return "false","The Exception is $error(0)"}
						$ret=cmd.exe /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
						If($ret|?{$_ -like "*$expire*"}){Return "true","Property modified successfully"}
						Return "false",($ret -join ',')
					}
					$ret=cmd.exe /c "wmic.exe UserAccount Where Name=`"$acc`" Get PasswordExpires"
					If(!$? -or ($ret -eq $null)){Return "false","the Exception is $error(0)"}
					Foreach($r in $ret){
						If('false' -eq $r.trim()){
							If('false' -eq $expire){Return "true","no need handle"}
							Return Set-PE $acc $expire
						}ElseIf('true' -eq $r.trim()){
							If('true' -eq $expire){Return "true","no need handle"}
							Return Set-PE $acc $expire
						}
					}
					Return "false",($ret -join ',')
				}
				Try{
					$arr=Set-PasswordExpires $args[0] $args[1]
				}Catch{
					$arr=@('false',"the exception is $($error[0])")
				}
				Return $arr+=@{
					ipsStr=(gwmi win32_NetworkAdapterConfiguration|?{$_.ipenabled -like $true -and $_.ServiceName -ne 'VMnetAdapter' -and $_.DefaultIPGateway}|%{if($_.ipaddress -ne $null){ $_.ipaddress[0]}}) -join ',';
					enabledMacs=(gwmi win32_networkadapter|?{$_.NetEnabled -eq $true}|%{$_.MACAddress}) -join ',';
					enabledNoVMMacs=(gwmi win32_networkadapter|?{$_.NetEnabled -eq $true -and $_.serviceName -ne 'VMnetAdapter'}|%{$_.MACAddress}) -join ','
					MachineGUID=(Get-Item HKLM:\SOFTWARE\Microsoft\Cryptography).GetValue('MachineGUID');
					BIOSID=(gwmi Win32_BIOS).SerialNumber;
					CPUID=(wmic cpu get processorid|select -Skip 1|?{$_.trim() -ne ''}) -join ',';
					ProductId=(Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ProductId')
				}
			} -ArgumentList $modifyAccount,$expire -ErrorAction SilentlyContinue
			If($?){
				WriteLog $ret[0] 'Invoke-Command' $ret[1] $ret[2]
				Break
			}Else{
				WriteLog 'false' 'Invoke-Command' "the exception is $($error[0])"
			}
			If($session -and 'Opened' -eq $session.state){Remove-PSSession $session}
		}	
	}
}