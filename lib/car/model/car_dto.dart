class CarDTO {
  final int id;
  final int companyId;
  final String companyName;
  final String name;
  final String type;
  final int seats;
  final String fuel;
  final int dailyPrice;
  final int year;

  CarDTO({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.name,
    required this.type,
    required this.seats,
    required this.fuel,
    required this.dailyPrice,
    required this.year,
  });

  factory CarDTO.fromJson(Map<String, dynamic> json) {
    return CarDTO(
      id: json['id'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      name: json['name'],
      type: json['type'],
      seats: json['seats'],
      fuel: json['fuel'],
      dailyPrice: json['dailyPrice'],
      year: json['year'],
    );
  }
}