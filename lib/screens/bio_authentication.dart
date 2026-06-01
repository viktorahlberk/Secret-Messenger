// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:secure_messenger/screens/profile.dart';
import 'package:secure_messenger/services/firebase/google_auth.dart';

class BioAuthenticationScreen extends StatefulWidget {
  const BioAuthenticationScreen(this.data, {super.key});
  final User? data;
  @override
  State<BioAuthenticationScreen> createState() =>
      _BioAuthenticationScreenState();
}

class _BioAuthenticationScreenState extends State<BioAuthenticationScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
  }

  Future<void> _checkDeviceSupport() async {
    late bool isSupported;
    late bool canCheckBiometrics;
    try {
      isSupported = await auth.isDeviceSupported();
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      isSupported = false;
      canCheckBiometrics = false;
      debugPrint('Local auth support check failed: $e');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _supportState =
          isSupported ? _SupportState.supported : _SupportState.unsupported;
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Future<void> _getAvailableBiometrics() async {
  //   late List<BiometricType> availableBiometrics;
  //   try {
  //     availableBiometrics = await auth.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     availableBiometrics = <BiometricType>[];
  //     print(e);
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _availableBiometrics = availableBiometrics;
  //   });
  // }

  // Future<void> _authenticate() async {
  //   bool authenticated = false;
  //   try {
  //     setState(() {
  //       _isAuthenticating = true;
  //       _authorized = 'Authenticating';
  //     });
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'Let OS determine authentication method',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //       ),
  //     );
  //     setState(() {
  //       _isAuthenticating = false;
  //     });
  //   } on PlatformException catch (e) {
  //     print(e);
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Error - ${e.message}';
  //     });
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   setState(
  //       () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  // }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to open Secret Messenger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = _messageForAuthError(e);
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });

    if (authenticated) {
      _openProfile();
    }
  }

  String _messageForAuthError(PlatformException error) {
    switch (error.code) {
      case auth_error.notEnrolled:
        return 'No biometric is enrolled. Set a screen lock or add a fingerprint in the emulator/device settings.';
      case auth_error.passcodeNotSet:
        return 'No screen lock is set. Add a PIN, pattern, password, or biometric first.';
      case auth_error.notAvailable:
        return 'Local authentication is not available on this device.';
      case auth_error.lockedOut:
      case auth_error.permanentlyLockedOut:
        return 'Local authentication is locked. Unlock the device with PIN/password and try again.';
      default:
        return 'Authorization failed: ${error.message ?? error.code}';
    }
  }

  void _openProfile() {
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(signInData: widget.data),
      ),
    );
  }

  Future<void> logOut() async {
    await AuthService.logOutFromGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    // home:
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('bio'),
        actions: [
          IconButton(
            onPressed: () => AuthService.logOutFromGoogle(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 30),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_supportState == _SupportState.unknown)
                const CircularProgressIndicator()
              else if (_supportState == _SupportState.supported)
                Text(_canCheckBiometrics == true
                    ? 'This device is ready for biometric auth'
                    : 'This device can use screen lock auth')
              else
                Column(
                  children: [
                    const Text('This device is not supported'),
                    TextButton(
                      onPressed: () =>
                          // Navigator.pushNamed(context, 'profile'),
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'profile'),
                          builder: (context) =>
                              ProfilePage(signInData: widget.data),
                        ),
                      ),
                      child: const Text('next'),
                    )
                  ],
                ),
              // const Divider(height: 100),
              // Text('Can check biometrics: $_canCheckBiometrics\n'),
              // ElevatedButton(
              //   onPressed: _checkBiometrics,
              //   child: const Text('Check biometrics'),
              // ),
              // const Divider(height: 100),
              // Text('Available biometrics: $_availableBiometrics\n'),
              // ElevatedButton(
              //   onPressed: _getAvailableBiometrics,
              //   child: const Text('Get available biometrics'),
              // ),
              // const Divider(height: 100),
              // Text('Current State: $_authorized\n'),
              // if (_isAuthenticating)
              //   ElevatedButton(
              //     onPressed: _cancelAuthentication,
              //     // TODO(goderbauer): Make this const when this package requires Flutter 3.8 or later.
              //     // ignore: prefer_const_constructors
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: const <Widget>[
              //         Text('Cancel Authentication'),
              //         Icon(Icons.cancel),
              //       ],
              //     ),
              //   )
              // else
              Column(
                children: <Widget>[
                  // ElevatedButton(
                  //   onPressed: _authenticate,
                  //   // TODO(goderbauer): Make this const when this package requires Flutter 3.8 or later.
                  //   // ignore: prefer_const_constructors
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: const <Widget>[
                  //       Text('Authenticate'),
                  //       Icon(Icons.perm_device_information),
                  //     ],
                  //   ),
                  // ),
                  _supportState == _SupportState.supported
                      ? ElevatedButton(
                          onPressed: _authenticate,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(_isAuthenticating
                                  ? 'Cancel'
                                  : 'Authenticate'),
                              const Icon(Icons.fingerprint),
                            ],
                          ),
                        )
                      : Container(),
                  _authorized == 'Authorized'
                      ? TextButton(
                          onPressed: _openProfile,
                          child: const Text(
                              'Good! You are authenticated! \nGo in ->'),
                        )
                      : Text(_authorized),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    // );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
