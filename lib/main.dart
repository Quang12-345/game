import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
import 'list_screen.dart';
import 'race_screen.dart';
import 'audio_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Đua Xe Đặt Cược',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),        // 1. Màn Đăng ký / Đăng nhập
        '/main': (context) => const MainScreen(),    // 2. Màn Main (Trang chủ)
        '/bet': (context) => const ListScreen(),     // 3. Màn Đặt Cược
        '/race': (context) => const RaceScreen(),    // 4. Màn Kết quả Đường đua
      },
    );
  }
}