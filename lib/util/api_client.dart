import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'secure_storage_helper.dart';

late final Dio dio; // 회원
late final Dio publicDio; // 비회원

class ApiClient {
  // 싱글톤 패턴
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  final _storage = SecureStorageHelper();

  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    return (url == null || url.isEmpty) ? 'http://10.0.2.2:8080' : url;
  }

  // ─── 초기화 ───────────────────────────────────────
  void init() {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    );

    // 인증 불필요한 공개 API용
    publicDio = Dio(baseOptions);

    // 인증 필요한 API용 (토큰 인터셉터 포함)
    dio = Dio(baseOptions);

    // 요청 인터셉터 → 모든 요청에 자동으로 토큰 추가
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          print('===== API 호출 토큰: $token ====='); // 로그 추가
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('===== 헤더: ${options.headers} ====='); // 로그 추가
          return handler.next(options);
        },
        // 응답 에러 처리
        onError: (error, handler) async {
          // 토큰 만료 (401) 시 로그아웃
          if (error.response?.statusCode == 401) {
            await _storage.logout();
            print('토큰 만료 → 로그아웃 처리');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ─── 찜 추가 ──────────────────────────────────────
  Future<Map<String, dynamic>?> addFavorite({
    required String contentId,
    required String accommodationTitle,
    required String firstImage,
    required String addr1,
  }) async {
    try {
      final response = await dio.post(
        '/api/favorites',
        data: {
          'contentId': contentId,
          'accommodationTitle': accommodationTitle,
          'firstImage': firstImage,
          'addr1': addr1,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print('찜 추가 에러: ${e.message}');
      return null;
    }
  }

  // ─── 찜 삭제 ──────────────────────────────────────
  Future<bool> removeFavorite(String contentId) async {
    try {
      await dio.delete('/api/favorites/$contentId');
      return true;
    } on DioException catch (e) {
      print('찜 삭제 에러: ${e.message}');
      return false;
    }
  }

  // ─── 내 찜 목록 조회 ──────────────────────────────
  Future<List<dynamic>?> getMyFavorites() async {
    try {
      final response = await dio.get('/api/favorites');
      return response.data;
    } on DioException catch (e) {
      print('찜 목록 조회 에러: ${e.message}');
      return null;
    }
  }

  // ─── 찜 여부 확인 ─────────────────────────────────
  Future<bool> checkFavorite(String contentId) async {
    try {
      final response = await dio.get('/api/favorites/check/$contentId');
      return response.data as bool;
    } on DioException catch (e) {
      print('찜 여부 확인 에러: ${e.message}');
      return false;
    }
  }

  // ─── 예약 생성 ────────────────────────────────────
  Future<Map<String, dynamic>?> createReservation({
    required String contentId,
    required String roomCode,
    required String accommodationTitle,
    required String roomTitle,
    required String checkInDate,
    required String checkOutDate,
    required int guestCount,
    required int totalPrice,
  }) async {
    try {
      final response = await dio.post(
        '/api/reservations',
        data: {
          'contentId': contentId,
          'roomCode': roomCode,
          'accommodationTitle': accommodationTitle,
          'roomTitle': roomTitle,
          'checkInDate': checkInDate,
          'checkOutDate': checkOutDate,
          'guestCount': guestCount,
          'totalPrice': totalPrice,
        },
      );
      return response.data;
    } on DioException catch (e) {
      // 에러 메시지 반환
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data ?? '예약에 실패했습니다.');
      }
      throw Exception('예약에 실패했습니다.');
    }
  }

  // ─── 내 예약 목록 조회 ────────────────────────────
  Future<List<dynamic>> getMyReservations() async {
    try {
      final response = await dio.get('/api/reservations');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      print('예약 목록 조회 에러: ${e.message}');
      return []; // null 대신 빈 리스트 반환
    }
  }

  // ─── 예약 취소 ────────────────────────────────────
  Future<bool> cancelReservation(int reservationId) async {
    try {
      await dio.delete('/api/reservations/$reservationId');
      return true;
    } on DioException catch (e) {
      print('예약 취소 에러: ${e.message}');
      return false;
    }
  }

  Future<List<String>> getBookedDates({
    required String contentId,
    required String roomCode,
  }) async {
    try {
      final response = await dio.get(
        '/api/reservations/booked-dates',
        queryParameters: {'contentId': contentId, 'roomCode': roomCode},
      );
      return List<String>.from(response.data);
    } on DioException catch (e) {
      print('예약된 날짜 조회 에러: ${e.message}');
      return [];
    }
  }



  // ─── 패키지 상품 목록 조회 ────────────────────────────────────
  Future<List<dynamic>> getPackageList({
    required String category,
    required int page,
    required int size,
  }) async {
    try {
      final response = await dio.get(
        '/api/packages/packages_list',
        queryParameters: {'category': category, 'page': page, 'size': size},
      );

      // Spring Boot Page 객체에서 content 리스트만 추출
      if (response.data != null && response.data['content'] != null) {
        return response.data['content'];
      }
      return [];
    } on DioException catch (e) {
      print('패키지 목록 조회 에러: ${e.message}');
      return [];
    }
  }

  // ─── 패키지 상품 상세 조회 ────────────────────────────────────
  Future<Map<String, dynamic>?> getPackageDetail(int id) async {
    try {
      final response = await dio.get('/api/packages/$id');
      return response.data;
    } on DioException catch (e) {
      print('패키지 상세 조회 에러: ${e.message}');
      return null;
    }
  }

  // ─── 패키지 상품 예약 생성 ────────────────────────────────────────
  Future<dynamic> createPackageReservation({
    required int? packageId,
    required DateTime? reservationDate, // 타입을 DateTime?으로 받습니다.
    required int peopleCount,
    required int totalPrice,
  }) async {
    try {
      // DateTime을 서버가 인식하기 좋은 "yyyy-MM-dd" 문자열로 변환
      String? formattedDate = reservationDate != null
          ? DateFormat('yyyy-MM-dd').format(reservationDate)
          : null;

      final response = await dio.post(
        '/api/package_reservations',
        data: {
          'packageId': packageId,
          'reservationDate': formattedDate, // 변환된 문자열 전송
          'peopleCount': peopleCount,
          'totalPrice': totalPrice,
        },
      );

      return response.data;
    } on DioException catch (e) {
      print('패키지 예약 전송 에러: ${e.message}');
      rethrow;
    }
  }


  // ─── 내 패키지 예약 목록 조회(마이페이지에서 조회) ───────────────
  Future<List<dynamic>> getMyPackageReservations() async {
    try {
      // 경로를 언더바(_)로 통일하기로 하셨으므로 확인 필수!
      final response = await dio.get('/api/package_reservations/my_package');
      return response.data as List<dynamic>;
    } catch (e) {
      print('목록 조회 에러: $e');
      return [];
    }
  }

  // 내 패키지 예약 취소
  Future<void> deletePackageReservation(int reservationId) async {
    try {
      await dio.delete('/api/package_reservations/$reservationId');
    } catch (e) {
      print('삭제 통신 에러: $e');
      rethrow;
    }
  }


}
