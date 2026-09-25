import 'package:flutter/material.dart';
import 'audio_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Bật nhạc nền ngay khi chuyển từ Đăng nhập vào Trang chủ
    AudioManager().playBgm();
  }

  @override
  void dispose() {
    // Tắt nhạc khi rời khỏi Trang chủ
    AudioManager().stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANG CHỦ GAME ĐUA XE'),
        backgroundColor: const Color(0xFF141E30),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF141E30),
              Color(0xFF243B55),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_motorsports,
                size: 100,
                color: Colors.cyanAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'RACING GAME 2026',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Chào mừng bạn đến với Trường Đua Xe Tốc Độ!',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Nút Đặt Cược & Đua
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AudioManager().stopSound(); // Dừng nhạc nền khi vào đặt cược
                    if (context.mounted) {
                      Navigator.pushNamed(context, '/bet');
                    }
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
                  label: const Text(
                    'VÀO PHÒNG ĐẶT CƯỢC',
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nút Đăng xuất
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AudioManager().stopSound(); // Dừng nhạc nền khi Đăng xuất
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    'ĐĂNG XUẤT',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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