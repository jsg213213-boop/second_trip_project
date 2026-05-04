import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/package_item_dto.dart';
import '../service/package_item_service.dart';
import 'package_detail_screen.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final PackageItemService _packageService = PackageItemService();
  final NumberFormat _numberFormat = NumberFormat('#,###');
  final TextEditingController _searchController = TextEditingController();

  final Color _brandColor = const Color(0xFFFD0059);

  bool _isLoading = true;
  bool _isMoreLoading = false; // 추가 로딩 상태

  // 1. 카테고리별로 데이터와 페이지 번호를 관리합니다.
  Map<String, List<PackageItemDTO>> _categoryData = {
    "Best": [],
    "Special": [],
    "Season": [],
  };

  Map<String, int> _currentPage = {
    "Best": 0,
    "Special": 0,
    "Season": 0,
  };

  List<PackageItemDTO> _allPackages = []; // 검색용 원본 통합 데이터
  List<PackageItemDTO> _searchResults = []; // 검색 결과

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  // 초기 데이터 로드 (모든 카테고리의 0페이지 호출)
  Future<void> _initialLoad() async {
    try {
      // 병렬로 첫 페이지 데이터들을 가져옵니다.
      final results = await Future.wait([
        _packageService.getPackageList(category: "Best", page: 0, size: 10),
        _packageService.getPackageList(category: "Special", page: 0, size: 10),
        _packageService.getPackageList(category: "Season", page: 0, size: 10),
      ]);

      setState(() {
        _categoryData["Best"] = results[0];
        _categoryData["Special"] = results[1];
        _categoryData["Season"] = results[2];

        // 검색 필터링을 위해 전체 리스트 업데이트
        _allPackages = results.expand((x) => x).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("데이터를 불러오지 못했습니다: $e");
    }
  }

  // '더보기' 클릭 시 호출될 함수
  Future<void> _fetchMoreData(String category) async {
    if (_isMoreLoading) return;

    setState(() => _isMoreLoading = true);

    try {
      int nextIdx = _currentPage[category]! + 1;
      final newData = await _packageService.getPackageList(
          category: category, page: nextIdx, size: 10);

      if (newData.isNotEmpty) {
        setState(() {
          _categoryData[category]!.addAll(newData);
          _currentPage[category] = nextIdx;
          _allPackages.addAll(newData); // 전체 리스트에도 추가
        });
      } else {
        _showSnackBar("마지막 상품입니다.");
      }
    } catch (e) {
      _showSnackBar("추가 데이터를 가져오지 못했습니다.");
    } finally {
      setState(() => _isMoreLoading = false);
    }
  }

  void _filterPackages(String query) {
    setState(() {
      _searchResults = _allPackages
          .where((item) =>
      (item.title?.contains(query) ?? false) ||
          (item.region?.contains(query) ?? false))
          .toList();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("국내 패키지",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isSearching
                ? _buildSearchResultList()
                : _buildHomeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterPackages,
          cursorColor: _brandColor,
          decoration: InputDecoration(
            hintText: "도시명을 입력하세요",
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: _brandColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _filterPackages('');
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return ListView(
      children: [
        _buildHorizontalSection("Best 상품", "Best"),
        _buildHorizontalSection("이달의 특가", "Special"),
        _buildHorizontalSection("시즌 한정 여행", "Season"),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHorizontalSection(String sectionTitle, String category) {
    final List<PackageItemDTO> items = _categoryData[category]!;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(sectionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // 아이템 개수 + 1 (더보기 버튼)
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return _buildMoreCard(category);
              }
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                child: _buildPackageCard(context, items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // 가로 스크롤 끝 '더보기' 카드 디자인
  Widget _buildMoreCard(String category) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16, top: 5, bottom: 5),
      child: InkWell(
        onTap: () => _fetchMoreData(category),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isMoreLoading
                ? CircularProgressIndicator(color: _brandColor)
                : Icon(Icons.add_circle_outline, color: _brandColor, size: 40),
            const SizedBox(height: 10),
            const Text("더보기",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, PackageItemDTO item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PackageDetailScreen(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                item.thumbnail ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title ?? '제목 없음',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.region ?? '',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          "${_numberFormat.format(item.price ?? 0)}원",
                          style: TextStyle(
                              color: _brandColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
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
    );
  }

  Widget _buildSearchResultList() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) =>
          _buildSearchResultCard(_searchResults[index]),
    );
  }

  Widget _buildSearchResultCard(PackageItemDTO item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PackageDetailScreen(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.thumbnail ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: 80, height: 80, color: Colors.grey[200]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.region ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text("${_numberFormat.format(item.price ?? 0)}원",
                      style: TextStyle(
                          color: _brandColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}