import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _clientId =
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
    // inspect(gUser);
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
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _clientId,
    );
  }

  static Future<void> logOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      // await GoogleSignIn.instance.disconnect();
    } catch (e) {
      log('Google sign-out failed: $e');
    }
  }

  Future<void> deleteOAuth2Account() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "no-such-provider":
          print("The user isn't linked to the provider or the provider"
              "doesn't exist.");
          break;
        case "requires-recent-login":
          log("user's last sign-in time does not meet the security threshold. Use [User.reauthenticateWithCredential] to resolve. This does not apply if the user is anonymous.");
          break;
        default:
          print(e.code);
      }
    }
  }
}
