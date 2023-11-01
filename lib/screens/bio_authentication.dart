// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, avoid_print

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:secure_messenger/screens/profile.dart';
import 'package:secure_messenger/services/google_auth.dart';

class BioAuthenticationScreen extends StatefulWidget {
  const BioAuthenticationScreen(this.data, {Key? key}) : super(key: key);
  final User? data;
  @override
  State<BioAuthenticationScreen> createState() =>
      _BioAuthenticationScreenState();
}

class _BioAuthenticationScreenState extends State<BioAuthenticationScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
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

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
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
  }

  // Future<void> _cancelAuthentication() async {
  //   await auth.stopAuthentication();
  //   setState(() => _isAuthenticating = false);
  // }
  logOut() async {
    await AuthService.logOutFromGoogle();
    // Navigator.pushNamed(context, 'login');
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
                const Text('This device is supported')
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
                          onPressed: _authenticateWithBiometrics,
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              // settings: const RouteSettings(name: 'profile'),
                              builder: (context) =>
                                  ProfilePage(signInData: widget.data),
                            ),
                          ),
                          child: const Text(
                              'Good! You are authenticated! \nGo in ->'),
                        )
                      : Container(),
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
