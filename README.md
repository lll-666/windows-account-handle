# windows-account-handle

#一、前置操作
#管理员模式打开powershell，切换到脚本目录（请依据实际情况灵活变通），执行如下脚本
$workspace='C:\Users\Administrator\Desktop\account'
cd $workspace

#二、环境检测和部署
#step1 查看模块【Mdbc】是否已经安装；有返回则说明已经安装，则跳过步骤step1..6，执行步骤step7
Get-Module Mdbc

#step2 执行如下命令，如果返回true，则跳过步骤step3，执行步骤step4
(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release -ge 461308

#step3 升级.Net版本为4.8；此步骤耗时很长，不要心急。
#手动双击文件 【ndp48-x86-x64-allos-enu.exe】，并进行安装
#.Net升级包下载地址：https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe

#step4 安装完成，重启系统

#step5 将整个文件夹【Mdbc】拷贝到PsModulePath下
#[Mdbc]位于脚本目录，请先把活动目录切换到脚本目录
cp Mdbc $env:PSModulePath.split(';')[1] -Recurse -Force

#step6 导入模块到powershell环境中
Import-Module Mdbc

#三、执行帐户修复
#step7 [Unified-Execution]位于脚本目录，请先把活动目录切换到脚本目录
.\Unified-Execution.ps1
