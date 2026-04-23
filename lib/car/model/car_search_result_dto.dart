import 'company_car_dto.dart';

class CarSearchResultDTO {
  final String carName;
  final String type;
  final int seats;
  final String fuel;
  final int lowestPrice;
  final List<CompanyCarDTO> companyCarDTOs;

  CarSearchResultDTO({
    required this.carName,
    required this.type,
    required this.seats,
    required this.fuel,
    required this.lowestPrice,
    required this.companyCarDTOs,
  });

  factory CarSearchResultDTO.fromJson(Map<String, dynamic> json) {
    return CarSearchResultDTO(
      carName: json['carName'],
      type: json['type'],
      seats: json['seats'],
      fuel: json['fuel'],
      lowestPrice: json['lowestPrice'],
      companyCarDTOs: (json['companyCarDTOs'] as List)
          .map((e) => CompanyCarDTO.fromJson(e))
          .toList(),
    );
  }
}