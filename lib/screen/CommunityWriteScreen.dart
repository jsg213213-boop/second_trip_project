import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // 1. Dio 패키지 추가

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '자유게시판';

  // 2. 서버로 데이터를 보내는 함수
  Future<void> _submitPost() async {
    final dio = Dio();
    // 에뮬레이터에서 내 컴퓨터 백엔드에 접근할 때는 10.0.2.2를 사용합니다.
    final String url = 'http://10.0.2.2:8080/community/register';

    try {
      final response = await dio.post(
        url,
        data: {
          'title': _titleController.text,
          'content': _contentController.text,
          'mid': 'testuser', // 백엔드에서 받는 필드명과 일치시켜야 합니다.
        },
      );

      if (response.statusCode == 200) {
        print('서버 전송 성공!');
        if (mounted) Navigator.pop(context, true); // 성공 시 화면 닫기
      }
    } catch (e) {
      print('서버 전송 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 전송에 실패했습니다.')),
        );
      }
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('글쓰기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
                );
                return;
              }
              // 3. 기존 Navigator.pop 대신 서버 전송 함수 호출
              _submitPost();
            },
            child: const Text('등록', style: TextStyle(color: Color(0xFFF7323F), fontWeight: FontWeight.bold, fontSize: 16)),
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