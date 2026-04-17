import 'package:flutter/material.dart';

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '자유게시판';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // 아무것도 안 보냄 (취소)
        ),
        title: const Text('글쓰기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // 제목이나 내용이 비어있으면 등록 안 되게 막기
              if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
                );
                return;
              }

              // ⭐ 1. 입력된 데이터를 Map 형태로 만듭니다.
              final Map<String, String> newPost = {
                'category': _selectedCategory,
                'title': _titleController.text,
                'author': '박금동', // 현재 로그인한 사용자 이름 (더미)
                'date': '방금 전',
              };

              // ⭐ 2. 데이터를 인자로 실어서 이전 화면으로 돌아갑니다.
              Navigator.pop(context, newPost);
            },
            child: const Text('등록', style: TextStyle(color: Color(0xFF004680), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리 선택',
                border: OutlineInputBorder(),
              ),
              items: ['자유게시판', '여행후기', '질문답변']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextField(
              controller: _contentController,
              maxLines: 15,
              decoration: const InputDecoration(
                hintText: '내용을 입력하세요 (팁: 여행 후기는 사진과 함께 올리면 더 좋아요!)',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

