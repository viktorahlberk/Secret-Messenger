import 'package:flutter/material.dart';
import 'package:secure_messenger/services/qr_code.dart';

class QrScreen extends StatelessWidget {
  const QrScreen(this.uid, {super.key});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade400,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade400,
      ),
      body: Center(
        child: QrCodeService.createQrCode(uid),
      ),
    );
  }
}
