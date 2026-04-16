import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/comp_model.dart';

class RentCompController with ChangeNotifier {
  static const int _perRegion = 10;

  final List<CompModel> _allItems = [];
  final Map<String, List<CompModel>> _regionItems = {};
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedRegion;

  Map<String, List<CompModel>> get regionItems => _regionItems;
  List<String> get regions => _regionItems.keys.toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedRegion => _selectedRegion;

  /// 선택된 지역의 업체 목록
  List<CompModel> get filteredItems =>
      _selectedRegion != null ? (_regionItems[_selectedRegion] ?? []) : [];

  void setRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  /// 서버에서 지역별 렌트카 회사 목록 조회
  Future<void> fetchByRegion(String region) async {
    if (_isLoading) return;
    _selectedRegion = region;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.http('10.0.2.2:8080', '/rent/companies', {'region': region});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final items = jsonList.map((e) => CompModel.fromJson(e)).toList();
        _regionItems[region] = items;
        debugPrint('$region 렌트카 업체 ${items.length}개 로드');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('데이터 로딩 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 주소에서 첫 번째 단어 추출 (예: "부산광역시 해운대구 ..." → "부산광역시")
  static const _exceptionRegions = {'충청북도', '충청남도', '전라북도', '전라남도', '경상북도', '경상남도'};

  String _normalizeRegion(String region) {
    if (_exceptionRegions.contains(region)) {
      return '${region[0]}${region[2]}';
    }
    return region.substring(0, 2);
  }

  String? _extractRegion(CompModel item) {
    final addr = item.road ?? item.address ?? '';
    if (addr.isEmpty) return null;
    return _normalizeRegion(addr.split(' ').first);
  }

  Future<void> fetchInitial() async {
    if (_isLoading) return;
    // 이미 데이터가 있으면 다시 안 불러옴
    if (_allItems.isNotEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    _allItems.clear();
    _regionItems.clear();
    notifyListeners();

    int page = 1;
    bool apiHasMore = true;

    while (apiHasMore) {
      apiHasMore = await _fetchPage(page);
      page++;
    }

    _groupByRegion();

    _isLoading = false;
    notifyListeners();
  }

  // _allItems를 지역별로 10개씩 그룹핑
  void _groupByRegion() {
    final Map<String, List<CompModel>> grouped = {};

    for (final item in _allItems) {
      final region = _extractRegion(item);
      if (region == null) continue;

      grouped.putIfAbsent(region, () => []);
      // if (grouped[region]!.length < _perRegion) {
        grouped[region]!.add(item);
      // }
    }

    // 도시별 개수를 10으로 나누고 버림한 만큼만 가져오기
    for (final entry in grouped.entries) {
      final count = (entry.value.length / 10);
      if (count > 0) {
        _regionItems[entry.key] = entry.value.sublist(0, count.floor());
      }
    }
  }

  // API에서 해당 페이지 데이터를 가져옴 (1페이지당 1000개)
  Future<bool> _fetchPage(int page) async {
    final queryParams = {
      'serviceKey': dotenv.env['PUBLIC_DATA_SERVICE_KEY'] ?? '',
      'pageNo': page.toString(),
      'numOfRows': '1000',
      'type': 'json',
    };
    final uri = Uri.https(
      'api.data.go.kr',
      '/openapi/tn_pubr_public_car_rental_api',
      queryParams,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        debugPrint('API 응답: ${decoded.toString().substring(0, 500)}');
        final body = decoded['response']?['body'];

        final items = body?['items'];
        final List<dynamic>? itemList =
            items is List ? items : items is Map ? items['item'] : null;

        if (itemList != null && itemList.isNotEmpty) {
          final newItems = itemList.map((e) => CompModel.fromJson(e)).toList();
          _allItems.addAll(newItems);

          final totalCount = int.tryParse('${body['totalCount']}') ?? 0;
          return _allItems.length < totalCount;
        }
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('데이터 로딩 실패: $e');
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}