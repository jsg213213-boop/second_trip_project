class CompanyCarDTO {
  final int carId;
  final String companyName;
  final int year;
  final int dailyPrice;

  CompanyCarDTO({
    required this.carId,
    required this.companyName,
    required this.year,
    required this.dailyPrice,
  });

  factory CompanyCarDTO.fromJson(Map<String, dynamic> json) {
    return CompanyCarDTO(
      carId: json['carId'],
      companyName: json['companyName'],
      year: json['year'],
      dailyPrice: json['dailyPrice'],
    );
  }
}