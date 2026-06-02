import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:secure_messenger/models/user_profile.dart';

class QrCodeService {
  static QrImageView createQrCode(String uid) {
    return QrImageView(data: uid);
  }

  static Future<String> scanQrCode() async {
    var result = await BarcodeScanner.scan();

    // print(result.type); // The result type (barcode, cancelled, failed)
    // print(result.rawContent); // The barcode content
    // print(result.format); // The barcode format (as enum)
    // print(result
    //     .formatNote); // If a unknown format was scanned this field contains a note
    return result.rawContent;
  }
}
