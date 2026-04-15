import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InquiryDetailScreen extends StatelessWidget {
  // InquiryScreen에서 넘겨받을 데이터 변수
  final Map<String, String> inquiryData;

  const InquiryDetailScreen({super.key, required this.inquiryData});

  final Color classicBlue = const Color(0xFF004680);

  @override
  Widget build(BuildContext context) {
    bool isDone = inquiryData['status'] == '답변완료';

    return Scaffold(
      backgroundColor: Colors.white, // 상세 페이지는 깨끗한 화이트 배경
      appBar: AppBar(
        title: const Text('문의 상세 보기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 영역 (상태 배지, 카테고리, 날짜)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone ? classicBlue.withOpacity(0.1) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    inquiryData['status']!,
                    style: TextStyle(color: isDone ? classicBlue : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text('[${inquiryData['category']}]', style: TextStyle(color: classicBlue, fontWeight: FontWeight.w500, fontSize: 13)),
                const Spacer(),
                Text(inquiryData['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),

            // 2. 제목 영역
            Text(
              inquiryData['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(), // 구분선
            const SizedBox(height: 24),

            // 3. 문의 내용 영역
            const Text('문의 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Text(
              inquiryData['content']!,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6), // 가독성을 위한 줄간격
            ),
            const SizedBox(height: 40),

            // 4. 답변 영역 (답변이 있을 때만 표시)
            if (isDone) _buildReplyBox() else _buildWaitingBox(),
          ],
        ),
      ),
    );
  }

  // 답변 완료 박스 위젯
  Widget _buildReplyBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FA), // 아주 연한 블루톤 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.arrow_turn_down_right, size: 16, color: classicBlue),
              const SizedBox(width: 6),
              const Text('트래블허브 답변', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            inquiryData['reply']!,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 답변 대기 중 박스 위젯!
  Widget _buildWaitingBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '답변을 기다리고 있습니다.\n빠른 시일 내에 답변해 드리겠습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ),
    );
  }
}