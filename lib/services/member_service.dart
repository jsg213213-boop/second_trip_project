import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../util/secure_storage_helper.dart';

class MemberService {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    return (url == null || url.isEmpty) ? 'http://10.0.2.2:8080' : url;
  }

  final _storage = SecureStorageHelper();

  // ─── 이메일 중복 확인 ─────────────────────────────
  Future<bool> checkEmailDuplicate(String email) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/exists/$email');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) == true;
      }
      return false;
    } catch (e) {
      print('중복 확인 에러: $e');
      return true;
    }
  }

  // ─── 로그인 (Role 저장 로직 추가) ──────────────────────────
  Future<Map<String, dynamic>?> login(String mid, String mpw) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mid': mid, 'mpw': mpw}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData =
        jsonDecode(utf8.decode(response.bodyBytes));

        // ⭐ 수정: 서버에서 받은 Role 정보를 포함하여 저장
        // 서버 응답 JSON에 'role' 혹은 'roleNames' 등의 필드가 있는지 확인해봐!
        await _storage.saveUserInfo(
          mid: userData['mid'] ?? mid,
          name: userData['mname'] ?? '사용자',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          role: userData['role'] ?? 'USER', // 👈 권한 정보 저장 (기본값 USER)
        );

        // 토큰 저장
        if (userData['accessToken'] != null) {
          await _storage.saveAccessToken(userData['accessToken']);
        }
        if (userData['refreshToken'] != null) {
          await _storage.saveRefreshToken(userData['refreshToken']);
        }

        return userData;
      }
      return null;
    } catch (e) {
      print('로그인 에러: $e');
      return null;
    }
  }

  // ─── 회원 정보 수정 (Role 동기화 유지) ──────────────────────────
  Future<bool> updateMember(Map<String, String> updateData) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/modify');
      final token = await _storage.getAccessToken();

      String? currentMid = await _storage.getUserMid();
      if (currentMid != null) {
        updateData['mid'] = currentMid;
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ DB 업데이트 성공!");

        String currentEmail = await _storage.getUserEmail() ?? "";
        String? currentRole = await _storage.getUserRole(); // 기존 권한 유지

        await _storage.saveUserInfo(
          mid: currentMid ?? "",
          name: updateData['mname'] ?? "",
          email: currentEmail,
          phone: updateData['phone'] ?? "",
          role: currentRole ?? "USER", // 👈 권한 정보 유지
        );

        return true;
      } else {
        print("❌ 업데이트 실패: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print('업데이트 에러: $e');
      return false;
    }
  }

  // ─── 로그아웃 ─────────────────────────────────────
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _storage.logout();
    print("로그아웃 완료: 전체 데이터 삭제됨");
  }

  // ─── 로그인 상태 체크 ─────────────────────────────
  Future<bool> checkLoginStatus() async {
    return await _storage.isLoggedIn();
  }

  // ─── 회원가입 ─────────────────────────────────────
  Future<bool> register(Map<String, String> userData) async {
    try {
      final url = Uri.parse('$baseUrl/api/member/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ─── 토큰 가져오기 ────────────────────────────────
  Future<String?> getAccessToken() async {
    return await _storage.getAccessToken();
  }

  // ─── 현재 사용자 정보 가져오기 (Role 포함) ───────────────────
  Future<Map<String, String?>> getUserInfo() async {
    return {
      'mid': await _storage.getUserMid(),
      'name': await _storage.getUserName(),
      'email': await _storage.getUserEmail(),
      'phone': await _storage.getUserPhone(),
      'role': await _storage.getUserRole(), // ⭐ 추가: 권한 정보 꺼내오기
    };
  }
}