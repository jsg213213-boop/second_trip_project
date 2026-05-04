import 'package:intl/intl.dart';

class PackageReservationDTO {
  final int? packageId;       // 서버의 Long 타입에 대응
  final int? reservationId;   // 서버의 Long 타입에 대응
  final String? packageName;
  final DateTime? reservationDate;
  final int peopleCount;
  final int totalPrice;

  PackageReservationDTO({
    this.packageId,
    this.reservationId,
    this.packageName,
    this.reservationDate,
    required this.peopleCount,
    required this.totalPrice,
  });

  // 1. JSON 데이터를 Dart 객체로 변환 (서버 -> 프론트)
  factory PackageReservationDTO.fromJson(Map<String, dynamic> json) {
    return PackageReservationDTO(
      packageId: json['packageId'],
      reservationId: json['reservationId'],
      packageName: json['packageName'],
      // 서버의 yyyy-MM-dd 문자열을 DateTime 객체로 변환
      reservationDate: json['reservationDate'] != null
          ? DateTime.parse(json['reservationDate'])
          : null,
      peopleCount: json['peopleCount'] ?? 1,
      totalPrice: json['totalPrice'] ?? 0,
    );
  }

  // 2. Dart 객체를 JSON 데이터로 변환 (프론트 -> 서버)
  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'reservationId': reservationId,
      'packageName': packageName,
      // 서버의 @JsonFormat 패턴에 맞춰 yyyy-MM-dd 문자열로 전송
      'reservationDate': reservationDate != null
          ? DateFormat('yyyy-MM-dd').format(reservationDate!)
          : null,
      'peopleCount': peopleCount,
      'totalPrice': totalPrice,
    };
  }
}