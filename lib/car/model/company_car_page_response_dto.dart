import 'company_car_dto.dart';

class CompanyCarPageResponseDTO {
  final List<CompanyCarDTO> companyCarDTOs;
  final int page;
  final int totalCount;
  final int totalPages;
  final bool hasNext;

  CompanyCarPageResponseDTO({
    required this.companyCarDTOs,
    required this.page,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
  });

  factory CompanyCarPageResponseDTO.fromJson(Map<String, dynamic> json) {
    return CompanyCarPageResponseDTO(
      companyCarDTOs: (json['companyCarDTOs'] as List)
          .map((e) => CompanyCarDTO.fromJson(e))
          .toList(),
      page: json['page'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
    );
  }
}