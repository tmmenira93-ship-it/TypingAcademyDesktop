# Build and package Typing Academy Desktop

Development in this environment was Linux (Debian 12). Flutter 3.24.5 and Dart 3.5.4 were used.

## Prerequisites

```bash
flutter --version
flutter doctor
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
```

## Run tests

```bash
cd typing_academy_desktop
flutter pub get
flutter analyze
flutter test
```

## Linux

Supported for development and local packages: Debian 12, Ubuntu 22.04+, Fedora 38+. GTK 3 is required.

Key sounds use the `audioplayers` plugin, which needs GStreamer development packages on Linux, for example on Debian/Ubuntu:

```bash
sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

Run `flutter pub get` after updating: `audioplayers` is a new dependency and `pubspec.lock` has to be refreshed.

```bash
flutter run -d linux
flutter build linux --release
```

The runnable bundle is:

`build/linux/x64/release/bundle/typing_academy_desktop`

## Continuous integration (GitHub Actions)

`.github/workflows/ci.yml` runs `flutter analyze` and `flutter test` on Linux, then builds the Windows release and uploads `typing-academy-windows.zip` as an artifact. Put the contents of `typing_academy_desktop` at the root of the repository so GitHub finds the workflow. Keep `FLUTTER_VERSION` equal to the version you develop with. The Windows job fails with a clear message if `sqlite3.dll` is not bundled next to the exe.

## Windows

Compatible targets: Windows 10 version 21H2 or later, and Windows 11. Build on a Windows machine with Visual Studio 2022 (Desktop development with C++).

```bash
flutter build windows --release
```

The SQLite library comes from the `sqlite3_flutter_libs` plugin (run `flutter pub get` after updating, because it is a new dependency). Without it the exe stops at start-up with "Failed to load dynamic library 'sqlite3.dll'". After a build, `sqlite3.dll` must sit next to the exe.

The exe is:

`build/windows/x64/runner/Release/typing_academy_desktop.exe`

To create an installer, use Inno Setup or `msix` on Windows after the release folder is produced.

## macOS

Build and notarize on a Mac with Xcode. Minimum: macOS 10.14.

```bash
flutter build macos --release
```

The app bundle is under `build/macos/Build/Products/Release/`.

## Offline check

After install, disconnect the network, open the app, complete a lesson, close it, and open it again. Results must still be present.
