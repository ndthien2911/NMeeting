import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

const flash_on = "FLASH ON";
const flash_off = "FLASH OFF";
const front_camera = "FRONT CAMERA";
const back_camera = "BACK CAMERA";

class PageQRScan extends StatefulWidget {
  const PageQRScan({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageQRScanState();
}

class _PageQRScanState extends State<PageQRScan> {
  var qrText = '';
  var flashState = flash_on;
  var cameraState = front_camera;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scan'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              flashState == flash_on ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              if (controller != null) {
                controller!.toggleFlash();
                if (_isFlashOn(flashState)) {
                  setState(() {
                    flashState = flash_off;
                  });
                } else {
                  setState(() {
                    flashState = flash_on;
                  });
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
            flex: 4,
          ),
        ],
      ),
    );
  }

  _isFlashOn(String current) {
    return flash_on == current;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      this.controller?.dispose();
      setState(() {
        qrText = scanData.code ?? '';
        Navigator.pop(context, scanData);
      });
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
