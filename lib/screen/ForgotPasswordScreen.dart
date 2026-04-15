import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final Color classicBlue = const Color(0xFF004680);
  final TextEditingController _emailController = TextEditingController();

  // ⭐ 임시 비밀번호 발송 함수
  void _sendTemporaryPassword() {
    String email = _emailController.text.trim();

    // 이메일 형식 간단 유효성 검사 (기본 매너!)
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가입하신 이메일 형식을 올바르게 입력해주세요.')),
      );
      return;
    }

    // ⭐ 실제 서버 API 연결할 곳! (지금은 임시 모달)
    // TODO: 서버에 이메일 보내고 결과 받기

    showDialog(
      context: context,
      barrierDismissible: false, // 배경 눌러도 안 닫히게
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('발송 완료', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[$email]으로 임시 비밀번호가 발송되었습니다.'),
            const SizedBox(height: 12),
            const Text('이메일을 확인하신 후, 로그인하여 반드시 비밀번호를 변경해주시기 바랍니다.',
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 모달 닫기
              Navigator.pop(context); // 비밀번호 찾기 화면도 닫고 로그인 화면으로!
            },
            child: Text('확인', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('비밀번호 찾기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. 안내 타이틀 & 설명
            const Text('비밀번호가 기억나지 않으신가요?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3)),
            const SizedBox(height: 12),
            const Text('가입하신 이메일 주소를 입력해주세요.\n임시 비밀번호를 보내드립니다.',
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5)),

            const SizedBox(height: 50),

            // 2. 이메일 입력 필드 (로그인 화면 디자인 맞춰서!)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(CupertinoIcons.mail, color: Colors.grey, size: 20),
                  hintText: '가입한 이메일 입력',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // 3. 발송 버튼 (로그인 버튼 디자인 맞춰서!)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: classicBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _sendTemporaryPassword,
                child: const Text('임시 비밀번호 받기',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}