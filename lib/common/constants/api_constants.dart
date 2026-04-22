import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._(); // 인스턴스 생성 방지

  // ── 스프링부트 BASE_URL ──────────────────────────────────
  // .env 파일에 BASE_URL 설정 시 해당 값 사용
  // .env 없거나 설정 안 된 경우 기본값 'http://10.0.2.2:8080' 사용
  // (10.0.2.2: Android 에뮬레이터에서 localhost 접근 시 사용하는 주소)
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';
}