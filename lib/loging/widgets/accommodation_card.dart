import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/accommodation_providers.dart';
import '../data/models/accommodation.dart';
import '../theme/app_theme.dart';

class AccommodationCard extends ConsumerWidget {
  final Accommodation item;
  final VoidCallback? onTap; // 카드 눌렀을 때 동작 (나중에 라우팅 연결)

  const AccommodationCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.contains(item.contentId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 이미지 영역 ───────────────────────────────────
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  _buildImage(),
                  // 찜 버튼
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(favoriteProvider.notifier)
                          .toggle(item.contentId),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav ? AppTheme.primary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // 숙소 유형 배지
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.accommodationType,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ─── 정보 영역 ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 숙소 이름
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 주소
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        item.shortAddr,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 별점 & 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 별점
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppTheme.star),
                          const SizedBox(width: 2),
                          Text(
                            item.rating?.toStringAsFixed(1) ?? '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${item.reviewCount})',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      // 가격 (TourAPI는 가격 미제공)
                      // 가격 → 객실 목록에서 가져옴
                      Consumer(
                        builder: (context, ref, _) {
                          final roomsAsync = ref.watch(
                              roomListProvider(item.contentId));
                          return roomsAsync.when(
                            loading: () => const Text(
                              '가격 조회 중...',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                            ),
                            error: (_, __) => const Text(
                              '가격문의',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary),
                            ),
                            data: (rooms) {
                              // 가격 있는 객실만 필터 → 오름차순 정렬
                              final prices = rooms
                                  .where((r) =>
                              r.offSeasonWeekMin != null &&
                                  r.offSeasonWeekMin! > 0)
                                  .map((r) => r.offSeasonWeekMin!)
                                  .toList()
                                ..sort();

                              if (prices.isEmpty) {
                                return const Text(
                                  '가격문의',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary),
                                );
                              }

                              // 제일 싼 가격 표시
                              final cheapest = prices.first;
                              final formatted = cheapest
                                  .toString()
                                  .replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                              );

                              return Text(
                                '$formatted원~',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이미지 빌더
  Widget _buildImage() {
    if (item.hasImage) {
      return CachedNetworkImage(
        imageUrl: item.firstImage,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        // 로딩 중 스켈레톤 표시
        placeholder: (_, __) => _skeleton(),
        // 이미지 실패 시 기본 이미지
        errorWidget: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  // 로딩 중 스켈레톤 (shimmer 효과)
  Widget _skeleton() => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(height: 180, color: Colors.white),
  );

  // 이미지 없을 때 기본 화면
  Widget _fallbackImage() => Container(
    height: 180,
    color: const Color(0xFFEEEEEE),
    child: const Center(
      child: Icon(Icons.hotel, size: 48, color: Color(0xFFCCCCCC)),
    ),
  );
}

// ─── 로딩 중 스켈레톤 카드 ────────────────────────────────────────
// 데이터 불러오는 동안 보여줄 카드
class AccommodationCardSkeleton extends StatelessWidget {
  const AccommodationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 이미지 자리
            Container(height: 180, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 200, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                      height: 12,
                      width: double.infinity,
                      color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}