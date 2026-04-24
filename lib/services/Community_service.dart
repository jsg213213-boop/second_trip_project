import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunityService {
  late final Dio _dio;

  CommunityService() {
    // 💡 Dio 초기 설정 (타임아웃 5초 설정)
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5), // 연결 대기 시간 5초
      receiveTimeout: const Duration(seconds: 5), // 응답 대기 시간 5초
    ));
  }

  // 💡 IP가 있으면 사용, 없으면 에뮬레이터 주소 사용
  String get _baseUrl {
    final ip = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    return 'http://$ip:8080/community';
  }

  Future<bool> registerPost(Map<String, dynamic> postData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: postData,
      );

      return response.statusCode == 200;
    } catch (e) {
      // 💡 이제 5초 지나면 무한 로딩 대신 에러 로그가 즉시 찍힙니다.
      print('서버 통신 오류: $e');
      return false;
    }
  }
}
