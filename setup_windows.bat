@echo off
setlocal
cd /d "%~dp0"

echo ============================================
echo SHELL GJILAN FLUTTER V1 - WINDOWS SETUP
echo ============================================
where flutter >nul 2>nul
if errorlevel 1 (
  echo.
  echo ERROR: Flutter nuk u gjet ne PATH.
  echo Instalo Flutter SDK dhe shtoje flutter\bin ne PATH,
  echo pastaj hape perseri kete file.
  pause
  exit /b 1
)

echo.
echo [1/4] Flutter version
flutter --version
if errorlevel 1 goto :error

echo.
echo [2/4] Krijimi i platformave Android / iOS / Windows
if not exist "android" (
  if exist ".shell_source_backup" rmdir /s /q ".shell_source_backup"
  mkdir ".shell_source_backup"
  xcopy /e /i /y "lib" ".shell_source_backup\lib" >nul
  xcopy /e /i /y "assets" ".shell_source_backup\assets" >nul
  copy /y "pubspec.yaml" ".shell_source_backup\pubspec.yaml" >nul
  copy /y "analysis_options.yaml" ".shell_source_backup\analysis_options.yaml" >nul
  flutter create --platforms=android,ios,windows --org com.shellgjilan --project-name shell_gjilan .
  if errorlevel 1 goto :error
  rmdir /s /q "lib"
  rmdir /s /q "assets"
  xcopy /e /i /y ".shell_source_backup\lib" "lib" >nul
  xcopy /e /i /y ".shell_source_backup\assets" "assets" >nul
  copy /y ".shell_source_backup\pubspec.yaml" "pubspec.yaml" >nul
  copy /y ".shell_source_backup\analysis_options.yaml" "analysis_options.yaml" >nul
  rmdir /s /q ".shell_source_backup"
  powershell -NoProfile -Command "$p='android/app/src/main/AndroidManifest.xml'; $s=Get-Content $p -Raw; if($s -notmatch 'android.permission.INTERNET'){ $s=$s -replace '<manifest([^>]*)>', '<manifest$1>`r`n    <uses-permission android:name="android.permission.INTERNET" />'; Set-Content $p $s -Encoding UTF8 }"
) else (
  echo Platform files ekzistojne - skip flutter create.
)

echo.
echo [3/4] Packages
flutter pub get
if errorlevel 1 goto :error

echo.
echo [4/4] Kontroll
flutter doctor

echo.
echo ============================================
echo GATI.
echo Per Windows: flutter run -d windows
echo Per Android: flutter devices  pastaj flutter run -d DEVICE_ID
echo ============================================
pause
exit /b 0

:error
echo.
echo SETUP DESHTOI. Lexo error-in siper.
pause
exit /b 1
