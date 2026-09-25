import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  // Tiến trình vị trí của 3 xe (từ 0.0 đến 1.0)
  List<double> _carPositions = [0.0, 0.0, 0.0];
  bool _isRacing = false;
  int? _winnerIndex;
  Timer? _timer;

  // Cấu hình xe đua
  final List<Map<String, dynamic>> _cars = [
    {'name': 'Xe 1 - Đỏ', 'color': Colors.redAccent, 'icon': Icons.directions_car_filled},
    {'name': 'Xe 2 - Xanh', 'color': Colors.cyanAccent, 'icon': Icons.sports_motorsports},
    {'name': 'Xe 3 - Vàng', 'color': Colors.amberAccent, 'icon': Icons.electric_car},
  ];

  @override
  void initState() {
    super.initState();
    // Chờ frame đầu tiên dựng xong mới kích hoạt đua để tránh giật lag UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRace();
    });
  }

  void _startRace() {
    setState(() {
      _carPositions = [0.0, 0.0, 0.0];
      _isRacing = true;
      _winnerIndex = null;
    });

    // 1. Phát âm thanh xuất phát (Bọc catchError để không block Timer nếu lỗi âm thanh)
    AudioManager().playStartSound().catchError((e) {
      debugPrint("Lỗi phát nhạc start: $e");
    });

    // 2. Chạy Timer di chuyển xe
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        for (int i = 0; i < 3; i++) {
          if (_carPositions[i] < 1.0) {
            // Tốc độ ngẫu nhiên tăng tiến vị trí
            _carPositions[i] += Random().nextDouble() * 0.02 + 0.008;
            if (_carPositions[i] >= 1.0) {
              _carPositions[i] = 1.0;
              if (_winnerIndex == null) {
                _winnerIndex = i;
                _finishRace();
              }
            }
          }
        }
      });
    });
  }

  void _finishRace() {
    _timer?.cancel();
    if (!mounted) return;

    setState(() {
      _isRacing = false;
    });

    // Phát âm thanh chiến thắng
    AudioManager().playWinSound().catchError((e) {
      debugPrint("Lỗi phát nhạc win: $e");
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1C2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text(
              'KẾT QUẢ CUỘC ĐUA',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          '🏆 ${_cars[_winnerIndex!]['name']} đã về ĐÍCH ĐẦU TIÊN!',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Quay về màn Đặt cược
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Quay lại Đặt Cược', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioManager().stopSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ĐƯỜNG ĐUA KỊCH TÍNH'),
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // HEADER TRẠNG THÁI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: Text(
                _isRacing ? '⚡ ĐANG ĐUA KỊCH TÍNH ⚡' : '🏁 CUỘC ĐUA KẾT THÚC',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TRƯỜNG ĐUA (LÀN ĐƯỜNG XE)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  return _buildTrackLane(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET DỰNG LÀN ĐƯỜNG ĐUA
  Widget _buildTrackLane(int index) {
    var car = _cars[index];
    double progress = _carPositions[index];

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF1E242B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: car['color'], width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (car['color'] as Color).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Stack(
        children: [
          // 1. Vạch kẻ đường đứt nét
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                10,
                    (i) => Container(
                  width: 15,
                  height: 3,
                  color: Colors.white24,
                ),
              ),
            ),
          ),

          // 2. Vạch ĐÍCH
          Positioned(
            right: 15,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              color: Colors.redAccent,
            ),
          ),

          // 3. Tên xe
          Positioned(
            left: 10,
            top: 6,
            child: Text(
              car['name'],
              style: TextStyle(
                color: car['color'],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          // 4. XE ĐUA DI CHUYỂN
          LayoutBuilder(
            builder: (context, constraints) {
              double maxDistance = constraints.maxWidth - 60;
              double leftPosition = progress * maxDistance;

              return Positioned(
                left: leftPosition,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: car['color'],
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    car['icon'],
                    color: car['color'],
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}