import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // 2. 서버로 데이터를 보내는 함수 (카테고리 필드 제거)
  Future<void> _submitPost() async {
    final dio = Dio();
    final String url = 'http://10.0.2.2:8080/community/register';

    try {
      final response = await dio.post(
        url,
        data: {
          'title': _titleController.text,
          'content': _contentController.text,
          'mid': 'testuser',
        },
      );

      if (response.statusCode == 200) {
        print('서버 전송 성공!');
        if (mounted) Navigator.pop(context, true);
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
            // 💡 DropdownButtonFormField 위젯을 삭제했습니다.
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