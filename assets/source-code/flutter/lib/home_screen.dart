import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_general_dry_box/screens/dashboard_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/simco_friends.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _idController = TextEditingController();
  String? errorText;
  bool isIdVisible = false;

  void submitId() {
    final id = _idController.text.trim();

    if (id == 'DRYBOX001') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(dryBoxId: id),
        ),
      );
    } else {
      setState(() {
        errorText = 'ID tidak valid! Masukkan ID yang benar!';
      });
    }
  }

  void keluarAplikasi() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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

          // Awan kiri
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/Awan_1.png',
              width: 120,
            ),
          ),

          // Awan kanan
          Positioned(
            top: -25,
            right: 0,
            child: Image.asset(
              'assets/images/Awan_2.png',
              width: 120,
            ),
          ),

          // Konten utama
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),

                  const Text(
                    'Hello SimCoin Friends!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Silahkan masukkan ID Dry Box kamu dulu ya',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Icon Simco Friends
                  const SimcoFriends(
                    imagePath: 'assets/images/simco_friends.png',
                  ),

                  const SizedBox(height: 24),

                  // Input ID Dry Box
                  TextField(
                    controller: _idController,
                    textAlign: TextAlign.center,
                    obscureText: !isIdVisible,
                    decoration: InputDecoration(
                      hintText: 'Masukkan ID Dry Box',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      errorText: errorText,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                        left: 40,
                        right: 10,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            isIdVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isIdVisible = !isIdVisible;
                            });
                          },
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tombol Submit
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 115,
                        height: 40,
                        child: CustomButton(
                          text: 'Keluar',
                          height: 45,
                          onPressed: keluarAplikasi,
                          backgroundColor: const Color(0xFFFEFFAF),
                          textColor: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 115,
                        height: 40,
                        child: CustomButton(
                          text: 'Submit',
                          height: 45,
                          onPressed: submitId,
                          backgroundColor: const Color(0xFFFEFFAF),
                          textColor: Colors.black,
                        ),
                      ),
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
}
