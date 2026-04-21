import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. import 수정
import '../package/model/package_reservation_dto.dart';

class ReservationService {
  final Dio _dio = Dio();
  // 2. dotenv.get을 통해 .env 파일의 값을 가져옵니다.
  final String _baseUrl = dotenv.get('BASE_URL', fallback: 'http://10.0.2.2:8080');

  // 예약 등록 API 호출
  Future<int?> registerReservation(PackageReservationDTO dto, String token) async {

    // 3. print 문을 API 호출 전으로 이동 (함수 호출 인자 안에서는 print를 사용할 수 없습니다)
    print('🚀 요청 전송 시도');
    print('URL: $_baseUrl/api/reservations/');
    print('Token: $token');
    print('Body: ${dto.toJson()}');

    try {
      // 4. API 호출 (중복 제거)
      final response = await _dio.post(
        '$_baseUrl/api/reservations/',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ 성공: ${response.data}');
      return response.data as int;

    } on DioException catch (e) {
      // 에러 상세 출력
      print('❌ 에러 상세: ${e.response?.statusCode}');
      print('❌ 에러 데이터: ${e.response?.data}');
      return null;
    }
  }
}