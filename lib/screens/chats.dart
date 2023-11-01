import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_messenger/screens/chat.dart';
import 'package:secure_messenger/services/database.dart';

class ChatsScreen extends StatefulWidget {
  final String userUid;
  const ChatsScreen(this.userUid, {super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Map> chats = [];

  @override
  void initState() {
    fetchChats(widget.userUid);
    super.initState();
  }

  fetchChats(userUid) async {
    List<Map>? c = await DatabaseService.fetchUserChats(userUid);
    if (c != null) {
      setState(() {
        chats = c;
      });
    }
  }

  ///Convert chatters string to opponent username.
  Future<String> convert(chattersString) async {
    var splitted = chattersString.split(' ');
    if (splitted[0] == widget.userUid) {
      String r = await DatabaseService.userNameFromUserUid(splitted[1]);
      return r;
    } else {
      String r = await DatabaseService.userNameFromUserUid(splitted[0]);
      return r;
    }
  }

  openChat(roomId, opponent) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatScreen(roomId, widget.userUid, opponent)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All conversations'),
      ),
      body: chats.isEmpty
          ? const Text('Sorry, you dont have any opened chats.')
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return FutureBuilder<String>(
                  future: convert(chats[index]['chatters']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return GestureDetector(
                        onTap: () {
                          String fullString = chats[index]['chatters'];
                          String woMe =
                              fullString.replaceAll(widget.userUid, '');
                          String woSpace = woMe.replaceAll(' ', '');
                          // print(chats[index]['chatters']);
                          // print(ch);
                          openChat(chats[index]['roomId'], woSpace);
                        },
                        child: SizedBox(
                          height: 60,
                          child: Card(
                            child: Center(
                              child: Text(
                                snapshot.data ?? 'Unknown User',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
