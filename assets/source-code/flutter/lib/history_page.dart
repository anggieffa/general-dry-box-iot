import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/google_sheets_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();

  List<Map<String, dynamic>> historyData = [];
  List<Map<String, dynamic>> filteredData = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    await _sheetsService.init();
    final data = await _sheetsService.getHistory();

    setState(() {
      historyData = data.reversed.toList();
      filteredData = historyData;
      isLoading = false;
    });
  }

  void searchData(String query) {
    final results = historyData.where((item) {
      final nama = item['Nama Barang'].toString().toLowerCase();
      return nama.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredData = results;
    });
  }

  Future<void> downloadCSV() async {
    List<List<dynamic>> rows = [];
    rows.add(["Waktu", "Nama Barang", "Status", "Jumlah"]);

    for (var item in historyData) {
      rows.add([
        item['Waktu'],
        item['Nama Barang'],
        item['Status'],
        item['Jumlah'],
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    try {
      Directory? dir;

      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File(
          "${dir.path}/history_${DateTime.now().millisecondsSinceEpoch}.csv");

      await file.writeAsString(csvData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("CSV tersimpan di: ${file.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal download CSV")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// =========================
          /// GRADIENT BACKGROUND
          /// =========================
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

          /// =========================
          /// BACK BUTTON
          /// =========================
          Positioned(
            left: 15,
            top: 80,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),

          /// =========================
          /// TITLE
          /// =========================
          Positioned(
            left: 15,
            top: 110,
            child: Row(
              children: const [
                Icon(Icons.history, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  "History Detail",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// =========================
          /// REFRESH BUTTON
          /// =========================
          Positioned(
            right: 20,
            top: 105,
            child: GestureDetector(
              onTap: loadData,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          /// =========================
          /// CONTENT AREA
          /// =========================
          Positioned.fill(
            top: 170,
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                /// SEARCH
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search Nama Barang...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                    onChanged: searchData,
                  ),
                ),

                const SizedBox(height: 15),

                /// LIST HISTORY
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredData.isEmpty
                          ? const Center(child: Text("Tidak ada data"))
                          : ListView.builder(
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final item = filteredData[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['Nama Barang'] ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "${item['Status']} • ${item['Waktu']}"),
                                        ],
                                      ),
                                      Text(
                                        item['Jumlah']?.toString() ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                const SizedBox(height: 10),

                /// DOWNLOAD BUTTON
                Padding(
                  padding: const EdgeInsets.only(bottom: 25, top: 5),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      onPressed: historyData.isEmpty ? null : downloadCSV,
                      icon: const Icon(Icons.download),
                      label: const Text(
                        "Download CSV",
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
        ],
      ),
    );
  }
}
