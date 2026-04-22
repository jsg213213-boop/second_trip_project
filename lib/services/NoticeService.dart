import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeService {
  final String baseUrl = "http://YOUR_SERVER_IP:8080"; // 서버 주소

  // 1. 공지사항 불러오기 (GET)
  Future<List<dynamic>> fetchNotices() async {
    final response = await http.get(Uri.parse('$baseUrl/api/notices'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // 한글 깨짐 방지
    } else {
      throw Exception('불러오기 실패');
    }
  }

  // 2. 공지사항 등록하기 (POST)
  Future<void> writeNotice(String title, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/notices'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "content": content}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('등록 실패');
    }
  }
}
