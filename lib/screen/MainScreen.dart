import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'MyPageScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<String> _imgList = [
    'assets/images/main_thumbnail5.png',
    'assets/images/main_thumbnail4.png',
    'assets/images/main_thumbnail2.png',
    'assets/images/main_thumbnail3.png',
    'assets/images/main_thumbnail1.png',
  ];

  @override
  void initState() {
    super.initState();
    // 이제 오류 없이 정상적으로 초기화 가능
    _pageController = PageController(initialPage: 5000);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            // 1. 상단 비주얼 배너 영역 (슬라이더)
            _buildHeaderImage(),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 2. 메인 카테고리 섹션
            _buildMainCategoryGrid(context),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 3. 서비스 메뉴 섹션
            _buildServiceMenuSection(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // 앱바 구성
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.asset(
        'assets/images/logo.png', // 로고 이미지 경로
        height: 30, // 로고 높이 조절 (앱바 크기에 맞춰 적절히 조정하세요)
        fit: BoxFit.contain, // 이미지가 비율을 유지하며 영역 안에 들어가도록 설정
        errorBuilder: (context, error, stackTrace) => const Text(
          '로고 없음', // 이미지를 로드할 수 없을 때 표시할 대체 텍스트
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text(
            '로그인/회원가입',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/search'),
        ),
      ],
    );
  }

  // 헤더 이미지 슬라이더
  Widget _buildHeaderImage() {
    return SizedBox(
      height: 230,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: 10000,
        itemBuilder: (context, index) {
          final itemIndex = index % _imgList.length;
          return Image.asset(
            _imgList[itemIndex],
            width: double.infinity,
            height: 230,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  // 메인 카테고리 그리드
  Widget _buildMainCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        children: [
          _buildCatItem(context, Icons.home_work, "숙소", '/hotel'),
          _buildCatItem(context, Icons.flight, "항공", '/flights'),
          _buildCatItem(context, Icons.directions_car, "렌터카", '/rent_car'),
          _buildCatItem(context, Icons.inventory_2, "패키지", '/package_list'),
        ],
      ),
    );
  }

  Widget _buildCatItem(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFFE61919), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // 서비스 메뉴 섹션
  Widget _buildServiceMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("✨ 추천 서비스",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildMenuButton(context, Icons.near_me, '지금 여기 (주변검색)', '/nearby'),
          _buildMenuButton(context, Icons.forum, '커뮤니티 (게시판)', '/community'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          side: BorderSide(color: Colors.grey[200]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(color: Colors.black87, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // ⭐ [최종 수정] 하단 네비게이션 바 로직
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFF7323F),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) async { // ⭐ async 추가
        if (index == 4) {
          // 1. 저장소에서 실시간 로그인 상태 확인
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          bool loginStatus = prefs.getBool('isLoggedIn') ?? false;

          if (loginStatus) {
            // 2. 로그인 성공 상태: 저장된 이름과 이메일 가지고 마이페이지 이동
            String name = prefs.getString('userName') ?? "사용자";
            String email = prefs.getString('userEmail') ?? "";

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPageScreen(userName: name, userEmail: email),
              ),
            );
          } else {
            // 3. 로그아웃 상태: 로그아웃 전용 화면으로 이동
            if (!mounted) return;
            Navigator.pushNamed(context, '/logout_mypage');
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "내주변"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "찜"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "내정보"),
      ],
    );
  }
}