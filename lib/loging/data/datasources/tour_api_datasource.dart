import 'package:dio/dio.dart';
import '../models/accommodation.dart';
import '../models/room.dart';

class TourApiDatasource {
  // TourAPI 기본 주소
  static const String _baseUrl =
      'https://apis.data.go.kr/B551011/KorService2';

  final Dio _dio;       // HTTP 통신 담당 (택배 트럭)
  final String _apiKey; // 공공데이터 인증키

  TourApiDatasource({required String apiKey})
      : _apiKey = apiKey,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  // 지역 기반 숙소 목록 가져오기
  // areaCode: 서울=1, 부산=6, 제주=39 등
  Future<List<Accommodation>> fetchAreaBasedList({
    required String areaCode,
    int pageNo = 1,
    int numOfRows = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/areaBasedList2',
        queryParameters: {
          'serviceKey':    _apiKey,
          'MobileOS':      'AND',
          'MobileApp':     'AccommoApp',
          '_type':         'json',
          'contentTypeId': '32',   // 32 = 숙박 고정값
          'areaCode':      areaCode,
          'pageNo':        pageNo,
          'numOfRows':     numOfRows,
          'arrange':       'A',    // A = 제목순
        },
      );
      return _parseList(response.data);
    } on DioException catch (e) {
      throw Exception('숙소 목록을 불러오지 못했습니다: ${e.message}');
    }
  }

  // 키워드로 숙소 검색
  Future<List<Accommodation>> searchKeyword({
    required String keyword,
    int pageNo = 1,
    int numOfRows = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/searchKeyword2',
        queryParameters: {
          'serviceKey':    _apiKey,
          'MobileOS':      'AND',
          'MobileApp':     'AccommoApp',
          '_type':         'json',
          'contentTypeId': '32',
          'keyword':       keyword,
          'pageNo':        pageNo,
          'numOfRows':     numOfRows,
        },
      );
      return _parseList(response.data);
    } on DioException catch (e) {
      throw Exception('검색 결과를 불러오지 못했습니다: ${e.message}');
    }
  }
  // 객실 목록 가져오기 (detailInfo2)
  Future<List<Room>> fetchRoomList({
    required String contentId,
  }) async {
    try {
      final response = await _dio.get(
        '/detailInfo2',
        queryParameters: {
          'serviceKey':    _apiKey,
          'MobileOS':      'AND',
          'MobileApp':     'AccommoApp',
          '_type':         'json',
          'contentTypeId': '32',
          'contentId':     contentId,
          'numOfRows':     20,
          'pageNo':        1,
        },
      );

      final items = response.data['response']?['body']?['items']?['item'];
      if (items == null) return [];

      final list = items is List ? items : [items];
      return list
          .map((e) => Room.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('객실 정보를 불러오지 못했습니다: ${e.message}');
    }
  }

  // JSON 응답 → List<Accommodation> 으로 변환하는 내부 함수
  List<Accommodation> _parseList(dynamic data) {
    // TourAPI 응답 구조: data → response → body → items → item
    final items = data['response']?['body']?['items']?['item'];
    if (items == null) return [];

    // item이 1개일 때는 List가 아니라 Map으로 오는 경우가 있음
    final list = items is List ? items : [items];

    return list
        .map((e) => Accommodation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // 숙소 상세 정보 가져오기 (체크인/아웃, 주차 등)
  Future<Accommodation> fetchDetailIntro({
    required Accommodation base,
  }) async {
    try {
      final response = await _dio.get(
        '/detailIntro2',
        queryParameters: {
          'serviceKey':    _apiKey,
          'MobileOS':      'AND',
          'MobileApp':     'AccommoApp',
          '_type':         'json',
          'contentTypeId': '32',
          'contentId':     base.contentId,
        },
      );

      final items = response.data['response']?['body']?['items']?['item'];
      if (items == null) return base;

      final item = items is List ? items[0] : items;

      // 기존 base 데이터에 상세 정보만 덮어쓰기
      return Accommodation(
        contentId:  base.contentId,
        title:      base.title,
        addr1:      base.addr1,
        firstImage: base.firstImage,
        tel:        base.tel,
        mapX:       base.mapX,
        mapY:       base.mapY,
        areaCode:   base.areaCode,
        cat3:       base.cat3,
        isFavorite: base.isFavorite,
        rating:     base.rating,
        reviewCount: base.reviewCount,
        // 상세 정보 채우기
        checkIn:  item['checkintime']?.toString(),
        checkOut: item['checkouttime']?.toString(),
        parking:  item['parkinglodging']?.toString(),
      );
    } on DioException catch (e) {
      throw Exception('상세 정보를 불러오지 못했습니다: ${e.message}');
    }
  }
}