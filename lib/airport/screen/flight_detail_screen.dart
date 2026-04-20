import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants/app_colors.dart';
import '../constants/airport_constants.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart'; // 공통 포맷 유틸 사용
import 'flight_list_screen.dart';
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

  // ── 시간 포맷 (202604201030 → 10:30) ─────────────────────
  String _formatTime(String? time) {
    if (time == null || time.length < 12) return '-';
    return '${time.substring(8, 10)}:${time.substring(10, 12)}';
  }

  // ── 비행 시간 계산 ────────────────────────────────────────
  String _duration(String? dep, String? arr) {
    if (dep == null || arr == null ||
        dep.length < 12 || arr.length < 12) return '-';
    final d = DateTime.parse(
        '${dep.substring(0, 4)}-${dep.substring(4, 6)}-${dep.substring(6, 8)} '
            '${dep.substring(8, 10)}:${dep.substring(10, 12)}:00');
    final a = DateTime.parse(
        '${arr.substring(0, 4)}-${arr.substring(4, 6)}-${arr.substring(6, 8)} '
            '${arr.substring(8, 10)}:${arr.substring(10, 12)}:00');
    final diff = a.difference(d);
    return '${diff.inHours}시간 ${diff.inMinutes % 60}분';
  }

  // ── 날짜 포맷 (API 용: 20260420) ─────────────────────────
  String _formatDateApi(DateTime date) {
    return '${date.year}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ── 날짜 포맷 (표시용: 4.20 월) ──────────────────────────
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
      // 왕복이고 오는편 날짜가 있으면 자동으로 오는편 항공편 조회
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

    // 총 인원 수 (성인 + 소아 + 유아)
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
              onTap: () => Navigator.pop(context), // [변경] 클릭 시 리스트로 복귀
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

              // 오는편 항공편 리스트
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
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
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
            // 편도는 바로 표시, 왕복은 오는편 선택 후 표시
            if (!controller.isRoundTrip ||
                controller.selectedRet != null) ...[
              _sectionTitleWithAction(
                title: '선택한 항공권',
                onTap: null,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [

                    // 가는편 요약 행
                    _summaryRow(
                      label: '가는편',
                      time: '${_formatTime(dep.depPlandTime)} - '
                          '${_formatTime(dep.arrPlandTime)}',
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
                        time: '${_formatTime(controller.selectedRet!.depPlandTime)} - '
                            '${_formatTime(controller.selectedRet!.arrPlandTime)}',
                        info: '${controller.selectedRet!.depAirportNm ?? '-'}, '
                            '${controller.selectedRet!.airlineNm ?? '-'} '
                            '${controller.selectedRet!.flightNo ?? '-'}',
                        price: controller.selectedRet!.price,
                      ),
                    ],

                    const Divider(height: 20),

                    // 발급 수수료 (AirportConstants 에서 관리)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('발급 수수료',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          FormatUtils.price(AirportConstants.issueFee),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 결제 예상금액 (인원 수 × 항공료 + 발급 수수료)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '결제 예상금액 ($totalPassengers명)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FormatUtils.price(
                            (dep.price + (controller.selectedRet?.price ?? 0)) *
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
              ElevatedButton(
                onPressed: () async {
                  // 로그인 상태 확인
                  final prefs = await SharedPreferences.getInstance();
                  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

                  if (!mounted) return;

                  if (!isLoggedIn) {
                    // 비로그인 → 스낵바 표시 후 로그인 화면으로
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인이 필요한 서비스입니다.')),
                    );

                    await Navigator.pushNamed(context, '/login');

                    // 로그인 후 돌아왔을 때 상태 재확인
                    if (!mounted) return;
                    final prefsAfter = await SharedPreferences.getInstance();
                    final isLoggedInAfter =
                        prefsAfter.getBool('isLoggedIn') ?? false;

                    if (isLoggedInAfter) {
                      // 로그인 성공 → 예약 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReservationScreen()),
                      );
                    }
                    return;
                  }

                  // 로그인 상태 → 바로 예약 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReservationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '항공권 예약',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 섹션 타이틀 + [변경] 버튼 ────────────────────────────
  // onTap 이 null 이면 [변경] 버튼 숨김
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
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  // ── 항공편 카드 ───────────────────────────────────────────
  // 가는편/오는편 리스트 항목 및 선택한 가는편 표시에 사용
  Widget _flightCard(FlightItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 좌측: 항공사, 시간, 비행시간
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatTime(item.depPlandTime)} - '
                      '${_formatTime(item.arrPlandTime)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  _duration(item.depPlandTime, item.arrPlandTime),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            // 우측: 가격 + 성인 1인 기준 표시
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FormatUtils.price(item.price), // ✅ 공통 FormatUtils 사용
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  '성인 1인 기준',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 항공권 요약 행 ────────────────────────────────────────
  // 선택한 항공권 섹션에서 가는편/오는편 각각 표시
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
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(time,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(info,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        // ✅ price 파라미터 사용 (이전에 item.price 로 잘못 사용하던 버그 수정)
        Text(
          FormatUtils.price(price),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}