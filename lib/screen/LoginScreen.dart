import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ⭐ 비밀번호 찾기 화면 임포트 (파일명 확인해줘!)
import 'package:second_trip_project/screen/ForgotPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  final Color classicBlue = const Color(0xFF004680);

  InputDecoration _buildAppleInputDecoration(String labelText, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: classicBlue, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.paperplane_fill, size: 80, color: classicBlue),
                      const SizedBox(height: 16),
                      const Text(
                        'Travel-Hub',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '스마트 통합 여행 매니지먼트',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildAppleInputDecoration('이메일', CupertinoIcons.mail),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildAppleInputDecoration(
                    '패스워드',
                    CupertinoIcons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),

                // ⭐ [수정 포인트] 비밀번호 찾기 연결!
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/mypage');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${emailController.text}님, 환영합니다!'),
                          backgroundColor: classicBlue,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: classicBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아직 회원이 아니신가요?', style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text('회원가입',
                          style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}