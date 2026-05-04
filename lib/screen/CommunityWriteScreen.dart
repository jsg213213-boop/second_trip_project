import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 dotenv 추가

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}



class _CommunityWriteScreenState extends State<CommunityWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _submitPost() async {
    try {
      // 1. .env에서 값을 가져옵니다.
      final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

      // 2. http 프로토콜 자동 확인 및 붙이기
      String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

      // 3. 포트(:8080) 확인 및 붙이기
      if (!baseUrl.contains(':8080')) {
        baseUrl = '$baseUrl:8080';
      }

      // 4. 슬래시(/) 처리를 고려하여 최종 URL 조합 (글 등록 경로: /community/register)
      final String finalUrl = baseUrl.endsWith('/')
          ? '${baseUrl}community/register'
          : '$baseUrl/community/register';

      // 5. Dio 요청 실행
      final dio = Dio();
      final response = await dio.post(
        finalUrl,
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
    // ... 기존 build 위젯 코드는 그대로 유지
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
                hintText: '내용을 입력하세요',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}