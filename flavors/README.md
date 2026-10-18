# Multi-app flavors

This repo builds multiple store apps from one codebase using Flutter flavors.

## Current flavors

| Flavor | App name | Android package | iOS bundle ID |
|--------|----------|-----------------|---------------|
| `vector_academy` | Entrance Tricks | `com.vector_academy.app` | `com.vectoracademy.app` |
| `exitexam` | Ethio Exit Exam | `com.ethioexitexam.app` | `com.ethioexitexam.app` |
| `remedial` | Remedial Tricks | `com.remedialtricks.app` | `com.remedial_tricks.app` |
| `ministry` | Ministry Tricks | `com.ministrytricks.app` | `com.ministrytricks.app` |

Remedial backend `app_package` is `com.remedial_tricks.app` (same as iOS). Android store ID stays `com.remedialtricks.app`.

Ministry backend `app_package` is `com.ministry_tricks.app`. Android and iOS store IDs stay `com.ministrytricks.app`.

## Run / build

```powershell
# Run
.\scripts\run.ps1 exitexam
.\scripts\run.ps1 vector_academy
.\scripts\run.ps1 remedial
.\scripts\run.ps1 ministry

# Release builds
.\scripts\build.ps1 exitexam appbundle
.\scripts\build.ps1 vector_academy apk
.\scripts\build.ps1 remedial appbundle
.\scripts\build.ps1 ministry appbundle
```

Or directly:

```bash
flutter run --flavor exitexam --dart-define=FLAVOR=exitexam
flutter build appbundle --flavor exitexam --dart-define=FLAVOR=exitexam
flutter run --flavor remedial --dart-define=FLAVOR=remedial
flutter build appbundle --flavor remedial --dart-define=FLAVOR=remedial
flutter run --flavor ministry --dart-define=FLAVOR=ministry
flutter build appbundle --flavor ministry --dart-define=FLAVOR=ministry
```

## Android signing

Release builds use the flavor-specific keystore (`productFlavors.signingConfig`). Debug always uses the debug keystore.

| Flavor | Properties file | Keystore in `android/app/` |
|--------|-----------------|----------------------------|
| `vector_academy` | `android/key.properties` | `upload-keystore_entrance.jks` |
| `exitexam` | `android/key_exitexam.properties` | `upload-keystore_exitexam.jks` |
| `remedial` | `android/key_remedial.properties` | `upload-keystore_remedial.jks` |
| `ministry` | `android/key_ministry.properties` | `upload-keystore_ministry.jks` |

1. Copy the matching `android/key_<flavor>.properties.example` to `android/key_<flavor>.properties` (except `vector_academy`, which uses `key.properties`)
2. Fill in keystore credentials
3. Place the `.jks` file in `android/app/`

## Add a new app (checklist)

1. Add `assets/images/logo_<flavor>.png`
2. Add an entry in `lib/flavors/flavor_config.dart`
3. Add Android `productFlavor` in `android/app/build.gradle.kts` + keystore properties
4. Add iOS xcconfig files in `ios/Flutter/` and Xcode build configurations
5. Add `flutter_launcher_icons-<flavor>.yaml` and run:
   `dart run flutter_launcher_icons -f flutter_launcher_icons-<flavor>.yaml`
6. Create Xcode scheme `<flavor>.xcscheme`
7. Register `app_package` on the backend API
8. Add launch config in `.vscode/launch.json`
