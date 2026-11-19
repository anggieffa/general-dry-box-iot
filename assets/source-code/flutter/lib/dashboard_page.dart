import 'package:flutter/material.dart';
import 'package:ta_general_dry_box/screens/inventory.dart';
import 'penyimpanan.dart';
import 'scan_qr.dart';

class DashboardPage extends StatefulWidget {
  final String dryBoxId;

  const DashboardPage({
    super.key,
    required this.dryBoxId,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BAGIAN BACKGROUND
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

          /// BAGIAN MENU
          Positioned(
            left: 11,
            top: 72,
            child: Image.asset(
              'assets/images/menu_outline_icon.png',
              width: 28,
            ),
          ),

          /// BAGIAN DASHBOARD
          Positioned(
            top: 200,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 260,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
                child: Column(
                  children: [
                    /// TITLE
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/moon_solid.png',
                          width: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// BAGIAN MENU
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MenuItem(
                          icon: 'assets/images/penyimpanan_icon.png',
                          label: 'Penyimpanan',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PenyimpananPage(),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: 'assets/images/inventory_icon.png',
                          label: 'Inventory',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const InventoryPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BAGIAN SCAN QR
          Positioned(
            top: 510,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 390,
                height: 62,
                child: OutlinedButton(
                  onPressed: () async {
                    double suhu =
                        double.tryParse(PenyimpananPage.lastSuhu) ?? 0;
                    double rh =
                        double.tryParse(PenyimpananPage.lastLembap) ?? 0;

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    final result = await navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ScanQRPage(
                          suhu: suhu,
                          rh: rh,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text("QR Result: $result"),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: -25,
            bottom: -30,
            child: Image.asset(
              'assets/images/simco_hello.png',
              height: 349,
            ),
          ),

          /// BAGIAN TEXT WELCOME
          Positioned(
            left: 15,
            top: 110,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'User!',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'poppins',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          /// LOGOUT
          Positioned(
            right: 40,
            top: 660,
            child: SizedBox(
              width: 101,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home_screen',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEFFAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// BAGIAN MENU
class _MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(icon, height: 120),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
