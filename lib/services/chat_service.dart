import 'package:secure_messenger/models/message.dart';
import 'package:secure_messenger/services/firebase/database.dart';
import 'package:secure_messenger/services/encryption.dart';

class ChatService {
  static createChatRoom(chatUid, userId1, userId2) async {
    await DatabaseService.addChatRoom(chatUid, userId1, userId2);
    // return uid;
  }

  static sendMessage(
      chatUid, senderUid, receiverUid, message, messageType) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (messageType == 'text') {
      var receiverPublicKey =
          await DatabaseService.fetchUserPublicKey(receiverUid);
      String encryptedMessage =
          await EncryptionService.encryptMessage(message, receiverPublicKey);
      await DatabaseService.addMessage(
          chatUid, senderUid, encryptedMessage, timestamp, messageType);
    } else if (messageType == 'image' || messageType == 'video') {
      await DatabaseService.addMessage(
          chatUid, senderUid, message, timestamp, messageType);
    }
  }

  static editMessage(
    int chatUid,
    String messageUid,
    String receiverUid,
    String newMessage,
  ) async {
    String receiverPublicKey =
        await DatabaseService.fetchUserPublicKey(receiverUid);
    String encryptedMessage =
        await EncryptionService.encryptMessage(newMessage, receiverPublicKey);
    await DatabaseService.editMessage(chatUid, messageUid, encryptedMessage);
    // }
  }
}
