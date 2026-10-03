# Shell Gjilan Flutter V1

Aplikacion Flutter për Windows, Android dhe iOS, i lidhur me:

`https://shellgjilan2.pythonanywhere.com/api/v1`

## Çfarë përmban V1

- Login me llogaritë ekzistuese të web-it
- Token i ruajtur me `flutter_secure_storage`
- Dashboard me KPI reale
- Artikuj: kërkim, filtra, listë, Add/Edit/Delete për Admin
- Porosi: listë, detaje, shtim, fshirje për Admin
- Statistika sipas furnitorëve
- Role Admin / Punëtor
- Light / Dark / System
- Shqip / English
- UI adaptive: sidebar në Windows/tablet, bottom navigation në telefon
- Logo Shell nga projekti ekzistues

## Instalimi në Windows

1. Instalo Flutter SDK për Windows.
2. Instalo Android Studio (nëse do Android) dhe Visual Studio 2022 me **Desktop development with C++** (nëse do app Windows desktop).
3. Ekstrakto këtë ZIP.
4. Double-click `setup_windows.bat`.
5. Pastaj double-click `run_windows.bat` për versionin Windows.

Ose nga terminali:

```powershell
cd ShellGjilanFlutter_V1
.\setup_windows.bat
flutter run -d windows
```

## Android

```powershell
flutter devices
flutter run -d <DEVICE_ID>
```

Për APK release:

```powershell
flutter build apk --release
```

Rezultati zakonisht krijohet te:

`build\app\outputs\flutter-apk\app-release.apk`

## iOS

Kodi iOS është i njëjti projekt Flutter, por build/signing final për iPhone/App Store kërkon macOS + Xcode.

Në Mac:

```bash
flutter pub get
flutter build ios
```

## Server

Base URL është në:

`lib/core/api_client.dart`

```dart
static const String baseUrl = 'https://shellgjilan2.pythonanywhere.com/api/v1';
```

## Siguria

Mos vendos password të përdoruesve në kod. App-i dërgon login-in vetëm te API HTTPS dhe ruan token-in lokalisht në secure storage.
