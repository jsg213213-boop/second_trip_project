import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final Color classicBlue = const Color(0xFF004680);

  // 1. 게시글 데이터 (content 필드 추가)
  List<Map<String, String>> myPosts = [
    {'id': '1', 'title': '부산 해운대 바다 여행 후기 🌊', 'date': '2026.04.10', 'location': '부산 해운대구', 'image': 'https://picsum.photos/200', 'content': '해운대 바다는 언제 봐도 정말 예쁘네요!'},
    {'id': '2', 'title': '제주도 카페 투어 베스트 3 ☕', 'date': '2026.03.28', 'location': '제주 제주시', 'image': 'https://picsum.photos/201', 'content': '제주도 가면 꼭 가봐야 할 카페 리스트입니다.'},
    {'id': '3', 'title': '서울 경복궁 야간 개장 다녀왔어요', 'date': '2026.03.15', 'location': '서울 종로구', 'image': 'https://picsum.photos/202', 'content': '야간 개장 분위기가 너무 좋았어요.'},
  ];

  // 2. 댓글 데이터
  List<Map<String, String>> myComments = [
    {'id': '1', 'content': '와, 사진 너무 예뻐요! 정보 공유 감사합니다.', 'postTitle': '여수 밤바다 힐링 코스', 'date': '2026.04.12'},
    {'id': '2', 'content': '여기 주차장 자리 넉넉한가요?', 'postTitle': '경주 황리단길 맛집 공유', 'date': '2026.04.11'},
  ];

  // 3. 좋아요 데이터
  List<Map<String, String>> myLikes = [
    {'id': '1', 'title': '강원도 양양 서핑 명소 추천', 'author': '여행마스터', 'image': 'https://picsum.photos/203'},
    {'id': '2', 'title': '전주 한옥마을 한복 대여 꿀팁', 'author': '금동이친구', 'image': 'https://picsum.photos/204'},
  ];

  // --- 게시글 삭제 로직 (완전 삭제 확인) ---
  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('게시글 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말로 이 게시글을 완전히 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() { myPosts.removeAt(index); });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('게시글이 완전히 삭제되었습니다.'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 게시글 수정 로직 (바텀 시트 활용) ---
  void _editPost(int index) {
    final TextEditingController titleController = TextEditingController(text: myPosts[index]['title']);
    final TextEditingController contentController = TextEditingController(text: myPosts[index]['content']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('게시글 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: classicBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    myPosts[index]['title'] = titleController.text;
                    myPosts[index]['content'] = contentController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정이 완료되었습니다.')));
                },
                child: const Text('수정 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('내 활동 관리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          centerTitle: true,
          bottom: TabBar(
            labelColor: classicBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: classicBlue,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '게시글'),
              Tab(text: '댓글'),
              Tab(text: '좋아요'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPostTab(),
            _buildCommentTab(),
            _buildLikeTab(),
          ],
        ),
      ),
    );
  }

  // --- 탭별 화면 빌더 ---

  Widget _buildPostTab() {
    return myPosts.isEmpty
        ? _buildEmptyState('작성한 게시글이 없습니다.')
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPosts.length,
      itemBuilder: (context, index) => _buildPostCard(index),
    );
  }

  Widget _buildCommentTab() {
    return myComments.isEmpty
        ? _buildEmptyState('작성한 댓글이 없습니다.')
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myComments.length,
      itemBuilder: (context, index) {
        final comment = myComments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(comment['content']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('원문: ${comment['postTitle']} | ${comment['date']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),
            trailing: Icon(CupertinoIcons.trash, size: 18, color: Colors.grey[400]),
            onTap: () {
              // 댓글 삭제 로직도 필요하면 여기에 추가!
            },
          ),
        );
      },
    );
  }

  Widget _buildLikeTab() {
    return myLikes.isEmpty
        ? _buildEmptyState('좋아요한 글이 없습니다.')
        : GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: myLikes.length,
      itemBuilder: (context, index) {
        final like = myLikes[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(like['image']!),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(like['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('by ${like['author']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  const Icon(CupertinoIcons.heart_fill, color: Colors.redAccent, size: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 위젯 부품들 ---

  Widget _buildPostCard(int index) {
    final post = myPosts[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post['image']!, height: 140, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(post['location']!, style: TextStyle(color: classicBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(post['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(post['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // 수정 버튼 디자인 개선
                      _buildFlatActionBtn(CupertinoIcons.pencil, '수정', () => _editPost(index)),
                      const SizedBox(width: 20),
                      // 삭제 버튼 디자인 개선
                      _buildFlatActionBtn(CupertinoIcons.trash, '삭제', () => _deletePost(index), color: Colors.redAccent),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatActionBtn(IconData icon, String label, VoidCallback onTap, {Color color = Colors.black54}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.square_list, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}