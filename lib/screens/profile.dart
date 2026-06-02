import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/app_state.dart';
import 'package:secure_messenger/screens/chats.dart';
import 'package:secure_messenger/screens/qr.dart';
import 'package:secure_messenger/screens/search.dart';
import 'package:secure_messenger/services/firebase/database.dart';
import 'package:secure_messenger/services/firebase/google_auth.dart';
import 'package:secure_messenger/services/local_storage.dart';
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
  bool _privateKeyExist = true;

  @override
  initState() {
    initUser(widget.signInData);
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  dynamic initUser(User? signInData) async {
    _privateKeyExist = await LocalStorageService().privateKeyExist();
    if (!await DatabaseService.isUserExists(signInData!.uid)) {
      KeyPair<EcdhPrivateKey, EcdhPublicKey> keys =
          await EncryptionService.generateKeys();
      DatabaseService.addUser(signInData, keys);
    } else {
      if (mounted) {
        AppState appState = Provider.of<AppState>(context, listen: false);
        await appState.initUser(signInData.uid);
      }
    }
  }

  // setUser(signInData) async {
  //   var d = await DatabaseService.fetchUserData(signInData.uid);
  //   return d;
  // }

  Future<void> logOut() async {
    await AuthService.logOutFromGoogle();

    if (!mounted) return;

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
        return Scaffold(
          backgroundColor: Colors.grey.shade400,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade400,
            automaticallyImplyLeading: false,
            // title: Center(child: Text('Profile')),
            leading: Visibility(
              visible: _privateKeyExist,
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatsScreen(widget.signInData!.uid),
                      )),
                  icon: const Icon(Icons.chat)),
            ),
            actions: [
              IconButton(
                  onPressed: navigateToQrScreen, icon: Icon(Icons.qr_code_2)),
              IconButton(
                  onPressed: navigateToSearchScreen,
                  icon: const Icon(Icons.search)),
              IconButton(
                onPressed: () => logOut(),
                icon: const Icon(Icons.logout),
              )
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CircleAvatar(
                      //   radius: 40,
                      //   child: Image.network(
                      //     widget.signInData!.photoURL!,
                      //   ),
                      // ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            NetworkImage(widget.signInData!.photoURL!),
                      ),
                      // Spacer(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    appState.userName ?? 'No username provided',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = !_isEditing;
                                          _usernameController.text = '';
                                        });
                                      },
                                      icon: const Icon(Icons.edit))
                                ],
                              ),
                              Text(appState.userEmail ?? 'No email provided'),
                            ],
                          ),
                        ),
                      ),
                      // Spacer()
                    ],
                  ),
                  IgnorePointer(
                    ignoring: !_isEditing,
                    child: AnimatedOpacity(
                      opacity: _isEditing ? 1 : 0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.bounceIn,
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              // helperText: 'type new username',
                              hintText: 'Type new username',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await DatabaseService.updateUserName(
                                      appState.userUid,
                                      _usernameController.text);
                                  await appState.initUser(appState.userUid);
                                  setState(() {
                                    _isEditing = false;
                                    _usernameController.text = '';
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
                  ),
                  const Spacer(),
                  Container(
                    // width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 198, 198, 198)),
                    child: Visibility(
                      visible: !_privateKeyExist,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'This device has no encryption keys. You can’t send or receive new messages. To continue using this app on this device, please delete your account and sign in again. Alternatively, use a device that has valid encryption keys.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          OutlinedButton(
                            style: ButtonStyle(
                                foregroundColor:
                                    WidgetStatePropertyAll(Colors.red)),
                            onPressed: AuthService().deleteOAuth2Account,
                            child: const Text('Recreate account'),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
