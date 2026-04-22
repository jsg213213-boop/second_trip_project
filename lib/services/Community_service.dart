import 'package:dio/dio.dart';

class CommunityService {
  final Dio _dio = Dio();
  // 에뮬레이터에서 내 컴퓨터 백엔드 주소
  final String _baseUrl = 'http://10.0.2.2:8080/community';

  // 글 등록 함수
  Future<bool> registerPost(Map<String, dynamic> postData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: postData,
      );

      if (response.statusCode == 200) {
        return true; // 성공
      }
      return false;
    } catch (e) {
      print('서버 통신 오류: $e');
      return false; // 실패
    }
  }
}