import 'package:flutter/material.dart';

import 'basic2-miniproject/Mainscreen.dart';
import 'basic2-miniproject/mainscreen.dart';
// 작성하신 MainScreen 파일과 SplashScreen 파일을 임포트하세요.
// import 'screens/main_screen.dart';
// import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yeogiyeoddae Clone',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      // 앱 실행 시 처음 보여줄 화면 (스플래시 화면)
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // 스플래시 화면
        '/main': (context) => const MainScreen(), // 메인 화면

        // --- 메인 화면의 메뉴 및 버튼 라우트들 ---
        '/login': (context) => const Scaffold(body: Center(child: Text('로그인 화면'))),
        '/signup': (context) => const Scaffold(body: Center(child: Text('회원가입 화면'))),

        // 숙소 카테고리 라우트
        '/hotel': (context) => const Scaffold(body: Center(child: Text('호텔·리조트 화면'))),
        '/motel': (context) => const Scaffold(body: Center(child: Text('모텔 화면'))),
        // ... 필요한 만큼 추가 가능
      },
    );
  }
}

// 테스트를 위한 임시 SplashScreen (이미 파일이 있다면 삭제해도 됩니다)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('여기어때', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }
}