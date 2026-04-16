import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/member_service.dart';
import 'package:second_trip_project/screen/ForgotPasswordScreen.dart';
import 'MyPageScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final MemberService _memberService = MemberService();

  bool _isPasswordVisible = false;

  // 🎨 여기어때 레드 컬러 (#F7323F) 적용!
  final Color yeogiRed = const Color(0xFFF7323F);

  // ⭐ 이메일 유효성 검사 정규식
  bool _isValidEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // ⭐ 스낵바 통합 함수
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : yeogiRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 애플 스타일 입력창 디자인
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
        borderSide: BorderSide(color: yeogiRed, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  // 로그인 로직 처리
  void _handleLogin() async {
    String mid = emailController.text.trim();
    String mpw = passwordController.text;

    if (mid.isEmpty || mpw.isEmpty) {
      _showSnackBar('아이디(이메일)와 비밀번호를 입력해주세요!');
      return;
    }

    if (!_isValidEmail(mid)) {
      _showSnackBar('올바른 이메일 형식이 아닙니다.');
      return;
    }

    var userData = await _memberService.login(mid, mpw);

    if (userData != null) {
      String realName = userData['mname'] ?? "이름 없음";
      String realEmail = userData['mid'] ?? mid;

      if (!mounted) return;

      // 로그인 성공 시 메인으로 가거나 마이페이지로 이동
      Navigator.pushReplacementNamed(context, '/main');
      _showSnackBar('$realName님, 환영합니다!', isError: false);
    } else {
      _showSnackBar('로그인 실패! 정보를 다시 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                      // ⭐ [수정] 팀원 로고 이미지 적용 (assets 경로 확인!)
                      Image.asset(
                        'assets/images/logo.png',
                        height: 50, // 로고 크기 적절히 조절
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(CupertinoIcons.paperplane_fill, size: 80, color: yeogiRed),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '스마트 통합 여행 매니지먼트',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // 이메일 입력창
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildAppleInputDecoration('이메일', CupertinoIcons.mail),
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력창
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
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 30),

                // 로그인 버튼 (여기어때 레드!)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yeogiRed,
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
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: Text('회원가입',
                          style: TextStyle(color: yeogiRed, fontWeight: FontWeight.bold)),
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