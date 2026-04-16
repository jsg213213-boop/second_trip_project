import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
// Future.delayed를 사용하기 위해 dart:async를 임포트합니다.
import 'dart:async';

import 'MainScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후에 메인 화면(예: HomeScreen)으로 이동합니다.
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // 'HomeScreen()' 부분은 실제 프로젝트의 메인 화면 위젯으로 변경해야 합니다.
          builder: (context) => const MainScreen(),
        ),
      );
    });
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