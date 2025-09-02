import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// شاشة مسح الـ QR باستخدام mobile_scanner
class QRScannerScreen extends StatelessWidget {
  final Function(String) onCodeScanned;
  const QRScannerScreen({super.key, required this.onCodeScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null) {
              onCodeScanned(code);
              Navigator.pop(context); // نقفل الشاشة بعد القراءة
              break;
            }
          }
        },
      ),
    );
  }
}

