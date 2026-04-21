import 'package:dio/dio.dart';

import '../../util/api_client.dart';
import '../model/car_reservation_cursor_request_dto.dart';
import '../model/car_reservation_cursor_response_dto.dart';
import '../model/car_rental_reservation_dto.dart';

class CarReservationService {
  Future<({CarRentalReservationDTO? rental, String? error})> createRental(int carId, String startDate, String endDate) async {
    try {
      final response = await dio.post(
        '/api/car/reservation',
        data: {'carId': carId, 'startDate': startDate, 'endDate': endDate},
      );
      return (rental: CarRentalReservationDTO.fromJson(response.data), error: null);
    } catch (e) {
      if (e is DioException && e.response != null) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return (rental: null, error: '로그인이 필요합니다.');
        }
        final data = e.response?.data;
        final String message = data is String
            ? data
            : ((data?['message'] as String?) ?? (data?['msg'] as String?) ?? '예약에 실패했습니다.');
        return (rental: null, error: message);
      }
      return (rental: null, error: '예약 실패: $e');
    }
  }

  Future<({CarReservationCursorResponseDTO? response, String? error})> fetchMyRentals(
    CarReservationCursorRequestDTO request,
  ) async {
    try {
      final response = await dio.get(
        '/api/car/reservation/my',
        queryParameters: request.toQueryParameters(),
      );
      return (response: CarReservationCursorResponseDTO.fromJson(response.data), error: null);
    } catch (e) {
      return (response: null, error: '목록 조회 실패: $e');
    }
  }

  Future<({bool success, String? error})> cancelRental(int rentalId) async {
    try {
      await dio.delete('/api/car/reservation/$rentalId');
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: '취소 실패: $e');
    }
  }
}