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

  // ⭐ 로그인 상태와 사용자 이름을 담을 변수
  bool isLoggedIn = false;
  String userName = "";

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
    _checkLoginStatus(); // ⭐ 앱 시작 시 로그인 상태 확인

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

  // ⭐ 저장소에서 로그인 정보를 가져와 화면을 갱신하는 함수
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userName = prefs.getString('userName') ?? "";
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

  // ⭐ 앱바 구성 (로그인 상태 반영)
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
        // 💡 로그인 상태에 따라 다른 위젯 표시
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
            // 로그인 화면에 갔다 오면 상태를 다시 체크함
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
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
            ),
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
          const Text("추천 서비스",
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFF7323F),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,

      onTap: (index) async {
        if (index == 0) {
          // 홈 버튼 클릭 시 로직 (필요 시)
        } else if (index == 1) {
          Navigator.pushNamed(context, '/search');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/nearby');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/favorite');
        } else if (index == 4) {


          final SharedPreferences prefs = await SharedPreferences.getInstance();
          bool loginStatus = prefs.getBool('isLoggedIn') ?? false;

          if (loginStatus) {
            String name = prefs.getString('userName') ?? "사용자";
            String email = prefs.getString('userEmail') ?? "";

            if (!mounted) return;
            // 마이페이지에 갔다가 돌아올 때도 상단 앱바 갱신을 위해 await 사용
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPageScreen(userName: name, userEmail: email),
              ),
            );
            _checkLoginStatus(); // 로그아웃하고 돌아올 수도 있으니 다시 체크!
          } else {
            if (!mounted) return;
            await Navigator.pushNamed(context, '/logout_mypage');
            _checkLoginStatus();
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