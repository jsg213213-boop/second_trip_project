import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NoticeWriteScreen.dart';
import 'NoticeDetailScreen.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  bool isAdmin = true; // 서버 연동 전까지는 테스트를 위해 true로 유지

  // 리스트의 각 항목이 가지는 Map의 구조를 명확히 합니다.
  List<Map<String, String>> notices = [
    {'title': '여기좋아 LIVE <진에어 특가> 이벤트 당첨 안내', 'date': '2026. 04. 13', 'content': '이벤트 당첨자 발표입니다.'},
    {'title': '서비스 점검 안내 (4/21 03:00 ~ 06:00)', 'date': '2026. 04. 10', 'content': '점검 내용입니다.'},
    {'title': '리뷰 쓰고 포인트 받자! 4월 리뷰 이벤트', 'date': '2026. 04. 01', 'content': '리뷰 작성 이벤트 안내입니다.'},
  ];

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString('role');
    debugPrint("=== [DEBUG] 저장된 role: $role ===");

    if (mounted) {
      setState(() {
        // 실제 운영 시에는: isAdmin = (role != null && role.trim().toUpperCase() == 'ADMIN');
        isAdmin = true;
      });
    }
  }

  // 글쓰기 화면으로 이동 후 데이터를 받아서 리스트에 추가
  Future<void> _navigateToWrite() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const NoticeWriteScreen()),
    );

    // result가 정상적으로 전달되었는지 확인 후 추가
    if (result != null && result.isNotEmpty) {
      if (mounted) {
        setState(() {
          notices.insert(0, result);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.separated(
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
          ? FloatingActionButton(
        onPressed: _navigateToWrite,
        child: const Icon(Icons.edit),
      )
          : null,
    );
  }
}
