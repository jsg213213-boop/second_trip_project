import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/reservation_item.dart';

class ReservationController with ChangeNotifier {

  // ── 상태 변수 ─────────────────────────────────────────────
  final List<ReservationItem> _items = [];
  bool    _isLoading    = false;
  String? _errorMessage;

  List<ReservationItem> get items        => _items;
  bool                  get isLoading    => _isLoading;
  String?               get errorMessage => _errorMessage;

  // ── 예약 목록 조회 (스프링부트 GET) ──────────────────────
  // ✅ [변경 전] passengerName 으로 조회 (주석처리)
  // Future<void> fetchReservations(String passengerName) async { ... }

  // ✅ [변경 전] memberId 로 조회
  // Future<void> fetchReservations(String memberId) async {
  //   final url = '$baseUrl/airport/reservations/member?memberId=$memberId';
  // }

  // ✅ [변경 후] mid 로 변경
  Future<void> fetchReservations(String mid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('[ReservationController] 예약 목록 조회 → mid: $mid');

    try {
      final baseUrl = dotenv.env['SPRING_BASE_URL'] ?? '';
      // ✅ [변경 전] /reservations/member?memberId=
      // ✅ [변경 후] /reservations/my?mid=
      final url = '$baseUrl/airport/reservations/my?mid=$mid';

      debugPrint('[ReservationController] 요청 URL: $url');

      final response = await http.get(Uri.parse(url));
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        _items.clear();
        _items.addAll(
          data.map((e) => ReservationItem.fromJson(e)).toList(),
        );
        debugPrint('[ReservationController] 조회 완료 → ${_items.length}건');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── 예약 추가 (스프링부트 POST) ───────────────────────────
  // ✅ [변경 전] 메모리에 직접 추가
  // void addReservation(ReservationItem item) {
  //   _items.add(item);
  //   notifyListeners();
  // }
  // ✅ [변경 후] 스프링부트 API 호출
  Future<void> addReservation(ReservationItem item) async {
    debugPrint('[ReservationController] 예약 등록 → 탑승객: ${item.passengerName}');

    try {
      final baseUrl = dotenv.env['SPRING_BASE_URL'] ?? '';
      final url = '$baseUrl/airport/reservations';

      debugPrint('[ReservationController] 요청 URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      );

      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        // ✅ [변경 전] fetchReservations(item.passengerName)
        // ✅ [변경 후] mid 로 조회
        if (item.mid != null) {
          await fetchReservations(item.mid!);
        }
        debugPrint('[ReservationController] 예약 등록 완료');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
    }

    notifyListeners();
  }

  // ── 예약 취소 (스프링부트 DELETE) ────────────────────────
  // ✅ [변경 전] 메모리에서 index로 삭제
  // void cancelReservation(int index) {
  //   _items.removeAt(index);
  //   notifyListeners();
  // }
  // ✅ [변경 후] 스프링부트 API 호출
  Future<void> cancelReservation(int index) async {
    final item = _items[index];

    debugPrint('[ReservationController] 예약 취소 → id: ${item.id}');

    try {
      final baseUrl = dotenv.env['SPRING_BASE_URL'] ?? '';
      final url = '$baseUrl/airport/reservations/${item.id}';

      debugPrint('[ReservationController] 요청 URL: $url');

      final response = await http.delete(Uri.parse(url));
      debugPrint('[ReservationController] 상태코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        _items.removeAt(index);
        debugPrint('[ReservationController] 취소 완료 → '
            '남은 예약: ${_items.length}건');
      } else {
        _errorMessage = '서버 오류: ${response.statusCode}';
        debugPrint('[ReservationController] 서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      debugPrint('[ReservationController] 네트워크 오류: $e');
    }

    notifyListeners();
  }

  // ── 국내 예약만 필터 ──────────────────────────────────────
  List<ReservationItem> get domesticItems =>
      _items.where((e) => !e.isRoundTrip || e.depAirportId != null).toList();
}