import 'package:image_picker/image_picker.dart';

class ImagepickerService {
  static Future<XFile?> getImage(/*ImageSource source*/) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    //TODO: make also image picking from camera.
    return pickedFile;
  }

  static Future<XFile?> getVideo() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickVideo(source: ImageSource.gallery);
    return pickedFile;
  }
}
