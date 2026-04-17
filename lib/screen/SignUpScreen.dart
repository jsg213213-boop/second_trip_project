import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ⭐ 숫자 필터링을 위해 꼭 필요해!
import '../services/member_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final MemberService _memberService = MemberService();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;
  bool _isEmailChecked = false;

  final Color classicBlue = const Color(0xFFF7323F);

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> _handleCheckDuplicate() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar("이메일을 입력해주세요.");
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackBar("올바른 이메일 형식이 아닙니다.");
      return;
    }

    bool isDuplicate = await _memberService.checkEmailDuplicate(email);

    if (isDuplicate) {
      setState(() => _isEmailChecked = false);
      _showSnackBar("이미 사용 중인 이메일입니다.");
    } else {
      setState(() => _isEmailChecked = true);
      _showSnackBar("사용 가능한 이메일입니다.", backgroundColor: Colors.blue);
    }
  }

  void _attemptSignUp() async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String pw = passwordController.text;
    String pwConfirm = passwordConfirmController.text;
    String phone = phoneController.text.trim();

    if (email.isEmpty || name.isEmpty || pw.isEmpty || pwConfirm.isEmpty || phone.isEmpty) {
      _showSnackBar("모든 정보를 입력해주세요.");
      return;
    }

    if (!_isEmailChecked) {
      _showSnackBar("이메일 중복 확인을 먼저 진행해주세요.");
      return;
    }

    if (pw != pwConfirm) {
      _showSnackBar("비밀번호가 일치하지 않습니다.");
      return;
    }

    Map<String, String> userData = {
      "mid": email,
      "mpw": pw,
      "mname": name,
      "email": email,
      "phone": phone,
    };

    bool success = await _memberService.register(userData);

    if (success) {
      _showSuccessDialog();
    } else {
      _showSnackBar("회원가입에 실패했습니다. 다시 시도해주세요.");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('가입 완료', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('회원가입이 성공적으로 완료되었습니다.\n로그인 화면으로 이동합니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('확인', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor ?? Colors.redAccent),
    );
  }

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
        title: const Text('회원가입', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text('필수 정보 입력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
                const SizedBox(height: 12),
                Text('All-In-One 트래픽 플랫폼 서비스를 시작해보세요.', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                const SizedBox(height: 40),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        onChanged: (value) => setState(() => _isEmailChecked = false),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildAppleInputDecoration('이메일(아이디)', CupertinoIcons.mail),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _handleCheckDuplicate,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _isEmailChecked ? Colors.blue : classicBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: _isEmailChecked ? Colors.blue : classicBlue,
                        ),
                        child: Text(_isEmailChecked ? '확인완료' : '중복확인', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: nameController,
                  decoration: _buildAppleInputDecoration('이름', CupertinoIcons.person),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: _buildAppleInputDecoration(
                    '패스워드',
                    CupertinoIcons.lock,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.grey[600], size: 20),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: passwordConfirmController,
                  obscureText: !_isPasswordConfirmVisible,
                  decoration: _buildAppleInputDecoration(
                    '패스워드 확인',
                    CupertinoIcons.lock_shield,
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordConfirmVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.grey[600], size: 20),
                      onPressed: () => setState(() => _isPasswordConfirmVisible = !_isPasswordConfirmVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ⭐ 전화번호 입력 부분 수정
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.number, // 숫자 키보드 호출
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // 숫자 외 입력 원천 차단
                    LengthLimitingTextInputFormatter(11),   // 11자리까지만 입력 가능
                  ],
                  decoration: _buildAppleInputDecoration('전화번호 (- 없이 숫자만)', CupertinoIcons.phone),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _attemptSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: classicBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('회원가입 하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}