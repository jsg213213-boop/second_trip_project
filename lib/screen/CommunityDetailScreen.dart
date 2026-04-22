import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CommunityDetailScreen extends StatefulWidget {
  final dynamic post;

  const CommunityDetailScreen({super.key, this.post});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  List<dynamic> replies = [];

  @override
  void initState() {
    super.initState();
    _fetchReplies();
  }

  // 댓글 목록 불러오기
  Future<void> _fetchReplies() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:8080/replies/${widget.post['id']}');
      setState(() { replies = response.data; });
    } catch (e) {
      print("댓글 불러오기 실패: $e");
    }
  }

  // 댓글 작성하기
  Future<void> _submitReply() async {
    if (_replyController.text.isEmpty) return;
    try {
      final dio = Dio();
      await dio.post('http://10.0.2.2:8080/replies/register', data: {
        'content': _replyController.text,
        'mid': '현재사용자ID', // 실제 로그인한 유저 ID로 변경 필요
        'community': {'id': widget.post['id']}
      });
      _replyController.clear();
      _fetchReplies(); // 작성 후 새로고침
    } catch (e) {
      print("댓글 작성 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post == null) {
      return Scaffold(appBar: AppBar(title: const Text("오류")), body: const Center(child: Text("게시글 정보를 찾을 수 없습니다.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(widget.post['title']?.toString() ?? '제목 없음', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("작성자: ${widget.post['mid'] ?? '알 수 없음'}"),
                const Divider(height: 30),
                Text(widget.post['content']?.toString() ?? '내용이 없습니다.', style: const TextStyle(fontSize: 16)),
                const Divider(height: 40),
                const Text("댓글", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ...replies.map((r) => ListTile(title: Text(r['content']), subtitle: Text(r['mid']))),
              ],
            ),
          ),
          // 💡 댓글 입력창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _replyController, decoration: const InputDecoration(hintText: "댓글을 입력하세요"))),
                IconButton(icon: const Icon(Icons.send), onPressed: _submitReply)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
