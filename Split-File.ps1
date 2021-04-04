param([int]$Segs=4)
Function Split-File($Segs){
	$DateStr=Get-Date -Format 'yyyyMMdd'
	$TimeStr=Get-Date -Format 'HHmmss'
	If(!(Test-Path logDir/$DateStr/ipMacMapListSource.csv)){Throw 'Please collect data first.'}
	$ipMacListSum=Import-Csv -Path logDir/$DateStr/ipMacMapListSource.csv -Encoding UTF8
	$length=$ipMacListSum.count
	$duanL=$length/$Segs
	Foreach($i in 0..($Segs-1)){
		$splitFilePath="logDir/$DateStr/ipMacList$i.csv"
		If(Test-Path $splitFilePath){mv logDir/$DateStr/ipMacList$i.csv logDir/$DateStr/${TimeStr}-ipMacList$i.csv}
		If($i -ne ($Segs-1)){
			$ipMacListSum[($i*$duanL)..(($i+1)*$duanL-1)]|Export-Csv -Path $splitFilePath -Encoding UTF8
		}else{
			$ipMacListSum[($i*$duanL)..$length]|Export-Csv -Path $splitFilePath -Encoding UTF8
		}
	}
}
Split-File $Segs