import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/member_service.dart';
import '../../services/reservation_service.dart';
import '../model/package_item.dart';
import '../controller/package_controller.dart'as ctrl;


class PackageDetailScreen extends StatefulWidget {
  static bool isTesting = false;
  final PackageItem item;
  final MemberService? memberService;

  const PackageDetailScreen({
    super.key,
    required this.item,
    this.memberService,
  });

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final NumberFormat _numberFormat = NumberFormat('#,###');
  late final MemberService _memberService;
  int _selectedPeople = 1;

  @override
  void initState() {
    super.initState();
    _memberService = widget.memberService ?? MemberService();
  }

  // 1. 예약 처리 함수 (독립적인 메서드)
  Future<void> _processBooking(BuildContext context) async {
    final token = await _memberService.getAccessToken() ?? '';
    final controller = ctrl.PackageController(ReservationService());

    final result = await controller.reservePackage(
      token: token,
      packageId: widget.item.id,
      peopleCount: _selectedPeople,
      price: widget.item.price,
    );

    if (!context.mounted) return;

    if (result != null) {
      _showSuccessSnackBar(context, "🎉 예약 성공!");
    } else {
      _showSuccessSnackBar(context, "⚠️ 예약 실패!");
    }
  }

// 2. 성공 스낵바(토스트) 띄우는 함수
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

// 3. 예약 확인 다이얼로그
  void _showReservationConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("예약 확인"),
        content: Text("총 $_selectedPeople명, ${_numberFormat.format(widget.item.price * _selectedPeople)}원을 예약하시겠습니까?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소")
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _processBooking(context);
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

// 4. 로그인 필요 안내
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그인 필요"),
        content: const Text("로그인 후 이용 가능한 서비스입니다.\n로그인 페이지로 이동하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text("로그인하러 가기"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item.title)),
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildThumbnail(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("${_numberFormat.format(widget.item.price)}원 / 1인", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  _buildPeopleSelector(),
                  const Divider(height: 40),
                  _buildSectionTitle("포함사항"),
                  Text(widget.item.inclusions.join(", ")),
                  const SizedBox(height: 20),
                  _buildSectionTitle("여행 일정"),
                  ...widget.item.itinerary.map((day) => Text("Day ${day['day']}: ${day['activities'].join(", ")}")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildBottomBar() 부분을 이렇게 수정하세요
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () async {
            final token = await _memberService.getAccessToken();
            if (token == null || token.isEmpty) {
              if (!mounted) return;
              _showLoginDialog(context);
            } else {
              _showReservationConfirmDialog(context);
            }
          },
          child: const Text("예약하기", style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildPeopleSelector() {
    return Row(
      children: [
        const Text("인원수: ", style: TextStyle(fontSize: 16)),
        IconButton(
          onPressed: () {
            if (_selectedPeople > widget.item.minPeople) {
              setState(() => _selectedPeople--);
            }
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text("$_selectedPeople 명", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: () {
            if (_selectedPeople < widget.item.maxPeople) {
              setState(() => _selectedPeople++);
            }
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    return PackageDetailScreen.isTesting
        ? Container(height: 250, color: Colors.grey)
        : Image.network(widget.item.thumbnail, height: 250, width: double.infinity, fit: BoxFit.cover);
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}