import 'package:flutter/material.dart';
import '../services/google_sheets_service.dart';
import 'transaksi_sukses.dart';

class InformasiTransaksiPage extends StatefulWidget {
  final String componentName;
  final String action;
  final double suhu;
  final double rh;

  const InformasiTransaksiPage({
    super.key,
    required this.componentName,
    required this.action,
    required this.suhu,
    required this.rh,
  });

  @override
  State<InformasiTransaksiPage> createState() => _InformasiTransaksiPageState();
}

class _InformasiTransaksiPageState extends State<InformasiTransaksiPage> {
  late String action;
  double suhu = 0;
  double rh = 0;

  final TextEditingController jumlahController = TextEditingController();
  final GoogleSheetsService sheetsService = GoogleSheetsService();

  double parseValue(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9.]'), '');

    return double.tryParse(cleaned) ?? 0;
  }

  @override
  void initState() {
    super.initState();

    action = widget.action;
    suhu = widget.suhu;
    rh = widget.rh;

    initService();
  }

  Future<void> initService() async {
    await sheetsService.init();
    await loadRealtimeData();
    startAutoRefresh();
  }

  Future<void> loadRealtimeData() async {
    final data = await sheetsService.getLastMonitoringData();

    if (data != null && mounted) {
      setState(() {
        suhu = parseValue(data['Suhu']);
        rh = parseValue(data['Kelembaban']);
      });
    }
  }

  void startAutoRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      await loadRealtimeData();
      return true;
    });
  }

  @override
  void dispose() {
    jumlahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.now();

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                alignment: const Alignment(0, -0.5),
                child: Container(
                  width: 385,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nama Komponen: ${widget.componentName}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text("Aksi: $action"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: jumlahController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Jumlah Komponen",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Suhu: ${suhu.toStringAsFixed(1)} °C"),
                        Text("RH: ${rh.toStringAsFixed(1)} %"),
                        const SizedBox(height: 10),
                        Text("Timestamp: $timestamp"),
                        const SizedBox(height: 20),
                        const Text(
                          "Periksa Data! Simpan transaksi?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEFFAF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Batal"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEFFAF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                setState(() {
                                  action =
                                      action == "MASUK" ? "KELUAR" : "MASUK";
                                });
                              },
                              child: const Text("Ubah Aksi"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEFFAF),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final jumlah = jumlahController.text.trim();

                                if (jumlah.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Isi jumlah dulu"),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  await sheetsService.addTransaksiData(
                                    timestamp.toString(),
                                    widget.componentName,
                                    jumlah,
                                    action,
                                    suhu.toString(),
                                    rh.toString(),
                                  );

                                  if (!mounted) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TransaksiSuksesPage(),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Gagal menyimpan transaksi"),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
