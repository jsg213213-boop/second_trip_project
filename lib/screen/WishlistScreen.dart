import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Color classicBlue = const Color(0xFFF7323F);

  // ⭐ 실시간 삭제 반영을 위해 데이터를 State 안으로 이동!
  List<Map<String, dynamic>> wishItems = [
    {
      'name': '제주 해비치 호텔',
      'category': '숙소',
      'location': '제주 서귀포시',
      'price': '280,000원~',
      'image': 'https://picsum.photos/id/10/400/300',
    },
    {
      'name': '테슬라 모델3 (24년형)',
      'category': '렌터카',
      'location': '제주공항 인근',
      'price': '45,000원~',
      'image': 'https://picsum.photos/id/1071/400/300',
    },
    {
      'name': '강릉 씨마크 호텔',
      'category': '숙소',
      'location': '강원 강릉시',
      'price': '450,000원~',
      'image': 'https://picsum.photos/id/1015/400/300',
    },
    {
      'name': '현대 싼타페 MX5',
      'category': '렌터카',
      'location': '제주공항 인근',
      'price': '38,000원~',
      'image': 'https://picsum.photos/id/183/400/300',
    },
  ];

  // ⭐ 하트 클릭 시 찜 해제(삭제) 함수
  void _toggleWish(int index) {
    String removedItemName = wishItems[index]['name'];

    setState(() {
      wishItems.removeAt(index); // 리스트에서 해당 아이템 삭제
    });

    // 삭제 후 간단한 알림(스낵바) 띄우기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$removedItemName 찜이 해제되었습니다.'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('찜 목록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: wishItems.isEmpty
          ? _buildEmptyState() // 찜 목록이 비었을 때 화면
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72, // 카드 하단 텍스트가 안 잘리도록 살끔 조정
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: wishItems.length,
        itemBuilder: (context, index) => _buildWishCard(index),
      ),
    );
  }

  Widget _buildWishCard(int index) {
    final item = wishItems[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // 상품 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // ⭐ 하트 아이콘 (GestureDetector로 클릭 감지)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleWish(index), // 클릭하면 삭제 함수 실행!
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: const Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item['category'],
          style: TextStyle(color: Colors.grey[600], fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          item['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 2),
        Text(
          item['price'],
          style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  // 찜 목록이 텅 비었을 때 보여줄 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.heart, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('찜한 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}