import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:second_trip_project/car/model/company_car_dto.dart';
import 'package:second_trip_project/car/model/car_search_cursor_response.dart';

import '../controller/car_rent_list_controller.dart';
import '../util/car_format_util.dart';
import 'car_reservation_screen.dart';

class CarListScreen extends StatefulWidget {
  final String region;
  final String startDate;
  final String endDate;
  final String? startTime;
  final String? endTime;

  const CarListScreen({
    super.key,
    required this.region,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
  });

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final _scrollController = ScrollController();

  /// 스크롤페이징을 위한 컨트롤러와 화면 준비 후에 차 데이터를 읽어옴
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarRentListController>().fetchAvailableCars(
            widget.region,
            widget.startDate,
            widget.endDate,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

/// 스크롤 해서 특정 위치 이하로 가면 다음 값을 더 읽어옴
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CarRentListController>().loadMoreCars();
    }
  }

  //차량 타입에 맞게 이미지 세팅
  String _carTypeImage(String type) {
    switch (type) {
      case 'SUV':
        return 'assets/images/removebgsuv.png';
      case '대형':
        return 'assets/images/removebgbig.png';
      case '중형':
        return 'assets/images/removebgmiddle.png';
      case '소형':
        return 'assets/images/removebgsmall.png';
      case '경형':
        return 'assets/images/removebgmini.png';
      case '승합':
        return 'assets/images/removebgtoobig.png';
      default:
        return 'assets/images/removebgmiddle.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarRentListController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: Text('${widget.region} 렌터카')),
          body: _buildBody(controller),
        );
      },
    );
  }

  Widget _buildBody(CarRentListController controller) {
    if (controller.isLoading && controller.cars.isEmpty) {
      return ListView.builder(  //10개의 shimmer를 표시
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: CarRentListController.pageSize,
        itemBuilder: (_, __) => const _ShimmerCarCard(),
      );
    }

    //에러메세지 출력
    if (controller.errorMessage != null) {
      return Center(child: Text(controller.errorMessage!));
    }
    if (controller.cars.isEmpty) {
      return const Center(child: Text('예약 가능한 차량이 없습니다.'));
    }

    //로딩이 끝나면 화면 출력
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: controller.cars.length + (controller.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.cars.length) {  //마지막 인덱스는 shimmer자리(다음 로딩을 위함)
          return const _ShimmerCarCard();
        }
        final car = controller.cars[index]; //차량 종류 데이터
        return _CarCard(  //차량종류 화면
          carIndex: index,
          car: car,
          carTypeImage: _carTypeImage(car.type),
          startDate: widget.startDate,
          endDate: widget.endDate,
          startTime: widget.startTime,
          endTime: widget.endTime,
        );
      },
    );
  }
}

///shimmer 카드 차량 종류 형태
class _ShimmerCarCard extends StatelessWidget {
  const _ShimmerCarCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 72, height: 48, color: Colors.white),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 14, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(width: 150, height: 12, color: Colors.white),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(width: double.infinity, height: 12, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// shimmer 카드 회사별 차량 형태
class _ShimmerOptionTile extends StatelessWidget {
  const _ShimmerOptionTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 120, height: 13, color: Colors.white),
            Container(width: 70, height: 13, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends StatefulWidget {
  final int carIndex;
  final CarSearchCursorResponseDTO car;
  final String carTypeImage;
  final String startDate;
  final String endDate;
  final String? startTime;
  final String? endTime;

  const _CarCard({
    required this.carIndex,
    required this.car,
    required this.carTypeImage,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
  });

  @override
  State<_CarCard> createState() => _CarCardState();
}

/// AutomaticKeepAliveClientMixin는 스크롤 시 화면 밖으로 나간 위젯이 메모리에 남아있게 하는 믹스인
/// 더보기 버튼을 누르고 스크롤을 내리면 더보기를 안눌린 상태로 돌아가는 현상을 막기 위해
class _CarCardState extends State<_CarCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //화면 밖으로 나가도 위젯 상태 유지

  static const int _optionLoadSize = 10;  //1회 최대 더보기 수 제한
  bool _isLoadingMore = false;
  CompanyCarDTO? _selectedCar;

  ///더보기 버튼 눌렀을때 데이터를 더 읽어옴
  Future<void> _loadMoreOptions() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await context.read<CarRentListController>().loadMoreOptions(widget.carIndex);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final car = widget.car;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  widget.carTypeImage,
                  width: 72,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.carName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${car.type} · ${car.seats}인승 · ${car.fuel}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            //CarSearchResultDTO 안에 있는 List<CompanyOptionDTO>의 각각의 CompanyOptionDTO를 동기적으로 타일에 담는다
            ...car.companyCarDTOs.map((companyCarDTO) => _CompanyPriceTile(
                  companyCarDTO: companyCarDTO,   //차량 옵션
                  isSelected: _selectedCar?.carId == companyCarDTO.carId, //선택한 차의 id와 데이터의 차 id가 같으면 isSeleted를 true로해서 버튼 색을 표시 해줌
                  onTap: () => setState(() {  //눌렀을때 _selectedOption의 상태를 변경함
                    //선택한 차의 id와 데이터의 차 id가 같으면 null이 들어오고 다르면 옵션을 넣는다.
                    //선택이 취소을 취소 할수 있게 했음
                    _selectedCar =
                    _selectedCar?.carId == companyCarDTO.carId ? null : companyCarDTO;
                  }),
                )),
            if (car.companyCarDTOs.length < car.totalOptionCount)
              _isLoadingMore
                  ? Column(
                      children: List.generate(
                        //로딩중엔 shimmer타일을 더보기 갯수 만큼 그려줌
                        min(_optionLoadSize, car.remainingCount), //min(10, 남은 수) 둘중에 작은 수만큼 shimmer를 만듦
                        (_) => const _ShimmerOptionTile(),
                      ),
                    )
                  : TextButton(
                      onPressed: _loadMoreOptions,
                      child: Text('더보기 ${min(_optionLoadSize, car.remainingCount)}개'),
                    ),
            if (_selectedCar != null)  //회사 차량의 데이터가 있다면
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarReservationScreen(
                            car: car,
                            companyCarDTO: _selectedCar!,
                            startDate: DateTime.parse(widget.startDate),
                            endDate: DateTime.parse(widget.endDate),
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004680),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('${_selectedCar!.companyName} 예약하기'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompanyPriceTile extends StatelessWidget {
  final CompanyCarDTO companyCarDTO;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyPriceTile({
    required this.companyCarDTO,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F0FE) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF004680) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${companyCarDTO.companyName} · ${companyCarDTO.year}년',
                style: const TextStyle(fontSize: 14)),
            Text(
              '${formatPrice(companyCarDTO.dailyPrice)}원/일',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF004680) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}