@echo off
Setlocal enabledelayedexpansion
::CODER BY lework

title VMware Workstation 虚拟机批量管理

IF EXIST "%PROGRAMFILES%\VMWare\VMWare Workstation\vmrun.exe" SET VMwarePath=%PROGRAMFILES%\VMWare\VMWare Workstation
IF EXIST "%PROGRAMFILES(X86)%\VMWare\VMWare Workstation\vmrun.exe" SET VMwarePath=%PROGRAMFILES(X86)%\VMWare\VMWare Workstation
IF EXIST "%PROGRAMFILES%\VMware\VMware VIX\vmrun.exe" SET VMwarePath=%PROGRAMFILES%\VMware\VMware VIX
IF EXIST "%PROGRAMFILES(X86)%\VMware\VMware VIX\vmrun.exe" SET VMRUN=%PROGRAMFILES(X86)%\VMware\VMware VIX

:: VMware安装地址
# set VMwarePath="C:\Program Files (x86)\VMware\VMware Workstation"
:: 虚拟机存放目录
set VMpath="D:\Virtual Machines"
:: 虚拟机名称
set VMname=CentOS_7.6_x64_node
:: 虚拟机快照名称
set VMSnapshot=init
:: 新建虚拟机数目
set VMcount=5
:: 虚拟机owa模板位置
set VMowa="D:\vmware owa\CentOS_7.6_x64_node1.ova"
:: 模板系统用户名
set VMuser=root
:: 模板系统密码
set VMpass=123456
:: 虚拟机网络
set VMnetwork=192.168.111
:: 虚拟机ip开始地址
set VMipStart=130



:init
cls
echo.
echo. VMware Workstation 虚拟机批量管理
echo.
echo ==============================
echo.
echo. 输入 0 一键初始化(包含1,2,3步骤)
echo. 输入 1 创建虚拟机
echo. 输入 2 设置ip地址
echo. 输入 3 创建快照
echo. 输入 4 查看启动的虚拟机
echo. 输入 5 启动虚拟机
echo. 输入 6 关闭虚拟机
echo. 输入 7 重启虚拟机
echo. 输入 8 恢复虚拟机快照
echo. 输入 9 删除虚拟机
echo. 输入 10 挂起虚拟机
echo. 输入 11 暂停虚拟机
echo. 输入 12 恢复虚拟机
echo. 输入 q 退出
echo.
echo ==============================
echo.

cd /d "%VMwarePath%"

set "input="
set /p input=请输入您的选择:
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
echo 执行完毕, 等待中...
for /l %%a in (1,1,5) do (
ping /n 2 127.1>nul
set /p a=^><nul
)

cls
goto init

:oneKey
echo [创建虚拟机...]
set "cname="
set "ccount="
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
set /p VMSnapshot=请输入快照名称(默认:%VMSnapshot%):
set /p VMuser=请输入用户名(默认:%VMuser%):
set /p VMpass=请输入密码(默认:%VMpass%):
set /p VMipStart=请输入ip开始地址(默认:%VMipStart%):

echo.
echo =============
echo. 
echo. 虚拟机模板: !VMowa!
echo. 虚拟机存放目录: !VMpath!
echo. 虚拟机名称: !VMname!
echo. 虚拟机数量: !VMcount!
echo. 虚拟机初始快照名称: !VMSnapshot!
echo. 虚拟机用户名: !VMuser!
echo. 虚拟机密码: !VMpass!
echo. 虚拟机网段: !VMnetwork!
echo. 虚拟机ip开始地址: !VMipStart!
echo.
echo =============

for /l %%a in (1,1,!VMcount!) do (
echo.
echo 创建虚拟机: !VMname!%%a
cd OVFTool
ovftool.exe --name=!VMname!%%a !VMowa! !VMpath!
cd ..
echo.
echo 启动虚拟机: !VMname!%%a
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx
)

echo.
echo 设置ip:
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
set /a num=%VMipStart%+%%a-1
set ip=!VMnetwork!.!num!
echo !name!:!ip!
vmrun -T ws -gu !VMuser! -gp !VMpass! runProgramInGuest !VMpath!\!name!\!name!.vmx /bin/bash -c "sudo echo 'node!num!' > /etc/hostname; sudo sed -i 's/IPADDR=.*$/IPADDR="!ip!"/g' /etc/sysconfig/network-scripts/ifcfg-e*;/etc/init.d/network restart || sudo sed -i 's/address .*$/address !ip!/g' /etc/network/interfaces;/etc/init.d/network restart" nogui
)

echo.
echo 创建快照:
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws snapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx nogui
)

goto wait


:start
echo [启动虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws start !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:stop
echo [关闭虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:restart
echo [重启虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws start !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:suspend
echo [挂起虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws suspend !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:pausevm
echo [暂停虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws pause !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:unpausevm
echo [恢复虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws unpause !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:revertToSnapshot
echo [恢复虚拟机快照...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
set /p VMSnapshot=请输入快照名称(默认:%VMSnapshot%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws revertToSnapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
)
goto wait

:list
echo [虚拟机启动列表...]
vmrun list
echo.
pause
goto wait


:create
echo [创建虚拟机...]
set "cname="
set "ccount="
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):

echo.
echo =============
echo. 
echo. 虚拟机模板: !VMowa!
echo. 虚拟机存放目录: !VMpath!
echo. 虚拟机名称: !VMname!
echo. 虚拟机数量: !VMcount!
echo.
echo =============

for /l %%a in (1,1,!VMcount!) do (
echo.
echo 创建虚拟机: !VMname!%%a
cd OVFTool
ovftool --name=!VMname!%%a !VMowa! !VMpath!
cd ..
echo 启动虚拟机: !VMname!%%a
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx
)
goto wait


:delete
echo [删除虚拟机...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
set is=no
set /p is=确定删除么?(yes/no, 默认:%is%):

if "%is%" NEQ "yes" (
echo 已取消
goto wait
)

echo 关闭vmware
taskkill /f /t /im vmware.exe

for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo 删除: !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun deleteVM !VMpath!\!name!\!name!.vmx nogui
)
goto wait


:snapshot
echo [创建快照...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
set /p VMSnapshot=请输入快照名称(默认:%VMSnapshot%):
for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
echo !name!
vmrun -T ws stop !VMpath!\!name!\!name!.vmx nogui
vmrun -T ws snapshot !VMpath!\!name!\!name!.vmx !VMSnapshot! nogui
vmrun -T ws start !VMpath!\!VMname!%%a\!VMname!%%a.vmx nogui
)
goto wait


:setip
echo [设置ip地址...]
set /p VMname=请输入虚拟机名称(默认:%VMname%):
set /p VMcount=请输入虚拟机数量(默认:%VMcount%):
set /p VMuser=请输入用户名(默认:%VMuser%):
set /p VMpass=请输入密码(默认:%VMpass%):
set /p VMipStart=请输入ip开始地址(默认:%VMipStart%):

for /l %%a in (1,1,%VMcount%) do (
set name=!VMname!%%a
set /a num=%VMipStart%+%%a-1
set ip=!VMnetwork!.!num!
echo !name!:!ip!
vmrun -T ws -gu !VMuser! -gp !VMpass! runProgramInGuest !VMpath!\!name!\!name!.vmx /bin/bash -c "sudo sed -i 's/IPADDR=.*$/IPADDR="!ip!"/g' /etc/sysconfig/network-scripts/ifcfg-e*;/etc/init.d/network restart || sudo sed -i 's/address .*$/address !ip!/g' /etc/network/interfaces;/etc/init.d/network restart" nogui
)
goto wait


:exit
echo 退出...
ping /n 5 127.1>nul
exit