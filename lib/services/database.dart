import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:secure_messenger/models/message.dart';
import 'package:secure_messenger/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webcrypto/webcrypto.dart';

// import 'encryption.dart';

class DatabaseService {
  static FutureOr<bool> isUserExists(String userUID) async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child("users/$userUID").get();
    if (snapshot.exists) {
      // print('User exist');
      return true;
    } else {
      // print('User dont exist');
      return false;
    }
  }

  static addUser(
      User userData, KeyPair<EcdhPrivateKey, EcdhPublicKey> keys) async {
    var jwkpublic = await keys.publicKey.exportJsonWebKey();
    // final keyPair = generateKeyPair();
    await FirebaseDatabase.instance.ref().child('users/${userData.uid}').set({
      'userName': userData.displayName,
      'key': jsonEncode(jwkpublic),
      'email': userData.email,
      'picturePath': userData.photoURL,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwkprivate = await keys.privateKey.exportJsonWebKey();
    await prefs.setString('key', jsonEncode(jwkprivate));
    return UserProfile(userData.uid, jwkpublic, userData.displayName,
        userData.email, userData.photoURL);
  }

  static fetchUserData(String userUid) async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('users/$userUid').get();
    if (snapshot.exists) {
      var u = snapshot.value as Map;
      // inspect(u);
      return UserProfile(
        userUid,
        u['key'],
        u['userName'],
        u['email'],
        u['picturePath'],
      );
      // return User(u['username'], u['email'], double.parse(u['balance']));
    }
  }

  /// Algorithm speed is O(n)
  static fetchUserDataByEmail(String email) async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('users').get();
    if (snapshot.exists) {
      var u = snapshot.value as Map;
      // inspect(u);
      UserProfile? profile;
      u.forEach((key, value) {
        // print(key);
        if (value['email'] == email) {
          // print(key);
          profile = UserProfile(
            key,
            value['key'],
            value['userName'],
            value['email'],
            value['picturePath'],
          );
        }
      });
      // print(profile);
      return profile;
    }
  }

  static updateUserName(String userUid, String newUserName) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('users/$userUid/userName');
    // print(ref.);
    await ref.set(newUserName);
  }

  static addChatRoom(int chatUid, String userId1, String userId2) async {
    // var uid = DateTime.now().microsecondsSinceEpoch;
    await FirebaseDatabase.instance
        .ref()
        .child('chats/${chatUid.toString()}')
        .set({
      'roomId': chatUid,
      'chatters': '$userId1 $userId2',
      // 'messages': {},
    });
    // return uid;
    // return UserProfile(
    //   userData.uid,
    //   userData.displayName,
    //   userData.email,
    //   userData.photoURL,
    // );
  }

  static fetchUserPublicKey(userUid) async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.ref().child('users/$userUid/key').get();
    if (snapshot.exists) {
      return snapshot.value as String;
    }
  }

  static addMessage(chatUid, senderUid, message, timestamp, messageType) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('chats/$chatUid/messages').push();
    var k = ref.key;
    // print(k);
    await ref.set({
      'key': k,
      'sender': senderUid,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType,
      'readed': false,
    });
  }

  static fetchChatMessages(String chatUid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('chats/$chatUid/messages');
    DataSnapshot snapshot = await ref.orderByChild('timestamp').get();
    List<Message> list = [];

    if (snapshot.exists) {
      var messages = snapshot.value as Map;
      messages.forEach((key, value) {
        list.add(Message(
          value['key'],
          value['sender'],
          value['timestamp'],
          value['message'],
          value['messageType'],
          value['readed'],
        ));
      });
    }

    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  static markMessageToReaded(int chatUid, String messageUid) async {
    // print(chatUid);
    // print(messageUid);
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('chats/$chatUid/messages/$messageUid/readed');
    await ref.set(true);
  }

  static fetchUserChats(String userUid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('chats');
    DataSnapshot snapshot = await ref.get();
    List<Map> userChats = [];
    if (snapshot.exists) {
      var chats = snapshot.value as Map;
      inspect(chats);
      chats.forEach((key, value) {
        String s = value['chatters'];
        if (s.contains(userUid)) {
          userChats.add(value);
        }
      });
      return userChats;
    }
  }

  static userNameFromUserUid(String userUid) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .ref()
        .child('users/$userUid/userName')
        .get();
    if (snapshot.exists) {
      String userName = snapshot.value as String;
      return userName;
      // inspect(u);
      // return UserProfile(userUid, u['userName'], u['email'], u['picturePath']);
      // return User(u['username'], u['email'], double.parse(u['balance']));
    }
  }

  static isUsersHaveChat(u1, u2) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance.ref('chats').get();
    if (snapshot.exists) {
      var chats = snapshot.value as Map;
      int? roomId;
      chats.forEach((key, value) {
        // print(value['chatters'].contains(u1) && value['chatters'].contains(u2));
        if (value['chatters'].contains(u1) && value['chatters'].contains(u2)) {
          roomId = value['roomId'];
          // return roomId;
        } else {
          // return null;
        }
      });
      // print(roomId);
      return roomId;
    }
  }

  static userIsTypingSetter(int chatUid, String userUid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('chats/$chatUid/typing/$userUid');
    await ref.set(true);
  }

  static userIsTypingDeleter(int chatUid, String userUid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('chats/$chatUid/typing/$userUid');
    await ref.set(false);
  }

  static deleteMessage(int chatUid, String messageUid) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('chats/$chatUid/messages/$messageUid');
    await ref.set(null);
  }

  static editMessage(int chatUid, String messageUid, newMessage) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('chats/$chatUid/messages/$messageUid/message');
    ref.set(newMessage);
  }
}
