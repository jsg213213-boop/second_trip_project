import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:second_trip_project/airport/screen/my_reservation_screen.dart';
import '../../common/constants/app_colors.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({super.key});

  // ✅ 원본 방식 유지 - 모달창으로 열기
  void _openDialog(BuildContext context, BookingType type) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '닫기',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
      pageBuilder: (_, __, ___) => Dialog(
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: MyReservationScreen(type: type, isModal: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text(
          '내 예약 내역',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리를 선택하세요',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  // ── 항공 → AppColors.primary (빨강) ─────
                  _CategoryCard(
                    label: '항공',
                    subtitle: '국내선 항공 예약',
                    icon: CupertinoIcons.airplane,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    onTap: () => _openDialog(context, BookingType.flight),
                  ),
                  // ── 숙소 → 담당자 고유색 유지 ───────────
                  _CategoryCard(
                    label: '숙소',
                    subtitle: '호텔/펜션 예약',
                    icon: CupertinoIcons.bed_double_fill,
                    color: const Color(0xFF1D9E75),
                    bgColor: const Color(0xFFEDFAF5),
                    onTap: () => _openDialog(context, BookingType.hotel),
                  ),
                  // ── 렌터카 → 담당자 고유색 유지 ─────────
                  _CategoryCard(
                    label: '렌터카',
                    subtitle: '차량 렌탈 예약',
                    icon: CupertinoIcons.car_fill,
                    color: const Color(0xFFEF9F27),
                    bgColor: const Color(0xFFFFF8ED),
                    onTap: () => _openDialog(context, BookingType.rental),
                  ),
                  // ── 패키지 → 담당자 고유색 유지 ─────────
                  // TODO: 패키지 담당자 - _packageBody() 교체
                  _CategoryCard(
                    label: '패키지',
                    subtitle: '여행 패키지 예약',
                    icon: CupertinoIcons.gift_fill,
                    color: const Color(0xFF7F77DD),
                    bgColor: const Color(0xFFF3F0FF),
                    onTap: () => _openDialog(context, BookingType.package),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 카드 위젯 ────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── 아이콘 영역 ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: bgColor,
                child: Icon(icon, size: 36, color: color),
              ),

              // ── 텍스트 영역 ──────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // 제목 + 부제목
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // ── 예약 내역 보기 + 화살표 ─────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '예약 내역 보기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            size: 14,
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}