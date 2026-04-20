import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/common_button.dart';
import '../constants/airport_constants.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';
import 'reservation_screen.dart';

/// 항공편 상세 화면
/// - 선택한 가는편 표시
/// - 왕복인 경우 오는편 선택
/// - 항공권 요약 및 예약 버튼
class FlightDetailScreen extends StatefulWidget {
  const FlightDetailScreen({super.key});

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {

  // ── API용 날짜 포맷 ───────────────────────────────────────
  String _formatDateApi(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── 표시용 날짜 포맷 ──────────────────────────────────────
  String _formatDateDisplay(DateTime? date) {
    if (date == null) return '-';
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}.${date.day} ${days[date.weekday - 1]}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<FlightController>();
      if (controller.isRoundTrip && controller.retDate != null) {
        controller.fetchReturnFlights(
          retPlandTime: _formatDateApi(controller.retDate!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlightController>();
    final dep = controller.selectedDep;

    if (dep == null) {
      return const Scaffold(
        body: Center(child: Text('항공편 정보가 없습니다')),
      );
    }

    final totalPassengers =
        controller.adultCount + controller.childCount + controller.infantCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${controller.depAirportNm} - ${controller.arrAirportNm}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 선택한 가는편 ─────────────────────────────
            _sectionTitleWithAction(
              title: '선택한 가는편',
              onTap: () => Navigator.pop(context),
            ),
            _flightCard(dep),

            const SizedBox(height: 24),

            // ── 왕복: 오는편 선택 ─────────────────────────
            if (controller.isRoundTrip) ...[
              _sectionTitleWithAction(
                title: '오는편 선택'
                    '${controller.retDate != null
                    ? ' · ${_formatDateDisplay(controller.retDate)}'
                    : ''}',
                onTap: null,
              ),

              const SizedBox(height: 12),

              if (controller.retItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('오는편 항공편이 없습니다'),
                  ),
                )
              else
                ...controller.retItems.map((retItem) {
                  final isSelected =
                      controller.selectedRet?.flightNo == retItem.flightNo;
                  return GestureDetector(
                    onTap: () => controller.selectRet(retItem),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _flightCard(retItem),
                    ),
                  );
                }),

              const SizedBox(height: 24),
            ],

            // ── 선택한 항공권 요약 ────────────────────────
            if (!controller.isRoundTrip ||
                controller.selectedRet != null) ...[
              _sectionTitleWithAction(
                title: '선택한 항공권',
                onTap: null,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [

                    // 가는편 요약 행
                    _summaryRow(
                      label: '가는편',
                      time: '${FormatUtils.time(dep.depPlandTime)} - '
                          '${FormatUtils.time(dep.arrPlandTime)}',
                      info: '${dep.depAirportNm ?? '-'}, '
                          '${dep.airlineNm ?? '-'} ${dep.flightNo ?? '-'}',
                      price: dep.price,
                    ),

                    // 왕복: 오는편 요약 행
                    if (controller.isRoundTrip &&
                        controller.selectedRet != null) ...[
                      const Divider(height: 20),
                      _summaryRow(
                        label: '오는편',
                        time: '${FormatUtils.time(controller.selectedRet!.depPlandTime)} - '
                            '${FormatUtils.time(controller.selectedRet!.arrPlandTime)}',
                        info: '${controller.selectedRet!.depAirportNm ?? '-'}, '
                            '${controller.selectedRet!.airlineNm ?? '-'} '
                            '${controller.selectedRet!.flightNo ?? '-'}',
                        price: controller.selectedRet!.price,
                      ),
                    ],

                    const Divider(height: 20),

                    // 발급 수수료
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('발급 수수료',
                            style: TextStyle(
                                color: AppColors.textSecondary)),
                        Text(
                          FormatUtils.price(AirportConstants.issueFee),
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 결제 예상금액
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 예상금액 ($totalPassengers명)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FormatUtils.price(
                            (dep.price +
                                (controller.selectedRet?.price ?? 0)) *
                                totalPassengers +
                                AirportConstants.issueFee,
                          ),
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

              // ── 항공권 예약 버튼 ──────────────────────
              CommonButton(
                text: '항공권 예약',
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

                  if (!mounted) return;

                  if (!isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('로그인이 필요한 서비스입니다.')),
                    );

                    await Navigator.pushNamed(context, '/login');

                    if (!mounted) return;
                    final prefsAfter =
                    await SharedPreferences.getInstance();
                    final isLoggedInAfter =
                        prefsAfter.getBool('isLoggedIn') ?? false;

                    if (isLoggedInAfter) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReservationScreen()),
                      );
                    }
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ReservationScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 섹션 타이틀 + [변경] 버튼 ────────────────────────────
  Widget _sectionTitleWithAction({
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: const Text(
                '변경',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  // ── 항공편 카드 ───────────────────────────────────────────
  Widget _flightCard(FlightItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${FormatUtils.time(item.depPlandTime)} - '
                      '${FormatUtils.time(item.arrPlandTime)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  FormatUtils.duration(
                      item.depPlandTime, item.arrPlandTime),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FormatUtils.price(item.price),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  '성인 1인 기준',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 항공권 요약 행 ────────────────────────────────────────
  Widget _summaryRow({
    required String label,
    required String time,
    required String info,
    required int price,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text(time,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(info,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
        Text(
          FormatUtils.price(price),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}