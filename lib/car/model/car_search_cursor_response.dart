import 'car_search_result_dto.dart';

class CarSearchCursorResponseDTO {
  final List<CarSearchResultDTO> content;
  final bool hasNext;
  final int? nextCursorPrice;
  final String? nextCursorName;

  CarSearchCursorResponseDTO({
    required this.content,
    required this.hasNext,
    this.nextCursorPrice,
    this.nextCursorName,
  });

  factory CarSearchCursorResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarSearchCursorResponseDTO(
      content: (json['content'] as List)
          .map((e) => CarSearchResultDTO.fromJson(e))
          .toList(),
      hasNext: json['hasNext'],
      nextCursorPrice: json['nextCursorPrice'],
      nextCursorName: json['nextCursorName'],
    );
  }
}