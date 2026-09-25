import 'package:flutter/material.dart';
import 'list_screen.dart'; // Import màn hình danh sách cược tại đây

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller Đăng nhập
  final TextEditingController _loginUserCtrl = TextEditingController();
  final TextEditingController _loginPassCtrl = TextEditingController();

  // Controller Đăng ký
  final TextEditingController _regUserCtrl = TextEditingController();
  final TextEditingController _regPassCtrl = TextEditingController();
  final TextEditingController _regConfirmPassCtrl = TextEditingController();

  // Lưu tài khoản mẫu
  final Map<String, String> _users = {'user': '123456'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUserCtrl.dispose();
    _loginPassCtrl.dispose();
    _regUserCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmPassCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    String username = _loginUserCtrl.text.trim();
    String password = _loginPassCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    if (_users.containsKey(username) && _users[username] == password) {
      _showMessage('Đăng nhập thành công!');

      // Chuyển trực tiếp sang ListScreen thay vì gọi route chuỗi '/main' gây crash app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListScreen(),
        ),
      );
    } else {
      _showMessage('Tài khoản hoặc mật khẩu không đúng!');
    }
  }

  void _handleRegister() {
    String username = _regUserCtrl.text.trim();
    String password = _regPassCtrl.text.trim();
    String confirmPass = _regConfirmPassCtrl.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPass.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin đăng ký!');
      return;
    }

    if (password != confirmPass) {
      _showMessage('Mật khẩu xác nhận không khớp!');
      return;
    }

    if (_users.containsKey(username)) {
      _showMessage('Tên tài khoản đã tồn tại!');
      return;
    }

    _users[username] = password;
    _showMessage('Đăng ký thành công! Vui lòng nhập mật khẩu để đăng nhập.');

    // Tự điền thông tin vừa đăng ký vào form Đăng nhập và tự chuyển tab
    _loginUserCtrl.text = username;
    _loginPassCtrl.clear();
    _regUserCtrl.clear();
    _regPassCtrl.clear();
    _regConfirmPassCtrl.clear();
    _tabController.animateTo(0); // Chuyển về tab Đăng nhập
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ĐĂNG NHẬP / ĐĂNG KÝ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.cyanAccent,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.cyanAccent,
          tabs: const [
            Tab(text: 'Đăng Nhập'),
            Tab(text: 'Đăng Ký'),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: ĐĂNG NHẬP
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.account_circle, size: 80, color: Colors.cyanAccent),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _loginUserCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tên tài khoản',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.person, color: Colors.cyanAccent),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _loginPassCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.lock, color: Colors.cyanAccent),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // TAB 2: ĐĂNG KÝ
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.person_add, size: 80, color: Colors.greenAccent),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _regUserCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Tên tài khoản mới',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _regPassCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _regConfirmPassCtrl,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.lock_clock, color: Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ĐĂNG KÝ TÀI KHOẢN', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}