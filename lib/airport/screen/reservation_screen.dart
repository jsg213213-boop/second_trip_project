import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/flight_controller.dart';
import '../controller/reservation_controller.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';
import '../widget/flight_summary_card.dart';
import 'reservation_confirm_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  // ── 탑승객 입력 컨트롤러 ──────────────────────────────────
  final _formKey             = GlobalKey<FormState>();
  final _lastNameController  = TextEditingController(text: '홍');       // ✅ [테스트용]
  final _firstNameController = TextEditingController(text: '길동');     // ✅ [테스트용]
  final _birthController     = TextEditingController(text: '19990101'); // ✅ [테스트용]
  String _selectedNation     = '대한민국';
  String _selectedGender     = '남성';
  bool   _isLoading          = false;

  final List<String> _nations = ['대한민국', '미국', '일본', '중국', '기타'];
  final List<String> _genders = ['남성', '여성'];

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _onReserve() async {
    debugPrint('[ReservationScreen] 계속 예약 버튼 클릭');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[ReservationScreen] 유효성 검사 실패');
      return;
    }

    final flightController = context.read<FlightController>();
    final dep = flightController.selectedDep;
    final ret = flightController.selectedRet;

    if (dep == null) {
      debugPrint('[ReservationScreen] 선택한 항공편 없음');
      return;
    }

    final passengerName =
        '${_lastNameController.text.trim()} '
        '${_firstNameController.text.trim()}';

    debugPrint('[ReservationScreen] 탑승객: $passengerName / '
        '생년월일: ${_birthController.text.trim()} / '
        '성별: $_selectedGender');

    // ✅ [변경 전] memberId 없음
    // ✅ [변경 후] mid 추가 (로그인 연동 후 교체)
    // final mid = context.read<LoginController>().mid;

    final reservation = ReservationItem(
      // ✅ [추후 로그인 연동] null → loginController.mid 로 교체
      // mid:             null,
      mid:             'user1',  // ✅ [테스트용]
      airlineNm:       dep.airlineNm,
      flightNo:        dep.flightNo,
      depAirportNm:    dep.depAirportNm,
      arrAirportNm:    dep.arrAirportNm,
      depAirportId:    dep.depAirportId,
      arrAirportId:    dep.arrAirportId,
      depPlandTime:    dep.depPlandTime,
      arrPlandTime:    dep.arrPlandTime,
      depPrice:        dep.price,
      retAirlineNm:    ret?.airlineNm,
      retFlightNo:     ret?.flightNo,
      retDepPlandTime: ret?.depPlandTime,
      retArrPlandTime: ret?.arrPlandTime,
      retPrice:        ret?.price,
      passengerName:   passengerName,
      passengerBirth:  _birthController.text.trim(),
      passengerGender: _selectedGender,
      isRoundTrip:     flightController.isRoundTrip,
      reservedAt:      DateTime.now().toString(),
      status:          '예약완료',
    );

    setState(() => _isLoading = true);

    await context.read<ReservationController>().addReservation(reservation);

    setState(() => _isLoading = false);

    debugPrint('[ReservationScreen] 예약 저장 완료 → 최종확인 화면으로 이동');

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationConfirmScreen(
            reservation: reservation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FlightController>();
    final dep = controller.selectedDep;
    final ret = controller.selectedRet;

    if (dep == null) {
      debugPrint('[ReservationScreen] 항공편 정보 없음');
      return const Scaffold(
        body: Center(child: Text('항공편 정보가 없습니다')),
      );
    }

    final totalPrice =
        dep.price + (ret?.price ?? 0) + AirportConstants.issueFee;

    return AppBaseLayout(
      title: '예약하기',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── 출발지 - 도착지 타이틀 ───────────────────
              Text(
                '${controller.depAirportNm} → ${controller.arrAirportNm}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ── 가는편 ────────────────────────────────────
              FlightSummaryCard(
                label: '가는편',
                depTime: dep.depPlandTime,
                arrTime: dep.arrPlandTime,
                depAirport: dep.depAirportNm ?? controller.depAirportNm,
                arrAirport: dep.arrAirportNm ?? controller.arrAirportNm,
                airline: '${dep.airlineNm ?? '-'} ${dep.flightNo ?? '-'}',
                price: dep.price,
              ),

              // ── 오는편 (왕복일 때) ────────────────────────
              if (controller.isRoundTrip && ret != null) ...[
                const SizedBox(height: 12),
                FlightSummaryCard(
                  label: '오는편',
                  depTime: ret.depPlandTime,
                  arrTime: ret.arrPlandTime,
                  depAirport: ret.depAirportNm ?? controller.arrAirportNm,
                  arrAirport: ret.arrAirportNm ?? controller.depAirportNm,
                  airline: '${ret.airlineNm ?? '-'} ${ret.flightNo ?? '-'}',
                  price: ret.price,
                ),
              ],

              const SizedBox(height: 24),

              // ── 탑승객 정보 입력 ──────────────────────────
              const Text(
                '탑승객 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // 안내 문구
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '내국인은 한글 이름을, 외국인은 영문 이름으로 입력해주세요.\n'
                      '로그인 시 저장된 탑승객 정보를 자동으로 불러올 수 있어요.',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 16),

              // 국적
              const Text('국적',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedNation,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
                items: _nations.map((n) => DropdownMenuItem(
                  value: n,
                  child: Text(n),
                )).toList(),
                onChanged: (val) =>
                    setState(() => _selectedNation = val!),
              ),

              const SizedBox(height: 16),

              // 성 / 이름
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('성',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: '홍',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return '성을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('이름',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            hintText: '길동',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return '이름을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 생년월일
              const Text('생년월일',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthController,
                decoration: const InputDecoration(
                  hintText: '예) 19990101',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                ),
                keyboardType: TextInputType.number,
                maxLength: 8,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '생년월일을 입력해주세요';
                  }
                  if (val.trim().length != 8) {
                    return '8자리로 입력해주세요';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 8),

              // 성별
              const Text('성별',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: _genders.map((gender) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: gender,
                          groupValue: _selectedGender,
                          onChanged: (val) =>
                              setState(() => _selectedGender = val!),
                          activeColor: AppColors.primary,
                        ),
                        Text(gender),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── 금액 요약 ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _priceRow('가는편', dep.price),
                    if (controller.isRoundTrip && ret != null) ...[
                      const SizedBox(height: 8),
                      _priceRow('오는편', ret.price),
                    ],
                    const SizedBox(height: 8),
                    _priceRow('발급 수수료', AirportConstants.issueFee,
                        isGrey: true),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '결제 예상금액',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          FormatUtils.price(totalPrice),
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

              const SizedBox(height: 12),

              // 안내 문구
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFF176)),
                ),
                child: const Text(
                  '· 발권 후 취소/변경 시 취소 수수료가 발생할 수 있습니다.\n'
                      '· 유류할증료는 항공사 정책에 따라 변경될 수 있습니다.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),

              const SizedBox(height: 32),

              // ── 계속 예약 버튼 ────────────────────────────
              CommonButton(
                text: '계속 예약',
                onPressed: _onReserve,
                isEnabled: !_isLoading,
              ),

            ],
          ),
        ),
      ),
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