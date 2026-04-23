import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 💡 dotenv 패키지 추가

class CommunityDetailScreen extends StatefulWidget {
  final dynamic post;

  const CommunityDetailScreen({super.key, this.post});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  List<dynamic> replies = [];

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  Future<void> _fetchReplies() async {
    try {
      // 1. .env에서 값을 가져옵니다.
      final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

      // 2. http 프로토콜 자동 확인 및 붙이기
      String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

      // 3. 포트(:8080) 확인 및 붙이기
      if (!baseUrl.contains(':8080')) {
        baseUrl = '$baseUrl:8080';
      }

      // 4. 슬래시(/) 처리를 고려하여 댓글 URL 조합
      final String finalUrl = baseUrl.endsWith('/')
          ? '${baseUrl}replies/${widget.post['id']}'
          : '$baseUrl/replies/${widget.post['id']}';

      // 5. Dio 요청 실행
      final dio = Dio();
      final response = await dio.get(finalUrl);

      setState(() {
        replies = response.data;
      });
    } catch (e) {
      print("댓글 불러오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post == null) {
      return Scaffold(appBar: AppBar(title: const Text("오류")), body: const Center(child: Text("게시글 정보를 찾을 수 없습니다.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.post['title']?.toString() ?? '제목 없음', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("작성자: ${widget.post['mid'] ?? '알 수 없음'}"),
          const Divider(height: 30),
          Text(widget.post['content']?.toString() ?? '내용이 없습니다.', style: const TextStyle(fontSize: 16)),
          const Divider(height: 40),

          ...replies.map((r) => ListTile(
              title: Text(r['content'] ?? '댓글 내용 없음'),
              subtitle: Text(r['mid'] ?? '익명')
          )),
        ],
      ),
    );
  }
}