import 'package:flutter/material.dart';

class CalendarController extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String? _startTime;
  String? _endTime;

  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;
  String? get startTime => _startTime;
  String? get endTime => _endTime;

  // 오전 8시 ~ 오후 8시, 30분 간격 시간 목록
  static final List<String> timeSlots = [
    for (int h = 8; h <= 20; h++)
      for (int m = 0; m < 60; m += 30)
        if (!(h == 20 && m == 30))
          '${h >= 12 ? "오후" : "오전"} ${h > 12 ? h - 12 : h}:${m.toString().padLeft(2, '0')}',
  ];

  void setStartTime(String time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(String time) {
    _endTime = time;
    notifyListeners();
  }

  /// 시간 문자열("오전 10:30")을 TimeOfDay로 변환
  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final isPm = timeStr.startsWith('오후');
    final timePart = timeStr.split(' ')[1]; // "10:30"
    final parts = timePart.split(':');
    int hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // 상태 백업/복원 (뒤로가기 시 원래 상태로 되돌리기 용)
  Map<String, dynamic> saveState() => {
    'rangeStart': _rangeStart,
    'rangeEnd': _rangeEnd,
    'startTime': _startTime,
    'endTime': _endTime,
    'selectedDay': _selectedDay,
    'focusedDay': _focusedDay,
  };

  void restoreState(Map<String, dynamic> state) {
    _rangeStart = state['rangeStart'];
    _rangeEnd = state['rangeEnd'];
    _startTime = state['startTime'];
    _endTime = state['endTime'];
    _selectedDay = state['selectedDay'];
    _focusedDay = state['focusedDay'] ?? DateTime.now();
    notifyListeners();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // 첫 번째 탭: 시작일 설정
    // 두 번째 탭: 종료일 설정
    // 세 번째 탭: 초기화 후 새 시작일
    if (_rangeStart == null || _rangeEnd != null) {
      _rangeStart = selectedDay;
      _rangeEnd = null;
    } else {
      if (!selectedDay.isAfter(_rangeStart!)) {
        _rangeStart = selectedDay;
      } else {
        _rangeEnd = selectedDay;
      }
    }
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }
}