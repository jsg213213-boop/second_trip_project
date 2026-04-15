import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accommodation_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/accommodation_card.dart';
import '../detail/accommodation_detail_screen.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProvider);
    final cache = ref.watch(accommodationCacheProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          '찜한 숙소 ${favorites.length}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
        // 전체 삭제 버튼
        actions: [
          if (favorites.isNotEmpty)
            TextButton(
              onPressed: () => _showClearDialog(context, ref),
              child: const Text('전체 삭제',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmpty()
          : _buildFavoriteList(context, ref, favorites, cache),
    );
  }

  // ─── 찜 목록이 비어있을 때 ────────────────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 56, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '찜한 숙소가 없습니다.',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            '마음에 드는 숙소에 하트를 눌러보세요!',
            style: TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── 찜 목록 ─────────────────────────────────────────────────
  Widget _buildFavoriteList(
      BuildContext context,
      WidgetRef ref,
      Set<String> favorites,
      Map<String, dynamic> cache,
      ) {
    final cachedItems = favorites
        .where((id) => cache.containsKey(id))
        .map((id) => cache[id])
        .toList();

    // 캐시에 없는 숙소 수
    final uncachedCount = favorites.length - cachedItems.length;

    return ListView(
      children: [
        // 캐시된 숙소 카드
        ...cachedItems.map((item) => AccommodationCard(
          item: item,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AccommodationDetailScreen(accommodation: item),
            ),
          ),
        )),
        // 캐시 안된 숙소 안내
        if (uncachedCount > 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '숙소 상세 페이지를 방문하면\n찜 목록에서 바로 확인할 수 있어요.',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── 전체 삭제 다이얼로그 ────────────────────────────────────
  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('찜 목록 초기화'),
        content: const Text('찜한 숙소를 모두 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              // 찜 목록 전체 삭제
              for (final id
              in ref.read(favoriteProvider).toList()) {
                ref.read(favoriteProvider.notifier).toggle(id);
              }
              Navigator.pop(context);
            },
            child: const Text('삭제',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}