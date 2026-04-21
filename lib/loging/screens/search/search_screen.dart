import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/accommodation_providers.dart';
import '../../../util/secure_storage_helper.dart';
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
  String _selectedType = '전체'; // 선택된 숙소 유형
  List<String> _recentSearches = []; // 최근 검색어

  // 숙소 유형 필터
  final List<String> _types = [
    '전체', '관광호텔', '펜션', '모텔', '게스트하우스', '민박', '한옥'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // ─── 최근 검색어 불러오기 ─────────────────────────
  Future<void> _loadRecentSearches() async {
    final isLoggedIn = await SecureStorageHelper().isLoggedIn();
    List<String> searches = [];

    if (isLoggedIn) {
      // 회원 → SecureStorage
      final storage = SecureStorageHelper();
      final mid = await storage.getUserMid() ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      searches = prefs.getStringList('recent_search_$mid') ?? [];
    } else {
      // 비회원 → SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      searches = prefs.getStringList('recent_search_guest') ?? [];
    }

    setState(() => _recentSearches = searches);
  }

  // ─── 최근 검색어 저장 ─────────────────────────────
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final isLoggedIn = await SecureStorageHelper().isLoggedIn();
    final prefs = await SharedPreferences.getInstance();

    String key;
    if (isLoggedIn) {
      final mid = await SecureStorageHelper().getUserMid() ?? 'guest';
      key = 'recent_search_$mid';
    } else {
      key = 'recent_search_guest';
    }

    List<String> searches = prefs.getStringList(key) ?? [];

    // 중복 제거 후 맨 앞에 추가
    searches.remove(query);
    searches.insert(0, query);

    // 최대 10개만 저장
    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await prefs.setStringList(key, searches);
    setState(() => _recentSearches = searches);
  }

  // ─── 최근 검색어 삭제 ─────────────────────────────
  Future<void> _removeRecentSearch(String query) async {
    final isLoggedIn = await SecureStorageHelper().isLoggedIn();
    final prefs = await SharedPreferences.getInstance();

    String key;
    if (isLoggedIn) {
      final mid = await SecureStorageHelper().getUserMid() ?? 'guest';
      key = 'recent_search_$mid';
    } else {
      key = 'recent_search_guest';
    }

    List<String> searches = prefs.getStringList(key) ?? [];
    searches.remove(query);
    await prefs.setStringList(key, searches);
    setState(() => _recentSearches = searches);
  }

  // ─── 전체 삭제 ────────────────────────────────────
  Future<void> _clearRecentSearches() async {
    final isLoggedIn = await SecureStorageHelper().isLoggedIn();
    final prefs = await SharedPreferences.getInstance();

    String key;
    if (isLoggedIn) {
      final mid = await SecureStorageHelper().getUserMid() ?? 'guest';
      key = 'recent_search_$mid';
    } else {
      key = 'recent_search_guest';
    }

    await prefs.remove(key);
    setState(() => _recentSearches = []);
  }

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
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '숙소명, 지역으로 검색',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => setState(() => _query = v),
          onSubmitted: (v) {
            setState(() => _query = v);
            _saveRecentSearch(v); // 검색어 저장
          },
        ),
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
          ? _buildInitialContent()
          : _buildSearchResults(),
    );
  }

  // ─── 검색어 없을 때 화면 ──────────────────────────
  Widget _buildInitialContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 최근 검색어
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('최근 검색어',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text('전체 삭제',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentSearches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('최근 검색어가 없습니다.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary)),
          )
        else
          ..._recentSearches.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history,
                size: 18, color: AppTheme.textSecondary),
            title: Text(s,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            trailing: IconButton(
              icon: const Icon(Icons.close,
                  size: 14, color: AppTheme.textSecondary),
              onPressed: () => _removeRecentSearch(s),
            ),
            onTap: () {
              _controller.text = s;
              setState(() => _query = s);
              _saveRecentSearch(s);
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
              _saveRecentSearch(area);
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

  // ─── 검색 결과 화면 ───────────────────────────────
  Widget _buildSearchResults() {
    final resultAsync = ref.watch(searchResultProvider(_query));

    return Column(
      children: [
        // ─── 숙소 유형 필터 ────────────────────────
        Container(
          color: AppTheme.surface,
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 6),
            itemCount: _types.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final type = _types[i];
              final isSelected = type == _selectedType;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14),
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
                    type,
                    style: TextStyle(
                      fontSize: 12,
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
        ),
        // ─── 검색 결과 목록 ────────────────────────
        Expanded(
          child: resultAsync.when(
            loading: () => ListView.builder(
              itemCount: 4,
              itemBuilder: (_, __) =>
              const AccommodationCardSkeleton(),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(e.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
            data: (list) {
              // 숙소 유형 필터링
              final filtered = _selectedType == '전체'
                  ? list
                  : list
                  .where((a) =>
              a.accommodationType == _selectedType)
                  .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('검색 결과가 없습니다.',
                          style: TextStyle(
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // 결과 수 표시
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 10, 16, 4),
                    child: Row(
                      children: [
                        Text('총 ${filtered.length}개',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => AccommodationCard(
                        item: filtered[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AccommodationDetailScreen(
                                  accommodation: filtered[i],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}