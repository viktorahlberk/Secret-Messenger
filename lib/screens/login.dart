// import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:secure_messenger/services/bio_auth.dart';
import 'package:secure_messenger/services/google_auth.dart';
import 'package:secure_messenger/widgets/square_tile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() => _isSigningIn = true);

    try {
      await AuthService().signInWithGoogle();
    } on GoogleSignInException catch (error) {
      _showSignInError(_messageForGoogleSignInError(error));
    } catch (_) {
      _showSignInError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }

  String _messageForGoogleSignInError(GoogleSignInException error) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      if (kDebugMode) {
        debugPrint(error.description);
      }
      return 'Google sign-in was cancelled. ${error.description}';
    }

    final description = error.description ?? '';
    if (description.contains('No credential available')) {
      return 'No Google credential is available for this build. Check the '
          'Firebase Android package name, SHA fingerprints, and Web client ID.';
    }

    return description.isNotEmpty
        ? description
        : 'Google sign-in failed. Please try again.';
  }

  void _showSignInError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(context, 'bioAuth');
              //   },
              //   child: const Icon(
              //     Icons.fingerprint,
              //     size: 50,
              //   ),
              // ),
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // google sign in button
              GestureDetector(
                onTap: _isSigningIn ? null : _signInWithGoogle,
                child: _isSigningIn
                    ? const SizedBox(
                        height: 48,
                        width: 48,
                        child: CircularProgressIndicator(),
                      )
                    : const SquareTile(imagePath: 'lib/images/google.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
