@echo off
Setlocal enabledelayedexpansion
::CODER BY lework

title VMware Workstation �������������

IF EXIST "%PROGRAMFILES%\VMWare\VMWare Workstation\vmrun.exe" SET VMwarePath=%PROGRAMFILES%\VMWare\VMWare Workstation
IF EXIST "%PROGRAMFILES(X86)%\VMWare\VMWare Workstation\vmrun.exe" SET VMwarePath=%PROGRAMFILES(X86)%\VMWare\VMWare Workstation
IF EXIST "%PROGRAMFILES%\VMware\VMware VIX\vmrun.exe" SET VMwarePath=%PROGRAMFILES%\VMware\VMware VIX
IF EXIST "%PROGRAMFILES(X86)%\VMware\VMware VIX\vmrun.exe" SET VMRUN=%PROGRAMFILES(X86)%\VMware\VMware VIX

:: VMware��װ��ַ
# set VMwarePath="C:\Program Files (x86)\VMware\VMware Workstation"
:: ��������Ŀ¼
set VMpath="D:\Virtual Machines"
:: ���������
set VMname=CentOS_7.6_x64_node
:: �������������
set VMSnapshot=init
:: �½��������Ŀ
set VMcount=5
:: �����owaģ��λ��
set VMowa="D:\vmware owa\CentOS_7.6_x64_node1.ova"
:: ģ��ϵͳ�û���
set VMuser=root
:: ģ��ϵͳ����
set VMpass=123456
:: ���������
set VMnetwork=192.168.111
:: �����ip��ʼ��ַ
set VMipStart=130



:init
cls
echo.
echo. VMware Workstation �������������
echo.
echo ==============================
echo.
echo. ���� 0 һ����ʼ��(����1,2,3����)
echo. ���� 1 ���������
echo. ���� 2 ����ip��ַ
echo. ���� 3 ��������
echo. ���� 4 �鿴�����������
echo. ���� 5 ���������
echo. ���� 6 �ر������
echo. ���� 7 ���������
echo. ���� 8 �ָ����������
echo. ���� 9 ɾ�������
echo. ���� 10 ���������
echo. ���� 11 ��ͣ�����
echo. ���� 12 �ָ������
echo. ���� q �˳�
echo.
echo ==============================
echo.

cd /d "%VMwarePath%"

set "input="
set /p input=����������ѡ��:
echo.
if "%input%"=="q" goto exit
if "%input%"=="0" goto oneKey
if "%input%"=="1" goto create
if "%input%"=="2" goto setip
if "%input%"=="3" goto snapshot
if "%input%"=="4" goto list
if "%input%"=="5" goto start
if "%input%"=="6" goto stop
if "%input%"=="7" goto restart
if "%input%"=="8" goto revertToSnapshot
if "%input%"=="9" goto delete
if "%input%"=="10" goto suspend
if "%input%"=="11" goto pausevm
if "%input%"=="12" goto unpausevm

:wait
echo. 
echo ִ�����, �ȴ���...
for /l %%a in (1,1,5) do (
ping /n 2 127.1>nul
set /p a=^><nul
)

cls
goto init

:oneKey
echo [���������...]
set "cname="
set "ccount="
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
set /p VMSnapshot=�������������(Ĭ��:%VMSnapshot%):
set /p VMuser=�������û���(Ĭ��:%VMuser%):
set /p VMpass=����������(Ĭ��:%VMpass%):
set /p VMipStart=������ip��ʼ��ַ(Ĭ��:%VMipStart%):

echo.
echo =============
echo. 
echo. �����ģ��: !VMowa!
echo. ��������Ŀ¼: !VMpath!
echo. ���������: !VMname!
echo. ���������: !VMcount!
echo. �������ʼ��������: !VMSnapshot!
echo. ������û���: !VMuser!
echo. ���������: !VMpass!
echo. ���������: !VMnetwork!
echo. �����ip��ʼ��ַ: !VMipStart!
echo.
echo =============

for /l %%a in (1,1,!VMcount!) do (
echo.
echo ���������: !VMname!%%a
cd OVFTool
ovftool.exe --name=!VMname!%%a !VMowa! !VMpath!
cd ..
echo.
echo ���������: !VMname!%%a
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx
)

echo.
echo ����ip:
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
set /a num=%VMipStart%+%%a-1
set ip=!VMnetwork!.!num!
echo !name!:!ip!
vmrun -T ws -gu !VMuser! -gp !VMpass! runProgramInGuest !VMpath!\!name!\!name!.vmx /bin/bash -c "sudo echo 'node!num!' > /etc/hostname; sudo sed -i 's/IPADDR=.*$/IPADDR="!ip!"/g' /etc/sysconfig/network-scripts/ifcfg-e*;/etc/init.d/network restart || sudo sed -i 's/address .*$/address !ip!/g' /etc/network/interfaces;/etc/init.d/network restart" nogui
)

echo.
echo ��������:
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws snapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx nogui
)

goto wait


:start
echo [���������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws start !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:stop
echo [�ر������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:restart
echo [���������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws start !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:suspend
echo [���������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws suspend !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:pausevm
echo [��ͣ�����...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws pause !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:unpausevm
echo [�ָ������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws unpause !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:revertToSnapshot
echo [�ָ����������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
set /p VMSnapshot=�������������(Ĭ��:%VMSnapshot%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws revertToSnapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
)
goto wait

:list
echo [����������б�...]
vmrun list
echo.
pause
goto wait


:create
echo [���������...]
set "cname="
set "ccount="
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):

echo.
echo =============
echo. 
echo. �����ģ��: !VMowa!
echo. ��������Ŀ¼: !VMpath!
echo. ���������: !VMname!
echo. ���������: !VMcount!
echo.
echo =============

for /l %%a in (1,1,!VMcount!) do (
echo.
echo ���������: !VMname!%%a
cd OVFTool
ovftool --name=!VMname!%%a !VMowa! !VMpath!
cd ..
echo ���������: !VMname!%%a
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx
)
goto wait


:delete
echo [ɾ�������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
set is=no
set /p is=ȷ��ɾ��ô?(yes/no, Ĭ��:%is%):

if "%is%" NEQ "yes" (
echo ��ȡ��
goto wait
)

echo �ر�vmware
taskkill /f /t /im vmware.exe

for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo ɾ��: !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun deleteVM !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:snapshot
echo [��������...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
set /p VMSnapshot=�������������(Ĭ��:%VMSnapshot%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws snapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx nogui
)
goto wait


:setip
echo [����ip��ַ...]
set /p VMname=���������������(Ĭ��:%VMname%):
set /p VMcount=���������������(Ĭ��:%VMcount%):
set /p VMuser=�������û���(Ĭ��:%VMuser%):
set /p VMpass=����������(Ĭ��:%VMpass%):
set /p VMipStart=������ip��ʼ��ַ(Ĭ��:%VMipStart%):

for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
set /a num=%VMipStart%+%%a-1
set ip=!VMnetwork!.!num!
echo !name!:!ip!
vmrun -T ws -gu !VMuser! -gp !VMpass! runProgramInGuest !VMpath!\!name!\!name!.vmx /bin/bash -c "sudo sed -i 's/IPADDR=.*$/IPADDR="!ip!"/g' /etc/sysconfig/network-scripts/ifcfg-e*;/etc/init.d/network restart || sudo sed -i 's/address .*$/address !ip!/g' /etc/network/interfaces;/etc/init.d/network restart" nogui
)
goto wait


:exit
echo �˳�...
ping /n 5 127.1>nul
exit