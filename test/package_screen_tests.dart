import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:second_trip_project/package/model/package_item.dart';
import 'package:second_trip_project/package/screen/package_detail_screen.dart';
import 'package:second_trip_project/services/member_service.dart'; // import 확인!

// 1. 가짜 서비스 클래스 정의
class MockMemberService extends MemberService {
  @override
  Future<bool> checkLoginStatus() async => true; // 테스트를 위해 항상 로그인됨으로 설정
}

// // 실패 상황을 흉내내는 Mock도 만들 수 있습니다.
// class MockMemberService extends MemberService {
//   @override
//   Future<bool> checkLoginStatus() async => true;
// }


void main() {
  // 테스트용 가짜 데이터
  final testItem = PackageItem(
      id: '5',
      title: '제주도 여행',
      price: 10000,
      thumbnail: '',
      minPeople: 1,
      maxPeople: 5,
      inclusions: [],
      itinerary: [], category: '', description: '', region: '', tags: [], exclusions: [], flightInfo: {}
  );

  testWidgets('예약 버튼 클릭 시 예약 완료 스낵바가 보여야 함', (WidgetTester tester) async {
    PackageDetailScreen.isTesting = true; // [중요] 테스트 모드 활성화

    final mockService = MockMemberService();

    // 2. 위젯 렌더링 (한 번만 호출!)
    await tester.pumpWidget(
      MaterialApp(
        home: PackageDetailScreen(
          item: testItem,
          memberService: mockService,
        ),
      ),
    );

    // 3. '예약하기' 버튼 클릭
    final reserveBtn = find.byKey(const Key('reserve_button'));
    await tester.tap(reserveBtn);
    await tester.pumpAndSettle(); // 모달이 뜰 때까지 기다림

    // 4. 모달 확인
    expect(find.byKey(const Key('reserve_dialog')), findsOneWidget);

    // 5. 확인 버튼 클릭
    final confirmBtn = find.byKey(const Key('confirm_booking_button'));
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle(); // 예약 로직 수행 및 스낵바 뜰 때까지 기다림

    // 6. 스낵바 확인
    expect(find.text('테스트 패키지 예약이 완료되었습니다!'), findsOneWidget);

    PackageDetailScreen.isTesting = false; // 테스트 종료 후 초기화
  });
}