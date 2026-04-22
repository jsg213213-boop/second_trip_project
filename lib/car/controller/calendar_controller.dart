import 'package:flutter/material.dart';

class CalendarController extends ChangeNotifier {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String? _startTime;
  String? _endTime;

  /// 달력 첫달 설정을 위한 날짜
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  /// 처음 선택한 날짜 값, 시작 날짜를 선택 하면  그걸 범위 시작값에 넣음
  DateTime? get rangeStart => _rangeStart;
  /// 끝 선택한 날짜 값, 끝 날짜를 선택 하면 그걸 범위 끝값에 넣음
  DateTime? get rangeEnd => _rangeEnd;
  /// 선택한 시작 시간
  String? get startTime => _startTime;
  /// 선택한 끝 시간
  String? get endTime => _endTime;

  ///선택 시간 목록 리스트: 오전 8시 ~ 오후 8시, 30분 간격
  static final List<String> timeSlots = [
    for (int hour = 8; hour <= 20; hour++)
      for (int minute = 0; minute < 60; minute += 30)
        if (!(hour == 20 && minute == 30))
          //padLeft(문자길이, '0')는 문자길이보다 짧으면 왼쪽에 0으로 채움
          //시간이 12가 넘으면 오후 안넘으면 오전을 붙이고, 12보다 크면 12를 빼서 오후의 시간으로 적어주고 나머지는 그냥 오전의 시간으로 적어줌
          '${hour >= 12 ? "오후" : "오전"} ${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')}',
          //오후 1:30  이렇게 나옴
  ];

  /// 선택된 시작시간을 저장
  void setStartTime(String time) {
    _startTime = time;
    notifyListeners();
  }

  /// 선택된 끝시간을 저장
  void setEndTime(String time) {
    _endTime = time;
    notifyListeners();
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

  ///날짜범위를 지정하기 위한 rangeStart/rangeEnd값 설정 로직
  void onDaySelected(DateTime selectedDay) {
    //시간 선택시 범위시작값이 없거나 범위끝값이 있을땐(즉, 한번도 날짜를 선택 하지 않았거나 시작 끝을 모두 선택했거나)
    if (_rangeStart == null || _rangeEnd != null) {
      _rangeStart = selectedDay;  //범위시작값에 선택된 날짜를 넣어주고, 범위끝값을 없애줌
      _rangeEnd = null;
    } else {  //시작 날짜만 선택 했을때
      if (!selectedDay.isAfter(_rangeStart!)) { //범위시작값보다 이전 날짜가 선택되었다면
        _rangeStart = selectedDay;  //시작 날짜를 다시 설정
      } else {
        _rangeEnd = selectedDay;
      }
    }
    notifyListeners();
  }
}