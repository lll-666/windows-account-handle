#0.У��ִ��Ŀ¼
$workspace="$env:USERPROFILE\Desktop\account"
If(!(Test-path $workspace)){Write-Warning 'Please make sure that the execution directory is the script directory';Break}
If(Test-path account){$workspace=Join-path $workspace account}
cd $workspace
If(!(Test-path Collection-Data.ps1)){Write-Warning 'Please make sure that the execution directory is the script directory';Break}

#1.�ռ�����
. .\Collection-Data -ConStr mongodb://admin:Shyfzx163@172.17.8.218:27017

#2.���˵��Ѿ�ִ�гɹ���
. .\Filter-NoFixMac

#3.�ļ���ֶΣ�4Ϊ��ָ������ɸ���ʵ���������
$segs=4
. .\Split-File.ps1 -segs $segs

#4.ִ�нű� ����hp��Ϊ�ʻ���������ʵ�ʻ��������޸ģ���shenmegui123,bunenggaosuni123��Ϊ���뼯�ϣ�����֮�䶺�Ÿ�����
. .\asyExecute.ps1 -segs $segs -account hp -passes shenmegui123,bunenggaosuni123

#5.ִ�н���ϲ�
. .\Meger-Data.ps1