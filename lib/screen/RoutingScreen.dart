import 'package:flutter/material.dart';

import '../car/screen/car_rent_home_screen.dart';
import '../car/screen/table_calendar_screen.dart';
import '../loging/screens/list/accommodation_list_screen.dart';
import 'ChangePasswordScreen.dart';
import 'EditProfileScreen.dart';
import 'InquiryScreen.dart';
import 'LoginScreen.dart';
import 'MainScreen.dart';
import 'MyPageScreen.dart';
import 'MyPostsScreen.dart';
import 'SignUpScreen.dart';
import 'SplashScreen.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel-Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004680)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/edit_profile': (context) => const EditProfileScreen(name: '', phone: ''),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/my_posts': (context) => const MyPostsScreen(),
        '/inquiry': (context) => const InquiryScreen(),
        '/car_rent': (context) => const TableCalendarScreen(),
        '/car_rent_home': (context) => const CarRentHomeScreen(),
        '/hotel': (context) => const AccommodationListScreen(),
        '/motel': (context) => const AccommodationListScreen(),

        // --- 연습용 및 숙소 카테고리 라우트 ---
        '/publicDataTest': (context) =>
            const Scaffold(body: Center(child: Text('공공데이터 테스트'))),
        '/mapBasic1': (context) =>
            const Scaffold(body: Center(child: Text('지도 서비스 테스트'))),
        '/dbTest2': (context) =>
            const Scaffold(body: Center(child: Text('DB ORM 테스트'))),
        '/todosMain': (context) =>
            const Scaffold(body: Center(child: Text('스프링 연결 연습'))),
        '/hotel': (context) =>
            const Scaffold(body: Center(child: Text('호텔·리조트 화면'))),
        '/motel': (context) =>
            const Scaffold(body: Center(child: Text('모텔 화면'))),
      },
    );
  }
}