import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 1. 현재 어떤 탭이 선택되었는지 저장하는 변수
  String selectedTab = '전체';

  // 2. 상단에 보여줄 카테고리 이름들
  final List<String> categories = ['전체', '자유게시판', '여행후기', '질문답변'];

  // 3. 실제 전체 데이터 리스트 (나중에 서버 연동 시 이 데이터가 서버에서 옵니다)
  final List<Map<String, String>> allPosts = [
    {'category': '여행후기', 'title': '부산 해운대 야경 명소 추천!', 'author': '여행가A'},
    {'category': '자유게시판', 'title': '이번 주말 경주 날씨 어때요?', 'author': '금동이'},
    {'category': '질문답변', 'title': '일본 비자 발급 질문입니다.', 'author': '초보자'},
    {'category': '여행후기', 'title': '도쿄 신주쿠 맛집 리스트 공유', 'author': '미식가'},
  ];

  @override
  Widget build(BuildContext context) {
    // 🔥 핵심 로직: 현재 선택된 탭에 맞는 글만 골라내기 (필터링)
    final filteredPosts = selectedTab == '전체'
        ? allPosts
        : allPosts.where((post) => post['category'] == selectedTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 상단 탭 영역 ---
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildTabItem(categories[index]);
              },
            ),
          ),

          // --- 게시글 리스트 영역 (필터링된 결과만 보여줌) ---
          Expanded(
            child: ListView.separated(
              itemCount: filteredPosts.length,
              // 항목 사이에 선을 그어주는 부분 (border 대신 사용)
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(filteredPosts[index]['title']!),
                  subtitle: Text("${filteredPosts[index]['category']} | ${filteredPosts[index]['author']}"),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // CommunityWriteScreen으로 연결 예정
        backgroundColor: const Color(0xFF004A7C),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // 탭 버튼 만드는 함수 (클릭 시 setState로 화면 갱신)
  Widget _buildTabItem(String label) {
    bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label; // 👈 탭을 누르면 선택된 값을 바꾸고 화면을 다시 그림!
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004A7C) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}