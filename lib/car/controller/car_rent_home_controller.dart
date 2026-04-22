import 'package:flutter/foundation.dart';

import '../service/car_rent_home_service.dart';

class CarRentHomeController with ChangeNotifier {
  final CarRentHomeService _service;

  CarRentHomeController({CarRentHomeService? service})
      : _service = service ?? CarRentHomeService();

  List<String> _regions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRegions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _regions = await _service.fetchRegions();
    } catch (e) {
      _errorMessage = '지역 조회 실패: $e';
      debugPrint('지역 조회 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}