import 'package:flutter/material.dart';

const weekDays = ['월', '화', '수', '목', '금', '토', '일'];

/// 날짜를 "2026.04.18 (토)" 형식의 문자열로 변환
/// [showWeekDay] true면 요일 포함, false면 날짜만
String formatDate(DateTime date, {bool showWeekDay = true, String separator = '.'}) {
  final weekDay = showWeekDay ? ' (${weekDays[date.weekday - 1]})' : '';
  return '${date.year}$separator${date.month.toString().padLeft(2, '0')}$separator${date.day.toString().padLeft(2, '0')}$weekDay';
}

/// 시간 문자열("오후 7:30")을 TimeOfDay(hour: 19, minute: 30)로 변환
TimeOfDay? formatTime(String? timeStr) {
  if (timeStr == null) return null;
  final isPm = timeStr.startsWith('오후'); //오전 오후 구분
  final timePart = timeStr.split(' ')[1]; //시간 부분
  final parts = timePart.split(':');
  int hour = int.parse(parts[0]); //시 부분
  final minute = int.parse(parts[1]); //분 부분
  if (isPm && hour != 12) hour += 12; //오후라면 시간에 12더해줌
  if (!isPm && hour == 12) hour = 0; //딱 오전 12시라면 0으로 적어줌
  return TimeOfDay(hour: hour, minute: minute);
}

/// ISO 날짜 문자열("2026-04-17" 또는 "2026-04-17T14:00:00")을 "2026.04.17" 형식으로 변환
String formatDateString(String date, String fromSeparateStr, String toSeparateStr) {
  if (date.length < 10) return date;
  return date.substring(0, 10).replaceAll(fromSeparateStr, toSeparateStr);
}

//돈 문자열
String formatPrice(int price) {
  final buffer = StringBuffer();
  final str = price.toString();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');  //역순으로 3자리마다 콤마 찍음
    buffer.write(str[i]);
  }
  return buffer.toString();
}