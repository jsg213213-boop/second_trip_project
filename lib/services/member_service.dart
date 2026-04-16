import 'dart:convert';
import 'package:http/http.dart' as http;

class MemberService {
  // 네 컴퓨터 IP나 localhost 주소! (에뮬레이터는 10.0.2.2를 써야 할 수도 있어)
  static const String baseUrl = 'http://10.0.2.2:8080/api/member';

  // 로그인 함수
  Future<bool> login(String mid, String mpw) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mid': mid, 'mpw': mpw}),
    );

    if (response.statusCode == 200) {
      print('로그인 성공: ${response.body}');
      return true;
    } else {
      print('로그인 실패: ${response.statusCode}');
      return false;
    }
  }
}