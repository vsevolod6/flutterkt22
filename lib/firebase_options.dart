import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
  );
  static const String storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );

  static const String emulatorFlag = String.fromEnvironment(
    'USE_FIREBASE_AUTH_EMULATOR',
  );
  static const String authEmulatorHost = String.fromEnvironment(
    'FIREBASE_AUTH_EMULATOR_HOST',
    defaultValue: '127.0.0.1',
  );
  static const int authEmulatorPort = int.fromEnvironment(
    'FIREBASE_AUTH_EMULATOR_PORT',
    defaultValue: 9099,
  );

  static bool get hasRealConfiguration =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty &&
      authDomain.isNotEmpty;

  static bool get useAuthEmulator {
    if (emulatorFlag.isNotEmpty) {
      return emulatorFlag.toLowerCase() == 'true';
    }

    return !hasRealConfiguration;
  }

  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
        'This project is configured for Flutter web only.',
      );
    }

    if (hasRealConfiguration) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket.isEmpty ? null : storageBucket,
        measurementId: measurementId.isEmpty ? null : measurementId,
      );
    }

    return const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:1234567890:web:abcdef1234567890',
      messagingSenderId: '1234567890',
      projectId: 'demo-firebase-auth',
      authDomain: 'demo-firebase-auth.firebaseapp.com',
    );
  }
}
