import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/reservation_service.dart';
import '../model/package_item.dart';
import '../model/package_reservation_dto.dart';

class PackageController extends ChangeNotifier{

  final ReservationService _service;

  PackageController(this._service);

  List<PackageItem> packageList = [];
  bool isLoading = false;

  /// 리스트 불러오기
  Future<void> loadPackages() async {
    try {
      final String response = await rootBundle.loadString('assets/data/packages.json');
      final List<dynamic> data = json.decode(response);

      packageList = data.map((json) => PackageItem.fromJson(json)).toList();

      print("데이터 로드 성공: ${packageList.length}개");
    } catch (e) {
      print("데이터 로드 중 오류 발생: $e");
    }
  }

  /// 검색 로직 추가
  List<PackageItem> searchPackages(String query) {
    if (query.isEmpty) return packageList;
    return packageList.where((item) =>
    item.title.toLowerCase().contains(query.toLowerCase()) ||
        item.region.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// 카테고리별로 데이터를 필터링하는 함수 (UI에서 호출할 용도)
  List<PackageItem> getPackagesByCategory(String category) {
    return packageList.where((item) => item.category == category).toList();
  }

  /// [예약 로직]
  Future<int?> reservePackage({
    required String token,
    required int packageId,
    required int peopleCount,
    required int price,
  }) async {
    isLoading = true;

    try {
      final dto = PackageReservationDTO(
        packageId: packageId,
        reservationDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        peopleCount: peopleCount,
        totalPrice: price * peopleCount,
      );

      final result = await _service.registerReservation(dto, token);
      return result;
    } catch (e) {
      print("예약 중 오류: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners(); // UI에 결과 알림 (로딩 끝)
    }
  }
}