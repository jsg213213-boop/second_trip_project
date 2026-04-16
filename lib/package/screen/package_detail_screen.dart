import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/package_item.dart';

class PackageDetailScreen extends StatefulWidget {

  //단위 테스트용 변수 추가
  static bool isTesting = false;

  final PackageItem item;
  const PackageDetailScreen({super.key, required this.item});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final NumberFormat _numberFormat = NumberFormat('#,###');



  // 예약 처리 로직
  Future<void> _processBooking(BuildContext context, PackageItem item) async {

    if (PackageDetailScreen.isTesting) {
      print('테스트 모드: 통신 없이 예약 완료 처리');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("테스트 패키지 예약이 완료되었습니다!")),
      );
      return;
    }

    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';

    try {
      print('백엔드 예약 전송 시작: ${item.id}');

      // 1. 서버로 데이터 전송 (위에서 만든 함수 활용)
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/api/reservations/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "memberId": 1, // 필요에 따라 변경
          "packageId": item.id,
          "reservationDate": DateTime.now().toString().substring(0, 10), // 날짜 포맷 확인 필요
          "peopleCount": 1,
          "totalPrice": item.price,
        }),
      );

      // 2. 결과 확인
      if (response.statusCode == 200) {
        // 서버 저장 성공 시 기존 로직 실행
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${item.title} 예약이 완료되었습니다!")),
          );
        }
      } else {
        // 서버 에러 발생 시 처리
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      // 3. 통신 실패 시 에러 메시지
      print('예약 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("예약에 실패했습니다. 다시 시도해주세요.")),
        );
      }
    }
  }

  //테스트 전용 코드(주석 안해도됨)
  Widget _buildThumbnail(String url) {
    if (PackageDetailScreen.isTesting) {
      return Container(height: 250, color: Colors.grey);
    }
    return Image.network(url, height: 250, width: double.infinity, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // [고정 버튼] 하단에 항상 고정되는 예약하기 버튼
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: ElevatedButton(
          key: const Key('reserve_button'),
          onPressed: () {
            // [모달창 띄우기]
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                key: const Key('reserve_dialog'),
                title: const Text("예약 확인"),
                content: const Text("해당 패키지 상품을 예약하시겠습니까?"),
                actions: [
                  TextButton(
                    child: const Text('취소'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    key: const Key('confirm_booking_button'),
                    child: const Text('확인'),
                    onPressed: () async {
                      // 1. 실제 예약 로직 호출
                      await _processBooking(context, widget.item);

                      // 2. 모달 닫기
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("예약하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.item.thumbnail, height: 250, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("${_numberFormat.format(widget.item.price)}원",
                        style: TextStyle(fontSize: 20, color: Colors.pinkAccent[400], fontWeight: FontWeight.bold)),
                    const Divider(height: 30),

                    _buildSectionTitle("포함사항"),
                    Text(widget.item.inclusions.join(", ")),
                    const SizedBox(height: 20),

                    _buildSectionTitle("불포함사항"),
                    Text(widget.item.exclusions.join(", ")),
                    const Divider(height: 30),

                    _buildSectionTitle("여행 일정"),
                    ...widget.item.itinerary.map((dayPlan) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Day ${dayPlan['day']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ...List.generate(dayPlan['activities'].length, (i) => Text("• ${dayPlan['activities'][i]}")),
                        const SizedBox(height: 20),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 제목 위젯 생성 메소드 (클래스 내부 정의)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}