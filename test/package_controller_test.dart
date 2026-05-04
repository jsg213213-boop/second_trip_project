// test/package_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:second_trip_project/package/controller/package_controller.dart';
import 'package:second_trip_project/services/package_reservation_service.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  group('PackageController 테스트', () {
    test('JSON 로드 및 파싱 확인', () async {
      final controller = PackageController(ReservationService());

      // 테스트용 더미 데이터 로드
      await controller.loadPackages();

      // 검증: 리스트가 비어있지 않아야 함
      expect(controller.packageList.isNotEmpty, true);

      // 검증: ID가 예상한 대로 들어왔는지 확인
      expect(controller.packageList.first.id, 'pkg_jeju_001');
    });

    test('카테고리별 필터링 확인', () async {
      final controller = PackageController(ReservationService());
      await controller.loadPackages();

      // 'Best' 카테고리 상품만 필터링
      final bestPackages = controller.getPackagesByCategory('Best');

      // 검증: 데이터가 존재해야 함
      expect(bestPackages.isNotEmpty, true);

      // 데이터 콘솔에 출력 (첫 번째 상품의 타이틀)
      final firstItem = controller.packageList.first;
      print("=== 로드된 상품 타이틀: ${firstItem.title} ===");
      print("=== 로드된 상품 지역: ${firstItem.region} ===");

      // 검증: 모든 필터링 결과는 'Best'여야 함
      for (var item in bestPackages) {
        expect(item.category, 'Best');
      }
    });
  });
}