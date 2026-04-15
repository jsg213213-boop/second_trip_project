import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/package_item.dart';

class PackageDetailScreen extends StatelessWidget {
  final PackageItem item;
  final numberFormat = NumberFormat('#,###');

  PackageDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // 1. 여기에 고정된 하단 버튼 배치
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: 예약 로직 구현
            print("예약하기 버튼 클릭 확인");
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
          // 버튼이 가리지 않도록 하단 여백 유지
          child: Column(
            children: [
              Image.network(item.thumbnail, height: 250, width: double.infinity, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("${numberFormat.format(item.price)}원",
                        style: TextStyle(fontSize: 20, color: Colors.pinkAccent[400], fontWeight: FontWeight.bold)),
                    const Divider(height: 30),
                    _buildSectionTitle("포함사항"),
                    Text(item.inclusions.join(", ")),
                    const SizedBox(height: 20),
                    _buildSectionTitle("여행 일정"),
                    ...item.itinerary.map((dayPlan) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Day ${dayPlan['day']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ...List.generate(dayPlan['activities'].length, (i) => Text("• ${dayPlan['activities'][i]}")),
                        const SizedBox(height: 10),
                      ],
                    )),
                    // 이제 하단 여백은 bottomNavigationBar가 대신해주므로 크게 줄여도 됩니다.
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}