import 'dart:convert';
import 'package:http/http.dart' as http;

class InquiryService {
  final String baseUrl = "http://10.0.2.2:8080/api/inquiries";

  // 문의글 저장 함수
  Future<bool> registerInquiry(Map<String, dynamic> inquiryData) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(inquiryData),
      );

      print("서버 응답 코드: ${response.statusCode}");
      print("서버 응답 내용: ${response.body}");

      // 200번대(성공)이면 true 리턴
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print("통신 중 에러 발생: $e");
      return false;
    }
  }
}