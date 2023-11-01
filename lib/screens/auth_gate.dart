// import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:secure_messenger/screens/bio_authentication.dart';
// import 'package:secure_messenger/screens/profile.dart';
import 'package:secure_messenger/screens/login.dart';

class GoogleAuthGate extends StatelessWidget {
  const GoogleAuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.idTokenChanges(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasData) {
                  // You can access the updated user data here using userSnapshot.data
                  // For example: User user = userSnapshot.data!;
                  return BioAuthenticationScreen(userSnapshot.data!);
                } else {
                  // If you want to handle the case when the user data is not available
                  // return a placeholder or loading widget, or whatever suits your app
                  return const CircularProgressIndicator();
                }
              },
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
