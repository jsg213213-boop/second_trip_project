import 'package:flutter/foundation.dart';

import '../model/company_car_dto.dart';
import '../model/car_search_cursor_request_dto.dart';
import '../model/car_search_cursor_response.dart';
import '../model/company_car_page_request_dto.dart';
import '../service/car_rent_list_service.dart';

class CarRentListController with ChangeNotifier {
  final CarRentListService _service;

  CarRentListController({required CarRentListService service})
      : _service = service;

  List<CarSearchCursorResponseDTO> _cars = [];
  bool _isLoading = false;
  bool _hasNext = false;
  String? _errorMessage;
  int? _nextCursorPrice;
  String? _nextCursorName;

  String? _selectedRegion;
  String? _startDate;
  String? _endDate;

  List<CarSearchCursorResponseDTO> get cars => _cars;
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
      await Future.delayed(const Duration(seconds: 5));
      final result = await _service.searchCars(
        CarSearchCursorRequestDTO(region: region, startDate: startDate, endDate: endDate, size: pageSize),
      );
      _cars = result.cars;
      _hasNext = result.hasNext;
      _nextCursorPrice = result.nextCursorPrice;
      _nextCursorName = result.nextCursorName;
      debugPrint('차량 목록 ${result.cars.length}개 로드, hasNext: ${result.hasNext}');
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
      await Future.delayed(const Duration(seconds: 5));
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
      _cars.addAll(result.cars);
      _hasNext = result.hasNext;
      _nextCursorPrice = result.nextCursorPrice;  //커서 위치를 지정
      _nextCursorName = result.nextCursorName;  //커서 위치를 지정
      debugPrint('추가 차량 ${result.cars.length}개 로드, hasNext: ${result.hasNext}');
    } catch (e) {
      _errorMessage = '추가 차량 조회 실패: $e';
      debugPrint('추가 차량 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
  final Map<int, int> _optionPages = {};  // carIndex -> 현재 로드된 마지막 페이지

  Future<void> loadMoreOptions(int carIndex) async {
    if (_selectedRegion == null || _startDate == null || _endDate == null) return;
    final car = _cars[carIndex];
    if (car.companyCarDTOs.length >= car.totalOptionCount) return;  //더 볼 데이터가 없을때

    final nextPage = (_optionPages[carIndex] ?? 0) + 1; //페이지를 하나씩 늘리며 페이지네이션 함

    try {
      await Future.delayed(const Duration(seconds: 5));
      final result = await _service.fetchCarOptions(
        CompanyCarPageRequestDTO(
          carName: car.carName,
          region: _selectedRegion!,
          startDate: _startDate!,
          endDate: _endDate!,
          page: nextPage,
        ),
      );
      _cars[carIndex] = car.copyWith(
        companyCarDTOs: [...car.companyCarDTOs, ...result.companyCarDTOs],  //해당 차종에서 더보기를 눌러서 현재 보이는 데이터와 받아온 데이터를 합친 데이터를 붙여서 리스트로 보여줌
          //car.companyCarDTOs = [A, B, C]이고 result.companyCarDTOs = [D, E, F]  이면
        //[...car.companyCarDTOs, ...result.companyCarDTOs]가 [A, B, C, D, E, F]
      );
      _optionPages[carIndex] = nextPage;
      notifyListeners();
      debugPrint('옵션 추가 로드: ${result.companyCarDTOs.length}개');
    } catch (e) {
      debugPrint('옵션 추가 조회 실패: $e');
    }
  }
}