import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:second_trip_project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/member_service.dart';
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';
import 'package:provider/provider.dart';
import '../controller/reservation_controller.dart';

// StatefulWidget: initState 에서 SharedPreferences 비동기 로드 필요
class ReservationConfirmScreen extends StatefulWidget {
  final ReservationItem reservation;

  const ReservationConfirmScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationConfirmScreen> createState() =>
      _ReservationConfirmScreenState();
}

class _ReservationConfirmScreenState extends State<ReservationConfirmScreen> {

  // ── 상태 변수 ─────────────────────────────────────────────
  // ReservationScreen 에서 예약자 정보를 전달하지 않아
  // SharedPreferences 에서 직접 이메일/전화번호 조회
  String _email = '-';
  String _phone = '-';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // ── 예약자 이메일/전화번호 로드 ───────────────────────────
  // SharedPreferences 에 저장된 userEmail, userPhone 조회
  Future<void> _loadUserInfo() async {
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _email = prefs.getString('userEmail') ?? '-';
    //   _phone = prefs.getString('userPhone') ?? '-';
    // });
    final userInfo = await MemberService().getUserInfo();
    setState(() {
      _email = userInfo['email'] ?? '-';
      _phone = userInfo['phone'] ?? '-';
    });
    debugPrint('[ReservationConfirmScreen] 예약자 이메일: $_email / 전화번호: $_phone');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ReservationConfirmScreen] 화면 진입 → '
        '첫 탑승객: ${widget.reservation.passengers.isNotEmpty
        ? widget.reservation.passengers[0].passengerName : '-'} / '
        '총금액: ${widget.reservation.totalPrice}원');

    return AppBaseLayout(
      title: '예약내역 최종확인',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 안내 문구 ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '이제 최종예약만 남았어요.\n내용 확인하신 후 최종예약를 진행해주세요.',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // ── 예약 정보 카드 ────────────────────────────
            // 예약자 이름: 첫 번째 탑승객 이름 사용
            // 이메일/전화번호: SharedPreferences 에서 로드
            _sectionCard(
              title: '예약 정보',
              child: Column(
                children: [
                  _infoRow('예약자 이름',
                      widget.reservation.passengers.isNotEmpty
                          ? widget.reservation.passengers[0].passengerName : '-'),
                  const SizedBox(height: 8),
                  _infoRow('이메일', _email),
                  const SizedBox(height: 8),
                  _infoRow('휴대폰 번호', _phone),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 여행 정보 카드 ────────────────────────────
            // 가는편 항상 표시
            // 왕복이고 retDepPlandTime 있을 때 오는편 추가 표시
            _sectionCard(
              title: '여행 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _travelRow(
                    label:      '가는편',
                    date:       FormatUtils.date(widget.reservation.depPlandTime),
                    depTime:    FormatUtils.time(widget.reservation.depPlandTime),
                    arrTime:    FormatUtils.time(widget.reservation.arrPlandTime),
                    depAirport: widget.reservation.depAirportNm ?? '-',
                    arrAirport: widget.reservation.arrAirportNm ?? '-',
                    airline:    '${widget.reservation.airlineNm ?? '-'} '
                                '${widget.reservation.flightNo ?? '-'}',
                  ),
                  if (widget.reservation.isRoundTrip &&
                      widget.reservation.retDepPlandTime != null) ...[
                    const Divider(height: 20),
                    _travelRow(
                      label:      '오는편',
                      date:       FormatUtils.date(widget.reservation.retDepPlandTime),
                      depTime:    FormatUtils.time(widget.reservation.retDepPlandTime),
                      arrTime:    FormatUtils.time(widget.reservation.retArrPlandTime),
                      depAirport: widget.reservation.arrAirportNm ?? '-',
                      arrAirport: widget.reservation.depAirportNm ?? '-',
                      airline:    '${widget.reservation.retAirlineNm ?? '-'} '
                                  '${widget.reservation.retFlightNo ?? '-'}',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 탑승객 정보 카드 ──────────────────────────
            // 탑승객 수에 따라 반복 표시 (탑승객 1, 탑승객 2 ...)
            _sectionCard(
              title: '탑승객 정보',
              child: Column(
                children: [
                  ...widget.reservation.passengers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p     = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 16),
                        _infoRow('탑승객 ${index + 1} (${p.passengerType})', ''),
                        const SizedBox(height: 8),
                        _infoRow('성명', p.passengerName),
                        const SizedBox(height: 8),
                        _infoRow('생년월일', FormatUtils.birth(p.passengerBirth)),
                        const SizedBox(height: 8),
                        _infoRow('성별', p.passengerGender),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 최종 결제금액 카드 ────────────────────────
            // 가는편 가격 + 오는편 가격(왕복) + 발급 수수료
            // totalPrice 는 ReservationItem.totalPrice getter 에서 계산
            _sectionCard(
              title: '최종 결제금액',
              child: Column(
                children: [
                  _priceRow('가는편', widget.reservation.depPrice),
                  if (widget.reservation.isRoundTrip &&
                      widget.reservation.retPrice != null) ...[
                    const SizedBox(height: 8),
                    _priceRow('오는편', widget.reservation.retPrice!),
                  ],
                  const SizedBox(height: 8),
                  _priceRow('발급 수수료', AirportConstants.issueFee, isGrey: true),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('최종 결제금액',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        FormatUtils.price(widget.reservation.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── 버튼 행 ───────────────────────────────────
            // 다시 입력: ReservationScreen 으로 복귀 (pop)
            // 최종예약: 완료 다이얼로그 → 검색화면으로 전체 복귀 (popUntil)
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: '다시 입력',
                    isOutlined: true,
                    onPressed: () {
                      debugPrint('[ReservationConfirmScreen] 다시 입력 → ReservationScreen 복귀');
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CommonButton(
                    text: '최종예약',
                    // onPressed: () {
                    onPressed: () async {
                      final error = await context.read<ReservationController>()
                          .addReservation(widget.reservation);

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      debugPrint('[ReservationConfirmScreen] 최종예약 클릭 → '
                          '총금액: ${widget.reservation.totalPrice}원');
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                          title: const Text('예약 완료'),
                          content: const Text(
                            '예약 및 결제가 완료되었습니다!',
                            textAlign: TextAlign.center,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                debugPrint('[ReservationConfirmScreen] 검색화면으로 전체 복귀');
                                // 스택 전체 제거 → SearchScreen (첫 화면)으로 이동
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                // Navigator.pushReplacementNamed(context, '/main');
                              },
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 섹션 카드 위젯 ────────────────────────────────────────
  // title: 섹션 제목 / child: 섹션 내용
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }

  // ── 정보 행 위젯 ──────────────────────────────────────────
  // label(좌) / value(우) 형태로 표시
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── 여행 정보 행 위젯 ─────────────────────────────────────
  // 가는편/오는편 각각 호출 (label, 날짜, 시각, 공항, 항공사)
  Widget _travelRow({
    required String label,
    required String date,
    required String depTime,
    required String arrTime,
    required String depAirport,
    required String arrAirport,
    required String airline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            Text(date,  style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(depTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(depAirport, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
            const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(arrTime, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(arrAirport, style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ],
        ),
        const SizedBox(height: 4),
        Text(airline, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // ── 금액 행 위젯 ──────────────────────────────────────────
  // isGrey: true 이면 발급 수수료처럼 회색으로 표시
  Widget _priceRow(String label, int price, {bool isGrey = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: isGrey ? AppColors.textSecondary : AppColors.textPrimary)),
        Text(FormatUtils.price(price),
            style: TextStyle(color: isGrey ? AppColors.textSecondary : AppColors.textPrimary)),
      ],
    );
  }
}

// =============================================================================
// [파일 정보]
// 위치  : lib/airport/screen/reservation_confirm_screen.dart
// 역할  : 예약 최종 확인 화면 (예약정보 / 여행정보 / 탑승객 / 금액 표시)
// 사용처 : ReservationScreen 에서 addReservation() 성공 시 이동
// -----------------------------------------------------------------------------
// [연관 파일]
// - reservation_item.dart      : 예약 데이터 모델 (전달받아 표시)
// - airport_constants.dart     : issueFee (발급 수수료)
// - format_utils.dart          : date(), time(), birth(), price()
// - app_base_layout.dart       : 공통 앱바 레이아웃
// -----------------------------------------------------------------------------
// [변경 이력]
// - 최초 작성 : StatelessWidget, 단일 탑승객 구조
// - 변경       : StatefulWidget 으로 변경 (SharedPreferences 비동기 로드)
//               이메일/전화번호 SharedPreferences 에서 직접 조회
//               탑승객 다중 표시 구조로 확장 (List<PassengerItem>)
// -----------------------------------------------------------------------------
// [메서드 목록]
// - _loadUserInfo()      : SharedPreferences 에서 이메일/전화번호 로드
// - build()              : 안내문구 / 예약정보 / 여행정보 / 탑승객 / 금액 / 버튼
// - _sectionCard(...)    : 섹션 카드 위젯 (제목 + 구분선 + 내용)
// - _infoRow(...)        : label / value 한 행 위젯
// - _travelRow(...)      : 가는편/오는편 여행 정보 행 위젯
// - _priceRow(...)       : 금액 행 위젯 (회색 옵션)
// -----------------------------------------------------------------------------
// [파일 흐름과 순서]
// 1. ReservationScreen.addReservation() 성공 → Navigator.push 로 진입
// 2. initState() → _loadUserInfo() → 이메일/전화번호 로드
// 3. 예약 정보 / 여행 정보 / 탑승객 정보 / 금액 순으로 표시
// 4. '다시 입력' → Navigator.pop() → ReservationScreen 복귀
// 5. '최종예약' → 완료 다이얼로그 → Navigator.popUntil(isFirst) → SearchScreen 복귀
// -----------------------------------------------------------------------------
// [주의사항 / 참고]
// - 이메일/전화번호는 ReservationScreen 에서 전달받지 않고 SharedPreferences 직접 조회
// - 총금액(totalPrice)은 ReservationItem.totalPrice getter 에서 계산됨
// - '최종예약' 버튼은 실제 결제 API 연동 없이 완료 처리 (발표용)
// - Navigator.popUntil(isFirst) 로 SearchScreen 까지 전체 복귀
// =============================================================================