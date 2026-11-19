import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ta_general_dry_box/screens/dashboard_page.dart';
import 'informasi_transaksi.dart';

class ScanQRPage extends StatefulWidget {
  final double suhu;
  final double rh;

  const ScanQRPage({
    super.key,
    required this.suhu,
    required this.rh,
  });

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  final MobileScannerController controller = MobileScannerController();

  bool isScanned = false;
  bool isStarting = true;

  late double suhu;
  late double rh;

  @override
  void initState() {
    super.initState();
    suhu = widget.suhu;
    rh = widget.rh;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        controller.start();
        setState(() {
          isStarting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final barcode = await controller.analyzeImage(image.path);

      if (barcode != null && barcode.barcodes.isNotEmpty) {
        final String? code = barcode.barcodes.first.rawValue;
        if (code != null) {
          _showResult(code);
        }
      }
    }
  }

  void _showResult(String code) {
    if (isScanned) return;

    isScanned = true;
    controller.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("QR Terdeteksi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Komponen:\n$code"),
            const SizedBox(height: 20),
            const Text("Pilih Jenis Transaksi"),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InformasiTransaksiPage(
                    componentName: code,
                    action: "MASUK",
                    suhu: suhu,
                    rh: rh,
                  ),
                ),
              );

              isScanned = false;

              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) controller.start();
              });
            },
            child: const Text("MASUK"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InformasiTransaksiPage(
                    componentName: code,
                    action: "KELUAR",
                    suhu: suhu,
                    rh: rh,
                  ),
                ),
              );

              isScanned = false;

              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) controller.start();
              });
            },
            child: const Text("KELUAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF78A2D2),
              Color(0xFFFEFFAF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                left: 11,
                top: 30,
                child: Image(
                  image: AssetImage('assets/images/menu_outline_icon.png'),
                  width: 28,
                ),
              ),
              Positioned(
                left: 15,
                top: 65,
                child: Row(
                  children: const [
                    Image(
                      image: AssetImage('assets/images/star-menu.png'),
                      width: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Scan QR Code",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 20,
                top: 95,
                child: Text(
                  "Please scan qr code using this page",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'poppins',
                    color: Colors.white70,
                  ),
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.3),
                child: Container(
                  width: 346,
                  height: 417,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MobileScanner(
                          controller: controller,
                          onDetect: (barcodeCapture) {
                            if (isScanned || isStarting) return;

                            final barcodes = barcodeCapture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final code = barcodes.first.rawValue;
                              if (code != null) {
                                _showResult(code);
                              }
                            }
                          },
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: GestureDetector(
                          onTap: _openGallery,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Image(
                              image: AssetImage('assets/images/photos.png'),
                              width: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: -30,
                bottom: -20,
                child: Image(
                  image: AssetImage('assets/images/simco_hello.png'),
                  height: 300,
                ),
              ),
              Positioned(
                right: 40,
                top: 630,
                child: SizedBox(
                  width: 101,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEFFAF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      controller.stop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DashboardPage(dryBoxId: 'DRYBOX001'),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Back",
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
