import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_messenger/models/message.dart';
import 'package:secure_messenger/services/chat.dart';
import 'package:secure_messenger/services/database.dart';
import 'package:secure_messenger/services/encryption.dart';
import 'package:secure_messenger/services/image_picker.dart';
import 'package:secure_messenger/services/storage.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final int chatUid;
  const ChatScreen(this.chatUid, this.senderUid, this.receiverUid, {super.key});
  final String senderUid;
  final String receiverUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var textFieldController = TextEditingController();
  String? receiverUid;
  List<Message> messages = [];
  List<VideoPlayerController> _videoControllers = [];
  List<int> _videoMessageIndexes = [];
  late StreamSubscription<DatabaseEvent> messagesStreamSubscription;
  late StreamSubscription<DatabaseEvent> typingStreamSubscription;
  final ScrollController _listViewController = ScrollController();
  bool typingIsActive = false;
  bool opponentIsTyping = false;

  fetchReceiverUid() async {
    DataSnapshot ds = await FirebaseDatabase.instance
        .ref('chats/${widget.chatUid}/chatters')
        .get();
    if (ds.exists) {
      var data = ds.value as String;
      var splitted = data.split(' ');
      if (splitted[0] == widget.senderUid) {
        receiverUid = splitted[1];
      } else {
        receiverUid = splitted[0];
      }
    }
  }

  @override
  void initState() {
    fetchReceiverUid();
    messagesStreamSubscription = FirebaseDatabase.instance
        .ref()
        .child('chats/${widget.chatUid}/messages')
        .onValue
        .listen((event) {
      update();
    });
    typingStreamSubscription = FirebaseDatabase.instance
        .ref()
        .child('chats/${widget.chatUid}/typing/${widget.receiverUid}')
        .onValue
        .listen(
      (event) {
        // inspect(event);
        if (event.snapshot.value == true) {
          setState(() {
            opponentIsTyping = true;
          });
        } else if (event.snapshot.value == false) {
          setState(() {
            opponentIsTyping = false;
          });
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    update();
    super.initState();
  }

  @override
  void dispose() {
    messagesStreamSubscription.cancel();
    typingStreamSubscription.cancel();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
    );
  }

  update() async {
    var m = await DatabaseService.fetchChatMessages(widget.chatUid.toString());
    setState(() {
      messages = m;
      _videoControllers.clear();
      _videoMessageIndexes.clear();
    });

    for (var i = 0; i < messages.length; i++) {
      // print(messages[i].sender != widget.senderUid &&
      //     messages[i].readed == false);
      if (messages[i].sender != widget.senderUid &&
          messages[i].readed == false) {
        // print('!');
        /* widget.senderUid= is ME */
        markMessageToReaded(messages[i]);
      }
      if (messages[i].messageType == 'video') {
        Uri url = Uri.parse(messages[i].content);
        var controller = VideoPlayerController.networkUrl(url);
        await controller.initialize();
        setState(() {
          _videoControllers.add(controller);
          _videoMessageIndexes.add(i);
        });
      }
    }
  }

  markMessageToReaded(Message m) async {
    await DatabaseService.markMessageToReaded(widget.chatUid, m.key);
  }

  pickAndStoreImageMessage() async {
    XFile? pickedImage = await ImagepickerService.getImage();
    if (pickedImage != null) {
      var image = File(pickedImage.path);
      await StorageService.uploadImageToFirebase(image);
      var imageName =
          await StorageService.getImageDownloadLink(pickedImage.name);

      await ChatService.sendMessage(
          widget.chatUid, widget.senderUid, receiverUid, imageName, 'image');
    } else {
      return;
    }
  }

  pickAndStoreVideoMessage() async {
    XFile? pickedVideo = await ImagepickerService.getVideo();
    if (pickedVideo != null) {
      var video = File(pickedVideo.path);
      await StorageService.uploadImageToFirebase(video);
      var videoName =
          await StorageService.getImageDownloadLink(pickedVideo.name);

      await ChatService.sendMessage(
          widget.chatUid, widget.senderUid, receiverUid, videoName, 'video');
    } else {
      return;
    }
  }

  typing(int chatUid, String userUid) async {
    if (!typingIsActive) {
      await DatabaseService.userIsTypingSetter(chatUid, userUid);
      Timer(const Duration(seconds: 7), () async {
        await DatabaseService.userIsTypingDeleter(chatUid, userUid);
        typingIsActive = false;
      });
    }
  }

  deleteMessage(Message m) async {
    // inspect(message);
    await DatabaseService.deleteMessage(widget.chatUid, m.key);
  }

  editMessage(BuildContext context, Message oldMessage) async {
    inspect(oldMessage);
    inspect(context);
    // inspect(object)
    TextEditingController textEditController = TextEditingController();

    var response = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              TextField(
                controller: textEditController,
                decoration:
                    const InputDecoration(hintText: 'Type new message..'),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        // inspect(textEditController.text);
                        Navigator.pop(context, textEditController.text);
                      },
                      child: const Text('Edit!'))
                ],
              )
            ],
          ),
        );
      },
    );
    if (response != null) {
      // inspect(response);
      String newMessage = response;
      if (newMessage.isNotEmpty) {
        String receiverUid = widget.receiverUid;
        await ChatService.editMessage(
            widget.chatUid, oldMessage.key, receiverUid, newMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _listViewController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (_videoMessageIndexes.contains(index)) {
                  var videoIndex = _videoMessageIndexes.indexOf(index);
                  return Column(
                    children: [
                      FutureBuilder(
                        future: DatabaseService.userNameFromUserUid(
                            messages[index].sender),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              '${snapshot.data as String}:',
                              textAlign: TextAlign.start,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                              aspectRatio: _videoControllers[videoIndex]
                                  .value
                                  .aspectRatio,
                              child:
                                  VideoPlayer(_videoControllers[videoIndex])),
                          GestureDetector(
                            onTap: () {
                              if (_videoControllers[videoIndex]
                                  .value
                                  .isPlaying) {
                                _videoControllers[videoIndex].pause();
                              } else {
                                _videoControllers[videoIndex].play();
                              }
                            },
                            child: Icon(
                              _videoControllers[videoIndex].value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      messages[index].sender == widget.senderUid
                          ? IconButton(
                              onPressed: () => deleteMessage(messages[index]),
                              icon: const Icon(Icons.delete))
                          : Container(),
                      messages[index].readed
                          ? const Row(
                              children: [
                                // Spacer(),
                                SizedBox(
                                  width: 30,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 15,
                                  ),
                                ),
                              ],
                            )
                          : Container()
                    ],
                  );
                } else {
                  return SizedBox(
                    // height: 80,
                    child: IntrinsicHeight(
                      child: Card(
                        child: Column(
                          crossAxisAlignment:
                              messages[index].sender == widget.senderUid
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                          children: [
                            FutureBuilder(
                              future: DatabaseService.userNameFromUserUid(
                                  messages[index].sender),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    '${snapshot.data as String}:',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              },
                            ),
                            const Spacer(),
                            messages[index].messageType == 'text'
                                ? FutureBuilder(
                                    future: EncryptionService.decryptMessage(
                                        messages[index].content, receiverUid),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState !=
                                          ConnectionState.waiting) {
                                        return Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                snapshot.data!,
                                                overflow: TextOverflow.visible,
                                                softWrap: true,
                                              ),
                                            ),
                                            messages[index].sender ==
                                                    widget.senderUid
                                                ? IconButton(
                                                    onPressed: () async {
                                                      await editMessage(context,
                                                          messages[index]);
                                                      setState(() {});
                                                      await update();
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit))
                                                : Container(),
                                            messages[index].sender ==
                                                    widget.senderUid
                                                ? IconButton(
                                                    onPressed: () async =>
                                                        await deleteMessage(
                                                            messages[index]),
                                                    icon: const Icon(
                                                        Icons.delete))
                                                : Container(),
                                            messages[index].readed
                                                ? const Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                          size: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container()
                                          ],
                                        );
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  )
                                : Container(),
                            messages[index].messageType == 'image'
                                ? Row(
                                    children: [
                                      Image.network(messages[index].content),
                                      messages[index].sender == widget.senderUid
                                          ? IconButton(
                                              onPressed: () => deleteMessage(
                                                  messages[index]),
                                              icon: const Icon(Icons.delete))
                                          : Container(),
                                      messages[index].readed
                                          ? const Row(
                                              children: [
                                                // Spacer(),
                                                SizedBox(
                                                  width: 30,
                                                  child: Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 15,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container()
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: [
                      Visibility(
                        visible: opponentIsTyping,
                        child: const Text('Opponent is typing...'),
                      ),
                      TextField(
                        controller: textFieldController,
                        onChanged: (value) {
                          typing(widget.chatUid, widget.senderUid);
                          typingIsActive = true;
                        },
                        // focusNode: textfieldFocus,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    if (textFieldController.text.isEmpty) {
                      return;
                    }
                    await ChatService.sendMessage(
                      widget.chatUid,
                      widget.senderUid,
                      receiverUid,
                      textFieldController.text,
                      'text',
                    );
                    await update();
                    textFieldController.text = '';
                  },
                  icon: const Icon(Icons.send)),
              IconButton(
                onPressed: () async {
                  await pickAndStoreImageMessage();
                  await update();
                },
                // pickAndStoreImageMessage,
                icon: const Icon(Icons.image),
              ),
              IconButton(
                onPressed: () async {
                  await pickAndStoreVideoMessage();
                  await update();
                },
                // pickAndStoreImageMessage,
                icon: const Icon(Icons.video_camera_back),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
