import 'package:flutter/foundation.dart';

import '../../util/api_client.dart';
import '../model/car_search_cursor_request_dto.dart';
import '../model/car_search_cursor_response.dart';
import '../model/company_car_page_request_dto.dart';
import '../model/company_car_page_response_dto.dart';

class CarRentListService {

  Future<({List<CarSearchCursorResponseDTO> cars, bool hasNext, int? nextCursorPrice, String? nextCursorName})> searchCars(
    CarSearchCursorRequestDTO request,
  ) async {
    final response = await publicDio.get(
      '/car/search/all',
      queryParameters: request.toQueryParameters(),
    );
    debugPrint('searchCars 응답: ${response.data}');
    final cars = (response.data['content'] as List)
        .map((e) => CarSearchCursorResponseDTO.fromJson(e))
        .toList();
    final hasNext = response.data['hasNext'] as bool;
    final nextCursorPrice = response.data['nextCursorPrice'] as int?;
    final nextCursorName = response.data['nextCursorName'] as String?;
    return (cars: cars, hasNext: hasNext, nextCursorPrice: nextCursorPrice, nextCursorName: nextCursorName);
  }

  Future<CompanyCarPageResponseDTO> fetchCarOptions(CompanyCarPageRequestDTO request) async {
    final response = await publicDio.get(
      '/car/search/company',
      queryParameters: request.toQueryParameters(),
    );
    debugPrint('fetchCarOptions 응답: ${response.data}');
    return CompanyCarPageResponseDTO.fromJson(response.data);
  }
}