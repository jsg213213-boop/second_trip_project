import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/airport_constants.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/flight_controller.dart';
import '../controller/reservation_controller.dart';
import '../model/passenger_item.dart';
import '../model/reservation_item.dart';
import '../utils/format_utils.dart';
import '../widget/flight_summary_card.dart';
import '../../services/member_service.dart';
import 'reservation_confirm_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {

  // ── 로딩 상태 ─────────────────────────────────────────────
  bool _isLoading = false;

  // ── 예약자 정보 (로그인 정보 자동입력) ───────────────────
  String _bookerName  = '';
  String _bookerEmail = '';
  String _bookerPhone = '';

  // ── 탑승객 목록 ───────────────────────────────────────────
  final List<PassengerItem> _passengers = [];

  // ── 인원 정보 (검색 화면에서 선택한 인원) ────────────────
  int _adultCount  = 1;
  int _childCount  = 0;
  int _infantCount = 0;
  int get _totalCount => _adultCount + _childCount + _infantCount;

  @override
  void initState() {
    super.initState();
    // 화면 빌드 후 로그인 정보 자동입력
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  // ── 로그인 정보 자동입력 ──────────────────────────────────
  // MainScreen 과 동일하게 MemberService.getUserInfo() 사용
  // SharedPreferences 에서 저장된 회원 정보를 가져옴
  Future<void> _loadUserInfo() async {
    final controller = context.read<FlightController>();
    final memberService = MemberService();
    final userInfo = await memberService.getUserInfo();

    setState(() {
      _bookerName  = userInfo['name']  ?? '';
      _bookerEmail = userInfo['email'] ?? '';
      _bookerPhone = userInfo['phone'] ?? '';
      _adultCount  = controller.adultCount;
      _childCount  = controller.childCount;
      _infantCount = controller.infantCount;
    });
  }

  // ── 탑승객 추가/수정 바텀시트 ────────────────────────────
  // editIndex: null 이면 추가, 값이 있으면 해당 인덱스 탑승객 수정
  void _showAddPassengerSheet({int? editIndex}) {

    // 현재 추가된 탑승객 유형별 수량
    final adultAdded  = _passengers.where((p) => p.passengerType == '성인').length;
    final childAdded  = _passengers.where((p) => p.passengerType == '소아').length;
    final infantAdded = _passengers.where((p) => p.passengerType == '유아').length;

    // 기본 선택 유형: 남은 인원 순서대로 자동 선택
    String selectedType = editIndex != null
        ? _passengers[editIndex].passengerType
        : (_adultCount > adultAdded ? '성인'
        : _childCount > childAdded ? '소아' : '유아');

    // 수정 시 기존 정보 불러오기
    final lastNameCtrl = TextEditingController(
        text: editIndex != null
            ? _passengers[editIndex].passengerName.split(' ').first
            : '');
    final firstNameCtrl = TextEditingController(
        text: editIndex != null && _passengers[editIndex].passengerName.contains(' ')
            ? _passengers[editIndex].passengerName.split(' ').last
            : '');
    final birthCtrl = TextEditingController(
        text: editIndex != null ? _passengers[editIndex].passengerBirth : '');
    String selectedGender = editIndex != null
        ? _passengers[editIndex].passengerGender
        : '남성';

    final formKey = GlobalKey<FormState>();

    // ✅ 외부 변수로 선언해야 StatefulBuilder 재빌드 시 초기화 안 됨
    bool sameAsBooker = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── 헤더 ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editIndex != null ? '탑승객 수정' : '탑승객 추가하기',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── 안내 문구 ──────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '탑승객 정보는 반드시 여권 정보와 동일해야 해요!',
                        style: TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 예약자와 동일 체크박스 ─────────────
                    // 성인 첫 번째 탑승객 추가 시에만 표시
                    if (selectedType == '성인' && editIndex == null) ...[
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '예약자와 동일',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: sameAsBooker,
                        activeColor: AppColors.primary,
                        onChanged: (checked) {
                          setModalState(() {
                            sameAsBooker = checked ?? false;
                            if (sameAsBooker) {
                              // 예약자 정보 자동입력
                              lastNameCtrl.text  = _bookerName.isNotEmpty
                                  ? _bookerName.substring(0, 1) : '';
                              firstNameCtrl.text = _bookerName.length > 1
                                  ? _bookerName.substring(1) : '';
                            } else {
                              // 체크 해제 시 초기화
                              lastNameCtrl.clear();
                              firstNameCtrl.clear();
                            }
                          });
                        },
                      ),
                      const Divider(),
                    ],

                    const SizedBox(height: 16),

                    // ── 탑승객 유형 선택 ───────────────────
                    const Text('탑승객 유형',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['성인', '소아', '유아'].map((type) {
                        // 해당 유형의 잔여 인원이 있는지 확인
                        final isAvailable = type == '성인'
                            ? adultAdded < _adultCount
                            : type == '소아'
                            ? childAdded < _childCount
                            : infantAdded < _infantCount;
                        final isSelected = selectedType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: (isAvailable || editIndex != null)
                                ? () => setModalState(() => selectedType = type)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isAvailable || editIndex != null)
                                    ? AppColors.backgroundWhite
                                    : AppColors.backgroundGrey,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isAvailable || editIndex != null)
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── 성 / 이름 입력 ─────────────────────
                    Row(
                      children: [
                        // 성 입력 (한글/영문만 허용)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('성',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: lastNameCtrl,
                                decoration: const InputDecoration(
                                  hintText: '홍',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                inputFormatters: [
                                  // 한글 또는 영문만 입력 허용
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                ],
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? '성을 입력해주세요' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 이름 입력 (한글/영문만 허용)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('이름',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: firstNameCtrl,
                                decoration: const InputDecoration(
                                  hintText: '길동',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                                inputFormatters: [
                                  // 한글 또는 영문만 입력 허용
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Zㄱ-ㅎ가-힣]')),
                                ],
                                validator: (val) => val == null || val.trim().isEmpty
                                    ? '이름을 입력해주세요' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── 생년월일 입력 ──────────────────────
                    const Text('생년월일',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: birthCtrl,
                      decoration: const InputDecoration(
                        hintText: '예) 19990101',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [
                        // 숫자만 입력 허용
                        FilteringTextInputFormatter.digitsOnly,
                      ],
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

                    // ── 성별 선택 ──────────────────────────
                    const Text('성별',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: ['남성', '여성'].map((gender) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: gender,
                                groupValue: selectedGender,
                                onChanged: (val) =>
                                    setModalState(() => selectedGender = val!),
                                activeColor: AppColors.primary,
                              ),
                              Text(gender),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── 취소 / 완료 버튼 ───────────────────
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            text: '취소',
                            isOutlined: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CommonButton(
                            text: '완료',
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final name =
                                  '${lastNameCtrl.text.trim()} '
                                  '${firstNameCtrl.text.trim()}';
                              final passenger = PassengerItem(
                                passengerType:   selectedType,
                                passengerName:   name,
                                passengerBirth:  birthCtrl.text.trim(),
                                passengerGender: selectedGender,
                              );
                              setState(() {
                                if (editIndex != null) {
                                  // 수정 모드: 기존 탑승객 교체
                                  _passengers[editIndex] = passenger;
                                } else {
                                  // 추가 모드: 새 탑승객 추가
                                  _passengers.add(passenger);
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 예약 진행 ─────────────────────────────────────────────
  Future<void> _onReserve() async {
    debugPrint('[ReservationScreen] 계속 예약 버튼 클릭');

    // 중복 클릭 방지
    if (_isLoading) return;

    // 탑승객 수 체크
    if (_passengers.length < _totalCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '탑승객 정보를 모두 입력해주세요. '
                  '(${_passengers.length}/$_totalCount)'),
        ),
      );
      return;
    }

    final flightController = context.read<FlightController>();
    final dep = flightController.selectedDep;
    final ret = flightController.selectedRet;

    if (dep == null) return;

    // 로그인 정보 가져오기
    final prefs      = await SharedPreferences.getInstance();
    final mid        = prefs.getString('userMid') ?? '';
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final token      = prefs.getString('accessToken') ?? '';
    debugPrint('[ReservationScreen] 로그인: $isLoggedIn / mid: $mid / 토큰: $token');

    // 예약 데이터 생성
    final reservation = ReservationItem(
      mid:             mid,
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
      passengers:      _passengers,
      isRoundTrip:     flightController.isRoundTrip,
      reservedAt:      DateTime.now().toString(),
      status:          '예약완료',
    );

    setState(() => _isLoading = true);

    // 예약 API 호출 (에러 시 에러 메시지 반환)
    final error = await context.read<ReservationController>().addReservation(reservation);
    setState(() => _isLoading = false);

    // 에러 발생 시 스낵바 표시 후 종료
    if (error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // 성공 시 예약 확인 화면으로 이동
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationConfirmScreen(reservation: reservation),
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
      return const Scaffold(
        body: Center(child: Text('항공편 정보가 없습니다')),
      );
    }

    // 총 금액 계산 (성인 1인 기준, 발급 수수료 포함)
    final totalPrice = dep.price + (ret?.price ?? 0) + AirportConstants.issueFee;

    return AppBaseLayout(
      title: '예약하기',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── 출발지 → 도착지 타이틀 ───────────────────
            Text(
              '${controller.depAirportNm} → ${controller.arrAirportNm}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ── 가는편 요약 카드 ──────────────────────────
            FlightSummaryCard(
              label: '가는편',
              depTime:    dep.depPlandTime,
              arrTime:    dep.arrPlandTime,
              depAirport: dep.depAirportNm ?? controller.depAirportNm,
              arrAirport: dep.arrAirportNm ?? controller.arrAirportNm,
              airline:    '${dep.airlineNm ?? '-'} ${dep.flightNo ?? '-'}',
              price:      dep.price,
            ),

            // ── 오는편 요약 카드 (왕복일 때만 표시) ──────
            if (controller.isRoundTrip && ret != null) ...[
              const SizedBox(height: 12),
              FlightSummaryCard(
                label: '오는편',
                depTime:    ret.depPlandTime,
                arrTime:    ret.arrPlandTime,
                depAirport: ret.depAirportNm ?? controller.arrAirportNm,
                arrAirport: ret.arrAirportNm ?? controller.depAirportNm,
                airline:    '${ret.airlineNm ?? '-'} ${ret.flightNo ?? '-'}',
                price:      ret.price,
              ),
            ],

            const SizedBox(height: 24),

            // ── 예약자 정보 ───────────────────────────────
            // 로그인 회원 정보 자동입력 (수정 불가)
            const Text('예약자 정보',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _infoRow('예약자 이름', _bookerName),
                  const Divider(height: 20),
                  _infoRow('이메일', _bookerEmail),
                  const Divider(height: 20),
                  _infoRow('전화번호', _bookerPhone),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 탑승객 선택 ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '탑승객 선택 (${_passengers.length} / $_totalCount명)',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 탑승객 안내 문구
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '예약을 계속 진행하시려면 정확한 승객수 만큼,\n탑승객을 선택/추가해주세요.',
                style: TextStyle(fontSize: 12, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 12),

            // ── 추가된 탑승객 목록 ────────────────────────
            ..._passengers.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // 완료 아이콘
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    // 탑승객 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.passengerType} · ${p.passengerName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${p.passengerBirth} · ${p.passengerGender}',
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // 수정 버튼
                    TextButton(
                      onPressed: () =>
                          _showAddPassengerSheet(editIndex: index),
                      child: const Text('수정',
                          style: TextStyle(color: AppColors.primary)),
                    ),
                    // 삭제 버튼
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: AppColors.textSecondary),
                      onPressed: () =>
                          setState(() => _passengers.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),

            // ── 탑승객 추가하기 버튼 ──────────────────────
            // 탑승객 수가 총 인원 수보다 적을 때만 표시
            if (_passengers.length < _totalCount) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _showAddPassengerSheet,
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: const Text(
                  '탑승객 추가하기',
                  style: TextStyle(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── 금액 요약 ─────────────────────────────────
            // 성인 1인 기준 금액 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _priceRow('가는편 (성인 1인)', dep.price),
                  if (controller.isRoundTrip && ret != null) ...[
                    const SizedBox(height: 8),
                    _priceRow('오는편 (성인 1인)', ret.price),
                  ],
                  const SizedBox(height: 8),
                  _priceRow('발급 수수료', AirportConstants.issueFee,
                      isGrey: true),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('결제 예상금액 (1인)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

            // ── 유의사항 안내 ─────────────────────────────
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
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: 32),

            // ── 계속 예약 버튼 ────────────────────────────
            // 탑승객 수 == 총 인원 수 일 때만 활성화
            CommonButton(
              text: '계속 예약',
              onPressed: _onReserve,
              isEnabled: !_isLoading && _passengers.length == _totalCount,
            ),
          ],
        ),
      ),
    );
  }

  // ── 정보 행 위젯 ──────────────────────────────────────────
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── 금액 행 위젯 ──────────────────────────────────────────
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