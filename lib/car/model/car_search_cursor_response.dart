import 'company_car_dto.dart';

class CarSearchCursorResponseDTO {
  final String carName;
  final String type;
  final int seats;
  final String fuel;
  final int lowestPrice;
  final List<CompanyCarDTO> companyCarDTOs;
  final int totalOptionCount;

  CarSearchCursorResponseDTO({
    required this.carName,
    required this.type,
    required this.seats,
    required this.fuel,
    required this.lowestPrice,
    required this.companyCarDTOs,
    required this.totalOptionCount,
  });

  factory CarSearchCursorResponseDTO.fromJson(Map<String, dynamic> json) {
    return CarSearchCursorResponseDTO(
      carName: json['carName'],
      type: json['type'],
      seats: json['seats'],
      fuel: json['fuel'],
      lowestPrice: json['lowestPrice'],
      companyCarDTOs: (json['companyCarDTOs'] as List)
          .map((e) => CompanyCarDTO.fromJson(e))
          .toList(),
      totalOptionCount: json['totalCompanyCarCount'] ?? 0,
    );
  }

  int get remainingCount => totalOptionCount - companyCarDTOs.length;

  CarSearchCursorResponseDTO copyWith({
    List<CompanyCarDTO>? companyCarDTOs,
  }) {
    return CarSearchCursorResponseDTO(
      carName: carName,
      type: type,
      seats: seats,
      fuel: fuel,
      lowestPrice: lowestPrice,
      companyCarDTOs: companyCarDTOs ?? this.companyCarDTOs,
      totalOptionCount: totalOptionCount,
    );
  }
}