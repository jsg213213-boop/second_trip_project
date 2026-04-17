import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TotalSearchScreen extends StatefulWidget {
  const TotalSearchScreen({super.key});

  @override
  State<TotalSearchScreen> createState() => _TotalSearchScreenState();
}

class _TotalSearchScreenState extends State<TotalSearchScreen> {
  List data = [];
  bool isLoading = false;
  String selectedCategory = 'stay'; // 기본값: 숙소
  final TextEditingController controller = TextEditingController();

  // 🔍 검색 함수 (API 연동)
  Future<void> fetchData(String keyword) async {
    setState(() {
      isLoading = true;
      data = []; // 이전 결과 초기화
    });

    try {
      final dio = Dio();
      // 에뮬레이터 접속 주소: 10.0.2.2
      final response = await dio.get(
        'http://10.0.2.2:8080/api/accommodations',
        queryParameters: {
          'keyword': keyword,
          'category': selectedCategory,
        },
      );

      setState(() {
        data = response.data;
      });
      print("검색 성공: ${data.length}건");
    } catch (e) {
      print('서버 연결 실패 또는 에러: $e');

      // 🔥 서버가 없을 때 테스트를 위한 더미 데이터 생성
      setState(() {
        data = [
          {'name': '[$selectedCategory] 부산 해운대 호텔', 'address': '부산 해운대구'},
          {'name': '[$selectedCategory] 광안리 오션뷰 펜션', 'address': '부산 수영구'},
          {'name': '[$selectedCategory] 서면 가성비 숙소', 'address': '부산진구'},
        ];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 🏷️ 상단 카테고리 선택 바 (스크롤 가능하게 수정)
  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 가로 스크롤 추가
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _buildCategoryItem('국내숙소', 'stay'),
            const SizedBox(width: 8),
            _buildCategoryItem('항공', 'flight'),
            const SizedBox(width: 8),
            _buildCategoryItem('패키지', 'package'),
            const SizedBox(width: 8),

          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, String value) {
    final isSelected = selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
        // 카테고리 바꿀 때 자동으로 재검색하고 싶다면 아래 주석 해제
        // if (controller.text.isNotEmpty) fetchData(controller.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통합 검색'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. 카테고리 바
          _buildCategorySelector(),

          // 2. 검색창
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (value) => fetchData(value), // 엔터 누르면 검색
                decoration: InputDecoration(
                  hintText: '$selectedCategory 키워드를 입력하세요',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => fetchData(controller.text),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // 3. 결과 영역
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(data[index]['name'].toString()),
                    subtitle: Text(data[index]['address']?.toString() ?? '주소 정보 없음'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}