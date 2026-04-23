import 'package:flutter/foundation.dart';

import '../model/car_reservation_cursor_request_dto.dart';
import '../model/car_rental_reservation_dto.dart';
import '../service/car_reservation_service.dart';

class CarReservationController with ChangeNotifier {
  final CarReservationService _service;

  CarReservationController({CarReservationService? service})
      : _service = service ?? CarReservationService();

  List<CarRentalReservationDTO> _myRentals = [];
  bool _isLoading = false;
  bool _hasNext = false;
  int? _nextCursorStatusOrder;
  String? _nextCursorStartDate;
  int? _nextCursorId;
  String? _errorMessage;

  List<CarRentalReservationDTO> get myRentals => _myRentals;
  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;
  String? get errorMessage => _errorMessage;

  Future<CarRentalReservationDTO?> createRental(int carId, String startDate, String endDate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.createRental(carId, startDate, endDate);

    _isLoading = false;
    if (result.error != null) {
      _errorMessage = result.error;
      debugPrint('예약 생성 실패: ${result.error}');
      notifyListeners();
      return null;
    }

    debugPrint('예약 응답: ${result.rental}');
    notifyListeners();
    return result.rental;
  }

  Future<void> fetchMyRentals() async {
    _isLoading = true;
    _errorMessage = null;
    _myRentals = [];
    _nextCursorStatusOrder = null;
    _nextCursorStartDate = null;
    _nextCursorId = null;
    _hasNext = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    final result = await _service.fetchMyRentals(const CarReservationCursorRequestDTO());

    _isLoading = false;
    if (result.error != null) {
      _errorMessage = result.error;
      debugPrint('내 예약 조회 실패: ${result.error}');
    } else {
      _myRentals = result.response!.reservation;
      _hasNext = result.response!.hasNext;
      _nextCursorStatusOrder = result.response!.nextCursorStatusOrder;
      _nextCursorStartDate = result.response!.nextCursorStartDate;
      _nextCursorId = result.response!.nextCursorId;
    }
    notifyListeners();
  }

  Future<void> loadMoreRentals() async {
    if (_isLoading || !_hasNext) return;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 5));
    final result = await _service.fetchMyRentals(
      CarReservationCursorRequestDTO(
        cursorStatusOrder: _nextCursorStatusOrder,
        cursorStartDate: _nextCursorStartDate,
        cursorId: _nextCursorId,
      ),
    );

    _isLoading = false;
    if (result.error != null) {
      debugPrint('내 예약 추가 조회 실패: ${result.error}');
    } else {
      _myRentals.addAll(result.response!.reservation);
      _hasNext = result.response!.hasNext;
      _nextCursorStatusOrder = result.response!.nextCursorStatusOrder;
      _nextCursorStartDate = result.response!.nextCursorStartDate;
      _nextCursorId = result.response!.nextCursorId;
    }
    notifyListeners();
  }

  Future<bool> cancelRental(int rentalId) async {
    final result = await _service.cancelRental(rentalId);

    if (!result.success) {
      _errorMessage = result.error;
      debugPrint('예약 취소 실패: ${result.error}');
      notifyListeners();
      return false;
    }

    _myRentals.removeWhere((r) => r.id == rentalId);
    notifyListeners();
    return true;
  }
}