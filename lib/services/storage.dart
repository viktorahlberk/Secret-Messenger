import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static Future uploadImageToFirebase(image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference =
        storage.ref().child('images/${image.path.split('/').last}');
    UploadTask uploadTask = storageReference.putFile(image);

    await uploadTask.whenComplete(() {
      print('Image successfully added to Firebase Storage');
    });
  }

  static getImageDownloadLink(String imageName) async {
    String? imageUrl;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('images/$imageName');

    try {
      final url = await storageReference.getDownloadURL();
      imageUrl = url;
    } catch (e) {
      print('Error when downloading image: $e');
    }
    return imageUrl;
  }
}
// }
