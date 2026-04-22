import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/review_service.dart'; // 서비스 경로 확인해줘!

class MyReviewScreen extends StatefulWidget {
  const MyReviewScreen({super.key});

  @override
  State<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends State<MyReviewScreen> {
  final Color yeogiRed = const Color(0xFFF7323F);
  final ReviewService _reviewService = ReviewService(); // 서비스 인스턴스 생성

  List<dynamic> myReviews = []; // 서버에서 받아올 리스트
  bool _isLoading = true; // 로딩 상태 확인

  @override
  void initState() {
    super.initState();
    _loadReviews(); // 1. 시작하자마자 데이터 불러오기
  }

  // ─── 데이터 불러오기 함수 ───────────────────────────
  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final data = await _reviewService.getMyReviews();
      setState(() {
        myReviews = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("리뷰 로드 에러: $e");
    }
  }

  // ─── 리뷰 등록 함수 ───────────────────────────────
  void _addReview() {
    final TextEditingController targetController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    String selectedCategory = '숙소';
    int currentRating = 5;

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
              const Text('새 리뷰 작성', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('카테고리', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ['숙소', '항공', '렌터카', '패키지'].map((cat) => ChoiceChip(
                  label: Text(cat),
                  selected: selectedCategory == cat,
                  onSelected: (selected) => setModalState(() => selectedCategory = cat),
                  selectedColor: yeogiRed.withOpacity(0.1),
                  labelStyle: TextStyle(color: selectedCategory == cat ? yeogiRed : Colors.black, fontWeight: FontWeight.bold),
                )).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: targetController,
                decoration: InputDecoration(
                  labelText: '이용 시설/상품명',
                  hintText: '예: 제주 신라호텔',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('별점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                  hintText: '이용하신 경험을 공유해주세요!',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yeogiRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (targetController.text.isEmpty || contentController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('내용을 모두 입력해주세요!')));
                      return;
                    }

                    // 서버로 보낼 데이터 맵핑
                    Map<String, dynamic> reviewData = {
                      'target': targetController.text,
                      'category': selectedCategory,
                      'rating': currentRating,
                      'content': contentController.text,
                    };

                    bool success = await _reviewService.registerReview(reviewData);
                    if (success) {
                      Navigator.pop(context);
                      _loadReviews(); // 서버에서 다시 불러오기
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰가 등록되었습니다!')));
                    }
                  },
                  child: const Text('리뷰 등록', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 리뷰 삭제 함수 ───────────────────────────────
  void _deleteReview(int rno) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('리뷰 삭제', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말로 이 리뷰를 완전히 삭제하시겠습니까?\n삭제된 리뷰는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              bool success = await _reviewService.deleteReview(rno);
              if (success) {
                Navigator.pop(context);
                _loadReviews(); // 서버에서 다시 불러오기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('리뷰가 삭제되었습니다.'), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── 리뷰 수정 함수 ───────────────────────────────
  void _editReview(int index) {
    final review = myReviews[index];
    final TextEditingController contentController = TextEditingController(text: review['content']);
    int currentRating = review['rating'];

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
              Text('${review['target']} 리뷰 수정', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    backgroundColor: yeogiRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Map<String, dynamic> updateData = {
                      'rno': review['rno'],
                      'content': contentController.text,
                      'rating': currentRating,
                    };

                    bool success = await _reviewService.modifyReview(updateData);
                    if (success) {
                      Navigator.pop(context);
                      _loadReviews(); // 서버에서 다시 불러오기
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('리뷰가 수정되었습니다.')));
                    }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: yeogiRed)) // 로딩 중일 때
          : myReviews.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator( // 2. 당겨서 새로고침 추가
        onRefresh: _loadReviews,
        color: yeogiRed,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myReviews.length,
          itemBuilder: (context, index) => _buildReviewCard(index),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReview,
        backgroundColor: yeogiRed,
        icon: const Icon(CupertinoIcons.pencil, color: Colors.white),
        label: const Text('리뷰 쓰기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReviewCard(int index) {
    final review = myReviews[index];

    // 3. 날짜 예쁘게 자르기 (2026-04-21T16:54:46 -> 2026.04.21)
    String formattedDate = review['regDate'] != null
        ? review['regDate'].toString().split('T')[0].replaceAll('-', '.')
        : "";

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
              Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              if (review['reviewImg'] != null) // 변수명 서버랑 맞춤
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(review['reviewImg'], width: 80, height: 80, fit: BoxFit.cover),
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
                onPressed: () => _deleteReview(review['rno']), // 4. 인덱스 대신 rno(PK) 사용
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