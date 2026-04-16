import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ChangePasswordScreen.dart'; // 비밀번호 변경 페이지 임포트

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
  final Color classicBlue = const Color(0xFF004680);

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
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

  // 프로필 사진 변경 로직 (기존 유지)
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

  // ⭐ 디테일 추가: 탈퇴 사유 선택 및 최종 확인 로직
  void _showDeleteReasonSheet() {
    final List<String> reasons = [
      "서비스 이용이 불편해요",
      "예약하고 싶은 상품이 없어요",
      "개인정보 유출이 걱정돼요",
      "자주 사용하지 않아요",
      "기타"
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('탈퇴하시는 사유가 궁금해요 😥', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...reasons.map((reason) => ListTile(
                  title: Text(reason, style: const TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context); // 사유창 닫기
                    _showFinalDeleteDialog(); // 최종 확인 다이얼로그 띄우기
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ⭐ 최종 탈퇴 확인 다이얼로그
  void _showFinalDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('정말 떠나시나요?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('탈퇴 시 모든 예약 내역과 리뷰 데이터가 즉시 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              // 1. 모든 스택 제거 후 로그인 화면으로 이동
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              // 2. 하단 스낵바 안내
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('탈퇴가 처리되었습니다. 그동안 이용해주셔서 감사합니다.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('탈퇴하기', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원 정보 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': nameController.text,
                'phone': phoneController.text,
                'image': _image,
              });
            },
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

            _buildEditField('이름', nameController, CupertinoIcons.person),
            const SizedBox(height: 20),
            _buildEditField('전화번호', phoneController, CupertinoIcons.phone),
            const SizedBox(height: 40),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('비밀번호 변경'),
              subtitle: const Text('보안을 위해 주기적으로 변경해주세요', style: TextStyle(fontSize: 12)),
              trailing: const Icon(CupertinoIcons.chevron_forward, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('회원 탈퇴', style: TextStyle(color: Colors.red)),
              onTap: _showDeleteReasonSheet, // ⭐ 수정된 사유 선택 함수 호출
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}