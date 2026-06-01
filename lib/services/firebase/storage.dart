import 'dart:developer';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future<dynamic> uploadImageToFirebase(image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference =
        storage.ref().child('images/${image.path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(image);

    await uploadTask.whenComplete(() {
      log('Image successfully added to Firebase Storage');
    });
  }

  static Future<String?> getImageDownloadLink(String imageName) async {
    String? imageUrl;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('images/$imageName');

    try {
      final url = await storageReference.getDownloadURL();
      imageUrl = url;
    } catch (e) {
      log('Error when downloading image: $e');
    }
    return imageUrl;
  }
}
// }
