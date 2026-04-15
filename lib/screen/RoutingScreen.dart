import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../car/screen/car_rent_home_screen.dart';
import '../car/screen/table_calendar_screen.dart';
import 'ChangePasswordScreen.dart';
import 'EditProfileScreen.dart';
import 'InquiryScreen.dart';
import 'MyPageScreen.dart';
import 'MyPostsScreen.dart';
import 'TestMainScreen.dart';
import 'SplashScreen.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});


  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        //임시 메인
        '/test_main':    (context) => const TestMainScreen(),

        '/mypage': (context) => const MyPageScreen(),
        '/edit_profile': (context) => const EditProfileScreen(name: '', phone: '',),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/my_posts': (context) => const MyPostsScreen(),
        '/inquiry': (context) => const InquiryScreen(),
        '/car_rent': (context) => const TableCalendarScreen(),
        '/car_rent_home': (context) => const CarRentHomeScreen(),


      },
    );
  }
}