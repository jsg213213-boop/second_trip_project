import 'package:flutter/material.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  // 공지사항 더미 데이터 (나중에 DB와 연결하세요)
  final List<Map<String, String>> notices = const [
    {
      'tag': '발표',
      'title': '여기좋아 LIVE <진에어 특가> 이벤트 당첨 안내',
      'date': '2026. 04. 13',
      'isNew': 'true',
      'content': '안녕하세요. 여기좋아입니다.\n\n진에어 특가 이벤트에 참여해주신 모든 분들께 감사드립니다.\n당첨자 명단은 아래와 같습니다...\n(중략)'
    },
    {
      'tag': '안내',
      'title': '서비스 점검 안내 (4/21 03:00 ~ 06:00)',
      'date': '2026. 04. 10',
      'isNew': 'false',
      'content': '안녕하세요. 여기좋아입니다.\n\n더 나은 서비스 제공을 위한 시스템 점검 일정을 안내해 드립니다.\n점검 시간 동안에는 앱 서비스 이용이 일시 중지됩니다.\n\n■ 점검 일정: 2026년 4월 21일 03:00 ~ 06:00\n■ 사유: 서버 안정화 작업'
    },
    {
      'tag': '이벤트',
      'title': '리뷰 쓰고 포인트 받자! 4월 리뷰 이벤트',
      'date': '2026. 04. 01',
      'isNew': 'false',
      'content': '4월 한 달간 정성스러운 리뷰를 남겨주신 분들 중 추첨을 통해 포인트를 드립니다!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        itemCount: notices.length,
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          final notice = notices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice['tag']!,
                  style: const TextStyle(color: Color(0xFF004680), fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  notice['title']!,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Text(notice['date']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (notice['isNew'] == 'true') ...[
                    const SizedBox(width: 8),
                    const Text('NEW', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
            onTap: () {
              // 상세 페이지로 이동하며 데이터 전달
              Navigator.pushNamed(context, '/notice_detail', arguments: notice);
            },
          );
        },
      ),
    );
  }


}