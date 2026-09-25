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
  List<double> _carPositions = [0.0, 0.0, 0.0];
  bool _isRacing = false;
  int? _winnerIndex;
  Timer? _timer;

  // Cấu hình 3 nhân vật/xe đua phong cách Hoạt hình
  final List<Map<String, dynamic>> _racers = [
    {'name': 'Xe 1 - Đỏ', 'color': Colors.redAccent, 'icon': Icons.directions_car_filled},
    {'name': 'Xe 2 - Xanh', 'color': Colors.lightBlueAccent, 'icon': Icons.sports_motorsports},
    {'name': 'Xe 3 - Vàng', 'color': Colors.amberAccent, 'icon': Icons.electric_car},
  ];

  @override
  void initState() {
    super.initState();
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

    AudioManager().playStartSound().catchError((e) {
      debugPrint("Lỗi âm thanh start: $e");
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < 3; i++) {
          if (_carPositions[i] < 1.0) {
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

    AudioManager().playWinSound().catchError((e) {
      debugPrint("Lỗi âm thanh win: $e");
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 3),
        ),
        title: const Center(
          child: Text(
            '🏆 KẾT QUẢ CUỘC ĐUA',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
            const SizedBox(height: 10),
            Text(
              '${_racers[_winnerIndex!]['name']}\nĐÃ VỀ ĐÍCH ĐẦU TIÊN!',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('CHƠI LẠI / ĐẶT CƯỢC', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: Stack(
        children: [
          // 1. TỰ VẼ HÌNH NỀN TRƯỜNG ĐUA SÂN CỎ 2D CARTOON
          CustomPaint(
            size: Size.infinite,
            painter: CartoonRaceTrackPainter(),
          ),

          // 2. PHẦN GIAO DIỆN CHÍNH
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                // TIÊU ĐỀ HOẠT HÌNH GO!
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange, // 👈 Đã sửa Colors.orangeBold -> Colors.orange
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Text(
                    _isRacing ? '🏁 GO! GO! GO! 🏁' : 'CUỘC ĐUA KẾT THÚC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900, // 👈 Đã sửa FontWeight.black -> FontWeight.w900
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // KHU VỰC 3 LÀN ĐƯỜNG ĐUA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) => _buildCartoonLane(index)),
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

  // LÀN ĐƯỜNG ĐUA HOẠT HÌNH CÓ CỔNG VẠCH ĐÍCH CỜ CARO
  Widget _buildCartoonLane(int index) {
    double progress = _carPositions[index];
    var racer = _racers[index];

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8), // Màu đất trường đua
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5D4037), width: 3), // Rào gỗ
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Stack(
        children: [
          // Vạch đường đứt nét
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                8,
                    (i) => Container(width: 20, height: 4, color: Colors.white54),
              ),
            ),
          ),

          // CỔNG VẠCH ĐÍCH CỜ CARO ĐỎ - TRẮNG
          Positioned(
            right: 15,
            top: 0,
            bottom: 0,
            child: Container(
              width: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.red, width: 6),
                  right: BorderSide(color: Colors.white, width: 6),
                ),
              ),
            ),
          ),

          // TÊN XE
          Positioned(
            left: 10,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                racer['name'],
                style: TextStyle(
                  color: racer['color'],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // XE ĐUA HOẠT HÌNH DI CHUYỂN
          LayoutBuilder(
            builder: (context, constraints) {
              double maxDistance = constraints.maxWidth - 65;
              double leftPosition = progress * maxDistance;

              return Positioned(
                left: leftPosition,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: racer['color'],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                  ),
                  child: Icon(
                    racer['icon'],
                    color: Colors.white,
                    size: 28,
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

// BỘ VẼ HÌNH NỀN TRƯỜNG ĐUA SÂN CỎ BẰNG CODE FLUTTER
class CartoonRaceTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Nền cỏ xanh tươi
    final Paint grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grassPaint);

    // 2. Vẽ đồi núi / Lùm cây hoạt hình phía trên
    final Paint hillPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawCircle(Offset(size.width * 0.2, 0), 120, hillPaint);
    canvas.drawCircle(Offset(size.width * 0.8, 0), 150, hillPaint);

    // 3. Vẽ mây trắng hoạt hình (Sử dụng withValues thay withOpacity để tránh warning deprecation)
    final Paint cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.15, 60), 25, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.22, 55), 35, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.75, 80), 30, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.82, 75), 40, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}