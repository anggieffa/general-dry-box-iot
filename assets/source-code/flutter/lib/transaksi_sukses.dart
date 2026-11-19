import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:ta_general_dry_box/screens/scan_qr.dart';

class TransaksiSuksesPage extends StatefulWidget {
  const TransaksiSuksesPage({super.key});

  @override
  State<TransaksiSuksesPage> createState() => _TransaksiSuksesPageState();
}

class _TransaksiSuksesPageState extends State<TransaksiSuksesPage> {
  double suhu = 0;
  double rh = 0;

  @override
  void initState() {
    super.initState();

    FlutterRingtonePlayer().play(
      fromAsset: "assets/sounds/sukses2.mp3",
      looping: false,
      volume: 1.0,
      asAlarm: false,
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
                      "Informasi Transaksi",
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
              Align(
                alignment: const Alignment(0, -0.4),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(55),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Terimakasih.\n\nData telah disimpan di database dan data komponen berhasil diperbarui",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'poppins',
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const Positioned(
                left: -30,
                bottom: -20,
                child: Image(
                  image: AssetImage('assets/images/simco_hello.png'),
                  width: 300,
                ),
              ),
              Positioned(
                top: 630,
                right: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEFFAF),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    FlutterRingtonePlayer().stop();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScanQRPage(
                          suhu: suhu,
                          rh: rh,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w600,
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
