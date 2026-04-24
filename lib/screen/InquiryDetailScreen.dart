import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InquiryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> inquiryData;

  const InquiryDetailScreen({super.key, required this.inquiryData});

  final Color classicBlue = const Color(0xFFF7323F);

  @override
  Widget build(BuildContext context) {
    // 1. 데이터 안전하게 추출 (Null이면 빈 문자열 처리)
    final status = inquiryData['status']?.toString() ?? '대기중';
    final category = inquiryData['category']?.toString() ?? '일반';
    final date = inquiryData['date']?.toString() ?? '';
    final title = inquiryData['title']?.toString() ?? '제목 없음';
    final content = inquiryData['content']?.toString() ?? '내용 없음';

    bool isDone = status == '답변완료';

    return Scaffold(
      backgroundColor: Colors.white,
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDone ? classicBlue.withOpacity(0.1) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: isDone ? classicBlue : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text('[$category]', style: TextStyle(color: classicBlue, fontWeight: FontWeight.w500, fontSize: 13)),
                const Spacer(),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            const Text('문의 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
            const SizedBox(height: 40),

            // 2. 답변 영역: reply 데이터가 있으면 전달
            if (isDone)
              _buildReplyBox(inquiryData['reply']?.toString() ?? '답변 내용이 없습니다.')
            else
              _buildWaitingBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox(String replyText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FA),
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
          Text(replyText, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildWaitingBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Center(




      ),
    );
  }
}