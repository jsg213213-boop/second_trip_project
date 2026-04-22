import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accommodation_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/accommodation_card.dart';
import '../detail/accommodation_detail_screen.dart';
import '../favorite/favorite_screen.dart';
import '../search/search_screen.dart';

class AccommodationListScreen extends ConsumerWidget {
  const AccommodationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArea = ref.watch(selectedAreaProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider); // 추가
    final listAsync = ref.watch(accommodationListProvider(selectedArea));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('숙소'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border,
                color: AppTheme.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoriteScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search,
                color: AppTheme.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── 지역 탭 ───────────────────────────────────────
          _buildAreaTabs(ref, selectedArea),
          // ─── 카테고리 탭 ────────────────────────────────────
          _buildCategoryTabs(ref, selectedCategory),
          // ─── 숙소 목록 ─────────────────────────────────────
          Expanded(
            child: listAsync.when(
              loading: () => ListView.builder(
                itemCount: 5,
                itemBuilder: (_, __) =>
                const AccommodationCardSkeleton(),
              ),
              data: (list) {
                // 카테고리 필터링
                final filtered = selectedCategory == '전체'
                    ? list
                    : list
                    .where((a) =>
                a.cat3 ==
                    CategoryCode.categories[selectedCategory])
                    .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      '해당 카테고리의 숙소가 없습니다.',
                      style:
                      TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => AccommodationCard(
                    item: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccommodationDetailScreen(
                          accommodation: filtered[i],
                        ),
                      ),
                    ),
                  ),
                );
              },
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(
                          accommodationListProvider(selectedArea)),
                      child: const Text('다시 시도',
                          style:
                          TextStyle(color: AppTheme.primary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 지역 탭 ──────────────────────────────────────────────────
  Widget _buildAreaTabs(WidgetRef ref, String selectedArea) {
    final areas = AreaCode.areas.keys.toList();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: areas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final area = areas[i];
          final isSelected = area == selectedArea;

          return GestureDetector(
            onTap: () =>
            ref.read(selectedAreaProvider.notifier).state = area,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                area,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── 카테고리 탭 ──────────────────────────────────────────────
  Widget _buildCategoryTabs(WidgetRef ref, String selectedCategory) {
    final categories = CategoryCode.categories.keys.toList();

    return Container(
      color: AppTheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => ref
                .read(selectedCategoryProvider.notifier)
                .state = category,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}