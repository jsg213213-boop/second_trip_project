import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CommunityDetailScreen extends StatefulWidget {
  final dynamic post;

  const CommunityDetailScreen({super.key, this.post});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  // 💡 댓글 기능이 필요 없으면 _replyController와 _submitReply는 삭제하셔도 됩니다.
  List<dynamic> replies = [];

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  Future<void> _fetchReplies() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:8080/replies/${widget.post['id']}');
      setState(() { replies = response.data; });
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
      // 💡 Column 대신 ListView만 사용해도 충분합니다.
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.post['title']?.toString() ?? '제목 없음', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("작성자: ${widget.post['mid'] ?? '알 수 없음'}"),
          const Divider(height: 30),
          Text(widget.post['content']?.toString() ?? '내용이 없습니다.', style: const TextStyle(fontSize: 16)),
          const Divider(height: 40),

          ...replies.map((r) => ListTile(title: Text(r['content']), subtitle: Text(r['mid']))),
        ],
      ),
    );
  }
}