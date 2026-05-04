import 'package:dio/dio.dart';

import '../../util/api_client.dart';
import '../model/package_reservation_dto.dart';

class PackageReservationService {

  final ApiClient _apiClient = ApiClient();

  // ─── 패키지 예약 등록 ──────────────────────────────
  Future<bool> createReservation(PackageReservationDTO reservation) async {
    try {
      final dynamic responseData = await _apiClient.createPackageReservation(
        packageId: reservation.packageId,
        reservationDate: reservation.reservationDate, // DTO의 DateTime 전달
        peopleCount: reservation.peopleCount ?? 1,
        totalPrice: reservation.totalPrice ?? 0,
      );

      if (responseData != null) {
        print('예약 성공! 생성된 ID: $responseData');
        return true;
      }
      return false;
    } catch (e) {
      print('서비스 에러: $e'); // 여기서 아까 보신 타입 에러가 발생했던 것입니다.
      return false;
    }
  }
}