import 'package:flutter/material.dart';
import 'dart:async';
import '../services/google_sheets_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class PenyimpananPage extends StatefulWidget {
  const PenyimpananPage({super.key});

  static String lastSuhu = '';
  static String lastLembap = '';

  @override
  State<PenyimpananPage> createState() => _PenyimpananPageState();
}

class _PenyimpananPageState extends State<PenyimpananPage> {
  final TextEditingController suhuController = TextEditingController();
  final TextEditingController lembapController = TextEditingController();

  final GoogleSheetsService sheetsService = GoogleSheetsService();

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("monitoring");

  final DatabaseReference setpointRef =
      FirebaseDatabase.instance.ref("setpoint");

  double suhuValue = 0;
  double lembapValue = 0;

  bool isSaving = false;

  Timer? timer;

  StreamSubscription<DatabaseEvent>? firebaseSubscription;
  StreamSubscription<DatabaseEvent>? setpointSubscription;

  double parseValue(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    return double.tryParse(cleaned) ?? 0;
  }

  void playsukses1Sound() {
    FlutterRingtonePlayer().play(
      fromAsset: "assets/sounds/sukses1.mp3",
      looping: false,
      volume: 1.0,
      asAlarm: false,
    );
  }

  @override
  void initState() {
    super.initState();
    sheetsService.init();

    suhuController.text = PenyimpananPage.lastSuhu;
    lembapController.text = PenyimpananPage.lastLembap;

    suhuValue = double.tryParse(PenyimpananPage.lastSuhu) ?? 0;
    lembapValue = double.tryParse(PenyimpananPage.lastLembap) ?? 0;

    firebaseSubscription = dbRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) return;

      final map = Map<dynamic, dynamic>.from(data as dynamic);

      setState(() {
        suhuValue = parseValue(
          map['suhu'] ?? map['Suhu'] ?? map['temperature'],
        );

        lembapValue = parseValue(
          map['kelembaban'] ?? map['kelembapan'] ?? map['humidity'],
        );
      });
    });

    setpointSubscription = setpointRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) return;

      final map = Map<dynamic, dynamic>.from(data as dynamic);

      final suhuSet = parseValue(map['suhu']);
      final humSet = parseValue(map['kelembaban']);

      setState(() {
        suhuController.text = suhuSet.toStringAsFixed(0);
        lembapController.text = humSet.toStringAsFixed(0);
      });
    });

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // getRealtimeData();
    });
  }

  Future<void> getRealtimeData() async {
    final data = await sheetsService.getLastMonitoringData();

    if (data == null) return;

    setState(() {
      suhuValue = parseValue(
        data['Suhu'] ?? data['suhu'],
      );

      lembapValue = parseValue(
        data['Kelembaban'] ??
            data['Kelembapan'] ??
            data['kelembaban'] ??
            data['humidity'],
      );
    });
  }

  Future<void> saveMonitoringData() async {
    final suhu = suhuController.text;
    final lembap = lembapController.text;

    if (suhu.isEmpty || lembap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi suhu dan kelembapan dulu")),
      );
      return;
    }

    final double? suhuInput = double.tryParse(suhu);
    final double? lembapInput = double.tryParse(lembap);

    if (suhuInput == null || lembapInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Input harus berupa angka")),
      );
      return;
    }

    if ((suhuInput < 20 || suhuInput > 40) ||
        (lembapInput < 20 || lembapInput > 60)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Suhu harus 20-40 dan Kelembapan harus 20-60",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final waktu = DateTime.now().toString();

    try {
      await sheetsService.addMonitoringData(
        waktu,
        suhuValue.toStringAsFixed(1),
        lembapValue.toStringAsFixed(1),
        lembap,
        suhu,
      );

      await setpointRef.set({
        "suhu": suhuInput,
        "kelembaban": lembapInput,
      });

      PenyimpananPage.lastSuhu = suhu;
      PenyimpananPage.lastLembap = lembap;

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan")),
      );

      playsukses1Sound();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data")),
      );
    }

    setState(() {
      isSaving = false;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    timer?.cancel();

    firebaseSubscription?.cancel();
    setpointSubscription?.cancel();

    suhuController.dispose();
    lembapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final circleSize = 140.0;
    final boxWidth = 151.0;
    final spacing = 24.0;

    final totalCircleWidth = circleSize * 2 + spacing;
    final startCircleX = (screenWidth - totalCircleWidth) / 2;

    final totalBoxWidth = boxWidth * 2 + spacing;
    final startBoxX = (screenWidth - totalBoxWidth) / 2;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
          ),
          Positioned(
            left: 11,
            top: 72,
            child: Image.asset(
              'assets/images/menu_outline_icon.png',
              width: 28,
            ),
          ),
          Positioned(
            left: 15,
            top: 110,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/star-menu.png',
                  width: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Penyimpanan',
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
          Positioned(
            left: startCircleX,
            top: 169,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/circle.png',
                  width: circleSize,
                ),
                Text(
                  '$suhuValue°C',
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: startCircleX + circleSize + spacing,
            top: 169,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/circle.png',
                  width: circleSize,
                ),
                Text(
                  '$lembapValue%',
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: startBoxX,
            top: 347,
            child: Container(
              width: boxWidth,
              height: 216,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset('assets/images/suhu.png', width: 20),
                      const SizedBox(width: 8),
                      const Text('Suhu'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: suhuController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Input',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: startBoxX + boxWidth + spacing,
            top: 347,
            child: Container(
              width: boxWidth,
              height: 216,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset('assets/images/kelembapan.png', width: 20),
                      const SizedBox(width: 8),
                      const Text('Kelembapan'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lembapController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Input',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: startBoxX - (boxWidth - 140),
            top: 618,
            child: SizedBox(
              width: 101,
              height: 38,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveMonitoringData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEFFAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text("SET"),
              ),
            ),
          ),
          Positioned(
            left: startBoxX + boxWidth + spacing + (boxWidth - 101),
            top: 618,
            child: SizedBox(
              width: 101,
              height: 38,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEFFAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text("Back"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
