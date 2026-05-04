import 'package:dio/dio.dart';

import '../../util/api_client.dart';
import '../model/package_item_dto.dart';


class PackageItemService {
// 1. 전체 상품 목록 가져오기 (비회원도 가능하므로 publicDio 사용)
  Future<List<PackageItemDTO>> getPackageList({
    required String category,
    required int page,
    required int size,
  }) async {
    try {

      //api 요청
      final response = await publicDio.get(
        '/api/packages/packages_list',
        queryParameters: {
          'category': category,
          'page': page,
          'size': size,
        },
      );
      print('🚀 [API 요청] 카테고리: $category | 페이지: $page');
      //현재 카테고리별로 서버 요청을 보냄
      //카테고리 수가 늘어나면 서버에 부하 가능성이 생기므로
      //모든 카테고리의 첫 페이지 데이터를 한 번에 묶어서 주는API를 만들어
      //호출 횟수를 1버으로 줄이는 방법 고려해보기

      // 데이터가 아예 없을 경우 빈 리스트 반환
      if (response.data != null && response.data['content'] != null) {
        final List<dynamic> content = response.data['content'];
        return content.map((item) => PackageItemDTO.fromJson(item)).toList();
      }
      return [];

    } on DioException catch (e) {
      // 네트워크나 서버 응답 관련 에러 (Dio 전용)
      throw Exception(_handleError(e));

    } catch (e) {
      // 그 외의 일반적인 에러 (데이터 변환 에러, Null 에러 등)
      print('알 수 없는 일반 에러 발생: $e');
      throw Exception("데이터 처리 중 오류가 발생했습니다.");
    }
  }

  // 2. 상품 상세 정보 가져오기
  Future<PackageItemDTO> getPackageDetail(int id) async {
    try {
      final response = await publicDio.get('/api/packages/$id');

      return PackageItemDTO.fromJson(response.data);
    } catch (e) {
      print('상세 조회 에러: $e');
      rethrow;
    }
  }

  // 공통 에러 처리 메서드
  String _handleError(DioException e) {
    if (e.response != null) {
      // 서버에서 에러 응답을 보낸 경우 (404, 500 등)
      return "서버 오류가 발생했습니다. (코드: ${e.response?.statusCode})";
    }
    // 서버에 연결조차 안 된 경우 (타임아웃, 오타, 오프라인 등)
    return "네트워크 연결을 확인해주세요. (${e.message})";
  }

}


/*
서버 컨트롤러 맵핑 경로: @RequestMapping("/api/packages")
공통 에러 처리 메서드 하단에 추가


*/