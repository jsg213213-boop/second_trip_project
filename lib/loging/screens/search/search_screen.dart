import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accommodation_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/accommodation_card.dart';
import '../detail/accommodation_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  // 최근 검색어 (나중에 SharedPreferences로 저장 가능)
  final List<String> _recentSearches = [
    '해운대 호텔',
    '제주 펜션',
    '강원 리조트',
    '서울 게스트하우스',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        // 검색창
        title: TextField(
          controller: _controller,
          autofocus: true, // 화면 열리면 키보드 자동으로 올라옴
          decoration: const InputDecoration(
            hintText: '숙소명, 지역으로 검색',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (v) => setState(() => _query = v),
        ),
        // 검색어 지우기 버튼
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildInitialContent()  // 검색어 없을 때
          : _buildSearchResults(),  // 검색어 있을 때
    );
  }

  // ─── 검색어 없을 때 화면 ──────────────────────────────────────
  Widget _buildInitialContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 최근 검색어
        const Text('최근 검색어',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        ..._recentSearches.map((s) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history,
              size: 18, color: AppTheme.textSecondary),
          title: Text(s,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary)),
          trailing: const Icon(Icons.north_west,
              size: 14, color: AppTheme.textSecondary),
          onTap: () {
            _controller.text = s;
            setState(() => _query = s);
          },
        )),
        const SizedBox(height: 20),
        // 인기 지역
        const Text('인기 지역',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AreaCode.areas.keys
              .where((a) => a != '전체')
              .map((area) => GestureDetector(
            onTap: () {
              _controller.text = area;
              setState(() => _query = area);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.border, width: 0.5),
              ),
              child: Text(area,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary)),
            ),
          ))
              .toList(),
        ),
      ],
    );
  }

  // ─── 검색 결과 화면 ───────────────────────────────────────────
  Widget _buildSearchResults() {
    final resultAsync = ref.watch(searchResultProvider(_query));

    return resultAsync.when(
      loading: () => ListView.builder(
        itemCount: 4,
        itemBuilder: (_, __) => const AccommodationCardSkeleton(),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('검색 결과가 없습니다.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => AccommodationCard(
            item: list[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccommodationDetailScreen(
                  accommodation: list[i],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}