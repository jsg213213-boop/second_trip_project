import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  // 1. 입력 필드를 제어하기 위한 컨트롤러
  final TextEditingController _commentController = TextEditingController();

  // 2. 댓글 데이터를 저장할 리스트 (더미 데이터 포함)
  final List<Map<String, String>> _comments = [
    {'author': '여행고수', 'content': '정보 감사합니다! 저도 이번 주말에 가보려구요.', 'date': '5분 전'},
    {'author': '금동이', 'content': '해운대 더베이 101 쪽이 진짜 명당이죠!', 'date': '2분 전'},
  ];

  // 3. 댓글 등록 함수
  void _addComment() {
    if (_commentController.text.trim().isEmpty) return; // 빈 내용 방지

    setState(() {
      // 새 댓글 데이터를 리스트 맨 뒤에 추가
      _comments.add({
        'author': '나(사용자)', // 실제로는 로그인 정보를 가져옵니다.
        'content': _commentController.text,
        'date': '방금 전',
      });
      _commentController.clear(); // 입력창 비우기
    });

    // 키보드 닫기 (선택 사항)
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> post =
    ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('게시글', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 게시글 본문 섹션 ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post['category']!,
                            style: const TextStyle(
                                color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(post['title']!,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const CircleAvatar(
                                radius: 15, child: Icon(Icons.person, size: 20)),
                            const SizedBox(width: 10),
                            Text(post['author']!,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 10),
                            Text(post['date']!,
                                style:
                                const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "여기에 게시글의 상세 내용이 들어갑니다. \n\n실제 데이터베이스(DB)와 연결되면 사용자가 작성한 글 내용을 불러와서 보여주게 됩니다. \n\n부산 해운대 야경은 정말 예쁘더라고요! 다들 꼭 가보세요.",
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ),

                  Container(height: 8, color: const Color(0xFFF5F5F5)),

                  // --- 댓글 리스트 영역 (갱신되는 부분) ---
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("댓글 ${_comments.length}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 20),
                        // 저장된 댓글 리스트를 순회하며 위젯 생성
                        ..._comments.map((comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildCommentItem(
                              comment['author']!,
                              comment['content']!,
                              comment['date']!),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 하단 댓글 입력창 (전송 기능 연결) ---
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String author, String content, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFE1E1E1),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(author,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(time,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _commentController, // 👈 컨트롤러 연결
                  decoration: const InputDecoration(
                    hintText: "댓글을 입력하세요...",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF004680)),
              onPressed: _addComment, // 👈 클릭 시 등록 함수 실행
            ),
          ],
        ),
      ),
    );
  }
}

