/// 패키지 여행 상품의 데이터를 정의하는 모델 클래스입니다.
/// API 응답 혹은 로컬 JSON 파일의 데이터를 파싱하여 앱 내에서 사용합니다.
class PackageItem {
  final String id;           // 상품 고유번호(PK)
  final String category;     // 분류 기준 (예: 'Special', 'Best', 'Season')
  final String title;        // 패키지 상품명
  final String description;  // 상품 소개글 (상세 화면 상단 표시)
  final String region;       // 여행 지역 (예: '제주', '부산', '강원')
  final String thumbnail;    // 리스트 및 상세 화면용 썸네일 이미지 URL
  final int price;           // 상품 가격
  final List<String> tags;   // 필터링 및 강조용 태그 리스트 (#온천, #가족여행 등)

  // --- 상세 화면용 데이터 ---
  final List<String> inclusions;             // 포함 사항 (예: ["숙박", "조식"])
  final List<String> exclusions;             // 불포함 사항 (예: ["개인경비"])
  final Map<String, dynamic> flightInfo;     // 항공 정보 (출/도착지 및 시간)
  final List<Map<String, dynamic>> itinerary; // 1~n일차별 상세 일정 리스트

  PackageItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.region,
    required this.thumbnail,
    required this.price,
    required this.tags,
    required this.inclusions,
    required this.exclusions,
    required this.flightInfo,
    required this.itinerary,
  });

  /// JSON 데이터를 받아 PackageItem 객체로 변환하는 팩토리 생성자
  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      region: json['region'],
      thumbnail: json['thumbnail'],
      price: json['price'],
      // 리스트 형태의 필드는 명시적으로 형변환 처리
      tags: List<String>.from(json['tags']),
      inclusions: List<String>.from(json['inclusions']),
      exclusions: List<String>.from(json['exclusions']),
      // 맵 및 리스트 데이터는 dynamic 타입으로 파싱
      flightInfo: Map<String, dynamic>.from(json['flightInfo']),
      itinerary: List<Map<String, dynamic>>.from(json['itinerary']),
    );
  }
}