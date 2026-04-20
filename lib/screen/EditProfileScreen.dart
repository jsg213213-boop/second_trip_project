import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/member_service.dart';
import 'ChangePasswordScreen.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final File? image;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    this.image,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;

  // 프로젝트 테마 컬러 (Classic Blue 계열로 유지)
  final Color classicBlue = const Color(0xFF2C3E50);

  final MemberService _memberService = MemberService();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 부모 페이지에서 넘겨받은 데이터로 초기화
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    _image = widget.image;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // --- 프로필 저장 로직 ---
  Future<void> _saveProfile() async {
    String newName = nameController.text.trim();
    String newPhone = phoneController.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      _showSnackBar('이름과 전화번호를 모두 입력해주세요.', isError: true);
      return;
    }

    // 1. 서버에 보낼 데이터 구성
    Map<String, String> updateData = {
      "mname": newName,
      "phone": newPhone,
    };

    // 2. MemberService를 통해 DB 업데이트 시도
    // (이제 MemberService 내부에서 mid를 자동으로 추가해서 쏠 거야!)
    bool success = await _memberService.updateMember(updateData);

    if (success) {
      if (!mounted) return;

      // 3. 성공하면 마이페이지로 정보 전달하며 돌아가기
      Navigator.pop(context, {
        'name': newName,
        'phone': newPhone,
        'image': _image,
      });

      _showSnackBar('회원 정보가 수정되었습니다.');
    } else {
      _showSnackBar('정보 수정에 실패했습니다. 다시 시도해주세요.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  // --- 이하 UI 및 부가 기능 로직 (기존과 동일) ---

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(CupertinoIcons.photo),
              title: const Text('앨범에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.camera),
              title: const Text('사진 촬영'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) setState(() => _image = File(pickedFile.path));
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash, color: Colors.red),
              title: const Text('기본 이미지로 변경', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() => _image = null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 탈퇴 사유 시트 및 다이얼로그 생략 (기존 코드 유지)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원 정보 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text('완료', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(CupertinoIcons.person_fill, size: 50, color: classicBlue)
                        : null,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text('프로필 사진 변경', style: TextStyle(color: classicBlue, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildEditField('이름', nameController, CupertinoIcons.person, isNumeric: false),
            const SizedBox(height: 20),
            _buildEditField('전화번호', phoneController, CupertinoIcons.phone, isNumeric: true),
            const SizedBox(height: 40),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('비밀번호 변경'),
              subtitle: const Text('보안을 위해 주기적으로 변경해주세요', style: TextStyle(fontSize: 12)),
              trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('회원 탈퇴', style: TextStyle(color: Colors.red)),
              onTap: () { /* 기존 탈퇴 로직 호출 */ },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, {required bool isNumeric}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          // ⭐ 전화번호 필드일 때만 숫자만 입력 가능하도록 필터링
          inputFormatters: isNumeric ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ] : [],
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
            hintText: '$label을 입력하세요',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: classicBlue)),
          ),
        ),
      ],
    );
  }
}