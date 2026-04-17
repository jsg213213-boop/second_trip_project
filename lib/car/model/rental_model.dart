class RentalModel {
  final int id;
  final int carId;
  final String carName;
  final String startDate;
  final String endDate;
  final int totalPrice;
  final String status;

  RentalModel({
    required this.id,
    required this.carId,
    required this.carName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'],
      carId: json['carId'],
      carName: json['carName'] ?? '',
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      totalPrice: json['totalPrice'] ?? 0,
      status: json['status'],
    );
  }

  static String _parseDate(dynamic value) {
    if (value is String) return value;
    if (value is List) {
      final y = value[0];
      final m = value[1].toString().padLeft(2, '0');
      final d = value[2].toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return '';
  }
}