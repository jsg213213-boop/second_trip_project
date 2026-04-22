import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:second_trip_project/util/secure_storage_helper.dart';

class WriteInquiryScreen extends StatefulWidget {
  const WriteInquiryScreen({super.key});

  @override
  State<WriteInquiryScreen> createState() => _WriteInquiryScreenState();
}

class _WriteInquiryScreenState extends State<WriteInquiryScreen> {
  final Color classicBlue = const Color(0xFFF7323F);
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _storage = SecureStorageHelper();

  Future<String?> _getToken() async {
    return await _storage.getAccessToken();
  }

  String _selectedCategory = '기타';
  final List<String> _categories = ['예약/결제', '취소/환불', '이용문의', '기타'];

  Future<void> _submitInquiry() async {
    // 1. 토큰 읽기 및 로그 확인
    String? token = await _getToken();
    debugPrint("### 서버로 전송할 토큰 확인: $token");

    if (token == null || token.isEmpty || token == "null") {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/inquiries');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          // 토큰이 올바르게 들어가는지 확인 (Bearer와 토큰 사이 공백 필수)
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": _titleController.text.trim(),
          "content": _contentController.text.trim(),
          "mid": "asd@naver.com",
          "category": _selectedCategory
        }),
      );

      debugPrint("서버 응답 코드: ${response.statusCode}");
      debugPrint("서버 응답 본문: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('문의가 등록되었습니다.')));
        Navigator.pop(context, true);
      } else {
        // 에러 발생 시 서버 응답 메시지를 상세히 보여줌
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패(${response.statusCode}): ${response.body}')),
        );
      }
    } catch (e) {
      debugPrint("통신 에러 발생: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('서버 통신 중 에러가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('1:1 문의하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')));
                return;
              }
              _submitInquiry();
            },
            child: Text('등록', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('문의 유형', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _buildDropdown(),
            const SizedBox(height: 24),
            const Text('제목', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _buildTextField(_titleController, '제목을 입력해주세요'),
            const SizedBox(height: 24),
            const Text('문의 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            _buildTextField(_contentController, '문의 내용을 상세히 입력해주세요', maxLines: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          items: _categories.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: classicBlue), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
