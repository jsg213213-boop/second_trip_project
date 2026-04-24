import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'NoticeWriteScreen.dart';
import 'NoticeDetailScreen.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  bool isAdmin = true;
  List<Map<String, String>> notices = [];

  @override
  void initState() {
    super.initState();
    _checkRole();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {
      // 💡 1. .env에서 값을 가져옵니다.
      final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

      // 💡 2. http 프로토콜 자동 확인 및 붙이기
      String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

      // 💡 3. 포트(:8080) 확인 및 붙이기
      if (!baseUrl.contains(':8080')) {
        baseUrl = '$baseUrl:8080';
      }

      // 💡 4. 공지사항 목록 조회를 위한 최종 URL 조합
      final String finalUrl = baseUrl.endsWith('/')
          ? '${baseUrl}api/notices'
          : '$baseUrl/api/notices';


      // 💡 5. 요청 실행
      final response = await http.get(Uri.parse(finalUrl));

      debugPrint("=== [디버그] 서버 응답 상태: ${response.statusCode}");
      debugPrint("=== [디버그] 서버 응답 본문: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          notices = data.map((item) {
            return {
              'title': item['title']?.toString() ?? '제목 없음',
              'date': item['createDate']?.toString() ?? '',
              'content': item['content']?.toString() ?? ''
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("리스트 가져오기 실패: $e");
    }
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => isAdmin = true);
  }

  Future<void> _navigateToWrite() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoticeWriteScreen()),
    );
    _fetchNotices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항'), backgroundColor: Colors.white, elevation: 1),
      body: notices.isEmpty
          ? const Center(child: Text("등록된 공지사항이 없습니다."))
          : ListView.separated(
        itemCount: notices.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notice = notices[index];
          return ListTile(
            title: Text(notice['title'] ?? '제목 없음'),
            subtitle: Text(notice['date'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailScreen(noticeData: notice),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(onPressed: _navigateToWrite, child: const Icon(Icons.edit))
          : null,
    );
  }
}