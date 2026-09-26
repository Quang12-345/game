import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model dữ liệu cho mỗi đối tượng đua (Xe / Ngựa)
class RaceItem {
  final int id;
  final String name;
  final String imagePath;
  final double odds; // Tỷ lệ trả thưởng (Odds)
  double betAmount;
  bool isSelected;

  RaceItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.odds,
    this.betAmount = 0.0,
    this.isSelected = false,
  });
}

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // Số dư tài khoản hiện tại
  double userBalance = 1000.0;

  // Danh sách các đối tượng đua với hệ số Odds tương ứng
  late List<RaceItem> raceList;

  @override
  void initState() {
    super.initState();
    _initRaceList();
  }

  void _initRaceList() {
    raceList = [
      RaceItem(id: 0, name: 'Xe 01 (Đỏ)', imagePath: 'assets/images/car_1.png', odds: 1.5),
      RaceItem(id: 1, name: 'Xe 02 (Xanh)', imagePath: 'assets/images/car_2.png', odds: 2.0),
      RaceItem(id: 2, name: 'Xe 03 (Vàng)', imagePath: 'assets/images/car_3.png', odds: 3.0),
    ];
  }

  // Logic tính tổng tiền cược hiện tại
  double get totalBet {
    return raceList
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.betAmount);
  }

  // Xử lý nút START
  void _onStartRace() async {
    List<RaceItem> selectedCars = raceList.where((item) => item.isSelected).toList();

    // 1. Kiểm tra phải chọn ít nhất 1 xe
    if (selectedCars.isEmpty) {
      _showSnackBar('Vui lòng chọn ít nhất 1 xe để đặt cược!');
      return;
    }

    // 2. Kiểm tra cược ít nhất 1$ cho mỗi xe đã chọn
    for (var car in selectedCars) {
      if (car.betAmount < 1.0) {
        _showSnackBar('Mỗi xe đặt cược phải cược tối thiểu 1\$!');
        return;
      }
    }

    // 3. Kiểm tra tổng cược không được vượt quá số dư
    if (totalBet > userBalance) {
      _showSnackBar('Tổng tiền cược (\$${totalBet.toStringAsFixed(0)}) vượt quá số dư hiện tại (\$${userBalance.toStringAsFixed(0)})!');
      return;
    }

    // Chuyển sang màn hình Đường đua và nhận lại số dư mới sau khi đua xong
    final updatedBalance = await Navigator.pushNamed(
      context,
      '/race',
      arguments: {
        'raceList': raceList,
        'userBalance': userBalance,
      },
    );

    // Cập nhật lại số dư và reset cược nếu nhận được kết quả
    if (updatedBalance != null && updatedBalance is double) {
      setState(() {
        userBalance = updatedBalance;
        _onReset();
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Xử lý nút RESET
  void _onReset() {
    setState(() {
      for (var item in raceList) {
        item.isSelected = false;
        item.betAmount = 0.0;
      }
    });
  }

  Color _getCarColor(int id) {
    switch (id) {
      case 0:
        return Colors.redAccent;    // Xe 01 (Đỏ)
      case 1:
        return Colors.blueAccent;   // Xe 02 (Xanh)
      case 2:
        return Colors.yellowAccent; // Xe 03 (Vàng)
      default:
        return Colors.cyanAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DANH SÁCH ĐẶT CƯỢC'),
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
        child: Column(
          children: [
            // Khối hiển thị Thông tin số dư & Tổng cược
            Container(
              margin: const EdgeInsets.all(12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Số dư: \$${userBalance.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Tổng cược: \$${totalBet.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                  ),
                ],
              ),
            ),

            // Danh sách các xe đua
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                itemCount: raceList.length,
                itemBuilder: (context, index) {
                  final item = raceList[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: item.isSelected ? Colors.cyanAccent : Colors.white12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Checkbox chọn xe
                          Checkbox(
                            value: item.isSelected,
                            activeColor: Colors.cyanAccent,
                            checkColor: Colors.black,
                            onChanged: (bool? value) {
                              setState(() {
                                item.isSelected = value ?? false;
                                if (!item.isSelected) {
                                  item.betAmount = 0.0;
                                }
                              });
                            },
                          ),

                          // Icon / Tên xe & Odds
                          Icon(Icons.directions_car, size: 36, color: _getCarColor(item.id)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.amber, width: 0.8),
                                  ),
                                  child: Text(
                                    'Odds: x${item.odds}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Ô nhập tiền cược
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              key: ValueKey('bet_${item.id}_${item.isSelected}'),
                              initialValue: item.betAmount > 0 ? item.betAmount.toStringAsFixed(0) : '',
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Min \$1',
                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                isDense: true,
                                fillColor: Colors.black26,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (val) {
                                double parsed = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  item.betAmount = parsed;
                                  item.isSelected = parsed > 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Khối chứa các nút bấm điều khiển (START / RESET)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onStartRace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('START', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('RESET', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}