import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 환경변수 패키지 추가
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
    // 1. 토큰 가져오기
    String? token = await _storage.getAccessToken();

    if (token == null || token.isEmpty || token == "null") {
      debugPrint("토큰 없음: 조회 불가능");
      return;
    }

    // 💡 1. .env에서 값을 가져옵니다.
    final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

    // 💡 2. 이미 'http'가 포함되어 있는지 확인하고, 없으면 붙입니다.
    String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

    // 💡 3. 만약 포트(:8080)가 이미 포함되어 있지 않다면 붙입니다.
    if (!baseUrl.contains(':8080')) {
      baseUrl = '$baseUrl:8080';
    }

    // 💡 4. 슬래시(/) 처리를 고려하여 최종 URL 조합 (api/inquiries 경로 사용)
    final String finalUrl = baseUrl.endsWith('/')
        ? '${baseUrl}api/inquiries'
        : '$baseUrl/api/inquiries';

    // 💡 5. 요청 실행
    final response = await http.get(
      Uri.parse(finalUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("조회 응답 코드: ${response.statusCode}");

    if (response.statusCode == 200) {
      setState(() {
        inquiries = jsonDecode(utf8.decode(response.bodyBytes));
      });
    }
  }

  Future<void> _goToWriteScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WriteInquiryScreen()),
    );

    if (result == true) {
      setState(() {
        inquiries = [];
      });
      await fetchInquiries();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('문의 내역을 새로 불러왔습니다.')),
        );
      }
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
              child: Text(item['title'] ?? '제목 없음', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(item['regDate']?.toString().substring(0, 10) ?? '', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
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