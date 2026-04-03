# Firebase Web Auth

Flutter web demo with email/password authorization through Firebase.

Implemented behavior:

- The app works in guest mode.
- Public features are available to everyone.
- Protected features are available only after sign-in.
- The user can register with email and password.
- The user can sign in and sign out.

## Default local setup

The project is configured to work out of the box with the local Firebase Auth Emulator.

1. Install Node.js dependencies:

```bash
npm install
```

2. Start the auth emulator:

```bash
npm run auth:emulator
```

3. In a second terminal, run the Flutter web app:

```bash
flutter run -d chrome
```

While the emulator is running, registration and sign-in work locally without a real Firebase cloud project.

## Real Firebase setup

If you want to use a real Firebase project instead of the local emulator:

1. Create a Firebase project.
2. Add a Web app inside Firebase.
3. In `Authentication -> Sign-in method`, enable `Email/Password`.
4. Run the app with your Firebase web config:

```bash
flutter run -d chrome ^
  --dart-define=FIREBASE_API_KEY=your_api_key ^
  --dart-define=FIREBASE_APP_ID=your_app_id ^
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id ^
  --dart-define=FIREBASE_PROJECT_ID=your_project_id ^
  --dart-define=FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com ^
  --dart-define=FIREBASE_STORAGE_BUCKET=your_project.firebasestorage.app ^
  --dart-define=FIREBASE_MEASUREMENT_ID=your_measurement_id ^
  --dart-define=USE_FIREBASE_AUTH_EMULATOR=false
```
