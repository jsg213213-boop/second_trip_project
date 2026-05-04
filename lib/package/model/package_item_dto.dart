
//패키지 상품 모델 DTO
class PackageItemDTO {

  final int? id;              // 상품의 고유 식별자 (ID)
  final String? title;        // 여행 패키지 제목
  final int? price;           // 패키지 가격
  final String? region;       // 여행 지역 (예: 경주, 제주 등)
  final String? description;  // 패키지에 대한 간단한 설명
  final List<dynamic>? itinerary;        // 여행 일정 상세 (리스트 형태)
  final List<String>? inclusions; // 포함 사항 (예: 숙박, 조식)
  final List<String>? exclusions; // 불포함 사항 (예: 중식, 개인경비)
  final int? minPeople;       // 최소 출발 인원
  final int? maxPeople;       // 최대 수용 인원
  final String? category;     // 카테고리 (예: Season, Family 등)
  final List<String>? tags;   // 해시태그 리스트 (예: #벚꽃, #가족여행)
  final String? thumbnail;    // 목록에 표시될 이미지 URL
  final Map<String, dynamic>? flightInfo; // 항공 또는 교통 정보 (객체 형태)

  // 기본 생성자
  PackageItemDTO({
    this.id,
    this.category,
    this.title,
    this.description,
    this.region,
    this.thumbnail,
    this.price,
    this.tags,
    this.minPeople,
    this.maxPeople,
    this.inclusions,
    this.exclusions,
    this.flightInfo,
    this.itinerary,
  });

  // 팩토리 생성자
  // 서버(백엔드)에서 받은 데이터는 Map 형태이므로, 이를 Dart 객체로 바꾸어 사용하기 편하게 만듭니다.
  factory PackageItemDTO.fromJson(Map<String, dynamic> json) {
    return PackageItemDTO(
      id: json['id'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      region: json['region'],
      thumbnail: json['thumbnail'],
      price: json['price'],
      // 서버에서 온 리스트 데이터를 Dart의 List<String> 형태로 변환
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      minPeople: json['minPeople'],
      maxPeople: json['maxPeople'],
      inclusions: json['inclusions'] != null ? List<String>.from(json['inclusions']) : null,
      exclusions: json['exclusions'] != null ? List<String>.from(json['exclusions']) : null,
      flightInfo: json['flightInfo'],
      itinerary: json['itinerary'],
    );
  }

  // (선택사항) 객체를 다시 JSON(Map)으로 변환하는 메서드
  // 나중에 데이터를 서버로 보낼(POST/PUT) 때 사용합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'region': region,
      'thumbnail': thumbnail,
      'price': price,
      'tags': tags,
      'minPeople': minPeople,
      'maxPeople': maxPeople,
      'inclusions': inclusions,
      'exclusions': exclusions,
      'flightInfo': flightInfo,
      'itinerary': itinerary,
    };
  }
}

/*
패키지 여행 상품의 데이터를 정의하는 모델 클래스입니다.
API 응답 혹은 로컬 JSON 파일의 데이터를 파싱하여 앱 내에서 사용합니다.
스프링의 DTO구조를 그대로 유지하여 작성하기
*/

