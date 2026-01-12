@echo off
echo Checking for Android emulator...
flutter devices | findstr "emulator" >nul
if %errorlevel% neq 0 (
    echo Starting Android emulator...
    start /B flutter emulators --launch Medium_Phone_API_36.1
    echo Waiting for emulator to start (30 seconds)...
    timeout /t 30 /nobreak
    echo Checking again...
    flutter devices | findstr "emulator" >nul
    if %errorlevel% neq 0 (
        echo Emulator is still starting. Please wait and run again.
        pause
        exit
    )
)

echo Running app on Android emulator...
flutter run -d emulator-5554
pause

