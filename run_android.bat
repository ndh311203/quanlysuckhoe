@echo off
echo Starting Android Emulator...
flutter emulators --launch Medium_Phone_API_36.1

echo Waiting for emulator to start...
timeout /t 30 /nobreak

echo Checking for Android device...
:check_device
flutter devices | findstr "emulator" >nul
if %errorlevel% neq 0 (
    echo Emulator not ready yet, waiting...
    timeout /t 5 /nobreak
    goto check_device
)

echo Emulator is ready! Running app...
flutter run -d emulator-5554

