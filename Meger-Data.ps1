Param($baseDir)
Function Do-MegerData($baseDir){
	#1.��������Դ
	$base=Import-Csv summary.csv -Encoding utf8
	#2.��ȡ��BIOSID�б�
	$BIOSIDList=$base|%{$_.BIOSID+$_.OSID+$_.CPUID+$_.ProductId}
	#3.����Set����
	If($BIOSIDList -eq $null){$BIOSIDList=@()}
	$set=New-Object -TypeName System.Collections.Generic.HashSet[string] -ArgumentList @([string[]]$BIOSIDList,[System.StringComparer]::OrdinalIgnoreCase)
	#4.�ϲ��ɹ�������
	$DateStr=Get-Date -Format 'yyyyMMdd'
	ls logDir\$DateStr\*_acc.csv|%{
		$newData=Import-Csv $_.FullName -Encoding utf8
		foreach($data in $newData){
			If(!$data.BIOSID){Continue}
			If($set.add($data.BIOSID+$data.OSID+$data.CPUID+$data.ProductId)){
				write-host $data
				$data|select date,ip,pass,OSID,BIOSID,CPUID,ProductId,ipsStr,mac,enabledMacs,enabledNoVMMacs|
					ConvertTo-Csv|
						select -Skip 2|
							Out-File summary.csv -Encoding UTF8 -Append
				
			}
		}
	}
}
Do-MegerData $baseDir