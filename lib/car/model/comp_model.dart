class CompModel {
  final int? id;
  final String? name;   // 관광지명
  final String? road;    // 부제목
  final String? address;    // 부제목
  final String? la;       // 대표 이미지
  final String? lo;       // 주소
  final String? phone;

  CompModel({
    this.id,
    this.name,
    this.road,
    this.address,
    this.la,
    this.lo,
    this.phone
  });

  factory CompModel.fromJson(Map<String, dynamic> json) {
    return CompModel(
      id: json['id'],
      name: json['name'],
      road: json['roadAddress'],
      address: json['address'],
      la: json['latitude']?.toString(),
      lo: json['longitude']?.toString(),
      phone: json['phone'],
    );
  }
}