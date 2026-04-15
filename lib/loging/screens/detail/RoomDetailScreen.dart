import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/room.dart';
import '../../theme/app_theme.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          room.roomTitle,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 객실 이미지 ────────────────────────────────
            _buildImages(),

            // ─── 기본 정보 ──────────────────────────────────
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomTitle,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoBadge('기준 ${room.baseCount}인'),
                      const SizedBox(width: 8),
                      _infoBadge('최대 ${room.maxCount}인'),
                      const SizedBox(width: 8),
                      _infoBadge('${room.roomCount}실'),
                    ],
                  ),
                  // 객실 소개
                  if (room.roomIntro != null &&
                      room.roomIntro!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      room.roomIntro!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5),
                    ),
                  ],
                ],
              ),
            ),

            // ─── 가격 정보 ──────────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 8),
              color: AppTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('가격 정보',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _priceItem(
                        label: '비수기 주중',
                        price: room.offSeasonWeekMin,
                      ),
                      _priceItem(
                        label: '비수기 주말',
                        price: room.offSeasonWeekend,
                      ),
                      _priceItem(
                        label: '성수기 주중',
                        price: room.peakSeasonWeekMin,
                      ),
                      _priceItem(
                        label: '성수기 주말',
                        price: room.peakSeasonWeekend,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── 시설 정보 ──────────────────────────────────
            if (room.facilityList.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                color: AppTheme.surface,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('객실 시설',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.facilityList
                          .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F1),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFCDD2),
                              width: 0.5),
                        ),
                        child: Text(f,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primary)),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // ─── 하단 예약 버튼 ────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
              top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('예약 기능은 추후 연동 예정입니다.'),
                backgroundColor: AppTheme.primary,
              ),
            );
          },
          child: Text(
            room.displayPrice != '가격문의'
                ? '${room.displayPrice} 예약하기'
                : '예약 문의하기',
          ),
        ),
      ),
    );
  }

  // ─── 이미지 영역 ─────────────────────────────────────
  Widget _buildImages() {
    final images = [room.img1, room.img2, room.img3]
        .where((img) => img != null && img.isNotEmpty)
        .toList();

    if (images.isEmpty) {
      return Container(
        height: 240,
        color: const Color(0xFFEEEEEE),
        child: const Center(
          child: Icon(Icons.bed, size: 60, color: Color(0xFFCCCCCC)),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, i) => CachedNetworkImage(
          imageUrl: images[i]!,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Colors.grey[200]),
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFEEEEEE),
            child: const Center(
              child:
              Icon(Icons.bed, size: 60, color: Color(0xFFCCCCCC)),
            ),
          ),
        ),
      ),
    );
  }

  // ─── 정보 배지 ───────────────────────────────────────
  Widget _infoBadge(String label) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
    );
  }

  // ─── 가격 아이템 ─────────────────────────────────────
  Widget _priceItem({required String label, required int? price}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(
            price != null && price > 0
                ? '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원'
                : '정보 없음',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}