import 'package:flutter/material.dart';
// ⚠️ 주의: CommunityWriteScreen.dart 파일의 실제 경로가 다르면 수정이 필요할 수 있습니다.
import 'package:second_trip_project/screen/CommunityWriteScreen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 1. 현재 어떤 탭이 선택되었는지 저장
  String selectedTab = '전체';

  // 2. 상단 카테고리 목록
  final List<String> categories = ['전체', '자유게시판', '여행후기', '질문답변'];

  // 3. 샘플 데이터 (나중에 서버 연동 시 데이터 구조에 맞춰 수정하세요)
  final List<Map<String, String>> allPosts = [
    {'category': '여행후기', 'title': '부산 해운대 야경 명소 추천!', 'author': '여행가A'},
    {'category': '자유게시판', 'title': '이번 주말 경주 날씨 어때요?', 'author': '금동이'},
    {'category': '질문답변', 'title': '일본 비자 발급 질문입니다.', 'author': '초보자'},
    {'category': '여행후기', 'title': '도쿄 신주쿠 맛집 리스트 공유', 'author': '미식가'},
  ];

  @override
  Widget build(BuildContext context) {
    // 🔥 필터링 로직: 선택된 탭에 맞는 글만 추출
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
          // --- 상단 카테고리 탭 영역 ---
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

          // --- 게시글 리스트 영역 ---
          Expanded(
            child: ListView.separated(
              itemCount: filteredPosts.length,
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
      // --- 글쓰기 버튼 (이제 정상 작동합니다) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ⭐ Navigator.push 앞에 'final newPost = await'를 붙여서 결과값을 기다립니다.
          final newPost = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityWriteScreen(),
            ),
          );

          // ⭐ 만약 돌아온 데이터(newPost)가 있다면 리스트에 추가합니다.
          if (newPost != null && newPost is Map<String, String>) {
            setState(() {
              // allPosts 리스트의 맨 앞에 추가 (최신글이 위로 오게)
              allPosts.insert(0, newPost);
            });

            // 등록 완료 알림 (선택사항)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('게시글이 등록되었습니다.')),
            );
          }
        },
        backgroundColor: const Color(0xFF004A7C),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // 탭 버튼 위젯 빌더
  Widget _buildTabItem(String label) {
    bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = label; // 선택 시 화면 갱신 및 필터링 적용
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