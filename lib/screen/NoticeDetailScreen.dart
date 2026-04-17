import 'package:flutter/material.dart';

class NoticeDetailScreen extends StatelessWidget {
  const NoticeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이전 화면에서 전달받은 데이터 추출
    final notice = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice['tag']!,
                    style: const TextStyle(color: Color(0xFF004680), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notice['title']!,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notice['date']!,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 1),
            // 본문 영역
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                notice['content']!,
                style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }


}