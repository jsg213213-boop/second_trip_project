import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/member_service.dart';
import 'MyBookingScreen.dart';
import 'MyReviewScreen.dart';
import 'EditProfileScreen.dart'; // WishlistScreen 임포트는 삭제함

class MyPageScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userRole;

  const MyPageScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userRole,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Color classicBlue = const Color(0xFF2C3E50);
  final MemberService _memberService = MemberService();

  late String _userName;
  late String _userEmail;
  late String _userPhone;
  late String _userRole;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _userPhone = widget.userPhone;
    _userRole = widget.userRole;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await _memberService.logout();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그아웃 되었습니다.'), duration: Duration(seconds: 2)),
                );
              },
              child: const Text('로그아웃', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("이미지 선택 오류: $e");
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('프로필 사진 변경', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(CupertinoIcons.photo),
                title: const Text('앨범에서 선택'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera),
                title: const Text('사진 촬영'),
                onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.trash, color: Colors.red),
                title: const Text('기본 이미지로 변경', style: TextStyle(color: Colors.red)),
                onTap: () { setState(() => _image = null); Navigator.pop(context); },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 프로필 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showProfileMenu(context),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: classicBlue.withOpacity(0.1),
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(CupertinoIcons.person_fill, size: 40, color: classicBlue)
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                          child: Icon(CupertinoIcons.camera_fill, size: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          if (_userRole == "ADMIN")
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7323F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "ADMIN",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(_userEmail, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(CupertinoIcons.settings, color: Colors.grey),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            name: _userName,
                            phone: _userPhone,
                            image: _image,
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _userName = result['name'] ?? _userName;
                          _userPhone = result['phone'] ?? _userPhone;
                          _image = result['image'];
                        });
                      }
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ⭐ 2. 메뉴 리스트 섹션 (기존 '활동 요약' 삭제 후 통합)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  // 내 예약 & 내 리뷰를 메뉴 최상단으로 이동
                  _buildMenuItem(
                      CupertinoIcons.calendar_today,
                      '내 예약 확인',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingScreen()))
                  ),
                  _buildMenuItem(
                      CupertinoIcons.square_pencil,
                      '내 리뷰 관리',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReviewScreen()))
                  ),

                  // 구분선 역할 (약간의 간격)
                  const Divider(thickness: 8, height: 8, color: Color(0xFFF8F9FA)),

                  _buildMenuItem(CupertinoIcons.doc_text, '내 게시글 관리', onTap: () => Navigator.pushNamed(context, '/my_posts')),
                  _buildMenuItem(CupertinoIcons.chat_bubble_2, '1:1 문의 내역', onTap: () => Navigator.pushNamed(context, '/inquiry')),
                  _buildMenuItem(CupertinoIcons.info_circle, '고객센터', onTap: () {}),
                  _buildMenuItem(CupertinoIcons.bell, '공지사항', onTap: () => Navigator.pushNamed(context, '/notice')),
                  _buildMenuItem(CupertinoIcons.square_arrow_right, '로그아웃', isLast: true, textColor: Colors.redAccent, onTap: () => _showLogoutDialog(context)),
                ],
              ),
            ),

            // 3. 관리자 전용 메뉴
            if (_userRole == "ADMIN") ...[
              const SizedBox(height: 12),
              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(
                          "관리자 전용 설정",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF7323F), fontSize: 14)
                      ),
                    ),
                    _buildMenuItem(
                        CupertinoIcons.speaker_2_fill,
                        '공지사항 등록 및 관리',
                        onTap: () => Navigator.pushNamed(context, '/admin_notice_write')
                    ),
                    _buildMenuItem(
                        CupertinoIcons.chat_bubble_2_fill,
                        '문의사항 답변 등록',
                        isLast: true,
                        onTap: () => Navigator.pushNamed(context, '/admin_inquiry_reply')
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 💡 _buildStatItem과 _buildStatLine은 이제 사용하지 않으므로 삭제해도 무방해!

  Widget _buildMenuItem(IconData icon, String title, {bool isLast = false, Color? textColor, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: textColor ?? Colors.black87, size: 22),
          title: Text(title, style: TextStyle(fontSize: 15, color: textColor ?? Colors.black87, fontWeight: FontWeight.w500)),
          trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) Divider(indent: 56, height: 1, color: Colors.grey[100]),
      ],
    );
  }
}