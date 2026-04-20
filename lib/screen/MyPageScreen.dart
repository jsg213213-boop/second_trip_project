import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/member_service.dart';
import 'MyBookingScreen.dart';
import 'MyReviewScreen.dart';
import 'WishlistScreen.dart';
import 'EditProfileScreen.dart';

class MyPageScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone; // ⭐ 1. 진짜 전화번호를 받을 변수 추가

  const MyPageScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhone, // ⭐ 2. 생성자에 추가
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final Color classicBlue = const Color(0xFF2C3E50); // 테마에 맞춘 컬러 수정

  final MemberService _memberService = MemberService();

  late String _userName;
  late String _userEmail;
  late String _userPhone; // ⭐ 3. 하드코딩 삭제하고 late로 선언
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ⭐ 4. 부모 위젯(MyPageScreen)으로부터 받은 진짜 정보들로 초기화
    _userName = widget.userName;
    _userEmail = widget.userEmail;
    _userPhone = widget.userPhone;
  }

  // ⭐ 로그아웃 확인 다이얼로그
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

  // 사진 가져오는 함수
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

  // 프로필 수정 바텀 시트
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
                      Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_userEmail, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const Spacer(),
                  // ⭐ 수정 버튼: 이제 실제 _userPhone을 넘겨줌
                  IconButton(
                    icon: const Icon(CupertinoIcons.settings, color: Colors.grey),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            name: _userName,
                            phone: _userPhone, // 진짜 번호 전달!
                            image: _image,
                          ),
                        ),
                      );
                      // 수정 완료 후 돌아왔을 때 화면 갱신
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

            // 2. 활동 요약 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('내 예약', '3', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingScreen()));
                  }),
                  _buildStatLine(),
                  _buildStatItem('내 리뷰', '12', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReviewScreen()));
                  }),
                  _buildStatLine(),
                  _buildStatItem('찜 목록', '25', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. 메뉴 리스트 섹션
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(CupertinoIcons.doc_text, '내 게시글 관리', onTap: () => Navigator.pushNamed(context, '/my_posts')),
                  _buildMenuItem(CupertinoIcons.chat_bubble_2, '1:1 문의 내역', onTap: () => Navigator.pushNamed(context, '/inquiry')),
                  _buildMenuItem(CupertinoIcons.info_circle, '고객센터', onTap: () {}),
                  _buildMenuItem(CupertinoIcons.square_arrow_right, '로그아웃', isLast: true, textColor: Colors.redAccent, onTap: () => _showLogoutDialog(context)),
                  _buildMenuItem(CupertinoIcons.bell, '공지사항', onTap: () => Navigator.pushNamed(context, '/notice')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: classicBlue)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatLine() { return Container(width: 1, height: 30, color: Colors.grey[200]); }

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