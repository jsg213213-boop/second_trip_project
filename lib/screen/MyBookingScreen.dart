import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({super.key});

  final Color classicBlue = const Color(0xFF004680);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('내 예약 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBookingSection('다가오는 여행', true),
          // ✈️ 항공
          _buildBookingCard(
            type: '항공',
            title: '김포(GMP) → 제주(CJU)',
            date: '2026.05.20 - 2026.05.23',
            status: '예약확정',
            color: classicBlue,
            icon: CupertinoIcons.airplane,
          ),
          const SizedBox(height: 12),
          // 🏨 숙소 (추가!)
          _buildBookingCard(
            type: '숙소',
            title: '제주 신라호텔 (디럭스 룸)',
            date: '2026.05.20 - 2026.05.23 (3박)',
            status: '예약완료',
            color: Colors.teal[700]!, // 숙소는 차분한 테일 색상
            icon: CupertinoIcons.bed_double_fill,
          ),
          const SizedBox(height: 12),
          // 🚗 렌터카
          _buildBookingCard(
            type: '렌터카',
            title: '제주공항 인수 (현대 아반떼 CN7)',
            date: '2026.05.20 14:00 ~',
            status: '예약완료',
            color: Colors.orange[700]!,
            icon: CupertinoIcons.car_fill,
          ),

          const SizedBox(height: 24),

          _buildBookingSection('지난 여행', false),
          // 🏨 지난 숙소 내역
          _buildBookingCard(
            type: '숙소',
            title: '강릉 세인트존스 호텔',
            date: '2026.03.10 - 2026.03.11 (1박)',
            status: '이용완료',
            color: Colors.grey,
            icon: CupertinoIcons.bed_double_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection(String title, bool isUpcoming) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isUpcoming ? Colors.black : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required String type,
    required String title,
    required String date,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            print('$title 상세 정보로 이동');
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: color.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(type, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                    Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(CupertinoIcons.chevron_forward, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}