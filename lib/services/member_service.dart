import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MemberService {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';

  // ⭐ 1. 이메일 중복 확인
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      // 인텔리제이 컨트롤러 주소와 정확히 일치시킴
      final url = Uri.parse('$baseUrl/api/member/exists/$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 서버에서 온 true/false 글자를 불리언 타입으로 변환
        return jsonDecode(response.body) == true;
      }
      return false;
    } catch (e) {
      print('중복 확인 에러: $e');
      return true; // 에러 시 안전하게 가입 방지용으로 true 리턴
    }
  }

  // ⭐ 2. 로그인 기능
  Future<Map<String, dynamic>?> login(String mid, String mpw) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mid': mid, 'mpw': mpw}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(utf8.decode(response.bodyBytes));
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userMid', userData['mid'] ?? mid);
        await prefs.setString('userName', userData['mname'] ?? "사용자");
        await prefs.setString('userEmail', userData['email'] ?? "");

        if (userData['accessToken'] != null) {
          await prefs.setString('accessToken', userData['accessToken']);
        }
        if (userData['refreshToken'] != null) {
          await prefs.setString('refreshToken', userData['refreshToken']);
        }

        print("✅ 로그인 성공!");
        return userData;
      }
      return null;
    } catch (e) {
      print('로그인 에러: $e');
      return null;
    }
  }

  // ⭐ 3. 로그아웃
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("로그아웃 완료");
  }

  // ⭐ 4. 로그인 상태 체크
  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ⭐ 5. 회원가입 전송 함수
  Future<bool> register(Map<String, String> userData) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ 서버에 회원가입 데이터 전송 성공!");
        return true;
      } else {
        print("❌ 서버 에러: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('회원가입 통신 에러: $e');
      return false;
    }
  }
}