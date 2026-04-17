import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/calendar_controller.dart';
import '../controller/rent_comp_controller.dart';
import 'car_rent_screen.dart';
import 'table_calendar_screen.dart';

class CarRentHomeScreen extends StatefulWidget {
  const CarRentHomeScreen({super.key});

  @override
  State<CarRentHomeScreen> createState() => _CarRentHomeScreenState();
}

class _CarRentHomeScreenState extends State<CarRentHomeScreen> {
  static const List<String> _regions = [
    '서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종',
    '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주',
  ];

  String? _selectedRegion;

  Future<void> _navigateToCalendar(BuildContext context) async {
    final calendar = context.read<CalendarController>();
    final saved = calendar.saveState();
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TableCalendarScreen()),
    );
    if (confirmed != true) {
      calendar.restoreState(saved);
    }
  }

  String _formatDate(DateTime date) {
    const weekDay = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}.${date.month}.${date.day} (${weekDay[date.weekday - 1]})';
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarController>();

    return Scaffold(
      appBar: AppBar(title: const Text('렌터카 예약')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지역 선택
            const Text('지역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRegion,
              hint: const Text('지역을 선택하세요'),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (value) => setState(() => _selectedRegion = value),
            ),

            const SizedBox(height: 24),

            // 인수일
            const Text('인수일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _DateTile(
              label: calendar.rangeStart != null
                  ? _formatDate(calendar.rangeStart!)
                  : '날짜를 선택하세요',
              time: calendar.startTime,
              onTap: () => _navigateToCalendar(context),
            ),

            const SizedBox(height: 24),

            // 반납일
            const Text('반납일', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _DateTile(
              label: calendar.rangeEnd != null
                  ? _formatDate(calendar.rangeEnd!)
                  : '날짜를 선택하세요',
              time: calendar.endTime,
              onTap: () => _navigateToCalendar(context),
            ),

            const Spacer(),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_selectedRegion != null &&
                        calendar.rangeStart != null &&
                        calendar.rangeEnd != null)
                    ? () async {
                        final cal = context.read<CalendarController>();
                        final start = cal.rangeStart!;
                        final end = cal.rangeEnd!;
                        final startDate = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
                        final endDate = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

                        final controller = context.read<RentCompController>();
                        await controller.fetchByRegion(_selectedRegion!);
                        await controller.fetchAvailableCars(startDate, endDate);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CarRentScreen()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('확인', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String? time;
  final VoidCallback onTap;

  const _DateTile({required this.label, this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                time != null ? '$label  $time' : label,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}