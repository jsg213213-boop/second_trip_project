import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            // 1. 상단 비주얼 배너 영역
            _buildHeaderImage(),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 2. 메인 카테고리 섹션 (숙소, 항공, 패키지, 렌터카)
            _buildMainCategoryGrid(context),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 3. 서비스 메뉴 섹션 (재현님 담당 파트 중심)
            _buildServiceMenuSection(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // 앱바 구성: 로그인/회원가입 버튼 추가
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        '여기어때',
        style: TextStyle(
          color: Color(0xFFE61919),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        // 상단 로그인/회원가입 버튼 (지효님 파트 연결)
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text(
            '로그인/회원가입',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
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

  // 헤더 이미지
  Widget _buildHeaderImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 50, color: Colors.grey),
                Text("이미지를 찾을 수 없습니다", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 메인 카테고리 그리드 (숙소, 항공, 패키지, 렌터카)
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
          _buildCatItem(context, Icons.inventory_2, "패키지", '/package_list'),
          _buildCatItem(context, Icons.directions_car, "렌터카", '/rent_car'),
        ],
      ),
    );
  }

  // 카테고리 아이템 빌더
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

  // 서비스 메뉴 섹션 (재현님 파트)
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

  // 메뉴 버튼 빌더
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

  // 하단 네비게이션 바
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE61919),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 4) {
          Navigator.pushNamed(context, '/mypage');
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