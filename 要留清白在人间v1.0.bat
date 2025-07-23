@echo off
:: =============================================
:: 数据销毁工具 - Windows批处理版本
:: 警告：此脚本会彻底删除设备上的所有数据！
:: =============================================

:: --------------------------
:: 语言定义和翻译函数
:: --------------------------
setlocal enabledelayedexpansion

:: 语言定义 (代码:名称)
set "LANG_DEFINITIONS=zh:中文,en:English,es:Español,fr:Français,ja:日本語"

:: 当前语言代码 (默认中文)
set "LANG=zh"

:: 简单语言选择 (实际使用时建议手动设置LANG变量)
:: 这里简化处理，直接使用中文
:: 完整语言选择功能在BAT中实现较复杂，建议使用其他语言

:: 根据语言代码获取翻译文本
:get_translation
set "key=%~2"
if "!LANG!"=="zh" (
    if "!key!"=="warning" echo 此脚本需要管理员权限执行
    if "!key!"=="continue_prompt" echo 这不是个玩笑是否要继续执行? (y/n): 
    if "!key!"=="invalid_choice" echo 无效输入，退出脚本...
    if "!key!"=="countdown" echo 要留清白在人间如反悔请马上退出10秒后开始格机.
    if "!key!"=="goodbye" echo 要留清白在人间：节哀
    if "!key!"=="self_destruct_warning_1" echo 🚨 自毁程序启动：以下脚本将被删除:
    if "!key!"=="self_destruct_warning_2" echo    %~f0
    if "!key!"=="self_destruct_countdown_3" echo 🕒 3秒后开始删除...
    if "!key!"=="self_destruct_countdown_2" echo 🕒 2秒后开始删除...
    if "!key!"=="self_destruct_countdown_1" echo 🕒 1秒后开始删除...
    if "!key!"=="self_destruct_executing" echo 💥 正在执行自毁...
    if "!key!"=="self_destruct_success" echo ✅ 自毁成功！脚本已删除。
    if "!key!"=="self_destruct_failed" echo ❌ 自毁失败！脚本可能位于只读位置。
) else if "!LANG!"=="en" (
    if "!key!"=="warning" echo This script requires administrator privileges to run
    if "!key!"=="continue_prompt" echo This is not a joke. Continue anyway? (y/n): 
    if "!key!"=="invalid_choice" echo Invalid input, exiting script...
    if "!key!"=="countdown" echo To leave a clear conscience, please exit now if you regret. Formatting will start in 10 seconds.
    if "!key!"=="goodbye" echo Rest in peace
    if "!key!"=="formatting" echo Formatting device
    if "!key!"=="unmounting" echo Unmounting partitions...
    if "!key!"=="overwriting" echo Overwriting storage data...
    if "!key!"=="destroying" echo Destroying partition table...
    if "!key!"=="deleting" echo Deleting all files...
    if "!key!"=="final_step" echo Destroying boot records...
    if "!key!"=="power_off" echo Forcing system shutdown...
    if "!key!"=="self_destruct_warning_1" echo 🚨 Self-destruct initiated: The following script will be deleted:
    if "!key!"=="self_destruct_warning_2" echo    %~f0
    if "!key!"=="self_destruct_countdown_3" echo 🕒 Deleting in 3 seconds...
    if "!key!"=="self_destruct_countdown_2" echo 🕒 Deleting in 2 seconds...
    if "!key!"=="self_destruct_countdown_1" echo 🕒 Deleting in 1 second...
    if "!key!"=="self_destruct_executing" echo 💥 Executing self-destruct...
    if "!key!"=="self_destruct_success" echo ✅ Self-destruct successful! Script deleted.
    if "!key!"=="self_destruct_failed" echo ❌ Self-destruct failed! Script may be read-only.
)
goto :eof

:: --------------------------
:: 进度条函数 (简化版)
:: --------------------------
:progress_bar
set "duration=%~1"
if "!duration!"=="" set "duration=10"
set "i=0"
:progress_loop
set /a "percent=i*100/duration"
set "bar="
for /l %%j in (1,1,!i!) do set "bar=!bar!=="
set "bar=[!bar:~0,50!] !percent%%%"
echo.\r!bar!
set /a "i+=1"
if !i! leq !duration! (
    ping -n 2 127.0.0.1 >nul
    goto progress_loop
)
echo.
goto :eof

:: --------------------------
:: 检查管理员权限
:: --------------------------
:check_admin
:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :get_translation %LANG% warning
    echo.
    call :get_translation %LANG% continue_prompt
    set /p choice=
    if /i "!choice!"=="y" (
        call :get_translation %LANG% countdown
        timeout /t 10 /nobreak >nul
    ) else (
        call :get_translation %LANG% invalid_choice
        call :self_destruct %LANG%
    )
)
goto :eof

:: --------------------------
:: 自毁功能
:: --------------------------
:self_destruct
set "lang_code=%~1"
call :get_translation %lang_code% self_destruct_warning_1
echo.
echo   %~f0
call :get_translation %lang_code% self_destruct_warning_2
echo.

for /l %%i in (3,-1,1) do (
    call :get_translation %lang_code% self_destruct_countdown_%%i
    ping -n 2 127.0.0.1 >nul
)

call :get_translation %lang_code% self_destruct_executing
del /f /q "%~f0" >nul 2>&1

if exist "%~f0" (
    call :get_translation %lang_code% self_destruct_failed
) else (
    call :get_translation %lang_code% self_destruct_success
)
exit /b 1

:: --------------------------
:: 主函数
:: --------------------------
:main
:: 检查管理员权限
call :check_admin

:: 清屏
cls

:: 进度条演示
call :get_translation %LANG% countdown
call :progress_bar 5
call :get_translation %LANG% goodbye

:: 显示确认提示
call :get_translation %LANG% continue_prompt
set /p choice=
if /i "!choice!"=="y" (
    call :get_translation %LANG% countdown
) else (
    call :get_translation %LANG% invalid_choice
    call :self_destruct %LANG%
)

:: 主功能部分
call :get_translation %LANG% unmounting
:: Windows下卸载分区比较复杂，这里只是示例
echo 正在尝试卸载分区...(注意: Windows下无法直接卸载所有分区)
timeout /t 2 /nobreak >nul

call :get_translation %LANG% overwriting
:: Windows下覆写磁盘数据需要特殊工具，这里只是模拟
echo 正在覆写存储数据...(模拟)
for /l %%i in (1,1,3) do (
    echo 正在第%%i次覆写数据...
    timeout /t 2 /nobreak >nul
)

call :get_translation %LANG% destroying
echo 正在破坏分区表...(模拟)
timeout /t 2 /nobreak >nul

call :get_translation %LANG% deleting
echo 正在删除所有文件...(模拟)
timeout /t 2 /nobreak >nul

call :get_translation %LANG% final_step
echo 正在破坏引导记录...(模拟)
timeout /t 2 /nobreak >nul

call :get_translation %LANG% power_off
echo 正在强制关机...
shutdown /s /f /t 0

:: --------------------------
:: 脚本入口
:: --------------------------
:: 主程序逻辑
call :main

endlocal