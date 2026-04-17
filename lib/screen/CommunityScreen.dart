import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// ⭐ 1. 데이터 변경을 화면에 반영하기 위해 StatefulWidget으로 변경했습니다.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // ⭐ 2. 'const'를 제거하고 변수로 선언하여 리스트 수정이 가능하게 만들었습니다.
  final List<Map<String, String>> posts = [
    {'category': '여행후기', 'title': '부산 해운대 야경 명소 추천합니다!', 'author': '여행가A', 'date': '10분 전'},
    {'category': '자유게시판', 'title': '이번 주말에 경주 가시는 분 계신가요?', 'author': '금동이', 'date': '30분 전'},
    {'category': '질문답변', 'title': '일본 여행 비자 발급 얼마나 걸리나요?', 'author': '초보여행', 'date': '1시간 전'},
    {'category': '여행후기', 'title': '도쿄 신주쿠 맛집 리스트 공유해요.', 'author': '미식가', 'date': '3시간 전'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('커뮤니티', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 카테고리 탭 (상단)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('전체', isSelected: true),
                  _buildCategoryChip('자유게시판'),
                  _buildCategoryChip('여행후기'),
                  _buildCategoryChip('질문답변'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // 게시글 리스트
          Expanded(
            child: ListView.separated(
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post['category']!,
                          style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post['title']!,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${post['author']}  •  ${post['date']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/community_detail',
                      arguments: post,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // 글쓰기 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ⭐ 3. 글쓰기 화면으로 이동하고, 반환되는 데이터를 기다립니다.
          final result = await Navigator.pushNamed(context, '/community_write');

          // ⭐ 4. 새 게시글 데이터가 넘어왔다면 리스트에 추가하고 화면을 갱신합니다.
          if (result != null && result is Map<String, String>) {
            setState(() {
              posts.insert(0, result); // 새 글을 리스트의 가장 맨 위(0번 인덱스)에 추가
            });
          }
        },
        backgroundColor: const Color(0xFF004680),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF004680) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

