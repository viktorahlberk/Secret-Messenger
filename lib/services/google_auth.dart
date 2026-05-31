import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const _googleSignInServerClientId =
    '870762296160-c6vckvlpnlarku4unqm3frhebq2jb7g9.apps.googleusercontent.com';

class AuthService {
  static Future<void>? _googleSignInInitialization;

  signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final GoogleSignInAccount gUser =
        await GoogleSignIn.instance.authenticate();
    final GoogleSignInAuthentication gAuth = gUser.authentication;
    // final credential = GoogleAuthProvider.credential(
    //     accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  static Future<void> _initializeGoogleSignIn() {
    if (_googleSignInServerClientId == 'PASTE_WEB_CLIENT_ID_HERE') {
      throw StateError(
        'Set _googleSignInServerClientId to the Firebase Web client ID before '
        'using Google Sign-In on Android.',
      );
    }

    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: _googleSignInServerClientId,
    );
  }

  static logOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.disconnect();
    } catch (e) {
      print(e);
    }
    // await FirebaseAuth.instance.signOut();
    // await GoogleSignIn().disconnect();
  }
}
