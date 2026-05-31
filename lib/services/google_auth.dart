import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// const _googleSignInServerClientId =
//     '870762296160-c6vckvlpnlarku4unqm3frhebq2jb7g9.apps.googleusercontent.com';
const _clientId =
    // '870762296160-sp6utgr52l5mmpitbv8blnuu70v4efh9.apps.googleusercontent.com'
    // '870762296160-ggb9eh0ntq12mi0vph84le8fmcjjm2kb.apps.googleusercontent.com';
    '870762296160-c6vckvlpnlarku4unqm3frhebq2jb7g9.apps.googleusercontent.com';

class AuthService {
  static Future<void>? _googleSignInInitialization;

  Future<UserCredential> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
        description:
            'Interactive Google Sign-In is not available on this platform.',
      );
    }

    final GoogleSignInAccount gUser =
        await GoogleSignIn.instance.authenticate();
    inspect(gUser);
    final GoogleSignInAuthentication gAuth = gUser.authentication;
    if (gAuth.idToken == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
        description: 'Google did not return an ID token for Firebase Auth.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<void> _initializeGoogleSignIn() {
    if (_clientId == 'PASTE_WEB_CLIENT_ID_HERE') {
      throw StateError(
        'Set _googleSignInServerClientId to the Firebase Web client ID before '
        'using Google Sign-In on Android.',
      );
    }

    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _clientId,
    );
  }

  static Future<void> logOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.disconnect();
    } catch (e) {
      debugPrint('Google sign-out failed: $e');
    }
  }
}
