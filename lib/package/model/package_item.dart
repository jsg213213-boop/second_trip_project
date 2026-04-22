/// 패키지 여행 상품의 데이터를 정의하는 모델 클래스입니다.
/// API 응답 혹은 로컬 JSON 파일의 데이터를 파싱하여 앱 내에서 사용합니다.
class PackageItem {
  final int id;           // 상품 고유번호(PK)
  final String category;     // 분류 기준 (예: 'Special', 'Best', 'Season')
  final String title;        // 패키지 상품명
  final String description;  // 상품 소개글 (상세 화면 상단 표시)
  final String region;       // 여행 지역 (예: '제주', '부산', '강원')
  final String thumbnail;    // 리스트 및 상세 화면용 썸네일 이미지 URL
  final int price;           // 상품 가격
  final List<String> tags;   // 필터링 및 강조용 태그 리스트 (#온천, #가족여행 등)
  final int minPeople; // 최소 인원
  final int maxPeople; // 최대 인원

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
    this.minPeople = 1,
    this.maxPeople = 10,
  });

  /// JSON 데이터를 받아 PackageItem 객체로 변환하는 팩토리 생성자
  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      id: json['id'] as int,
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      region: json['region'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: json['price'] ?? 0,
      // 데이터가 없으면 기본값(1, 10) 할당
      minPeople: json['minPeople'] ?? 1,
      maxPeople: json['maxPeople'] ?? 10,

      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      inclusions: json['inclusions'] != null ? List<String>.from(json['inclusions']) : [],
      exclusions: json['exclusions'] != null ? List<String>.from(json['exclusions']) : [],
      flightInfo: json['flightInfo'] != null ? Map<String, dynamic>.from(json['flightInfo']) : {},
      itinerary: json['itinerary'] != null ? List<Map<String, dynamic>>.from(json['itinerary']) : [],
    );
  }

  
}