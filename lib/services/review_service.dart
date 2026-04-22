import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../util/secure_storage_helper.dart';

class ReviewService {
  // ─── 환경 변수에서 Base URL 가져오기 ──────────────────────────
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    // 기본값은 에뮬레이터 로컬 주소
    return (url == null || url.isEmpty) ? 'http://10.0.2.2:8080' : url;
  }

  final _storage = SecureStorageHelper();

  // ─── 내 리뷰 목록 가져오기 (GET) - 토큰 추가 수정 ─────────────────────
  Future<List<dynamic>> getMyReviews() async {
    try {
      final mid = await _storage.getUserMid(); // 저장된 내 아이디 가져오기
      if (mid == null) return [];

      final url = Uri.parse('$baseUrl/api/review/my/$mid');

      // ⭐ [수정] 401 에러 해결을 위해 AccessToken 가져오기
      final token = await _storage.getAccessToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // 헤더에 토큰 실어주기
        },
      );

      if (response.statusCode == 200) {
        // 한글 깨짐 방지를 위해 utf8.decode 사용
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        // 여기서 401이 뜬다면 토큰이 만료되었거나 서버 설정 문제야!
        print("❌ 리뷰 목록 불러오기 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print('❌ 리뷰 목록 통신 에러: $e');
      return [];
    }
  }

  // ─── 리뷰 등록하기 (POST) ──────────────────────────────────
  Future<bool> registerReview(Map<String, dynamic> reviewData) async {
    try {
      final url = Uri.parse('$baseUrl/api/review/register');
      final token = await _storage.getAccessToken();
      final mid = await _storage.getUserMid();

      // 작성자 아이디를 현재 로그인된 사용자로 강제 설정
      reviewData['writer'] = mid;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ 리뷰 등록 성공!");
        return true;
      } else {
        print("❌ 리뷰 등록 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ 리뷰 등록 에러: $e");
      return false;
    }
  }

  // ─── 리뷰 수정하기 (PUT) ──────────────────────────────────
  Future<bool> modifyReview(Map<String, dynamic> reviewData) async {
    try {
      final url = Uri.parse('$baseUrl/api/review/modify');
      final token = await _storage.getAccessToken();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(reviewData),
      );

      if (response.statusCode == 200) {
        print("✅ 리뷰 수정 성공!");
        return true;
      } else {
        print("❌ 리뷰 수정 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ 리뷰 수정 에러: $e");
      return false;
    }
  }

  // ─── 리뷰 삭제하기 (DELETE) ───────────────────────────────
  Future<bool> deleteReview(int rno) async {
    try {
      final url = Uri.parse('$baseUrl/api/review/$rno');
      final token = await _storage.getAccessToken();

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("✅ 리뷰 삭제 성공!");
        return true;
      } else {
        print("❌ 리뷰 삭제 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ 리뷰 삭제 에러: $e");
      return false;
    }
  }
}