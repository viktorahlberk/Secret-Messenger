// import 'dart:developer';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/app_state.dart';
import 'package:secure_messenger/models/user_profile.dart';
import 'package:secure_messenger/screens/chats.dart';
import 'package:secure_messenger/screens/qr.dart';
import 'package:secure_messenger/screens/search.dart';
// import 'package:secure_messenger/screens/auth_gate.dart';
import 'package:secure_messenger/services/firebase/database.dart';
import 'package:secure_messenger/services/firebase/google_auth.dart';
import 'package:secure_messenger/services/local_storage.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;
  late bool privateKeyExist;

  @override
  initState() {
    initUser(widget.signInData);

    super.initState();
  }

  dynamic initUser(User? signInData) async {
    privateKeyExist = await LocalStorageService().privateKeyExist();
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

  Future<void> logOut(BuildContext context) async {
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

  Future<void> navigateToQrScreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrScreen(widget.signInData!.uid),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, AppState appState, _) {
        // inspect(appState);
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(child: Text('Profile')),
            leading: IconButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatsScreen(widget.signInData!.uid),
                    )),
                icon: const Icon(Icons.chat)),
            actions: [
              IconButton(
                  onPressed: navigateToQrScreen, icon: Icon(Icons.qr_code)),
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
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  Visibility(
                    child: Column(
                      children: [
                        Text(
                            'Your device didn\'t have encryption keys. You are unable write or receive new messages. Create new keys or use device with proper encryption keys.'),
                        TextButton(
                            onPressed: () {},
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.blueAccent)),
                            child: Text('Create new keys'))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
