# CASE 007 (پرونده ۰۰۷)

Offline local-network multiplayer detective game for 2 to 6 players. Flutter, Android first.

## Build

```
flutter create --org com.realspy --project-name case007 --platforms=android .
rm -f test/widget_test.dart
dart run tool/patch_android.dart
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

Output: `build/app/outputs/flutter-apk/`. Without a release keystore the build is signed with the debug key and installs normally. For store-grade signing create `android/key.properties` and a keystore yourself and wire them in `android/app/build.gradle`; never commit them.

## Fonts

Persian text uses the system font by default. To bundle Vazirmatn, put the font files in `assets/fonts/`, declare them under `flutter: fonts:` in `pubspec.yaml`, and set `fontFamily: 'Vazirmatn'` in `lib/core/theme.dart`.

## Playing

1. Host: Create room, then share the QR or code. Host phone can run a hotspot, or all phones join one Wi-Fi.
2. Players: Join room, then scan the QR or enter code and IP.
3. Host picks a case, everyone taps ready, host starts.
4. Investigate, share evidence, chat, submit a hypothesis, vote, see the result.

Support button opens Telegram chat with @MaTeoHastam. Creator: ReaLsPY.
