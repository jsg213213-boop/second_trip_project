import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => _checkToken());
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();

    // TODO: 자동 로그인 사용 시 아래 주석 해제
    // final refreshToken = prefs.getString('refreshToken');
    // if (refreshToken != null) {
    //   try {
    //     final response = await dio.post(
    //       '/refreshToken',
    //       data: {'refreshToken': refreshToken},
    //     );
    //     final newAccessToken = response.data['accessToken'];
    //     await prefs.setString('accessToken', newAccessToken);
    //   } catch (e) {
    //     await prefs.clear();
    //   }
    // }

    // 자동 로그인 미사용 시 매번 토큰 초기화
    await prefs.clear();
    _goToMain();
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    // 이미지가 들어있는 AssetImage 객체를 생성합니다.
    // 프로젝트 루트의 assets/logo.png 경로에 이미지가 있어야 합니다.
    const image = AssetImage('assets/images/logo.png');

    return Scaffold(
      backgroundColor: Colors.white, // 배경을 흰색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지를 표시하는 위젯입니다.
            const Image(
              image: image,
              width: 150, // 로고 크기를 조절합니다.
            ),
          ],
        ),
      ),
    );
  }
}