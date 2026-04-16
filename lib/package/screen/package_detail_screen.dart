import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/package_item.dart';

class PackageDetailScreen extends StatefulWidget {

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
    print('백엔드 예약 전송 시작: ${item.id}');
    // 추후 서버 통신 코드 작성 예정
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item.title} 예약이 완료되었습니다!")),
    );
  }

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
                    onPressed: () => Navigator.pop(context),
                    child: const Text("취소"),
                  ),
                  ElevatedButton(
                    key: const Key('confirm_booking_button'),
                    onPressed: () {
                      Navigator.pop(context); // 모달 닫기
                      _processBooking(context, widget.item); // 예약 로직 실행
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent[400]),
                    child: const Text("예", style: TextStyle(color: Colors.white)),
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