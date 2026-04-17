import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants.dart';
import '../model/rental_model.dart';

class RentalController with ChangeNotifier {
  List<RentalModel> _myRentals = [];
  List<int> _unavailableCarIds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RentalModel> get myRentals => _myRentals;
  List<int> get unavailableCarIds => _unavailableCarIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // 해당 기간에 예약 불가 차량 id 목록 조회
  Future<void> fetchUnavailable(String startDate, String endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dio.get(
        '/api/rental/unavailable',
        queryParameters: {'startDate': startDate, 'endDate': endDate},
      );
      _unavailableCarIds = List<int>.from(response.data);
    } catch (e) {
      _errorMessage = '조회 실패: $e';
      debugPrint('unavailable 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 예약 생성
  Future<RentalModel?> createRental(int carId, String startDate, String endDate) async {
    final token = await _getToken();
    if (token == null) {
      _errorMessage = '로그인이 필요합니다.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dio.post(
        '/api/rental',
        data: {'carId': carId, 'startDate': startDate, 'endDate': endDate},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('예약 응답: ${response.data}');
      final rental = RentalModel.fromJson(response.data);
      _myRentals.insert(0, rental);
      return rental;
    } catch (e) {
      _errorMessage = '예약 실패: $e';
      debugPrint('예약 생성 실패: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 내 예약 목록 조회
  Future<void> fetchMyRentals() async {
    final token = await _getToken();
    if (token == null) {
      _errorMessage = '로그인이 필요합니다.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await dio.get(
        '/api/rental/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _myRentals = (response.data as List).map((e) => RentalModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = '목록 조회 실패: $e';
      debugPrint('내 예약 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 예약 취소
  Future<bool> cancelRental(int rentalId) async {
    final token = await _getToken();
    if (token == null) {
      _errorMessage = '로그인이 필요합니다.';
      notifyListeners();
      return false;
    }

    try {
      await dio.delete(
        '/api/rental/$rentalId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final idx = _myRentals.indexWhere((r) => r.id == rentalId);
      if (idx != -1) {
        _myRentals[idx] = RentalModel(
          id: _myRentals[idx].id,
          carId: _myRentals[idx].carId,
          carName: _myRentals[idx].carName,
          startDate: _myRentals[idx].startDate,
          endDate: _myRentals[idx].endDate,
          totalPrice: _myRentals[idx].totalPrice,
          status: 'CANCELLED',
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = '취소 실패: $e';
      debugPrint('예약 취소 실패: $e');
      return false;
    }
  }
}