import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../loging/data/datasources/tour_api_datasource.dart';
import '../loging/data/models/accommodation.dart';
import '../loging/data/models/room.dart';
import '../loging/data/repositories/accommodation_repository.dart';

// 지역 코드 상수 모음
class AreaCode {
  static const Map<String, String> areas = {
    '전체': '',
    '서울': '1',
    '인천': '2',
    '대전': '3',
    '대구': '4',
    '광주': '5',
    '부산': '6',
    '울산': '7',
    '경기': '31',
    '강원': '32',
    '충북': '33',
    '충남': '34',
    '경북': '35',
    '경남': '36',
    '전북': '37',
    '전남': '38',
    '제주': '39',
  };
}

// ─── Datasource & Repository 제공 ────────────────────────────────
// Provider = "이걸 필요한 곳에 자동으로 제공해줄게" 라는 의미
final datasourceProvider = Provider<TourApiDatasource>((ref) {
  return TourApiDatasource(
    apiKey: dotenv.env['TOUR_API_KEY'] ?? '',  // .env에서 키 가져오기
  );
});

final repositoryProvider = Provider<AccommodationRepository>((ref) {
  return AccommodationRepository(
    datasource: ref.watch(datasourceProvider),  // 위에서 만든 datasource 사용
  );
});

// ─── 선택된 지역 상태 ─────────────────────────────────────────────
// StateProvider = 값이 바뀔 수 있는 상태 (사용자가 지역 탭 누르면 바뀜)
final selectedAreaProvider = StateProvider<String>((ref) => '부산');

// 선택된 숙소 카테고리
final selectedCategoryProvider = StateProvider<String>((ref) => '전체');

// 카테고리 코드 상수
class CategoryCode {
  static const Map<String, String> categories = {
    '전체': '',
    '호텔': 'B02010100',
    '모텔': 'B02010900',
    '게스트하우스': 'B02011100',
  };
}

// ─── 숙소 목록 ───────────────────────────────────────────────────
// FutureProvider = API처럼 비동기(시간이 걸리는) 작업 담당
// 로딩중 / 데이터있음 / 에러 3가지 상태를 자동으로 관리해줌
final accommodationListProvider =
FutureProvider.family<List<Accommodation>, String>(
      (ref, areaName) async {
    final repo = ref.watch(repositoryProvider);
    final areaCode = AreaCode.areas[areaName] ?? '6';
    return repo.getByArea(areaCode: areaCode);
  },
);

// ─── 검색 결과 ───────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider =
FutureProvider.family<List<Accommodation>, String>(
      (ref, query) async {
    if (query.isEmpty) return [];
    final repo = ref.watch(repositoryProvider);
    return repo.search(keyword: query);
  },
);

// ─── 찜 목록 ─────────────────────────────────────────────────────
// StateNotifier = 복잡한 상태 변화를 관리할 때 사용
// 찜 추가/삭제 + SharedPreferences에 저장까지 담당
class FavoriteNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'favorites';

  FavoriteNotifier(this._prefs)
      : super(Set.from(_prefs.getStringList(_key) ?? []));

  // 찜 추가 or 삭제 (이미 있으면 삭제, 없으면 추가)
  void toggle(String contentId) {
    final next = {...state};
    if (next.contains(contentId)) {
      next.remove(contentId);
    } else {
      next.add(contentId);
    }
    state = next;
    _prefs.setStringList(_key, next.toList()); // 앱 껐다 켜도 유지
  }

  bool isFavorite(String contentId) => state.contains(contentId);
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // main.dart에서 override 할 거예요
});

final favoriteProvider =
StateNotifierProvider<FavoriteNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoriteNotifier(prefs);
});

// 숙소 상세 정보 Provider
// Accommodation 객체를 받아서 상세 정보가 채워진 Accommodation 반환
final accommodationDetailProvider =
FutureProvider.family<Accommodation, Accommodation>(
      (ref, base) async {
    final repo = ref.watch(repositoryProvider);
    return repo.getDetail(base: base);
  },
);

// 찜 목록 캐시 Provider
// 상세 화면 방문 시 숙소 정보를 저장해둠
final accommodationCacheProvider =
StateProvider<Map<String, dynamic>>((ref) => {});

// 객실 목록 Provider
final roomListProvider =
FutureProvider.family<List<Room>, String>(
      (ref, contentId) async {
    final repo = ref.watch(repositoryProvider);
    return repo.getRooms(contentId: contentId);
  },
);