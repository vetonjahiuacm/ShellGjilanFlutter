@echo off
cd /d "%~dp0"
flutter pub get && flutter run -d windows
pause
