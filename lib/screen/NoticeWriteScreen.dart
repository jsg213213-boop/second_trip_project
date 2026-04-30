import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 추가
import 'package:second_trip_project/util/secure_storage_helper.dart';

class NoticeWriteScreen extends StatefulWidget {
  const NoticeWriteScreen({super.key});

  @override
  State<NoticeWriteScreen> createState() => _NoticeWriteScreenState();
}




class _NoticeWriteScreenState extends State<NoticeWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _storage = SecureStorageHelper();
  bool _isLoading = false;

  Future<void> _submitNotice() async {
    final String? token = await _storage.getAccessToken();

    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해주세요.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 💡 1. .env에서 값을 가져옵니다.
      final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

      // 💡 2. http 프로토콜 확인 및 붙이기
      String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

      // 💡 3. 포트(:8080) 확인 및 붙이기
      if (!baseUrl.contains(':8080')) {
        baseUrl = '$baseUrl:8080';
      }

      // 💡 4. 공지사항 등록용 최종 URL 조합
      final String finalUrl = baseUrl.endsWith('/')
          ? '${baseUrl}api/notices'
          : '$baseUrl/api/notices';

      // 💡 5. 요청 실행
      final response = await http.post(
        Uri.parse(finalUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "title": _titleController.text.trim(),
          "content": _contentController.text.trim(),
        }),
      );

      debugPrint("=== [디버그] 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception('응답 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("=== [디버그] 등록 에러: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항 작성')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용', border: OutlineInputBorder()),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitNotice,
                child: const Text('등록 완료'),
              ),
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