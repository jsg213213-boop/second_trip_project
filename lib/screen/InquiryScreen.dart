import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:second_trip_project/util/secure_storage_helper.dart'; // 저장소 헬퍼 사용
import 'WriteInquiryScreen.dart';
import 'InquiryDetailScreen.dart';

class InquiryScreen extends StatefulWidget {
  const InquiryScreen({super.key});

  @override
  State<InquiryScreen> createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final Color classicBlue = const Color(0xFFF7323F);
  List<dynamic> inquiries = [];
  final _storage = SecureStorageHelper(); // 저장소 헬퍼 객체

  @override
  void initState() {
    super.initState();
    fetchInquiries();
  }

  Future<void> fetchInquiries() async {
    // 1. 토큰 가져오기 (WriteInquiryScreen과 동일하게)
    String? token = await _storage.getAccessToken();

    if (token == null || token.isEmpty || token == "null") {
      debugPrint("토큰 없음: 조회 불가능");
      return;
    }

    // 2. 헤더에 Authorization 추가
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/inquiries'), // 서버가 mid를 토큰에서 추출하도록 주소 수정 권장
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("조회 응답 코드: ${response.statusCode}");
    debugPrint("조회 응답 내용: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        inquiries = jsonDecode(utf8.decode(response.bodyBytes));
      });
    }
  }

// InquiryScreen.dart 파일 수정
  Future<void> _goToWriteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteInquiryScreen()),
    );

    // 결과가 true(문의 성공)로 돌아오면
    if (result == true) {
      // 1. 기존 리스트 비우기
      setState(() {
        inquiries = [];
      });
      // 2. 서버에서 데이터 다시 가져오기
      await fetchInquiries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문의 내역을 새로 불러왔습니다.')),
        );
      }
    }
  }

  // ... 이하 build 및 기타 메서드는 그대로 유지
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
            onPressed: _goToWriteScreen,
            child: Text('문의하기', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildInquiryCard(dynamic item) {
    bool isDone = item['reply'] != null && item['reply'].toString().isNotEmpty;
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
                isDone ? '답변완료' : '검토중',
                style: TextStyle(color: isDone ? classicBlue : Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item['title'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),

          child: Text(item['regDate'].toString().substring(0, 10), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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