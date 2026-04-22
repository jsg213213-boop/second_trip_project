import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/calendar_controller.dart';
import '../controller/car_rent_home_controller.dart';
import '../util/car_format_util.dart';
import '../controller/car_rent_list_controller.dart';
import 'car_list_screen.dart';
import 'calendar_screen.dart';

class CarRentHomeScreen extends StatefulWidget {
  const CarRentHomeScreen({super.key});

  @override
  State<CarRentHomeScreen> createState() => _CarRentHomeScreenState();
}

class _CarRentHomeScreenState extends State<CarRentHomeScreen> {
  String? _selectedRegion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarRentHomeController>().fetchRegions();
    });
  }

  Future<void> _navigateToCalendar(BuildContext context) async {
    final calendar = context.read<CalendarController>();
    final saved = calendar.saveState();
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: calendar, //현재 provider를 이곳과 달력화면에서 같이 써야 해서 값을 넘겨줌
          child: const CalendarScreen(),
        ),
      ),
    );
    if (confirmed != true) {
      calendar.restoreState(saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.watch<CalendarController>();

    final regions = context.watch<CarRentHomeController>().regions;

    return Scaffold(
      appBar: AppBar(title: const Text('렌터카 예약')),
      body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 지역 선택
                const Text(
                  '지역',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRegion,
                  menuMaxHeight: 600,
                  hint: const Text('지역을 선택하세요'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: regions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedRegion = value),
                ),

                const SizedBox(height: 24),

                // 인수일
                const Text(
                  '인수일',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _DateTile(
                  label: calendar.rangeStart != null
                      ? formatDate(calendar.rangeStart!)
                      : '날짜를 선택하세요',
                  time: calendar.startTime,
                  onTap: () => _navigateToCalendar(context),
                ),

                const SizedBox(height: 24),

                // 반납일
                const Text(
                  '반납일',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _DateTile(
                  label: calendar.rangeEnd != null
                      ? formatDate(calendar.rangeEnd!)
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
                    onPressed: (_selectedRegion == null ||
                            calendar.rangeStart == null ||
                            calendar.rangeEnd == null)
                        ? null
                        : () {
                            final startDate = formatDate(
                              calendar.rangeStart!,
                              showWeekDay: false,
                              separator: '-',
                            );
                            final endDate = formatDate(
                              calendar.rangeEnd!,
                              showWeekDay: false,
                              separator: '-',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: context.read<CarRentListController>(),
                                  child: CarListScreen(
                                    region: _selectedRegion!,
                                    startDate: startDate,
                                    endDate: endDate,
                                    startTime: calendar.startTime,
                                    endTime: calendar.endTime,
                                  ),
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: Colors.blueAccent,
            ),
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
