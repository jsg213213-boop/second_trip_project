import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '여기어때',
          style: TextStyle(color: Color(0xFFE61919), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("로그인 / 회원가입", style: TextStyle(color: Colors.blue, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // [상단] 카테고리 그리드 메뉴 (왼쪽 사진 내용)
            _buildCategoryGrid(context),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // [하단] 상세 섹션들 (오른쪽 사진 내용)

            // 1. 최근에 본 상품
            _buildHorizontalSection("최근에 본 상품", [
              _buildLargeCard("국내 숙소", "★당일특가★...", "assets/images/recent1.png"),
            ]),

            // 이벤트 배너
            _buildEventBanner(),

            // 2. 미리 준비하는 공휴일
            _buildHorizontalSection("미리 준비하는 공휴일", [
              _buildProductCard("강릉", "세인트존스 호텔", "58,400원", true),
              _buildProductCard("서울", "시그니엘 서울", "456,500원", true),
            ]),

            // 3. 오늘 체크인 호텔특가
            _buildHorizontalSection("오늘 체크인 호텔특가", [
              _buildProductCard("부산", "해운대 호텔", "88,900원", false),
              _buildProductCard("제주", "서귀포 리조트", "112,400원", false),
            ]),

            // 4. 요즘 많이 찾는 펜션
            _buildHorizontalSection("요즘 많이 찾는 펜션", [
              _buildProductCard("가평", "럭셔리 풀빌라", "280,000원", false),
              _buildProductCard("포천", "숲속 글램핑", "120,000원", true),
            ]),

            // 5. 해외인기 도시 TOP6
            _buildHorizontalSection("해외인기 도시 TOP6", [
              _buildRankingCard("1", "오사카", "일본"),
              _buildRankingCard("2", "도쿄", "일본"),
              _buildRankingCard("3", "방콕", "태국"),
              _buildRankingCard("4", "다낭", "베트남"),
              _buildRankingCard("5", "후쿠오카", "일본"),
              _buildRankingCard("6", "타이베이", "대만"),
            ]),

            // 6. 해외 항공+숙소 특가
            _buildHorizontalSection("해외 항공+숙소 특가", [
              _buildProductCard("세부", "제이파크 리조트", "350,000원", true),
              _buildProductCard("코타키나발루", "샹그릴라", "420,000원", true),
            ]),

            // 7. 지금 여기
            _buildHorizontalSection("지금 여기", [
              _buildLargeCard("벚꽃 축제", "벚꽃 명소 베스트", "assets/images/cherry.png"),
              _buildLargeCard("서울 여행", "궁궐 야간 개장", "assets/images/palace.png"),
            ]),

            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- 위젯 구성 함수들 ---

  // 1. 상단 카테고리 그리드 (제외 항목 반영 및 색상 적용)
  Widget _buildCategoryGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 25,
        crossAxisSpacing: 10,
        children: [
          _buildMenuIcon(context, Icons.apartment, "호텔·리조트", const Color(0xFF424242), '/hotel'),
          _buildMenuIcon(context, Icons.hotel, "모텔", const Color(0xFFFF5252), '/motel'),
          _buildMenuIcon(context, Icons.pool, "펜션·풀빌라", const Color(0xFF40C4FF), '/pension'),
          _buildMenuIcon(context, Icons.terrain, "캠핑·글램핑", const Color(0xFF4CAF50), '/camping'),
          _buildMenuIcon(context, Icons.home_work, "홈&빌라", const Color(0xFFFF8A65), '/villa'),
          _buildMenuIcon(context, Icons.bed, "게하·한옥", const Color(0xFF8D6E63), '/guesthouse'),
          _buildMenuIcon(context, Icons.directions_car, "렌터카", const Color(0xFFFF5252), '/rentcar'),
          _buildMenuIcon(context, Icons.card_travel, "패키지 여행", const Color(0xFFFFAB40), '/package'),
          _buildMenuIcon(context, Icons.airplane_ticket, "항공+숙소", const Color(0xFF448AFF), '/flightHotel'),
          _buildMenuIcon(context, Icons.flight, "항공", const Color(0xFFFF5252), '/flight'),
        ],
      ),
    );
  }

  // 2. 공통 섹션 레이아웃 (제목 + 가로 리스트)
  Widget _buildHorizontalSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            children: items,
          ),
        ),
      ],
    );
  }

  // 3. 상품 카드 위젯
  Widget _buildProductCard(String location, String name, String price, bool isSale) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Icon(Icons.image, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(price, style: TextStyle(color: isSale ? Colors.red : Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 4. 순위 정보가 있는 카드 위젯 (해외인기 도시용)
  Widget _buildRankingCard(String rank, String city, String country) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          ),
          Positioned(
            top: 5, left: 10,
            child: Text(rank, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontStyle: FontStyle.italic, shadows: [Shadow(blurRadius: 2, color: Colors.black45)])),
          ),
          Positioned(
            bottom: 10, left: 10,
            child: Text("$city\n$country", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // 5. 큰 썸네일 카드 위젯 (최근 본 상품, 지금 여기용)
  Widget _buildLargeCard(String tag, String title, String imgPath) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          Text(tag, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
        ],
      ),
    );
  }

  // 6. 메뉴 아이콘 빌더
  Widget _buildMenuIcon(BuildContext context, IconData icon, String label, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // 7. 이벤트 배너
  Widget _buildEventBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 80,
      decoration: BoxDecoration(color: Colors.pink[50], borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Text("최대 10% 할인 국내숙소 쿠폰팩", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // 8. 하단 내비게이션 바
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: "혜택 모음"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "검색"),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: "주변"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "찜 목록"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "내 정보"),
      ],
    );
  }
}