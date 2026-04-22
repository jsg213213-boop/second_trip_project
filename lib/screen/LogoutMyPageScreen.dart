import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoutMyPageScreen extends StatelessWidget {
  const LogoutMyPageScreen({super.key});

  final Color yeogiRed = const Color(0xFFF7323F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('마이페이지',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. 텅 빈 프로필 느낌의 아이콘
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.person_fill, size: 80, color: Colors.grey[400]),
              ),
              const SizedBox(height: 30),

              // 2. 안내 문구
              const Text(
                '로그인이 필요해요',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '여기좋아의 다양한 서비스를\n로그인 후 이용해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 40),

              // 3. 로그인 버튼 (여기어때 레드 포인트!)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 화면으로 이동! (누나가 만든 LoginScreen 경로)
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yeogiRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('로그인 / 회원가입',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),

              // 4. 혹시 모르니 홈으로 돌아가기 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('홈으로 돌아가기', style: TextStyle(color: Colors.grey[400])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}