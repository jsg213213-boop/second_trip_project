import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:second_trip_project/util/secure_storage_helper.dart'; // 💡 문의하기와 동일한 경로
import 'CommunityWriteScreen.dart';
import 'CommunityDetailScreen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> allPosts = [];
  bool isLoading = true;
  String errorMessage = "";
  final _storage = SecureStorageHelper(); // 💡 문의하기와 동일한 저장소 헬퍼 사용

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      // 1. 토큰 가져오기 (문의하기 로직과 동일)
      String? token = await _storage.getAccessToken();

      if (token == null || token.isEmpty || token == "null") {
        setState(() {
          isLoading = false;
          errorMessage = "로그인이 필요합니다.\n다시 로그인해 주세요.";
        });
        return;
      }

      // 1. .env에서 값을 가져옵니다.
      final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';

// 2. 이미 'http'가 포함되어 있는지 확인하고, 없으면 붙입니다.
      String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';

// 3. 만약 포트(:8080)가 이미 포함되어 있지 않다면 붙입니다.
      if (!baseUrl.contains(':8080')) {
        baseUrl = '$baseUrl:8080';
      }

// 4. 슬래시(/) 처리를 고려하여 최종 URL 조합
      final String finalUrl = baseUrl.endsWith('/')
          ? '${baseUrl}community/list'
          : '$baseUrl/community/list';

// 5. 요청 실행
      final response = await http.get(
        Uri.parse(finalUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          allPosts = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "서버 요청 실패 (상태: ${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "연결 실패: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 10),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _fetchPosts, child: const Text("다시 시도"))
          ],
        ),
      )
          : allPosts.isEmpty
          ? const Center(child: Text("작성된 글이 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: allPosts.length,
        itemBuilder: (context, i) {
          final item = allPosts[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(item['title'] ?? '제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("작성자: ${item['mid'] ?? '익명'}"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CommunityDetailScreen(post: item))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 글 작성 후 돌아왔을 때 목록 새로고침
          if (await Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityWriteScreen())) == true) {
            _fetchPosts();
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}