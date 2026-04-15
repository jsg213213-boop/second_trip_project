import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:second_trip_project/package/model/package_item.dart';
import 'package:second_trip_project/package/screen/package_detail_screen.dart';

void main() {

  setUpAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('예약하기 버튼 클릭 시 모달이 뜨고 확인을 누르면 로직이 실행되어야 함', (WidgetTester tester) async {
    PackageDetailScreen.isTesting = true;

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
    await tester.pumpAndSettle(); // 애니메이션 끝날 때까지 대기

    await tester.pumpAndSettle();

    // 3. 모달창(AlertDialog)이 떴는지 확인
    expect(find.byKey(const Key('reserve_dialog')), findsOneWidget);
    expect(find.text('해당 패키지 상품을 예약하시겠습니까?'), findsOneWidget);

    // 4. 모달 안의 '확인' 버튼 클릭
    final confirmBtn = find.byKey(const Key('confirm_booking_button'));
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // 5. 모달이 닫혔는지 확인
    expect(find.byKey(const Key('reserve_dialog')), findsNothing);

    // 6. 스낵바가 떴는지 확인 (로직 실행 여부 간접 확인)
    expect(find.text('테스트 패키지 예약이 완료되었습니다!'), findsOneWidget);

    PackageDetailScreen.isTesting = false;
  });
}