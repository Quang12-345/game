import 'package:flutter/material.dart';

// 1. Model dữ liệu cho mỗi đối tượng đua (Xe / Ngựa)
class RaceItem {
  final int id;
  final String name;
  final String imagePath;
  double betAmount;
  bool isSelected;

  RaceItem({
    required this.id,
    required this.name,
    required this.imagePath,
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
  // Số dư tài khoản mẫu
  double userBalance = 1000.0;

  // Danh sách các đối tượng đua
  List<RaceItem> raceList = [
    RaceItem(id: 1, name: 'Xe 01 (Đỏ)', imagePath: 'assets/images/car_1.png'),
    RaceItem(id: 2, name: 'Xe 02 (Xanh)', imagePath: 'assets/images/car_2.png'),
    RaceItem(id: 3, name: 'Xe 03 (Vàng)', imagePath: 'assets/images/car_3.png'),
  ];

  // Logic tính tổng tiền cược hiện tại
  double get totalBet {
    return raceList
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.betAmount);
  }

  // Xử lý nút START
  void _onStartRace() {
    if (totalBet <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn xe và nhập số tiền cược!')),
      );
      return;
    }

    if (totalBet > userBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dư không đủ để đặt cược!')),
      );
      return;
    }

    // Chuyển sang màn hình Đường đua
    Navigator.pushNamed(context, '/race');
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
      // BỌC CONTAINER BACKGROUND GRADIENT TẠI ĐÂY
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF141E30), // Deep Navy
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

            // Danh sách các làn đua / Xe đua
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
                              });
                            },
                          ),

                          // Icon / Tên xe
                          const Icon(Icons.directions_car, size: 36, color: Colors.cyanAccent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),

                          // Ô nhập tiền cược
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              key: ValueKey(item.isSelected ? item.betAmount : 'reset_$index'),
                              initialValue: item.betAmount > 0 ? item.betAmount.toStringAsFixed(0) : '',
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Tiền cược',
                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                isDense: true,
                                fillColor: Colors.black26,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  item.betAmount = double.tryParse(val) ?? 0.0;
                                  if (item.betAmount > 0) {
                                    item.isSelected = true; // Tự động tích chọn khi nhập tiền
                                  }
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