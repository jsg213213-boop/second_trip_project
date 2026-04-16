import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'WriteInquiryScreen.dart';
import 'InquiryDetailScreen.dart';

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final Color classicBlue = const Color(0xFF004680);

  // 1. 문의 내역 데이터 (나중에 DB와 연동될 리스트)
  List<Map<String, String>> inquiries = [
    {
      'title': '비행기 예약 취소 관련 문의드립니다.',
      'date': '2026.04.14',
      'category': '취소/환불',
      'status': '답변완료',
      'content': '갑작스런 일정 변경으로 취소하고 싶은데 수수료가 얼마나 나오는지, 환불 규정은 어떻게 되는지 궁금합니다.',
      'reply': '안녕하세요, 트래블허브입니다. 해당 건은 항공사 규정에 따라 취소 시 5만원의 위약금이 발생합니다.'
    },
    {
      'title': '호텔 체크인 시간 변경 가능한가요?',
      'date': '2026.04.12',
      'category': '이용문의',
      'status': '검토중',
      'content': '오후 2시쯤 도착할 것 같은데 혹시 얼리 체크인이 가능할까요?',
      'reply': ''
    },
  ];

  // ⭐ 2. 작성 페이지로 이동하고 결과 받아오는 함수
  Future<void> _goToWriteScreen() async {
    // Navigator.push가 완료될 때까지 await(기다림)!
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteInquiryScreen()),
    );

    // ⭐ 작성 페이지에서 데이터를 가지고 돌아왔을 때 (등록 버튼 클릭 시)
    if (result != null && result is Map<String, String>) {
      setState(() {
        // 리스트 맨 앞에 추가!
        inquiries.insert(0, result);
      });

      // 등록 완료 안내
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문의가 정상적으로 등록되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('1:1 문의 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _goToWriteScreen, // ⭐ 수정된 함수 연결
            child: Text(
              '문의하기',
              style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
      body: inquiries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inquiries.length,
        itemBuilder: (context, index) => _buildInquiryCard(inquiries[index]),
      ),
    );
  }

  Widget _buildInquiryCard(Map<String, String> item) {
    bool isDone = item['status'] == '답변완료';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDone ? classicBlue.withOpacity(0.1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['status']!,
                style: TextStyle(color: isDone ? classicBlue : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item['title']!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(item['date']!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ),
        trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InquiryDetailScreen(inquiryData: item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.chat_bubble_2, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('문의 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}