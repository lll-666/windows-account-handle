Param(
	[Parameter(Mandatory=$true,HelpMessage="Please input the database connection, for example [mongodb://admin:Shyfzx163@172.17.8.218:27017]")]
	[String]$ConStr
)
Function Collection-Data($ConStr){
	If(!($pwd.path).EndsWith('account')){Throw 'Please ensure that the script execution directory is script directory'}
	$DateStr=Get-Date -Format 'yyyyMMdd'
	If(!(Test-Path logDir/$DateStr)){$null=md logDir/$DateStr -Force}
	If(Test-Path logDir\$DateStr\ipMacMapListSource.csv){
		$TimeStr=Get-Date -Format 'HHmmss'
		If(!(Test-Path logDir\bak\$DateStr\$TimeStr)){$null=md logDir\bak\$DateStr\$TimeStr\ -Force}
		mv logDir\$DateStr\* logDir\bak\$DateStr\$TimeStr\
	}
	
	Connect-Mdbc -ConnectionString $ConStr nodes nodeRecentComplianceResult
	$macList=Get-MdbcData -Distinct nodeMac
	$set=New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([string[]]$macList,[System.StringComparer]::OrdinalIgnoreCase)
	Connect-Mdbc -ConnectionString $ConStr nodes nodes
	$nodeList=Get-MdbcData -Project @{ipv4Addr=1;macAddr=1;lastModifiedTime=1}
	$final=$nodeList|%{If(($_['lastModifiedTime']) -gt (get-date).AddDays(-7) -and $set.contains($_['macAddr'])){New-Object PSObject -Property @{ip=$_['ipv4Addr'];mac=$_['macAddr']}}}
	$final|Export-Csv -Path logDir\$DateStr\ipMacMapListSource.csv -Encoding UTF8
}
Collection-Data $ConStr