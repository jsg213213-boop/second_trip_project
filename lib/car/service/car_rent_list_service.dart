import 'package:flutter/foundation.dart';

import '../../util/api_client.dart';
import '../model/car_search_cursor_request_dto.dart';
import '../model/car_search_cursor_response.dart';

class CarRentListService {

  Future<CarSearchCursorResponseDTO> searchCars(
    CarSearchCursorRequestDTO request,
  ) async {
    final response = await publicDio.get(
      '/car/search/all',
      queryParameters: request.toQueryParameters(),
    );
    debugPrint('searchCars 응답: ${response.data}');
    return CarSearchCursorResponseDTO.fromJson(response.data);
  }
}