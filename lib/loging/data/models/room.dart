class Room {
  final String contentId;     // 숙소 ID
  final String roomCode;      // 객실 코드
  final String roomTitle;     // 객실 이름
  final int roomCount;        // 객실 수
  final int baseCount;        // 기준 인원
  final int maxCount;         // 최대 인원

  // 가격 정보
  final int? offSeasonWeekMin;   // 비수기 주중 최소 가격
  final int? offSeasonWeekend;   // 비수기 주말 최소 가격
  final int? peakSeasonWeekMin;  // 성수기 주중 최소 가격
  final int? peakSeasonWeekend;  // 성수기 주말 최소 가격

  // 객실 소개
  final String? roomIntro;

  // 시설 여부 (1 = 가능, 0 = 불가)
  final String? bath;           // 욕조
  final String? airCondition;   // 에어컨
  final String? tv;             // TV
  final String? internet;       // 인터넷
  final String? refrigerator;   // 냉장고
  final String? toiletries;     // 세면도구
  final String? sofa;           // 소파
  final String? cook;           // 취사용품
  final String? hairdryer;      // 드라이기

  // 객실 이미지
  final String? img1;
  final String? img2;
  final String? img3;

  Room({
    required this.contentId,
    required this.roomCode,
    required this.roomTitle,
    this.roomCount = 0,
    this.baseCount = 0,
    this.maxCount = 0,
    this.offSeasonWeekMin,
    this.offSeasonWeekend,
    this.peakSeasonWeekMin,
    this.peakSeasonWeekend,
    this.roomIntro,
    this.bath,
    this.airCondition,
    this.tv,
    this.internet,
    this.refrigerator,
    this.toiletries,
    this.sofa,
    this.cook,
    this.hairdryer,
    this.img1,
    this.img2,
    this.img3,
  });

  // JSON → Room 객체로 변환
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      contentId:  json['contentid']?.toString() ?? '',
      roomCode:   json['roomcode']?.toString() ?? '',
      roomTitle:  json['roomtitle']?.toString() ?? '객실',
      roomCount:  int.tryParse(json['roomcount']?.toString() ?? '0') ?? 0,
      baseCount:  int.tryParse(json['roombasecount']?.toString() ?? '0') ?? 0,
      maxCount:   int.tryParse(json['roommaxcount']?.toString() ?? '0') ?? 0,
      offSeasonWeekMin:  int.tryParse(json['roomoffseasonminfee1']?.toString() ?? ''),
      offSeasonWeekend:  int.tryParse(json['roomoffseasonminfee2']?.toString() ?? ''),
      peakSeasonWeekMin: int.tryParse(json['roompeakseasonminfee1']?.toString() ?? ''),
      peakSeasonWeekend: int.tryParse(json['roompeakseasonminfee2']?.toString() ?? ''),
      roomIntro:    json['roomintro']?.toString(),
      bath:         json['roombath']?.toString(),
      airCondition: json['roomaircondition']?.toString(),
      tv:           json['roomtv']?.toString(),
      internet:     json['roominternet']?.toString(),
      refrigerator: json['roomrefrigerator']?.toString(),
      toiletries:   json['roomtoiletries']?.toString(),
      sofa:         json['roomsofa']?.toString(),
      cook:         json['roomcook']?.toString(),
      hairdryer:    json['roomhairdryer']?.toString(),
      img1:         json['roomimg1']?.toString(),
      img2:         json['roomimg2']?.toString(),
      img3:         json['roomimg3']?.toString(),
    );
  }

  // 가격 표시용 → 비수기 주중 기준으로 보여줌
  String get displayPrice {
    if (offSeasonWeekMin != null && offSeasonWeekMin! > 0) {
      return '${_formatPrice(offSeasonWeekMin!)}원~';
    }
    return '가격문의';
  }

  // 숫자 → 가격 형식으로 변환 (예: 80000 → 80,000)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  // 시설 목록 → 있는 것만 반환
  List<String> get facilityList {
    final list = <String>[];
    if (bath == '1') list.add('욕조');
    if (airCondition == '1') list.add('에어컨');
    if (tv == '1') list.add('TV');
    if (internet == '1') list.add('인터넷');
    if (refrigerator == '1') list.add('냉장고');
    if (toiletries == '1') list.add('세면도구');
    if (sofa == '1') list.add('소파');
    if (cook == '1') list.add('취사용품');
    if (hairdryer == '1') list.add('드라이기');
    return list;
  }

  bool get hasImage => img1 != null && img1!.isNotEmpty;
}