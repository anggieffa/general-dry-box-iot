import 'package:flutter/material.dart';
import 'history_page.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/google_sheets_service.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final GoogleSheetsService sheetsService = GoogleSheetsService();

  List<Map<String, dynamic>> inventoryData = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await sheetsService.init();
    final data = await sheetsService.getHistory();

    setState(() {
      inventoryData = data;
    });
  }

  int countIn() {
    return inventoryData.where((e) {
      final status = e['Status'].toString().toLowerCase();
      return status.contains('in') || status.contains('masuk');
    }).length;
  }

  int countOut() {
    return inventoryData.where((e) {
      final status = e['Status'].toString().toLowerCase();
      return status.contains('out') || status.contains('keluar');
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
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

          /// MENU ICON
          Positioned(
            left: 11,
            top: 70,
            child: Image.asset(
              'assets/images/menu_outline_icon.png',
              width: 28,
            ),
          ),

          /// TITLE
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
                  "Inventory",
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

          /// CARD AREA
          Positioned.fill(
            top: 160,
            left: 20,
            right: 20,
            child: Column(
              children: [
                kategoriCard(),
                const SizedBox(height: 15),
                grafikCard(),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryPage(),
                      ),
                    );
                  },
                  child: historyCard(),
                ),
              ],
            ),
          ),

          /// BACK BUTTON
          Positioned(
            right: 40,
            top: 660,
            child: SizedBox(
              width: 101,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEFFAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
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
    );
  }

  /// CARD KATEGORI
  Widget kategoriCard() {
    final reversed = inventoryData.reversed.toList();

    final latestIn = reversed.firstWhere(
      (e) {
        final status = e['Status'].toString().toLowerCase();
        return status.contains('in') || status.contains('masuk');
      },
      orElse: () => {},
    );

    final latestOut = reversed.firstWhere(
      (e) {
        final status = e['Status'].toString().toLowerCase();
        return status.contains('out') || status.contains('keluar');
      },
      orElse: () => {},
    );

    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// JUDUL
          Row(
            children: [
              Image.asset(
                'assets/images/puzzle.png',
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                "Kategori",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// CONTENT
          if (latestIn.isEmpty && latestOut.isEmpty)
            const Text("Belum ada data")
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// MASUK
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Masuk",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestIn.isNotEmpty
                            ? "${latestIn['Nama Barang']} (${latestIn['Jumlah']})"
                            : "-",
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                /// JARAK TENGAH
                const SizedBox(width: 10),

                /// KELUAR
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Keluar",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestOut.isNotEmpty
                            ? "${latestOut['Nama Barang']} (${latestOut['Jumlah']})"
                            : "-",
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// CARD GRAFIK
  Widget grafikCard() {
    final totalIn = countIn();
    final totalOut = countOut();

    return Container(
      height: 190,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/puzzle.png',
                width: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                "Grafik",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const Text("IN");
                        } else if (value == 1) {
                          return const Text("OUT");
                        }
                        return const Text("");
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalIn.toDouble(),
                        color: Colors.green,
                        width: 25,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: totalOut.toDouble(),
                        color: Colors.red,
                        width: 25,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CARD HISTORY
  Widget historyCard() {
    final previewData = inventoryData.reversed.take(3).toList();

    return Container(
      height: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/puzzle.png',
                width: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                "History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (previewData.isEmpty)
            const Text(
              "Belum ada data",
              style: TextStyle(fontSize: 11),
            )
          else
            ...previewData.map(
              (item) => Text(
                "${item['Nama Barang']} • ${item['Status']}",
                style: const TextStyle(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
