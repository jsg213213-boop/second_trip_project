import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';

class ReservationConfirmScreen extends StatelessWidget {
  // ✅ [변경 후] 예약 데이터 직접 받기
  final ReservationItem reservation;

  const ReservationConfirmScreen({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ [변경 전] controller.items.last 로 가져옴
    // final controller = context.watch<ReservationController>();
    // if (controller.items.isEmpty) { ... }
    // final reservation = controller.items.last;
    // ✅ [변경 후] 생성자로 받은 reservation 바로 사용

    debugPrint('[ReservationConfirmScreen] 예약 확인 → '
        '탑승객: ${reservation.passengerName} / '
        '총금액: ${reservation.totalPrice}');

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
                '이제 최종예약만 남았어요.\n'
                    '내용 확인하신 후 최종예약를 진행해주세요.',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 20),

            // ── 예약 정보 ─────────────────────────────────
            _sectionCard(
              title: '예약 정보',
              child: Column(
                children: [
                  _infoRow('예약자 이름', reservation.passengerName),
                  const SizedBox(height: 8),
                  // ✅ [추후 로그인 연동] 이메일/전화번호 자동 입력
                  _infoRow('이메일', '-'),
                  const SizedBox(height: 8),
                  _infoRow('휴대폰 번호', '-'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 여행 정보 ─────────────────────────────────
            _sectionCard(
              title: '여행 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 가는편
                  _travelRow(
                    label: '가는편',
                    date: FormatUtils.date(reservation.depPlandTime),
                    depTime: FormatUtils.time(reservation.depPlandTime),
                    arrTime: FormatUtils.time(reservation.arrPlandTime),
                    depAirport: reservation.depAirportNm ?? '-',
                    arrAirport: reservation.arrAirportNm ?? '-',
                    airline: '${reservation.airlineNm ?? '-'} '
                        '${reservation.flightNo ?? '-'}',
                  ),

                  // 오는편 (왕복일 때)
                  if (reservation.isRoundTrip &&
                      reservation.retDepPlandTime != null) ...[
                    const Divider(height: 20),
                    _travelRow(
                      label: '오는편',
                      date: FormatUtils.date(reservation.retDepPlandTime),
                      depTime: FormatUtils.time(reservation.retDepPlandTime),
                      arrTime: FormatUtils.time(reservation.retArrPlandTime),
                      depAirport: reservation.arrAirportNm ?? '-',
                      arrAirport: reservation.depAirportNm ?? '-',
                      airline: '${reservation.retAirlineNm ?? '-'} '
                          '${reservation.retFlightNo ?? '-'}',
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 탑승객 정보 ───────────────────────────────
            _sectionCard(
              title: '탑승객 정보',
              child: Column(
                children: [
                  _infoRow('성명', reservation.passengerName),
                  const SizedBox(height: 8),
                  _infoRow('생년월일',
                      FormatUtils.birth(reservation.passengerBirth)),
                  const SizedBox(height: 8),
                  _infoRow('성별', reservation.passengerGender),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── 최종 결제금액 ─────────────────────────────
            _sectionCard(
              title: '최종 결제금액',
              child: Column(
                children: [
                  _priceRow('가는편', reservation.depPrice),
                  if (reservation.isRoundTrip &&
                      reservation.retPrice != null) ...[
                    const SizedBox(height: 8),
                    _priceRow('오는편', reservation.retPrice!),
                  ],
                  const SizedBox(height: 8),
                  _priceRow('발급 수수료', AirportConstants.issueFee,
                      isGrey: true),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '최종 결제금액',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        FormatUtils.price(reservation.totalPrice),
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
            Row(
              children: [
                // 다시 입력
                Expanded(
                  child: CommonButton(
                    text: '다시 입력',
                    isOutlined: true,
                    onPressed: () {
                      debugPrint('[ReservationConfirmScreen] 다시 입력 → 이전 화면으로');
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // 최종 예약
                Expanded(
                  flex: 2,
                  child: CommonButton(
                    text: '최종예약',
                    onPressed: () {
                      debugPrint('[ReservationConfirmScreen] 최종예약 클릭 → '
                          '총금액: ${reservation.totalPrice}원');
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
                                debugPrint('[ReservationConfirmScreen] '
                                    '검색화면으로 이동');
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
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

  // ── 섹션 카드 ─────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Divider(height: 16),
          child,
        ],
      ),
    );
  }

  // ── 정보 행 ───────────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ── 여행 정보 행 ──────────────────────────────────────────
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
            Text(label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                )),
            Text(date,
                style: const TextStyle(
                    color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(depTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(depAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary)),
              ],
            ),
            const Icon(Icons.arrow_forward,
                color: AppColors.textSecondary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(arrTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                Text(arrAirport,
                    style: const TextStyle(
                        color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(airline,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // ── 금액 행 ───────────────────────────────────────────────
  Widget _priceRow(String label, int price, {bool isGrey = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isGrey
                    ? AppColors.textSecondary
                    : AppColors.textPrimary)),
        Text(
          FormatUtils.price(price),
          style: TextStyle(
              color: isGrey
                  ? AppColors.textSecondary
                  : AppColors.textPrimary),
        ),
      ],
    );
  }
}