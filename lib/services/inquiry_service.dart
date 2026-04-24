import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InquiryService {
  late final Dio _dio;

  InquiryService() {
    // 💡 Dio 초기 설정 (타임아웃 및 헤더 자동 설정)
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json; charset=UTF-8', // http 패키지의 헤더 역할
    ));
  }

  // 💡 환경 변수에서 IP를 가져오거나 없으면 에뮬레이터 IP 사용
  String get _baseUrl {
    final ip = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    return 'http://$ip:8080/api/inquiries';
  }

  // 문의글 저장 함수
  Future<bool> registerInquiry(Map<String, dynamic> inquiryData) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: inquiryData, // Map을 넘기면 Dio가 알아서 jsonEncode 해줍니다.
      );

      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 내용: ${response.data}");

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      print("통신 중 에러 발생: $e");
      return false;
    }
  }
}
