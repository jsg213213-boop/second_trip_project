
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../basic3-http/_1_dummyJson/screens/dummy_user_screen.dart';
import '../basic3-http/_2_reqres/screen/reqres_screen.dart';
import 'AccordionNavScreen.dart';
import 'DetailsScreen.dart';
import 'LoginScreen2.dart';
import 'MainScreen.dart';
import 'SignupScreen.dart';
import 'SplashScreen.dart';
import 'TabBarScreen.dart';
import 'ViewPagerScreen.dart';

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/main':    (context) => const MainScreen(),
        '/signup':  (context) => const SignupScreen(),
        '/login':   (context) => const LoginScreen2(),
        '/details': (context) => const DetailsScreen(),
        // 탭 메뉴 화면 추가.
        '/tabMenuTest': (context) => const TabBarScreen(),
        '/viewPagerTest': (context) => const PageViewScreen(),
        '/drawerNaviTest': (context) => const AccordionNavScreen(),
        // API 서버 호출 테스트
        '/reqresTest': (context) => const ReqresScreen(),
        '/dummyTest': (context) => const DummyUserScreen(),
        // 상세 화면 이동 라우팅 추가, /dummyDetailScreen -> 파라미터 , 유저 정보를 주입해야해서,
        // '/dummyDetailScreen': (context) => const DummyUserDetailScreen(user: user),
        '/newsTest': (context) => const NewsScreen(),
        '/publicDataTest': (context) => const PublicDataScreen(),
        '/providerTest': (context) => const CounterScreen(),
        '/providerTestPdTest': (context) => const MyPdTestScreen(),
        '/providerTestPdTest2': (context) => const TourScreen(),
        '/providerTestPdTest3': (context) => const TourScreen2(),
        '/mapBasic1': (context) => const LocationScreen(),
        '/mapBasic2': (context) => const LocationScreen2(),
        '/mapBasic3': (context) => const MapScreen(),
        '/mapBasic4': (context) => const MapScreen2(),
        '/dbTest1': (context) => const DbBasicScreen(),
        '/dbTest2': (context) => const TodoScreen(),



      },
    );
  }
}