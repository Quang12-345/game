import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'list_screen.dart';

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

  List<RaceItem> _raceList = [];
  double _userBalance = 0.0;
  bool _isDataLoaded = false;

  // Cập nhật lại icon cho xe màu xanh thành icon ô tô (Icons.directions_car)
  final List<Map<String, dynamic>> _racerUI = [
    {'color': Colors.redAccent, 'icon': Icons.directions_car_filled},
    {'color': Colors.lightBlueAccent, 'icon': Icons.directions_car},
    {'color': Colors.amberAccent, 'icon': Icons.electric_car},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _raceList = args['raceList'] as List<RaceItem>;
        _userBalance = args['userBalance'] as double;
      }
      _isDataLoaded = true;
      _startRace();
    }
  }

  void _startRace() async {
    _timer?.cancel();

    setState(() {
      _carPositions = [0.0, 0.0, 0.0];
      _isRacing = true;
      _winnerIndex = null;
    });

    AudioManager().playStartSound().catchError((e) {
      debugPrint("Lỗi âm thanh start: $e");
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        for (int i = 0; i < 3; i++) {
          if (_carPositions[i] < 1.0) {
            _carPositions[i] += Random().nextDouble() * 0.05 + 0.02;
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

    // --- LOGIC TÍNH TOÁN THẮNG / THUA VÀ CẬP NHẬT SỐ DƯ ---
    double totalBetAmount = 0.0;
    double totalWinAmount = 0.0;

    for (var car in _raceList) {
      if (car.isSelected) {
        totalBetAmount += car.betAmount;
      }
    }

    // Trừ tổng tiền cược ban đầu
    _userBalance -= totalBetAmount;

    // Kiểm tra xe thắng cuộc có được đặt cược không
    RaceItem winningCar = _raceList[_winnerIndex!];
    bool isUserWin = winningCar.isSelected && winningCar.betAmount > 0;

    if (isUserWin) {
      // Tiền thắng = Tiền cược trên xe đó * Odds
      totalWinAmount = winningCar.betAmount * winningCar.odds;
      _userBalance += totalWinAmount;
      AudioManager().playWinSound();
    } else {
      AudioManager().playLoseSound();
    }

    double netProfit = totalWinAmount - totalBetAmount;
    _showResultDialog(winningCar, isUserWin, netProfit);
  }

  void _showResultDialog(RaceItem winningCar, bool isUserWin, double netProfit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isUserWin ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isUserWin ? Colors.amber : Colors.white24, width: 3),
        ),
        title: Center(
          child: Text(
            isUserWin ? '🎉 BẠN ĐÃ THẮNG! 🎉' : '❌ BẠN ĐÃ THUA! ❌',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUserWin ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              '${winningCar.name}\nĐÃ VỀ ĐÍCH ĐẦU TIÊN! (x${winningCar.odds})',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    isUserWin
                        ? 'Lợi nhuận: +\$${netProfit.toStringAsFixed(0)}'
                        : 'Tiền cược đã mất: -\$${netProfit.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isUserWin ? Colors.greenAccent : Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Số dư mới: \$${_userBalance.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context, _userBalance); // Trả số dư mới về ListScreen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('XÁC NHẬN / QUAY VỀ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: CartoonRaceTrackPainter(),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Text(
                    _isRacing ? '🏁 GO! GO! GO! 🏁' : 'CUỘC ĐUA KẾT THÚC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
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

  Widget _buildCartoonLane(int index) {
    double progress = _carPositions[index];
    var racerData = _racerUI[index];
    RaceItem? racer = _raceList.length > index ? _raceList[index] : null;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5D4037), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double trackWidth = constraints.maxWidth;
          double carSize = 44.0;
          double maxDistance = trackWidth - carSize - 30;
          double leftPosition = progress * maxDistance;

          return Stack(
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

              // CỔNG VẠCH ĐÍCH
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

              // TÊN XE & ODDS
              Positioned(
                left: 10,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    racer != null ? '${racer.name} (x${racer.odds})' : 'Xe ${index + 1}',
                    style: TextStyle(
                      color: racerData['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // XE ĐUA DI CHUYỂN
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear,
                left: max(0.0, leftPosition),
                bottom: 10,
                child: Container(
                  width: carSize,
                  height: carSize,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: racerData['color'],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
                  ),
                  child: Icon(
                    racerData['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartoonRaceTrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint grassPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grassPaint);

    final Paint hillPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawCircle(Offset(size.width * 0.2, 0), 120, hillPaint);
    canvas.drawCircle(Offset(size.width * 0.8, 0), 150, hillPaint);

    final Paint cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(size.width * 0.15, 60), 25, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.22, 55), 35, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.75, 80), 30, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.82, 75), 40, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}