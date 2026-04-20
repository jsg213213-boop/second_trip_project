import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widget/app_base_layout.dart';
import '../../common/widget/common_button.dart';
import '../controller/flight_controller.dart';
import '../model/flight_item.dart';
import '../utils/format_utils.dart';
import 'flight_detail_screen.dart';

/// 항공편 목록 화면
/// - 검색 결과 항공편 리스트 표시
/// - 정렬 필터 (일정시간/가격/출발시간)
/// - 무한스크롤
/// - 검색 조건 재설정 모달
class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {

  // ── 무한스크롤 컨트롤러 ──────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  // ── 정렬 상태 ─────────────────────────────────────────────
  String _sortType = '일정시간 빠른순';
  final List<String> _sortOptions = [
    '일정시간 빠른순',
    '가격 낮은순',
    '가격 높은순',
    '출발시간 빠른순',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final position = _scrollController.position;
    final isNearEnd = position.pixels >= position.maxScrollExtent - 200;
    if (isNearEnd) {
      context.read<FlightController>().fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── 정렬 적용 ─────────────────────────────────────────────
  List<FlightItem> _sortedItems(List<FlightItem> items) {
    final sorted = List<FlightItem>.from(items);
    switch (_sortType) {
      case '가격 낮은순':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '가격 높은순':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '출발시간 빠른순':
        sorted.sort((a, b) =>
            (a.depPlandTime ?? '').compareTo(b.depPlandTime ?? ''));
        break;
      default:
        sorted.sort((a, b) =>
            (a.depPlandTime ?? '').compareTo(b.depPlandTime ?? ''));
    }
    return sorted;
  }

  // ── body 빌드 ─────────────────────────────────────────────
  Widget _buildBody(FlightController controller) {

    // 상태 1: 로딩 중
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 상태 2: 에러 발생
    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(controller.errorMessage!),
            const SizedBox(height: 12),
            CommonButton(
              text: '다시 시도',
              onPressed: () =>
                  context.read<FlightController>().fetchInitial(
                    depAirportId: controller.depAirportId,
                    arrAirportId: controller.arrAirportId,
                    depPlandTime: controller.depPlandTime,
                    isRoundTrip:  controller.isRoundTrip,
                    adultCount:   controller.adultCount,
                    childCount:   controller.childCount,
                    infantCount:  controller.infantCount,
                  ),
            ),
          ],
        ),
      );
    }

    // 상태 3: 데이터 없음
    if (controller.items.isEmpty) {
      return const Center(child: Text('항공편이 없습니다'));
    }

    final sorted = _sortedItems(controller.items);

    return Column(
      children: [

        // ── 검색 조건 요약 바 ──────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.primaryLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 날짜
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    FormatUtils.date(controller.depPlandTime),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.primary),
                  ),
                ],
              ),

              // 인원 정보
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    FormatUtils.passenger(
                      controller.adultCount,
                      controller.childCount,
                      controller.infantCount,
                    ),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.primary),
                  ),
                ],
              ),

              // 재설정 버튼
              GestureDetector(
                onTap: () => _showResetModal(context, controller),
                child: const Row(
                  children: [
                    Icon(Icons.tune, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      '재설정',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── 정렬 필터 탭 (가로 스크롤) ────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: _sortOptions.map((option) {
              final isSelected = _sortType == option;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _sortType = option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── 항공편 리스트 (무한스크롤) ─────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: sorted.length + 1,
            itemBuilder: (context, index) {

              if (index == sorted.length) {
                if (controller.isFetchingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!controller.hasMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '모든 항공편을 불러왔습니다 ✅',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final item = sorted[index];
              return _flightCard(context, item, controller);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ AppBaseLayout 적용
    return Consumer<FlightController>(
      builder: (context, controller, _) {
        return AppBaseLayout(
          title:
          '${FlightItem.getAirportName(controller.depAirportId)} → '
              '${FlightItem.getAirportName(controller.arrAirportId)}',
          body: _buildBody(controller),
        );
      },
    );
  }

  // ── 검색 조건 재설정 모달 ─────────────────────────────────
  void _showResetModal(BuildContext context, FlightController controller) {
    String? tempDep = controller.depAirportId;
    String? tempArr = controller.arrAirportId;
    DateTime tempDate = DateTime(
      int.parse(controller.depPlandTime.substring(0, 4)),
      int.parse(controller.depPlandTime.substring(4, 6)),
      int.parse(controller.depPlandTime.substring(6, 8)),
    );
    // ✅ 왕복일 때 오는편 날짜 초기값
    DateTime tempRetDate =
        controller.retDate ?? tempDate.add(const Duration(days: 3));
    int tempAdult  = controller.adultCount;
    int tempChild  = controller.childCount;
    int tempInfant = controller.infantCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {

          String formatDisplay(DateTime date) {
            const days = ['월', '화', '수', '목', '금', '토', '일'];
            return '${date.month}.${date.day} ${days[date.weekday - 1]}';
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Text(
                  '검색 조건 변경',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // ── 출발지 / 도착지 ─────────────────────
                const Text('출발지 / 도착지',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final airports =
                          FlightItem.airportCodes.entries.toList();
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('출발지 선택'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: airports.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(airports[i].value),
                                    onTap: () {
                                      setModalState(
                                              () => tempDep = airports[i].key);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            FlightItem.getAirportName(tempDep),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () => setModalState(() {
                        final t = tempDep;
                        tempDep = tempArr;
                        tempArr = t;
                      }),
                      icon: const Icon(Icons.swap_horiz,
                          color: AppColors.primary),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final airports =
                          FlightItem.airportCodes.entries.toList();
                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('도착지 선택'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: airports.length,
                                  itemBuilder: (_, i) => ListTile(
                                    title: Text(airports[i].value),
                                    onTap: () {
                                      setModalState(
                                              () => tempArr = airports[i].key);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            FlightItem.getAirportName(tempArr),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── 출발 날짜 선택 ─────────────────────
                const Text('출발 날짜',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempDate,
                      firstDate: now,
                      lastDate: DateTime(now.year + 1),
                    );
                    if (picked != null) {
                      setModalState(() => tempDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          formatDisplay(tempDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 오는편 날짜 선택 (왕복일 때만) ──────
                if (controller.isRoundTrip) ...[
                  const SizedBox(height: 16),
                  const Text('귀환 날짜',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempRetDate,
                        firstDate: tempDate,
                        lastDate: DateTime(tempDate.year + 1),
                      );
                      if (picked != null) {
                        setModalState(() => tempRetDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            formatDisplay(tempRetDate),
                            style:
                            const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── 인원 선택 ──────────────────────────
                const Text('인원',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _modalPassengerRow(
                      label: '성인',
                      count: tempAdult,
                      onMinus: () {
                        if (tempAdult > 1) setModalState(() => tempAdult--);
                      },
                      onPlus: () => setModalState(() => tempAdult++),
                    ),
                    _modalPassengerRow(
                      label: '소아',
                      count: tempChild,
                      onMinus: () {
                        if (tempChild > 0) setModalState(() => tempChild--);
                      },
                      onPlus: () => setModalState(() => tempChild++),
                    ),
                    _modalPassengerRow(
                      label: '유아',
                      count: tempInfant,
                      onMinus: () {
                        if (tempInfant > 0) setModalState(() => tempInfant--);
                      },
                      onPlus: () => setModalState(() => tempInfant++),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 검색 버튼 ─────────────────────────
                CommonButton(
                  text: '검색',
                  onPressed: () {
                    Navigator.pop(context);
                    final dateStr =
                        '${tempDate.year}'
                        '${tempDate.month.toString().padLeft(2, '0')}'
                        '${tempDate.day.toString().padLeft(2, '0')}';
                    context.read<FlightController>().fetchInitial(
                      depAirportId: tempDep ?? controller.depAirportId,
                      arrAirportId: tempArr ?? controller.arrAirportId,
                      depPlandTime: dateStr,
                      isRoundTrip:  controller.isRoundTrip,
                      adultCount:   tempAdult,
                      childCount:   tempChild,
                      infantCount:  tempInfant,
                      retDate: controller.isRoundTrip ? tempRetDate : null,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── 모달 인원 선택 행 ─────────────────────────────────────
  Widget _modalPassengerRow({
    required String label,
    required int count,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        Row(
          children: [
            IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline),
              color: count > 0 ? AppColors.primary : AppColors.textSecondary,
              iconSize: 20,
            ),
            Text('$count',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
              iconSize: 20,
            ),
          ],
        ),
      ],
    );
  }

  // ── 항공편 카드 ───────────────────────────────────────────
  Widget _flightCard(
      BuildContext context, FlightItem item, FlightController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: item.seatsLeft == 0 ? null : () {
          controller.selectDep(item);
          Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const FlightDetailScreen()));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 항공사명 + 편명 + 잔여석 ──────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.airlineNm ?? '-'} ${item.flightNo ?? '-'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  item.seatsLeft == 0
                      ? const Text(
                    '마감',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                      : Text(
                    '잔여 ${item.seatsLeft}석',
                    style: TextStyle(
                      color: item.seatsLeft <= 10
                          ? AppColors.danger
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 출발 → 도착 시각 + 소요시간 ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatUtils.time(item.depPlandTime),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.depAirportNm ?? '-',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        FormatUtils.duration(
                            item.depPlandTime, item.arrPlandTime),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.textSecondary, size: 16),
                      const Text('직항',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.time(item.arrPlandTime),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.arrAirportNm ?? '-',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 가격 + 성인 1인 기준 ───────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Column(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}