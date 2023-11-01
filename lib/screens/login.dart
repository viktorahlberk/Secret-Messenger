// import 'dart:developer';
import 'package:flutter/material.dart';
// import 'package:secure_messenger/services/bio_auth.dart';
import 'package:secure_messenger/services/google_auth.dart';
import 'package:secure_messenger/widgets/square_tile.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                onTap: () => AuthService().signInWithGoogle(),
                child: const SquareTile(imagePath: 'lib/images/google.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
