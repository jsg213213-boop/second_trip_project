import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:second_trip_project/package/model/package_item.dart';
import 'package:second_trip_project/package/screen/package_detail_screen.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('예약 버튼 클릭 시 백엔드 호출 확인', (WidgetTester tester) async {
    PackageDetailScreen.isTesting = true; // [중요]

    final testItem = PackageItem(

      id: 'test_01',
      title: '테스트 패키지',
      category: 'Best',
      description: '설명',
      region: '서울',
      thumbnail: 'https://example.com/image.jpg', // 빈 값이 아닌 형식적인 URL
      price: 1000000,
      tags: ['#테스트'],
      inclusions: ['포함1'],
      exclusions: ['불포함1'],
      flightInfo: {},
      itinerary: [
        {
          'day': 1,
          'activities': ['활동1'] // 리스트가 비어있지 않게 샘플 데이터 추가
        }
      ],
    );

    // 1. 상세 페이지 렌더링
    await tester.pumpWidget(MaterialApp(
      home: PackageDetailScreen(item: testItem),
    ));

    // 2. '예약하기' 버튼 클릭
    final reserveBtn = find.byKey(const Key('reserve_button'));
    await tester.tap(reserveBtn);
    await tester.pumpAndSettle();

    // 3. 모달 확인
    expect(find.byKey(const Key('reserve_dialog')), findsOneWidget);
    expect(find.text('해당 패키지 상품을 예약하시겠습니까?'), findsOneWidget);

    // 4. 확인 버튼 클릭
    final confirmBtn = find.byKey(const Key('confirm_booking_button'));
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // 5. [수정 포인트] 스낵바 확인을 위해 화면이 갱신되었는지 확인
    // 실제 UI 코드의 스낵바 텍스트와 일치하는지 확인하세요
    expect(find.text('테스트 패키지 예약이 완료되었습니다!'), findsOneWidget);

    // 6. 모달 닫힘 확인
    expect(find.byKey(const Key('reserve_dialog')), findsNothing);

    PackageDetailScreen.isTesting = false; // 테스트 종료 시 초기화
  });
}