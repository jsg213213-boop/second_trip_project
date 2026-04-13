import 'package:flutter/material.dart';

// ChangeNotifier를 상속받아 상태 클래스 정의
// 이 클래스의 역할,
// 1) 상태 관리 2) 변경시, 본인 클래스를 구독하고 있는 화면(위젯클래스)에 알려주는 역할
class CounterProvider extends ChangeNotifier {
  int _count = 0; // private 상태 변수

  // getter: 외부에서 읽기 전용으로 접근
  int get count => _count;

  // 상태 변경 메서드
  void increment() {
    _count++;             // 상태 변경
    // 이 부분이 매우 중요함, 방금 위에서, 상태 변경(숫자가 하나 증가), 그리고, 전달하는 메서드
    notifyListeners();    // ← 구독 중인 위젯에게 변경 알림 (재빌드 트리거)
  }

  void decrement() {
    if (_count > 0) _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}