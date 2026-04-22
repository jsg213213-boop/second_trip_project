import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../util/api_client.dart';
import '../../../util/secure_storage_helper.dart';
import '../../data/models/room.dart';
import '../../theme/app_theme.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;
  final String accommodationTitle; // 추가!
  const RoomDetailScreen({super.key, required this.room, required this.accommodationTitle,});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  Set<DateTime> _bookedDates = {};
  bool _isLoading = true;
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadBookedDates();
  }

  Future<void> _loadBookedDates() async {
    final dates = await ApiClient().getBookedDates(
      contentId: widget.room.contentId,
      roomCode: widget.room.roomCode,
    );
    setState(() {
      _bookedDates = dates.map((d) => DateTime.parse(d)).toSet();
      _isLoading = false;
    });
  }

  bool _isBooked(DateTime date) {
    return _bookedDates.any((d) =>
    d.year == date.year &&
        d.month == date.month &&
        d.day == date.day);
  }

  bool _isPeakSeason(DateTime date) =>
      [1, 7, 8, 12].contains(date.month);

  bool _isWeekend(DateTime date) =>
      date.weekday == DateTime.friday ||
          date.weekday == DateTime.saturday;

  int _getPriceForDate(DateTime date) {
    final isPeak = _isPeakSeason(date);
    final isWeekend = _isWeekend(date);
    if (isPeak && isWeekend) return widget.room.peakSeasonWeekend ?? 0;
    if (isPeak && !isWeekend) return widget.room.peakSeasonWeekMin ?? 0;
    if (!isPeak && isWeekend) return widget.room.offSeasonWeekend ?? 0;
    return widget.room.offSeasonWeekMin ?? 0;
  }

  String _getPriceLabel(DateTime date) {
    final isPeak = _isPeakSeason(date);
    final isWeekend = _isWeekend(date);
    if (isPeak && isWeekend) return '성수기 주말';
    if (isPeak && !isWeekend) return '성수기 주중';
    if (!isPeak && isWeekend) return '비수기 주말';
    return '비수기 주중';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  List<Map<String, dynamic>> _getDailyPrices(
      DateTime checkIn, DateTime checkOut) {
    final List<Map<String, dynamic>> dailyPrices = [];
    DateTime date = checkIn;
    while (date.isBefore(checkOut)) {
      dailyPrices.add({
        'date': date,
        'label': _getPriceLabel(date),
        'price': _getPriceForDate(date),
      });
      date = date.add(const Duration(days: 1));
    }
    return dailyPrices;
  }

  // ─── 커스텀 날짜 선택 다이얼로그 ─────────────────
  Future<DateTime?> _showCustomDatePicker({
    required String title,
    required DateTime firstDate,
  }) async {
    DateTime selectedMonth =
    DateTime(firstDate.year, firstDate.month);
    DateTime? selectedDate;

    return await showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final year = selectedMonth.year;
          final month = selectedMonth.month;
          final daysInMonth =
          DateUtils.getDaysInMonth(year, month);
          final firstWeekday =
              DateTime(year, month, 1).weekday % 7;

          return AlertDialog(
            title: Text(title,
                style: const TextStyle(fontSize: 15)),
            contentPadding:
            const EdgeInsets.fromLTRB(12, 8, 12, 0),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 월 이동
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                            Icons.chevron_left,
                            size: 20),
                        onPressed: () {
                          setDialogState(() {
                            selectedMonth = DateTime(
                                selectedMonth.year,
                                selectedMonth.month - 1);
                          });
                        },
                      ),
                      Text(
                        '${year}년 ${month}월',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(
                            Icons.chevron_right,
                            size: 20),
                        onPressed: () {
                          setDialogState(() {
                            selectedMonth = DateTime(
                                selectedMonth.year,
                                selectedMonth.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                  // 요일 헤더
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                    children: [
                      '일', '월', '화', '수', '목', '금', '토'
                    ]
                        .map((d) => SizedBox(
                      width: 32,
                      child: Text(d,
                          textAlign:
                          TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme
                                  .textSecondary,
                              fontWeight:
                              FontWeight.w500)),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  // 날짜 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: daysInMonth + firstWeekday,
                    itemBuilder: (_, index) {
                      if (index < firstWeekday)
                        return const SizedBox();

                      final day = index - firstWeekday + 1;
                      final date =
                      DateTime(year, month, day);
                      final isBooked = _isBooked(date);
                      final isPast = date.isBefore(
                          firstDate.subtract(
                              const Duration(days: 1)));
                      final isPeak = _isPeakSeason(date);
                      final isWeekend = _isWeekend(date);
                      final price = _getPriceForDate(date);
                      final isSelected =
                          selectedDate != null &&
                              selectedDate!.year ==
                                  date.year &&
                              selectedDate!.month ==
                                  date.month &&
                              selectedDate!.day == date.day;
                      final isDisabled = isBooked || isPast;

                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : isPast
                                ? Colors.grey[100]
                                : isBooked
                                ? Colors.red[100]
                                : isPeak
                                ? Colors.orange[50]
                                : Colors.green[50],
                            borderRadius:
                            BorderRadius.circular(6),
                            border: isWeekend &&
                                !isDisabled &&
                                !isSelected
                                ? Border.all(
                                color: Colors.blue[200]!,
                                width: 0.5)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isPast
                                      ? Colors.grey[400]
                                      : isBooked
                                      ? Colors.red[700]
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (!isPast &&
                                  !isBooked &&
                                  price > 0) ...[
                                const SizedBox(height: 1),
                                Text(
                                  _formatPrice(price)
                                      .replaceAll(',', '·'),
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: isSelected
                                        ? Colors.white70
                                        : isPeak
                                        ? Colors.orange[700]
                                        : Colors.green[700],
                                  ),
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                ),
                              ],
                              if (isBooked && !isPast)
                                Text(
                                  '예약중',
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.red[700]),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // 범례
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      _legend(Colors.orange[50]!,
                          Colors.orange[700]!, '성수기'),
                      const SizedBox(width: 8),
                      _legend(Colors.green[50]!,
                          Colors.green[700]!, '비수기'),
                      const SizedBox(width: 8),
                      _legend(Colors.red[100]!,
                          Colors.red[700]!, '예약중'),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소',
                    style: TextStyle(
                        color: AppTheme.textSecondary)),
              ),
              TextButton(
                onPressed: selectedDate != null
                    ? () =>
                    Navigator.pop(context, selectedDate)
                    : null,
                child: const Text('선택',
                    style:
                    TextStyle(color: AppTheme.primary)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          widget.room.roomTitle,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImages(),
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.roomTitle,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoBadge('기준 ${widget.room.baseCount}인'),
                      const SizedBox(width: 8),
                      _infoBadge('최대 ${widget.room.maxCount}인'),
                      const SizedBox(width: 8),
                      _infoBadge('${widget.room.roomCount}실'),
                    ],
                  ),
                  if (widget.room.roomIntro != null &&
                      widget.room.roomIntro!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.room.roomIntro!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
            // ─── 예약 현황 달력 ──────────────────────
            Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('예약 현황',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary))
                      : _buildCalendar(),
                ],
              ),
            ),
            // ─── 가격 정보 ──────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('가격 정보',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _priceItem(
                          label: '비수기 주중',
                          price: widget.room.offSeasonWeekMin),
                      _priceItem(
                          label: '비수기 주말',
                          price:
                          widget.room.offSeasonWeekend),
                      _priceItem(
                          label: '성수기 주중',
                          price:
                          widget.room.peakSeasonWeekMin),
                      _priceItem(
                          label: '성수기 주말',
                          price:
                          widget.room.peakSeasonWeekend),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.room.facilityList.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                color: AppTheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('객실 시설',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.room.facilityList
                          .map((f) => Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFFFF0F1),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(
                                  0xFFFFCDD2),
                              width: 0.5),
                        ),
                        child: Text(f,
                            style: const TextStyle(
                                fontSize: 12,
                                color:
                                AppTheme.primary)),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
              top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: ElevatedButton(
          onPressed: widget.room.roomCount == 0
              ? null
              : () async {
            final isLoggedIn =
            await SecureStorageHelper().isLoggedIn();
            print('===== 로그인 상태: $isLoggedIn =====');

            if (!isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '예약은 회원만 가능합니다. 로그인해주세요!'),
                  backgroundColor: AppTheme.primary,
                  duration: Duration(seconds: 3),
                ),
              );
              return;
            }

            // ─── 커스텀 체크인 날짜 선택 ──────────
            final checkIn = await _showCustomDatePicker(
              title: '체크인 날짜 선택',
              firstDate: DateTime.now(),
            );
            if (checkIn == null) return;

            // ─── 커스텀 체크아웃 날짜 선택 ─────────
            final checkOut = await _showCustomDatePicker(
              title: '체크아웃 날짜 선택',
              firstDate:
              checkIn.add(const Duration(days: 1)),
            );
            if (checkOut == null) return;

            final nights =
                checkOut.difference(checkIn).inDays;
            final dailyPrices =
            _getDailyPrices(checkIn, checkOut);
            final totalPrice = dailyPrices.fold<int>(
                0,
                    (sum, item) =>
                sum + (item['price'] as int));

            // ─── 예약 확인 다이얼로그 ──────────────
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('예약 확인'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.roomTitle,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '체크인: ${checkIn.year}.${checkIn.month}.${checkIn.day}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                      Text(
                        '체크아웃: ${checkOut.year}.${checkOut.month}.${checkOut.day}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary),
                      ),
                      Text('$nights박',
                          style: const TextStyle(
                              fontSize: 13,
                              color:
                              AppTheme.textSecondary)),
                      const Divider(height: 16),
                      const Text('날짜별 요금',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      ...dailyPrices.map((item) {
                        final date =
                        item['date'] as DateTime;
                        final label =
                        item['label'] as String;
                        final price =
                        item['price'] as int;
                        final weekdays = [
                          '월', '화', '수', '목',
                          '금', '토', '일'
                        ];
                        final weekday =
                        weekdays[date.weekday - 1];
                        final isPeak =
                        _isPeakSeason(date);
                        final labelColor = isPeak
                            ? Colors.red[700]!
                            : Colors.blue[700]!;

                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(
                              vertical: 3),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Text(
                                '${date.month}/${date.day}($weekday)',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme
                                        .textSecondary),
                              ),
                              Container(
                                padding: const EdgeInsets
                                    .symmetric(
                                    horizontal: 6,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPeak
                                      ? Colors.red[50]
                                      : Colors.blue[50],
                                  borderRadius:
                                  BorderRadius.circular(
                                      4),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: labelColor,
                                      fontWeight:
                                      FontWeight.w500),
                                ),
                              ),
                              Text(
                                price > 0
                                    ? '${_formatPrice(price)}원'
                                    : '가격문의',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w600,
                                    color: AppTheme
                                        .textPrimary),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('총 결제 금액',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: AppTheme
                                      .textPrimary)),
                          Text(
                            totalPrice > 0
                                ? '${_formatPrice(totalPrice)}원'
                                : '가격문의',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, false),
                    child: const Text('취소',
                        style: TextStyle(
                            color: AppTheme.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context, true),
                    child: const Text('예약하기',
                        style: TextStyle(
                            color: AppTheme.primary)),
                  ),
                ],
              ),
            );
            if (confirm != true) return;

            // ─── 백엔드 API 호출 ──────────────────
            try {
              final result =
              await ApiClient().createReservation(
                contentId: widget.room.contentId,
                roomCode: widget.room.roomCode,
                accommodationTitle: widget.accommodationTitle, // 수정!
                roomTitle: widget.room.roomTitle,
                checkInDate:
                '${checkIn.year}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}',
                checkOutDate:
                '${checkOut.year}-${checkOut.month.toString().padLeft(2, '0')}-${checkOut.day.toString().padLeft(2, '0')}',
                guestCount: 1,
                totalPrice: totalPrice,
              );

              if (result != null) {
                await _loadBookedDates();
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text('예약이 완료됐습니다! 🎉'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e
                      .toString()
                      .replaceAll('Exception: ', '')),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: Text(
            widget.room.displayPrice != '가격문의'
                ? '${widget.room.displayPrice} 예약하기'
                : '예약 문의하기',
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() {
                _currentMonth = DateTime(
                    _currentMonth.year, _currentMonth.month - 1);
              }),
            ),
            Text(
              '${year}년 ${month}월',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() {
                _currentMonth = DateTime(
                    _currentMonth.year, _currentMonth.month + 1);
              }),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['일', '월', '화', '수', '목', '금', '토']
              .map((d) => SizedBox(
            width: 36,
            child: Text(d,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ))
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.7,
          ),
          itemCount: daysInMonth + firstWeekday,
          itemBuilder: (_, index) {
            if (index < firstWeekday) return const SizedBox();

            final day = index - firstWeekday + 1;
            final date = DateTime(year, month, day);
            final isBooked = _isBooked(date);
            final isPast = date.isBefore(
                DateTime.now().subtract(const Duration(days: 1)));
            final isPeak = _isPeakSeason(date);
            final isWeekend = _isWeekend(date);
            final price = _getPriceForDate(date);

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                // 지난 날짜면 무조건 회색
                color: isPast
                    ? Colors.grey[100]
                    : isBooked
                    ? Colors.red[100]
                    : isPeak
                    ? Colors.orange[50]
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(6),
                border: isWeekend && !isBooked && !isPast
                    ? Border.all(
                    color: Colors.blue[200]!, width: 0.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      // 지난 날짜면 무조건 회색
                      color: isPast
                          ? Colors.grey[400]
                          : isBooked
                          ? Colors.red[700]
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (!isPast && !isBooked && price > 0) ...[
                    const SizedBox(height: 1),
                    Text(
                      _formatPrice(price).replaceAll(',', '·'),
                      style: TextStyle(
                        fontSize: 7,
                        color: isPeak
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // 지난 날짜면 예약중 표시 안함
                  if (isBooked && !isPast)
                    Text('예약중',
                        style: TextStyle(
                            fontSize: 7, color: Colors.red[700])),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(
                Colors.orange[50]!, Colors.orange[700]!, '성수기'),
            const SizedBox(width: 12),
            _legend(
                Colors.green[50]!, Colors.green[700]!, '비수기'),
            const SizedBox(width: 12),
            _legend(Colors.red[100]!, Colors.red[700]!, '예약중'),
            const SizedBox(width: 12),
            _legend(
                Colors.grey[100]!, Colors.grey[400]!, '지난날짜'),
          ],
        ),
      ],
    );
  }

  Widget _legend(Color bgColor, Color textColor, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }

  Widget _buildImages() {
    final images =
    [widget.room.img1, widget.room.img2, widget.room.img3]
        .where((img) => img != null && img.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return Container(
        height: 240,
        color: const Color(0xFFEEEEEE),
        child: const Center(
          child: Icon(Icons.bed,
              size: 60, color: Color(0xFFCCCCCC)),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => CachedNetworkImage(
          imageUrl: images[i]!,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Colors.grey[200]),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFEEEEEE),
            child: const Center(
              child: Icon(Icons.bed,
                  size: 60, color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBadge(String label) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
    );
  }

  Widget _priceItem({required String label, required int? price}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(
            price != null && price > 0
                ? '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원'
                : '정보 없음',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}