class PackageReservationDTO {
  final int packageId;
  final String reservationDate; // yyyy-MM-dd 형식
  final int peopleCount;
  final int totalPrice;

  PackageReservationDTO({
    required this.packageId,
    required this.reservationDate,
    required this.peopleCount,
    required this.totalPrice,
  });

  // 서버로 보낼 때 사용 (객체 -> JSON)
  Map<String, dynamic> toJson() {
    return {
      'packageId': packageId,
      'reservationDate': reservationDate,
      'peopleCount': peopleCount,
      'totalPrice': totalPrice,
    };
  }

  // 서버에서 받을 때 사용 (JSON -> 객체) - 나중에 조회 기능 만들 때 유용합니다.
  factory PackageReservationDTO.fromJson(Map<String, dynamic> json) {
    return PackageReservationDTO(
      packageId: json['packageId'],
      reservationDate: json['reservationDate'],
      peopleCount: json['peopleCount'],
      totalPrice: json['totalPrice'],
    );
  }
}