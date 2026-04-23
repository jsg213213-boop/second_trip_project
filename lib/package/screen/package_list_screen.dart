import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/package_controller.dart';
import '../model/package_item.dart';
import 'package_detail_screen.dart';
import '../../services/reservation_service.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final PackageController _controller = PackageController(ReservationService());
  final NumberFormat _numberFormat = NumberFormat('#,###');
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<PackageItem> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadPackages();
    setState(() => _isLoading = false);
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

  final Color _brandColor = const Color(0xFFFD0059);

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
          onChanged: (value) {
            setState(() {
              _searchResults = _controller.searchPackages(value);
            });
          },
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
                setState(() {
                  _searchResults = [];
                });
              },
            )
                : null,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 15, horizontal: 20),
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

  // 가로 스크롤 섹션
  Widget _buildHorizontalSection(String sectionTitle, String category) {
    final filteredList = _controller.packageList.where((item) =>
    item.category == category).toList();
    if (filteredList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(sectionTitle, style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 16),
                child: _buildPackageCard(context, filteredList[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, PackageItem item) {
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
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15)),
              child: Image.network(
                item.thumbnail,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 150,
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
                      item.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.region, style: const TextStyle(color: Colors
                            .grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                            "${_numberFormat.format(item.price)}원",
                            // 클래스 멤버 _numberFormat 사용
                            style: TextStyle(
                                color: Colors.pinkAccent[400],
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                            )
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



  // 검색 결과 리스트
  Widget _buildSearchResultList() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text("검색 결과가 없습니다."));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultCard(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultCard(PackageItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PackageDetailScreen(item: item)),
          );
        },
        borderRadius: BorderRadius.circular(15), // 터치 효과도 둥글게
        child: Row(
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(15)),
              child: Image.network(
                item.thumbnail,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image)),
              ),
            ),
            // 정보 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(item.region, style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      "${_numberFormat.format(item.price)}원",
                      style: TextStyle(
                        color: _brandColor, // 정의해두신 브랜드 컬러 적용!
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
}