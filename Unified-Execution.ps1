#0.校验执行目录
$workspace="$env:USERPROFILE\Desktop\account"
If(!(Test-path $workspace)){Write-Warning 'Please make sure that the execution directory is the script directory';Break}
If(Test-path account){$workspace=Join-path $workspace account}
cd $workspace
If(!(Test-path Collection-Data.ps1)){Write-Warning 'Please make sure that the execution directory is the script directory';Break}

#1.收集数据
. .\Collection-Data -ConStr mongodb://admin:Shyfzx163@172.17.8.218:27017

#2.过滤掉已经执行成功的
. .\Filter-NoFixMac

#3.文件拆分段，4为拆分个数；可根据实际情况设置
$segs=4
. .\Split-File.ps1 -segs $segs

#4.执行脚本 （‘hp’为帐户名，依据实际环境进程修改；‘shenmegui123,bunenggaosuni123’为密码集合，密码之间逗号隔开）
. .\asyExecute.ps1 -segs $segs -account hp -passes shenmegui123,bunenggaosuni123

#5.执行结果合并
. .\Meger-Data.ps1