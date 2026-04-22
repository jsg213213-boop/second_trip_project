import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// [중요] 사용하시는 토큰 조회 로직이 담긴 파일 import
// import '토큰파일경로.dart';

class NoticeWriteScreen extends StatefulWidget {
  const NoticeWriteScreen({super.key});

  @override
  State<NoticeWriteScreen> createState() => _NoticeWriteScreenState();
}

class _NoticeWriteScreenState extends State<NoticeWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  // 여기에 실제 사용 중인 토큰 조회 함수 내용을 가져오세요.
  Future<String?> getAccessToken() async {
    // 예시: 저장된 토큰을 읽어오는 로직
    return null;
  }

  Future<void> _submitNotice() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? token = await getAccessToken(); // 1. 토큰 조회

      // [디버그 로그]
      print("=== [디버그] 조회된 토큰 값: $token");
      print("=== [디버그] 요청 주소: http://10.0.2.2:8080/api/notices");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/notices'),
        headers: {
          'Content-Type': 'application/json',
          // if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'content': _contentController.text,
        }),
      );

      // [디버그 로그] 서버 응답 확인
      print("=== [디버그] 응답 상태코드: ${response.statusCode}");
      print("=== [디버그] 응답 바디: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print("=== [디버그] 에러 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항 작성')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()), maxLines: 10),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(onPressed: _submitNotice, child: const Text('등록 완료')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
