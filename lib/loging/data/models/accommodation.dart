class Accommodation {
  final String contentId;   // 숙소 고유 ID → 상세 API 호출할 때 필요
  final String title;       // 숙소 이름
  final String addr1;       // 주소
  final String firstImage;  // 대표 이미지 URL
  final String tel;         // 전화번호
  final double mapX;        // 경도 (지도에 핀 찍을 때 사용)
  final double mapY;        // 위도
  final String areaCode;    // 지역 코드 (서울:1, 부산:6 등)
  final String cat3;        // 숙소 유형 코드 (호텔/펜션/모텔 구분)

  // 상세 화면에서만 필요한 것들 → ? 붙이면 없어도 됨 (null 허용)
  final String? checkIn;
  final String? checkOut;
  final String? parking;

  // 아래 필드들 추가
  final String? roomCount;      // 객실수
  final String? chkCooking;     // 객실내취사여부
  final String? subFacility;    // 부대시설
  final String? pickup;         // 픽업서비스
  final String? barbecue;       // 바비큐장여부
  final String? fitness;        // 휘트니스센터여부
  final String? sauna;          // 사우나실여부

  // API가 안 줘서 앱에서 직접 만드는 값
  bool isFavorite;
  final double? rating;
  final int? reviewCount;

  Accommodation({
    required this.contentId,
    required this.title,
    required this.addr1,
    this.firstImage = '',
    this.tel = '',
    this.mapX = 0,
    this.mapY = 0,
    this.areaCode = '',
    this.cat3 = '',
    this.checkIn,
    this.checkOut,
    this.parking,
    // 아래 추가
    this.roomCount,
    this.chkCooking,
    this.subFacility,
    this.pickup,
    this.barbecue,
    this.fitness,
    this.sauna,
    this.isFavorite = false,
    this.rating,
    this.reviewCount,
  });

  // JSON → Accommodation 객체로 변환
  // ?? '' 의 의미 → API가 null을 줬을 때 빈 문자열('')로 대신 사용
  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      contentId:  json['contentid']?.toString() ?? '',
      title:      json['title']?.toString() ?? '',
      addr1:      json['addr1']?.toString() ?? '',
      firstImage: json['firstimage']?.toString() ?? '',
      tel:        json['tel']?.toString() ?? '',
      mapX:       double.tryParse(json['mapx']?.toString() ?? '0') ?? 0,
      mapY:       double.tryParse(json['mapy']?.toString() ?? '0') ?? 0,
      areaCode:   json['areacode']?.toString() ?? '',
      cat3:       json['cat3']?.toString() ?? '',
      // 별점은 API가 안 줌 → contentId로 임시 계산
      rating:      3.5 + (json['contentid'].hashCode % 30) / 20.0,
      reviewCount: 10 + (json['contentid'].hashCode.abs() % 200),

    );
  }

  // cat3 코드 → 사람이 읽을 수 있는 한글로 변환
  String get accommodationType {
    switch (cat3) {
      case 'B02010100': return '관광호텔';
      case 'B02010700': return '펜션';
      case 'B02010900': return '모텔';
      case 'B02011000': return '민박';
      case 'B02011100': return '게스트하우스';
      case 'B02011600': return '한옥';
      default:          return '숙소';
    }
  }

  // "부산광역시 해운대구 해운대해변로 264" → "부산광역시 해운대구" 만 보여주기
  String get shortAddr {
    final parts = addr1.split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return addr1;
  }

  bool get hasImage => firstImage.isNotEmpty;
}