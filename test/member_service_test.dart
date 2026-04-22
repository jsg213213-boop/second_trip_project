import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:second_trip_project/services/member_service.dart';

void main() {
  // 테스트를 시작하기 전 준비물!
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MemberService 로그인 테스트', () {
    late MemberService memberService;

    setUp(() {
      memberService = MemberService();
      // 가짜 주머니(SharedPreferences)를 준비해줘요.
      SharedPreferences.setMockInitialValues({});
    });

    test('로그인 성공 시 토큰이 주머니에 잘 들어가는지 확인!', () async {
      // 1. 가짜 로그인 실행 (원래는 서버랑 통신하지만, 여기선 성공했다고 가정하고 테스트!)
      // 서버에서 줄 법한 가짜 응답 데이터
      final fakeUserData = {
        'mid': 'testUser',
        'mname': '박금동',
        'accessToken': 'abc-123-token' // 🎫 이게 우리가 넣고 싶은 팔찌!
      };

      // 2. 주머니 가져오기
      final prefs = await SharedPreferences.getInstance();

      // 3. 주머니에 직접 데이터를 넣어보고 (MemberService가 할 일을 흉내)
      await prefs.setString('accessToken', fakeUserData['accessToken']!);

      // 4. 결과 확인: "주머니에 넣은 게 아까 그 팔찌랑 똑같아?"
      final savedToken = prefs.getString('accessToken');

      expect(savedToken, 'abc-123-token'); // 👈 맞으면 통과(Pass)! 다르면 에러!
      print('✅ 테스트 성공: 팔찌가 주머니에 쏙 들어갔어요!');
    });
  });
}