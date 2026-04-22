import 'package:flutter/material.dart';

class NoticeDetailScreen extends StatelessWidget {
  // 1. 데이터를 받을 변수를 'nullable(?를 붙임)'로 만듭니다.
  final Map<String, String>? noticeData;

  // 2. 'required'를 제거하고, 데이터 없이도 생성 가능하게 만듭니다.
  const NoticeDetailScreen({super.key, this.noticeData});

  @override
  Widget build(BuildContext context) {
    // 3. 데이터가 없을 경우(routes로 들어온 경우) 처리
    if (noticeData == null) {
      return Scaffold(appBar: AppBar(title: const Text('오류')), body: const Center(child: Text('잘못된 접근입니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('공지사항 상세')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(noticeData!['title']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Text(noticeData!['content']!),
          ],
        ),
      ),
    );
  }
}