import 'package:flutter/material.dart';
import 'dart:async';
import '../services/member_service.dart';
import 'MyPageScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  // 로그인 상태와 사용자 정보를 담을 변수
  bool isLoggedIn = false;
  String userName = "";
  String userEmail = "";
  String userPhone = ""; // ⭐ 전화번호 변수 추가

  final MemberService _memberService = MemberService();

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
    _pageController = PageController(initialPage: 5000);
    _checkLoginStatus();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ⭐ 저장소에서 로그인 정보를 가져와 화면을 갱신하는 함수
  Future<void> _checkLoginStatus() async {
    final bool status = await _memberService.checkLoginStatus();
    final userInfo = await _memberService.getUserInfo();

    setState(() {
      isLoggedIn = status;
      userName = userInfo['name'] ?? "";
      userEmail = userInfo['email'] ?? "";
      userPhone = userInfo['phone'] ?? "010-0000-0000"; // ⭐ 번호가 없으면 기본값 설정
    });

    print("현재 로그인 상태 체크: $isLoggedIn / 번호: $userPhone");
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
            _buildHeaderImage(),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            _buildMainCategoryGrid(context),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            _buildServiceMenuSection(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.asset(
        'assets/images/logo.png',
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Text(
          'Travel-Hub',
          style: TextStyle(color: Color(0xFFF7323F), fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        isLoggedIn
            ? Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              '$userName님, 안녕하세요!',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        )
            : TextButton(
          onPressed: () async {
            await Navigator.pushNamed(context, '/login');
            _checkLoginStatus();
          },
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
          );
        },
      ),
    );
  }

  Widget _buildMainCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        children: [
          _buildCatItem(context, Icons.home_work, "숙소", '/hotel'),
          _buildCatItem(context, Icons.flight, "항공", '/airport'),
          _buildCatItem(context, Icons.directions_car, "렌터카", '/car_rent_home'),
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
              color: const Color(0xFFF7323F).withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFFF7323F), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildServiceMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("추천 서비스", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  // ⭐ 하단 네비게이션 로직 수정
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFF7323F),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) async {
        if (index == 1) {
          Navigator.pushNamed(context, '/search');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/nearby');
        } else if (index == 3) {
          // ⭐ 내 정보 클릭 시 동작
          final bool status = await _memberService.checkLoginStatus();

          if (status) {
            final userInfo = await _memberService.getUserInfo();
            if (!mounted) return;

            // ⭐ MyPageScreen으로 진짜 정보를 다 넘겨줌!
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPageScreen(
                    userName: userInfo['name'] ?? "사용자",
                    userEmail: userInfo['email'] ?? "",
                    userPhone: userInfo['phone'] ?? "010-0000-0000" // 👈 여기!
                ),
              ),
            );
          } else {
            if (!mounted) return;
            await Navigator.pushNamed(context, '/logout_mypage');
          }
          _checkLoginStatus(); // 마이페이지에서 돌아왔을 때 메인 정보 최신화
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: "내 주변"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "내 정보"),
      ],
    );
  }
}