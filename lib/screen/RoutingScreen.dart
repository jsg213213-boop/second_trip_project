import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_trip_project/car/controller/car_rent_home_controller.dart';
import 'package:second_trip_project/car/service/car_rent_home_service.dart';

// [팀원별 실제 화면 Import]
// 렌터카 파트 (태흔님)
import '../airport/screen/my_reservation_screen.dart';
import '../airport/screen/search_screen.dart';
import '../car/controller/calendar_controller.dart';
import '../car/controller/car_rent_list_controller.dart';
import '../car/screen/car_rent_home_screen.dart';
import '../car/screen/calendar_screen.dart';
import '../car/service/car_rent_list_service.dart';

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
import 'LogoutMyPageScreen.dart';
import 'WishlistScreen.dart';

//공지사항 및 검색(재현)

import 'package:second_trip_project/screen/TotalSearchScreen.dart';

import 'package:second_trip_project/screen/CommunityDetailScreen.dart';
import 'package:second_trip_project/screen/CommunityScreen.dart';
import 'package:second_trip_project/screen/CommunityWriteScreen.dart';
import 'package:second_trip_project/screen/NoticeDetailScreen.dart';
import 'package:second_trip_project/screen/NoticeListScreen.dart';


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
        '/logout_mypage': (context) => const LogoutMyPageScreen(),
        '/favorite': (context) => const WishlistScreen(), // 찜 목록 경로 추가
        '/mypage': (context) => const MyPageScreen(userName: '사용자', userEmail: '', userPhone: '', userRole: '',),
        '/edit_profile': (context) => const EditProfileScreen(name: '', phone: ''),

        '/change_password': (context) => const ChangePasswordScreen(),
        '/my_posts': (context) => const MyPostsScreen(),
        '/inquiry': (context) => const InquiryScreen(),

        // [렌터카 - 태흔님]
        '/car_rent_home': (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CarRentHomeController()),
            ChangeNotifierProvider(create: (_) => CalendarController()),
            ChangeNotifierProvider(create: (_) => CarRentListController(service: CarRentListService())),
          ],
          child: const CarRentHomeScreen(),
        ),

        // 검색 화면 경로 등록
        '/search': (context) => const TotalSearchScreen(),

        // 공지사항및 게시판
        '/notice': (context) => const NoticeListScreen(),
        '/notice_detail': (context) => const NoticeDetailScreen(),
        '/community': (context) => const CommunityScreen(),
        '/community_detail': (context) => const CommunityDetailScreen(),
        '/community_write': (context) => const CommunityWriteScreen(),

        // [숙소 - 재욱님]
        '/hotel': (context) => const AccommodationListScreen(),
        '/motel': (context) => const AccommodationListScreen(),

        // [패키지 - 진주님]
        '/package_list': (context) => const PackageListScreen(),

        // [항공 - 황혜은]
        '/airport':    (context) => const SearchScreen(),
        '/myairport':    (context) => const MyReservationScreen(),
      },
    );
  }
}