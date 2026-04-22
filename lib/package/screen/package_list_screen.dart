import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/package_controller.dart';
import '../model/package_item.dart';
import 'package_detail_screen.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  final PackageController _controller = PackageController();
  final NumberFormat _numberFormat = NumberFormat('#,###');
  bool _isLoading = true;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("국내 패키지", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView( // 전체 세로 스크롤
        children: [
          _buildHorizontalSection("Best 상품", "Best"),
          _buildHorizontalSection("이달의 특가", "Special"),
          _buildHorizontalSection("시즌 한정 여행", "Season"), // Season 카테고리 추가
          const SizedBox(height: 30), // 하단 여백
        ],
      ),
    );
  }

  // 가로 스크롤 섹션 위젯
  Widget _buildHorizontalSection(String sectionTitle, String category) {
    final filteredList = _controller.packageList
        .where((item) => item.category == category)
        .toList();

    // 데이터가 없는 경우 섹션을 아예 표시하지 않음
    if (filteredList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(sectionTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        // 이미지의 Overflow 에러 해결을 위해 높이를 320 정도로 넉넉히 설정
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return Container(
                width: 220, // 카드의 가로 너비
                margin: const EdgeInsets.only(right: 16),
                child: _buildPackageCard(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  // 개별 카드 위젯 (레이아웃 오류 수정 버전)
  Widget _buildPackageCard(BuildContext context, PackageItem item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PackageDetailScreen(item: item)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.2)), // 테두리 추가로 더 깔끔하게
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
            // 1. 이미지 영역 (높이 고정)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                item.thumbnail,
                height: 150, // 이미지 높이 고정
                width: double.infinity,
                fit: BoxFit.cover,
                // 이미지 로딩 실패 시 처리
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.image)),
              ),
            ),
            // 2. 텍스트 영역 (충분한 공간 확보)
            Expanded( // 남은 공간을 사용하도록 설정하여 overflow 방지
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // 위아래 정렬
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2, // 제목이 길면 2줄까지만
                      overflow: TextOverflow.ellipsis, // 넘어가면 ... 처리
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            item.region,
                            style: const TextStyle(color: Colors.grey, fontSize: 13)
                        ),
                        const SizedBox(height: 4),
                        Text(
                            "${_numberFormat.format(item.price)}원",
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
}