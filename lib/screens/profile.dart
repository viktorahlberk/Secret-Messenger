// import 'dart:developer';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/app_state.dart';
import 'package:secure_messenger/models/user_profile.dart';
import 'package:secure_messenger/screens/chats.dart';
import 'package:secure_messenger/screens/search.dart';
// import 'package:secure_messenger/screens/auth_gate.dart';
import 'package:secure_messenger/services/database.dart';
import 'package:secure_messenger/services/google_auth.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import 'package:secure_messenger/services/qr_code.dart';
import 'package:webcrypto/webcrypto.dart';

import '../services/encryption.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.signInData, super.key});
  final User? signInData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // UserProfile? userProfile;
  TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;
  @override
  initState() {
    initUser(widget.signInData);
    super.initState();
  }

  initUser(User? signInData) async {
    if (!await DatabaseService.isUserExists(signInData!.uid)) {
      KeyPair<EcdhPrivateKey, EcdhPublicKey> keys =
          await EncryptionService.generateKeys();
      DatabaseService.addUser(signInData, keys);
    } else {
      // ignore: use_build_context_synchronously
      AppState appState = Provider.of<AppState>(context, listen: false);
      // if (appState.userProfile == null) {
      await appState.initUser(signInData.uid);
      // }
    }
  }

  setUser(signInData) async {
    var d = await DatabaseService.fetchUserData(signInData.uid);
    return d;
  }

  logOut(BuildContext context) async {
    await AuthService.logOutFromGoogle();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  navigateToSearchScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchScreen(widget.signInData!.uid),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, AppState appState, child) {
        inspect(appState);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Profile'),
            leading: IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatsScreen(widget.signInData!.uid),
                    )),
                icon: const Icon(Icons.chat)),
            actions: [
              IconButton(
                  onPressed: navigateToSearchScreen,
                  icon: const Icon(Icons.search)),
              IconButton(
                onPressed: () => logOut(context),
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  CircleAvatar(
                      child: Image.network(widget.signInData!.photoURL!)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(appState.userName ?? 'No username provided'),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                              _usernameController.text = appState.userName;
                            });
                          },
                          icon: const Icon(Icons.edit))
                    ],
                  ),
                  Visibility(
                    visible: _isEditing,
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await DatabaseService.updateUserName(
                                    appState.userUid, _usernameController.text);
                                await appState.initUser(appState.userUid);
                                setState(() {
                                  _isEditing = false;
                                });
                              },
                              child: const Text('Save'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _usernameController.text = '';
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Text(appState.userEmail ?? 'No email provided'),
                  const Spacer(),
                  QrCodeService.createQrCode(appState.userUid),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
