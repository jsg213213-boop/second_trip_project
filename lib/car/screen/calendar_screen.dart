import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; // TableCalendar 위젯

import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/calendar_controller.dart'; // range 선택 상태 관리 컨트롤러
import '../util/car_format_util.dart';

/// 달력 화면
/// 구조: 요일 헤더(고정) → 구분선 → 달력 리스트(스크롤) → 하단 패널(고정)
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  /// 설정 불가 다이얼로그
  ///
  /// [context] 다이얼로그 띄울 위치
  /// [message] 다이얼로그 내용
  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 화면 아래에서 슬라이드 되며 올라오는 시간 선택 modal
  ///
  /// [context] modal 띄울 위치
  /// [controller] 캘린터 컨트롤러
  /// [isStart] (required) true면 시작시간, false면 끝시간
  void _showTimePicker(
    BuildContext context,
    CalendarController controller, {
    required bool isStart,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: ListView.builder(
            //시간 리스트 만큼 ListTile을 그려줌
            itemCount: CalendarController.timeSlots.length,
            itemBuilder: (context, index) {
              final time = CalendarController.timeSlots[index];
              return ListTile(
                title: Text(time),
                onTap: () {
                  if (isStart) {
                    controller.setStartTime(time);
                  } else {
                    controller.setEndTime(time);
                  }
                  //선택 후 modal창 닫음
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseLayout(
      title: '캘린더',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0, //달력의 좌우를 맞추기 위해 적용
              vertical: 8.0,
            ),
            child: Row(
              // 각 요일을 Expanded로 감싸서 균등 너비 배분
              children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                // 토요일은 파랑, 일요일은 빨강, 나머지는 기본색
                final color = day == '일'
                    ? Colors.red
                    : day == '토'
                    ? Colors.blue
                    : null;
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 5),
          //구분선
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 10),
          // Consumer: CalendarController의 상태가 바뀔 때마다 하위 위젯을 다시 빌드
          Expanded(
            child: Consumer<CalendarController>(
              builder: (context, controller, _) {
                // === 날짜 기준값 계산 ===
                final now = DateTime.now();
                // DateTime.now()는 시간(15:30:45 등)이 포함되어 있어서
                // 날짜 비교 시 오늘이 비활성화될 수 있음 → 시간을 00:00:00으로 맞춤
                final today = DateTime(now.year, now.month, now.day);
                // 달력에 표시할 최대 날짜 (오늘부터 90일 후)
                final maxDay = today.add(const Duration(days: 90));
                // 달력 전체의 시작점 (이번 달 1일) - range 하이라이트가 월 좌측 끝까지 확장할 때 사용???
                final firstDay = DateTime(today.year, today.month, 1);

                // === 월 목록 생성 ===
                final monthCount =
                    (maxDay.year - today.year) * 12 + //연도가 다르다면 차이만큼 12배로 추가
                    maxDay.month -
                    today.month + //마지막 날의 달에서 지금 달을 빼고 1을 더해 갯수를 구함(7월 -4월은 3인데 4,5,6,7이렇게 4개가 필요해서 +1 해줌)
                    1;
                // 각 달의 1일을 리스트로 생성
                // DateTime(2026, 13, 1) → Dart가 자동으로 DateTime(2027, 1, 1)로 변환
                final months = List.generate(
                  monthCount, //갯수 만큼 리스트로 만듦
                  (i) => DateTime(today.year, today.month + i, 1),  //monthCount가 4라면 0,1,2,3이 되며 첫달부터 4개의 달이 그려짐
                );

                // 마지막 달의 말일 - range 하이라이트가 월 우측 끝까지 확장할 때 사용
                // DateTime(year, month+1, 0) → 해당 month의 마지막 날
                final lastMonth = months.last;
                final lastDay = DateTime(
                  lastMonth.year,
                  lastMonth.month + 1,
                  0,
                );

                // === 전체 레이아웃: Column으로 세로 배치 ===
                return Column(
                  children: [
                    // ▶ 3. 달력 리스트 (스크롤 가능, 남은 공간을 Expanded로 채움)
                    Expanded(
                      child: ListView.builder(
                        // 월 개수만큼 TableCalendar 위젯 생성
                        itemCount: months.length,
                        itemBuilder: (context, index) {
                          //그려진 각각의 달력(4월달력, 5월달력, 6월달력, 7월달력)에서 각각 계산을 해서 그려짐
                          final month =
                              months[index]; // 이 달력이 보여줄 달 (예: 2026-04-01)

                          // === 이 달력에 보여줄 range 계산 ===
                          // 각 달력마다 rangeStartDay/rangeEndDay를 개별 설정해야 함
                          // (하나의 range가 여러 달에 걸칠 수 있으므로)
                          DateTime? monthRangeStart;
                          DateTime? monthRangeEnd;

                          if (controller.rangeStart != null &&
                              controller.rangeEnd != null) {
                            // range가 완성된 상태 (시작일 + 끝일 모두 선택됨)
                            final start = controller.rangeStart!;
                            final end = controller.rangeEnd!;

                            //4월 달력이면 monthYM = 2026*12+4, 5월달력이면 2026*12+5이렇게 각각의 화면이 그려진다.
                            // 연도*12+월로 변환하여 하나의 숫자로 비교
                            // 예: 2026년 12월 = 2026*12+12 = 24324
                            // 예: 2027년 1월 = 2027*12+1 = 24325
                            // 이렇게 하면 연도가 달라도 단순 대소 비교로 판단 가능
                            final startYM = start.year * 12 + start.month;
                            final endYM = end.year * 12 + end.month;
                            final monthYM = month.year * 12 + month.month;

                            if (monthYM >= startYM && monthYM <= endYM) { //그려진 달력기간 내에서만 하이라이트 표시
                              // 시작 달이면 실제 start 날짜에서 시작
                              // 중간 달이면 firstDay(달력 좌측 outside 셀까지 하이라이트 확장)
                              monthRangeStart = (monthYM == startYM)  //
                                  ? start
                                  : DateTime(start.year, start.month, 1);
                              // 끝 달이면 실제 end 날짜에서 끝
                              // 중간 달이면 lastDay(달력 우측 outside 셀까지 하이라이트 확장)
                              monthRangeEnd = (monthYM == endYM)
                                  ? end
                                  : DateTime(end.year, end.month + 1, 0);
                            }
                          } else if (controller.rangeStart != null) {
                            // rangeStart만 선택된 상태 (사용자가 첫 번째 날짜만 탭한 상태)
                            // 해당 달력에서만 rangeStart 표시 (파란 원)
                            final start = controller.rangeStart!;
                            if (start.month == month.month &&
                                start.year == month.year) {
                              monthRangeStart = start;
                            }
                          }

                          // === 개별 달력 위젯 ===
                          // 각 달력 사이에 상하 5px 여백
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: TableCalendar(
                              // === 달력 범위 설정 ===
                              // firstDay: 달력이 표시할 수 있는 가장 이른 날짜
                              // lastDay: 달력이 표시할 수 있는 가장 늦은 날짜
                              // 이 범위 밖의 날짜는 아예 렌더링되지 않음 (셀 자체가 없음)
                              // 모든 달력이 동일한 firstDay/lastDay를 공유해야
                              // range 하이라이트가 월 경계를 넘어 outside 셀까지 확장됨
                              firstDay: firstDay, //필수
                              lastDay: lastDay, //필수
                              // focusedDay: 이 달력이 어떤 달을 보여줄지 결정
                              // months[0]=이번 달, months[1]=다음 달... 순서
                              focusedDay: month,  //필수

                              // === 날짜 활성화 조건 ===
                              // enabledDayPredicate: 달력의 모든 날짜 셀에 대해 호출됨
                              // true 반환 → 클릭 가능 (검은 글씨)
                              // false 반환 → 비활성화 (회색 글씨, 클릭 불가)
                              enabledDayPredicate: (day) {
                                // 오늘 이전 날짜는 비활성화
                                if (day.isBefore(today)) return false;
                                // 90일 이후 날짜는 비활성화
                                if (day.isAfter(maxDay)) return false;
                                // rangeStart만 찍힌 상태에서 추가 제한:
                                // rangeStart 이전 날짜는 그대로 활성화 (다시 선택할 수 있도록)
                                // rangeStart 이후 날짜는 6일까지만 활성화 (총 7일의 최대 숙박일 제한)
                                if (controller.rangeStart != null &&
                                    controller.rangeEnd == null) {
                                  final start = controller.rangeStart!;
                                  final maxRange = start.add(
                                    const Duration(days: 6),
                                  );
                                  if (day.isAfter(start) &&
                                      day.isAfter(maxRange))
                                    return false;
                                }
                                return true;
                              },

                              // === range 하이라이트 ===
                              // rangeStartDay ~ rangeEndDay 사이 날짜에 배경색(rangeHighlightColor)이 칠해짐
                              // 둘 다 null이면 하이라이트 없음
                              // 하나만 null이어도 하이라이트 없음 (TableCalendar 내부 동작)
                              rangeStartDay: monthRangeStart,
                              rangeEndDay: monthRangeEnd,

                              // === 날짜 클릭 이벤트 ===
                              onDaySelected: (selectedDay, focusedDay) {
                                // outside 날짜(다른 달에 속한 날짜)를 탭해도 반응하지 않게 필터링
                                // 예: 4월 달력에 보이는 3월 31일을 탭하면 무시
                                if (selectedDay.month == month.month &&
                                    selectedDay.year == month.year) {
                                  controller.onDaySelected(
                                    selectedDay
                                  );
                                }
                              },

                              // === 달력 표시 옵션 ===
                              // 요일 헤더는 달력이 아닌 별도로 그림
                              daysOfWeekVisible: false,
                              // 월간 보기 고정 (주간/2주간 전환 비활성화)
                              calendarFormat: CalendarFormat.month,
                              // 좌우 스와이프 제스처 비활성화
                              // (ListView 세로 스크롤과 충돌 방지)
                              availableGestures: AvailableGestures.none,

                              // === calendarBuilders: 날짜 셀 커스텀 렌더링 ===
                              // 각 builder는 해당 "상태"의 날짜가 그려질 때 호출됨
                              // 반환값이 null이면 → 기본 스타일로 그려짐
                              // SizedBox.expand() 반환 → 셀 크기는 유지하되 내용(숫자)만 숨김
                              // ※ SizedBox.shrink()는 크기가 0x0이라 테이블 레이아웃이 깨짐
                              calendarBuilders: CalendarBuilders(
                                // ● todayBuilder: 오늘 날짜 셀
                                // 기본 스타일(파란 원)을 덮어씌워서 숫자 아래 작은 점으로 표시
                                // Stack + Positioned로 점을 겹쳐서 숫자 위치가 밀리지 않게 함
                                todayBuilder: (context, day, focusedDay) {
                                  return Center(
                                    child: Stack(
                                      // clipBehavior: Clip.none → 점이 Stack 영역 밖으로 나가도 잘리지 않음
                                      // (bottom: -8이라 Stack 아래로 삐져나옴)
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        // 숫자 (다른 날짜와 동일한 기본 스타일)
                                        Text('${day.day}'),
                                        // 숫자 아래 파란 점
                                        Positioned(
                                          bottom: -8,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                // ● headerTitleBuilder: 달력 헤더의 제목 부분
                                // 기본 영문("April 2026")을 "2026년 4월" 한글 형식으로 변경
                                headerTitleBuilder: (context, day) {
                                  return Center(
                                    child: Text(
                                      '${day.year}년 ${day.month}월',
                                      style: const TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                // ● disabledBuilder: 비활성화된 날짜 셀
                                // (오늘 이전, 90일 이후, rangeStart+7일 이후 등은 이미 조건부 비활성화 되어서 이걸로 설정을 빈 칸으로)
                                // 다른 달 날짜면 → SizedBox.expand()로 숨김 (빈 칸 유지)
                                // 현재 달 날짜면 → null 반환 → 기본 회색 글씨로 표시
                                disabledBuilder: (context, day, focusedDay) =>
                                    day.month != month.month
                                    ? const SizedBox.expand()
                                    : null,
                                // ● outsideBuilder: 현재 달이 아닌 날짜 (예: 4월 달력에 보이는 3월 31일)
                                // 월간 중간 날짜들은 비활성화 안했기 때문에 이걸로 빈칸으로 설정함
                                // 무조건 SizedBox.expand()로 숨김 (셀 공간은 유지)
                                // 이 셀이 존재해야 range 하이라이트가 월 경계를 넘어 시각적으로 이어짐
                                outsideBuilder: (context, day, focusedDay) =>
                                    const SizedBox.expand(),
                                // ● rangeStartBuilder: range 시작일 셀
                                // 다른 달이면 숨기고, 현재 달이면 null → 기본 range 시작 스타일(파란 원)
                                rangeStartBuilder: (context, day, focusedDay) =>  null,
                                // ● rangeEndBuilder: range 끝일 셀 (rangeStartBuilder와 동일한 로직)
                                rangeEndBuilder: (context, day, focusedDay) => null,
                                // ● withinRangeBuilder: range 시작~끝 사이의 날짜 셀 (동일한 로직)
                                // outsideBuilder로 빈칸으로 설정을 줬지만 withinRangeBuilder가 우선순위가 높아서 중간 범위의 중간은 글자가 나온다.
                                withinRangeBuilder: (context, day, focusedDay) =>
                                        day.month != month.month
                                        ? const SizedBox.expand()
                                        : null,
                              ),

                              // === 헤더 스타일 (달력 상단의 "2026년 4월" 부분) ===
                              // 실제 표시 형식은 headerTitleBuilder에서 결정
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                // 월간/주간 전환 버튼 숨김
                                titleCentered: true,
                                // 제목 중앙 정렬
                                leftChevronVisible: false,
                                // ◀ 이전 달 버튼 숨김 (스크롤로 이동하므로 불필요)
                                rightChevronVisible: false, // ▶ 다음 달 버튼 숨김
                              ),

                              // === 달력 스타일 (색상, 모양, 패딩 등) ===
                              calendarStyle: CalendarStyle(
                                // 날짜 테이블 좌우 패딩 - 요일 Row의 horizontal: 16과 동일하게 맞춤
                                tablePadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                // outsideDaysVisible: true여야 outside 셀이 렌더링됨
                                // → outsideBuilder에서 숫자는 숨기지만 셀 자체는 존재
                                // → 그 셀에 range 하이라이트 배경색이 칠해져서 월 간 하이라이트가 이어짐
                                // false로 하면 outside 행 자체가 사라져서 하이라이트가 끊김
                                outsideDaysVisible: true,
                                // 비활성화 날짜 글씨 색 (오늘 이전, 90일 이후 등)
                                disabledTextStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                // 오늘 날짜 기본 스타일 (todayBuilder에서 덮어씌우므로 실제로 안 쓰임)
                                // 선택된 날짜 스타일 (rangeStart 있으면 selectedDayPredicate가 false라 안 쓰임)
                                selectedDecoration: BoxDecoration(
                                  color: Colors.deepOrange,
                                  shape: BoxShape.circle,
                                ),
                                // range 하이라이트 배경의 높이 비율 (1.0 = 셀 전체 높이 차지)
                                rangeHighlightScale: 1.0,
                                // range 시작~끝 사이 배경 색상 (연한 파랑)
                                rangeHighlightColor: AppColors.primary.withValues(alpha: 0.2),
                                // range 시작일 글씨 색 (흰색 계열 - 파란 원 위에 표시되므로)
                                rangeStartTextStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                // range 시작일 원 스타일 (blueAccent - 오늘 점 색상과 통일)
                                rangeStartDecoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                // range 끝일 글씨 색 (시작일과 동일)
                                rangeEndTextStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                // range 끝일 원 스타일 (시작일과 동일)
                                rangeEndDecoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // ▶ 4. 하단 패널 (하단 고정, 스크롤 안 됨)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // 상단에만 테두리 (달력과 구분)
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 32.0
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      5.0,
                                      5.0,
                                      0.0,
                                      5.0,
                                    ),
                                    child: Text(
                                      '인수일',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      5.0,
                                      0.0,
                                      0.0,
                                      5.0,
                                    ),
                                    child: Text(
                                      controller.rangeStart == null
                                          ? '날짜를 선택하세요.'
                                          : formatDate(controller.rangeStart!),
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showTimePicker(
                                      context,
                                      controller,
                                      isStart: true,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            controller.startTime ?? '시간 선택',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      5.0,
                                      5.0,
                                      0.0,
                                      5.0,
                                    ),
                                    child: Text(
                                      '반납일',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      5.0,
                                      0.0,
                                      0.0,
                                      5.0,
                                    ),
                                    child: Text(
                                      controller.rangeEnd == null
                                          ? '날짜를 선택하세요.'
                                          : formatDate(controller.rangeEnd!),
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showTimePicker(
                                      context,
                                      controller,
                                      isStart: false,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            controller.endTime ?? '시간 선택',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CommonButton(
                              text: '확인',
                              onPressed: () {
                                // 날짜 미선택
                                if (controller.rangeStart == null ||
                                    controller.rangeEnd == null) {
                                  _showAlert(context, '날짜를 선택해주세요.');
                                  return;
                                }
                                // 시간 미선택
                                if (controller.startTime == null ||
                                    controller.endTime == null) {
                                  _showAlert(context, '시간을 선택해주세요.');
                                  return;
                                }
                                // 시작일이 오늘인 경우 시간 검증
                                final now = DateTime.now();
                                final today = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                );
                                if (isSameDay(controller.rangeStart!, today)) {
                                  final time = formatTime(controller.startTime);
                                  if (time != null) {
                                    final selectedDateTime = DateTime(
                                      today.year,
                                      today.month,
                                      today.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    if (selectedDateTime.isBefore(now)) {
                                      _showAlert(context, '선택한 시간이 이미 지났습니다.');
                                      return;
                                    }
                                  }
                                }
                                Navigator.pop(context, true);
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
