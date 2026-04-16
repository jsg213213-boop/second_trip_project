import 'package:flutter/material.dart';

// [팀원별 실제 화면 Import]
// 렌터카 파트 (태흔님)
import '../car/screen/car_rent_home_screen.dart';
import '../car/screen/table_calendar_screen.dart';

// 숙소 파트 (재욱님)
import '../loging/screens/list/accommodation_list_screen.dart';

// 패키지 파트 (진주님)
import '../package/screen/package_list_screen.dart';

// 유저 및 공통 화면 (성규님 & 지효님)
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
        // [공통 및 유저]
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/edit_profile': (context) => const EditProfileScreen(name: '', phone: ''),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/my_posts': (context) => const MyPostsScreen(),
        '/inquiry': (context) => const InquiryScreen(),

        // [렌터카 - 태흔님]
        '/rent_car': (context) => const CarRentHomeScreen(),    // 메인 버튼 연결용
        '/car_calendar': (context) => const TableCalendarScreen(),

        // [숙소 - 재욱님]
        '/hotel': (context) => const AccommodationListScreen(),
        '/motel': (context) => const AccommodationListScreen(),

        // [패키지 - 진주님]
        '/package_list': (context) => const PackageListScreen(),
      },
    );
  }
}