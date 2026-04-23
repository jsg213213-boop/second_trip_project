import 'package:flutter/foundation.dart';

import '../model/car_search_cursor_request_dto.dart';
import '../model/car_search_cursor_response.dart';
import '../model/car_search_result_dto.dart';
import '../service/car_rent_list_service.dart';

class CarRentListController with ChangeNotifier {
  final CarRentListService _service;

  CarRentListController({required CarRentListService service})
      : _service = service;

  List<CarSearchResultDTO> _cars = [];
  bool _isLoading = false;
  bool _hasNext = false;
  String? _errorMessage;
  int? _nextCursorPrice;
  String? _nextCursorName;

  String? _selectedRegion;
  String? _startDate;
  String? _endDate;

  List<CarSearchResultDTO> get cars => _cars;
  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;
  static const int pageSize = 10;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAvailableCars(String region, String startDate, String endDate) async {
    _selectedRegion = region;
    _startDate = startDate;
    _endDate = endDate;
    _nextCursorPrice = null;
    _nextCursorName = null;
    _hasNext = false;
    _cars = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final result = await _service.searchCars(
        CarSearchCursorRequestDTO(region: region, startDate: startDate, endDate: endDate, size: pageSize),
      );
      _cars = result.content;
      _hasNext = result.hasNext;
      _nextCursorPrice = result.nextCursorPrice;
      _nextCursorName = result.nextCursorName;
      debugPrint('차량 목록 ${result.content.length}개 로드, hasNext: ${result.hasNext}');
    } catch (e) {
      _errorMessage = '차량 조회 실패: $e';
      debugPrint('차량 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreCars() async {
    if (_isLoading || !_hasNext || _selectedRegion == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final result = await _service.searchCars(
        CarSearchCursorRequestDTO(
          region: _selectedRegion!,
          startDate: _startDate!,
          endDate: _endDate!,
          cursorPrice: _nextCursorPrice ?? 0,
          cursorName: _nextCursorName ?? '',
          size: pageSize,
        ),
      );
      _cars.addAll(result.content);
      _hasNext = result.hasNext;
      _nextCursorPrice = result.nextCursorPrice;  //커서 위치를 지정
      _nextCursorName = result.nextCursorName;  //커서 위치를 지정
      debugPrint('추가 차량 ${result.content.length}개 로드, hasNext: ${result.hasNext}');
    } catch (e) {
      _errorMessage = '추가 차량 조회 실패: $e';
      debugPrint('추가 차량 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}