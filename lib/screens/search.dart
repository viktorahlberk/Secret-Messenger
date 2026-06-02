import 'package:flutter/material.dart';
import 'package:secure_messenger/models/user_profile.dart';
import 'package:secure_messenger/screens/chat.dart';
import 'package:secure_messenger/services/chat_service.dart';
import 'package:secure_messenger/services/firebase/database.dart';
import 'package:secure_messenger/services/qr_code.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen(this.userUid, {super.key});
  final String userUid;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController textFieldController = TextEditingController();

  Future<void> scanQrCodeAndShowUser(context) async {
    String uid = await QrCodeService.scanQrCode();
    if (uid.isNotEmpty) {
      UserProfile? userProfile = await DatabaseService.fetchUserData(uid);
      var response = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Center(
              child: Column(
                children: [
                  const Text('User found!'),
                  CircleAvatar(
                      child: Image.network(userProfile!.profilePictureUrl)),
                  Text(userProfile.userName ?? 'null'),
                  const Text(
                    'Start chatting?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No, thanks.'),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, uid);
                          },
                          child: const Text('Lets go!'))
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
      if (response != null) {
        int? r = await DatabaseService.isUsersHaveChat(widget.userUid, uid);
        if (r == null) {
          startChatWith(context, uid);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(r, widget.userUid, uid)));
        }
      }
    }
  }

  startChatWith(BuildContext context, String uid) async {
    int chatUid = DateTime.now().millisecondsSinceEpoch;
    await ChatService.createChatRoom(chatUid, widget.userUid,
        uid); //userUid = chatstarter uid & uid = receipient person uid
    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(chatUid, widget.userUid, uid)));
  }

  searchUserByEmail(context, String email) async {
    UserProfile? userProfile =
        await DatabaseService.fetchUserDataByEmail(email);
    if (userProfile == null) {
      // ignore: use_build_context_synchronously
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Dialog(
              child: Text('User not found',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            );
          });
    } else {
      //ignore: use_build_context_synchronously
      var response = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Center(
                child: Column(
                  children: [
                    const Text('User found!'),
                    CircleAvatar(
                        child: Image.network(userProfile.profilePictureUrl)),
                    Text(userProfile.userName ?? ''),
                    const Text(
                      'Start chatting?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('No, thanks.'),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context, userProfile.uid);
                            },
                            child: const Text('Lets go!'))
                      ],
                    )
                  ],
                ),
              ),
            );
          });
      if (response != null) {
        var roomUid = await DatabaseService.isUsersHaveChat(
            widget.userUid, userProfile.uid);
        if (roomUid == null) {
          // ignore: use_build_context_synchronously
          await startChatWith(context, userProfile.uid);
        } else {
          // ignore: use_build_context_synchronously
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(roomUid, widget.userUid, userProfile.uid)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.grey.shade400,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: textFieldController,
                      decoration:
                          const InputDecoration(hintText: 'Search by email'),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      if (textFieldController.text.isNotEmpty) {
                        searchUserByEmail(context, textFieldController.text);
                      }
                    },
                    icon: const Icon(Icons.search))
              ],
            ),
          ),
          SizedBox(
            height: 70,
          ),
          // const Divider(
          //   indent: 10,
          //   endIndent: 10,
          // ),
          const Text('or scan QR Code'),
          SizedBox(
            height: 35,
          ),
          OutlinedButton(
            onPressed: () => scanQrCodeAndShowUser(context),
            child: const Text('Scan'),
          )
        ],
      ),
    );
  }
}
