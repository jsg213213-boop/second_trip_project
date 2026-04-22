import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPwController = TextEditingController();
  final TextEditingController newPwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  final Color classicBlue = const Color(0xFFF7323F);

  // ⭐ 비밀번호 변경 로직 함수
  void _attemptChangePassword() {
    String current = currentPwController.text;
    String newPw = newPwController.text;
    String confirm = confirmPwController.text;

    // 1. 빈칸 체크
    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _showResultDialog("알림", "모든 항목을 입력해주세요.");
      return;
    }

    // 2. 현재 비밀번호 확인 (나중에는 DB 데이터와 비교하겠지만, 지금은 예시로 '1234'라고 칠게!)
    // 만약 나중에 DB 연결하면 이 부분을 서버 데이터와 비교하면 돼.
    if (current != "1234") {
      _showResultDialog("오류", "현재 비밀번호가 일치하지 않습니다.");
      return;
    }

    // 3. 새 비밀번호 일치 여부 체크
    if (newPw != confirm) {
      _showResultDialog("오류", "새 비밀번호가 서로 일치하지 않습니다.");
      return;
    }

    // 4. 모든 조건 통과 시 성공 알림
    _showResultDialog("완료", "비밀번호가 성공적으로 변경되었습니다.", isSuccess: true);
  }

  // ⭐ 결과 알림창 (모달) 함수
  void _showResultDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              if (isSuccess) {
                Navigator.pop(context); // 성공했을 경우 변경 화면까지 닫기
              }
            },
            child: Text("확인", style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildAppleInput(String label, bool isVisible, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      prefixIcon: const Icon(CupertinoIcons.lock, size: 20),
      suffixIcon: IconButton(
        icon: Icon(isVisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash, size: 20),
        onPressed: toggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildPasswordField("현재 비밀번호", currentPwController, _isCurrentVisible, () => setState(() => _isCurrentVisible = !_isCurrentVisible)),
            const SizedBox(height: 16),
            const Divider(height: 40),
            _buildPasswordField("새 비밀번호", newPwController, _isNewVisible, () => setState(() => _isNewVisible = !_isNewVisible)),
            const SizedBox(height: 16),
            _buildPasswordField("새 비밀번호 확인", confirmPwController, _isConfirmVisible, () => setState(() => _isConfirmVisible = !_isConfirmVisible)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _attemptChangePassword, // ⭐ 로직 함수 연결
                style: ElevatedButton.styleFrom(
                  backgroundColor: classicBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('비밀번호 변경 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool visible, VoidCallback toggle) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: _buildAppleInput(label, visible, toggle),
    );
  }
}