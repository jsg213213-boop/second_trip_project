import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MemberService {
  // 에뮬레이터 접속 주소 (실제 기기라면 PC IP로 바꿔야 해!)
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';

  // ⭐ 로그인: 성공 시 로컬 저장소에 상태 저장까지 완료!
  Future<Map<String, dynamic>?> login(String mid, String mpw) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/login'); // 경로 확인 필요!
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mid': mid, 'mpw': mpw}),
      );

      if (response.statusCode == 200) {
        // 1. 서버 응답 데이터 디코딩
        final Map<String, dynamic> userData = jsonDecode(utf8.decode(response.bodyBytes));

        // 2. ⭐ SharedPreferences에 로그인 정보 저장 (이게 핵심!)
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // "나 로그인했다!" 기록
        await prefs.setString('userMid', userData['mid'] ?? mid);
        await prefs.setString('userName', userData['mname'] ?? "사용자");
        await prefs.setString('userEmail', userData['email'] ?? "");

        // 만약 서버에서 토큰을 준다면 여기서 같이 저장하면 돼!
        // await prefs.setString('accessToken', userData['accessToken']);

        return userData;
      }
      return null;
    } catch (e) {
      print('로그인 에러: $e');
      return null;
    }
  }

  // ⭐ 회원가입: 서버에 유저 정보 전송
  Future<bool> register(Map<String, String> userData) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/register'); // 경로 수정!
      print("회원가입 요청 시도: $url"); // 로그 추가 (어디로 보내는지 확인)

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print("회원가입 응답 코드: ${response.statusCode}"); // 응답 코드 확인
      return response.statusCode == 200;
    } catch (e) {
      print('회원가입 에러: $e');
      return false;
    }
  }

  // ⭐ 로그아웃: 저장된 모든 정보 삭제
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // isLoggedIn을 포함한 모든 데이터를 날려버려!
    await prefs.clear();
    print("로그아웃 완료: 로컬 데이터 삭제됨");
  }

  // ⭐ 현재 로그인 상태인지 확인하는 함수 (MainScreen에서 쓰기 좋음)
  Future<bool> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}