# App Icon Instructions

## Custom App Icon

1. Create or download a square icon image (preferably 1024x1024 pixels)
2. Save it as `icon.png` in this directory
3. The icon should have a transparent background
4. Recommended format: PNG

## To Generate Icons and Splash Screen

After adding `icon.png` to this folder, run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Then rebuild your APK:
```bash
flutter build apk --release
```

## Note

The splash screen will use a light blue gradient background (`#EBF4FF`) with your icon in the center.

