import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyReviewScreen extends StatefulWidget {
  const MyReviewScreen({super.key});

  @override
  State<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends State<MyReviewScreen> {
  final Color classicBlue = const Color(0xFF004680);

  // ⭐ 실시간 반영을 위해 리스트를 State 안으로 가져왔어!
  List<Map<String, dynamic>> myReviews = [
    {
      'target': '제주 신라호텔',
      'category': '숙소',
      'rating': 5,
      'date': '2026.04.10',
      'content': '부모님 모시고 갔는데 서비스가 너무 좋았어요. 수영장 수온도 적당하고 조식도 맛있었습니다. 다음 제주 여행 때도 또 방문하고 싶네요!',
      'image': 'https://picsum.photos/200',
    },
    {
      'target': '제주공항 인수 (아반떼 CN7)',
      'category': '렌터카',
      'rating': 4,
      'date': '2026.03.25',
      'content': '차량 상태 깨끗하고 인수 절차가 빨라서 좋았습니다. 다만 워셔액이 부족해서 중간에 한 번 채웠네요. 그 외에는 만족합니다.',
      'image': null,
    },
  ];

  // ⭐ 1. 리뷰 삭제 함수
  void _deleteReview(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('리뷰 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말로 이 리뷰를 완전히 삭제하시겠습니까?\n삭제된 리뷰는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              setState(() {
                myReviews.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('리뷰가 삭제되었습니다.'), backgroundColor: Colors.redAccent),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ⭐ 2. 리뷰 수정 함수 (바텀 시트)
  void _editReview(int index) {
    final TextEditingController contentController = TextEditingController(text: myReviews[index]['content']);
    int currentRating = myReviews[index]['rating'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${myReviews[index]['target']} 리뷰 수정', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('별점 수정', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children: List.generate(5, (starIndex) => IconButton(
                  onPressed: () => setModalState(() => currentRating = starIndex + 1),
                  icon: Icon(
                    currentRating > starIndex ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber, size: 35,
                  ),
                )),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: '리뷰 내용',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: classicBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      myReviews[index]['content'] = contentController.text;
                      myReviews[index]['rating'] = currentRating;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰가 수정되었습니다.')));
                  },
                  child: const Text('수정 완료', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('내 리뷰 관리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: myReviews.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myReviews.length,
        itemBuilder: (context, index) => _buildReviewCard(index),
      ),
    );
  }

  Widget _buildReviewCard(int index) {
    final review = myReviews[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${review['category']} · ${review['target']}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              Text(review['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < review['rating'] ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review['image'] != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(review['image'], width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
              Expanded(
                child: Text(
                  review['content'],
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _editReview(index),
                child: const Text('수정', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              TextButton(
                onPressed: () => _deleteReview(index),
                child: const Text('삭제', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.chat_bubble_text, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('작성한 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}