import '../datasources/tour_api_datasource.dart';
import '../models/accommodation.dart';
import '../models/room.dart';

class AccommodationRepository {
  final TourApiDatasource _datasource;

  // Datasource를 외부에서 받아서 사용
  AccommodationRepository({required TourApiDatasource datasource})
      : _datasource = datasource;

  // 지역별 숙소 목록
  Future<List<Accommodation>> getByArea({
    required String areaCode,
    int page = 1,
    int pageSize = 20,
  }) =>
      _datasource.fetchAreaBasedList(
        areaCode: areaCode,
        pageNo: page,
        numOfRows: pageSize,
      );

  // 키워드 검색
  Future<List<Accommodation>> search({
    required String keyword,
    int page = 1,
  }) =>
      _datasource.searchKeyword(
        keyword: keyword,
        pageNo: page,
      );

  // 숙소 상세 정보
  Future<Accommodation> getDetail({
    required Accommodation base,
  }) =>
      _datasource.fetchDetailIntro(base: base);


// 객실 목록
  Future<List<Room>> getRooms({
    required String contentId,
  }) =>
      _datasource.fetchRoomList(contentId: contentId);

}