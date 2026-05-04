import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/package_item_dto.dart';
import '../model/package_reservation_dto.dart';
import '../service/package_reservation_service.dart';
import '../../util/secure_storage_helper.dart';

class PackageDetailScreen extends StatefulWidget {
  final PackageItemDTO item;

  const PackageDetailScreen({super.key, required this.item});

  @override
  State<PackageDetailScreen> createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  final NumberFormat _numberFormat = NumberFormat('#,###');
  final _storage = SecureStorageHelper();
  final _reservationService = PackageReservationService();

  int _selectedPeople = 1;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedPeople = widget.item.minPeople ?? 1;
  }

  // --- [로직] 예약 관련 함수 ---
  Future<void> _handleReservation() async {
    //로그인 검토
    final token = await _storage.getAccessToken();

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      _showLoginDialog(context);
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약 날짜를 선택해주세요.')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFF7323F))),
    );

    final reservationData = PackageReservationDTO(
      packageId: widget.item.id,
      reservationDate: _selectedDate,
      peopleCount: _selectedPeople,
      totalPrice: (widget.item.price ?? 0) * _selectedPeople,
    );

    bool success = await _reservationService.createReservation(reservationData);

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ 예약 실패: 다시 시도해주세요.')));
    }
  }

  //로그인 검토
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
              Navigator.pushNamed(context, '/login', arguments: 'from_detail');
            },
            child: const Text("로그인하러 가기"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 완료'),
        content: const Text('성공적으로 예약되었습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('확인'),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // --- [UI] 메인 빌더 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("상품 상세", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 제목 및 가격
                  Text(widget.item.title ?? "상품 제목", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text("${_numberFormat.format(widget.item.price ?? 0)}원 / 1인",
                      style: const TextStyle(fontSize: 20, color: Color(0xFFF7323F), fontWeight: FontWeight.bold)),
                  const Divider(height: 40),

                  // 중단: 교통 및 일정 정보
                  _buildFlightInfoSection(),
                  _buildItinerarySection(),
                  const Divider(height: 40),

                  // 중단: 상품 설명 및 포함/불포함 사항
                  _buildDetailSection("📝 상품 설명", widget.item.description),
                  _buildListSection("✅ 포함 사항", widget.item.inclusions, Colors.blue[700]!),
                  _buildListSection("❌ 불포함 사항", widget.item.exclusions, Colors.red[700]!),

                  const Divider(height: 40),

                  // 하단: 예약 옵션 설정 (인원 + 날짜)
                  const Text("🗓️ 예약 옵션 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 인원 선택 (최하단으로 이동)
                  _buildPeopleSelector(),
                  const SizedBox(height: 15),

                  // 날짜 선택 (최하단으로 이동)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    tileColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
                    leading: const Icon(Icons.calendar_today, color: Color(0xFFF7323F)),
                    title: const Text("여행 날짜 선택"),
                    subtitle: Text(_selectedDate == null ? "날짜를 선택해 주세요" : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _selectDate,
                  ),

                  // 하단 여백
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- [UI] 서브 위젯 함수들 ---

  Widget _buildImageSection() {
    return Image.network(
      widget.item.thumbnail ?? '',
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
          height: 250,
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 50)
      ),
    );
  }

  Widget _buildFlightInfoSection() {
    if (widget.item.flightInfo == null || widget.item.flightInfo!.isEmpty) return const SizedBox.shrink();

    final info = widget.item.flightInfo!;

    // DB 구조인 outbound와 inbound 값을 가져옵니다.
    final String outbound = info['outbound'] ?? '정보 없음';
    final String inbound = info['inbound'] ?? '정보 없음';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("이용 가능 교통정보", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blueGrey[100]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.outbound_outlined, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text("가는 편: $outbound", style: const TextStyle(fontSize: 15)),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.login_outlined, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text("오는 편: $inbound", style: const TextStyle(fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildItinerarySection() {
    if (widget.item.itinerary == null || widget.item.itinerary!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📍 여행 일정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...widget.item.itinerary!.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 12, backgroundColor: const Color(0xFFF7323F),
                  child: Text("${entry.key + 1}", style: const TextStyle(fontSize: 12, color: Colors.white))),
              const SizedBox(width: 10),
              Expanded(child: Text("${entry.value}", style: const TextStyle(fontSize: 15, height: 1.4))),
            ],
          ),
        )),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPeopleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("예약 인원 선택", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Row(
            children: [
              IconButton(onPressed: () { if (_selectedPeople > (widget.item.minPeople ?? 1)) setState(() => _selectedPeople--); }, icon: const Icon(Icons.remove_circle_outline)),
              Text("$_selectedPeople 명", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () { if (_selectedPeople < (widget.item.maxPeople ?? 10)) setState(() => _selectedPeople++); }, icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF7323F))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String? content) {
    if (content == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 15, height: 1.6)),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildListSection(String title, List<String>? items, Color color) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5), border: Border.all(color: color.withOpacity(0.3))),
            child: Text(item, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
          )).toList(),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7323F),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _handleReservation,
          child: const Text("지금 예약하기", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}