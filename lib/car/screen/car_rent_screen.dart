import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:second_trip_project/car/model/car_dto.dart';

import '../controller/rent_comp_controller.dart';
import 'car_reservation_screen.dart';

class CarRentScreen extends StatelessWidget {
  const CarRentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RentCompController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: Text('${controller.selectedRegion ?? ''} 렌터카')),
          body: _buildBody(controller),
        );
      },
    );
  }

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

  Widget _buildBody(RentCompController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null) {
      return Center(child: Text(controller.errorMessage!));
    }
    if (controller.availableCars.isEmpty) {
      return const Center(child: Text('예약 가능한 차량이 없습니다.'));
    }

    final grouped = controller.carsByName;
    final carNames = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: carNames.length,
      itemBuilder: (context, index) {
        final name = carNames[index];
        final cars = grouped[name]!..sort((a, b) => a.dailyPrice.compareTo(b.dailyPrice));
        return _CarCard(
          cars: cars,
          carTypeImage: _carTypeImage(cars.first.type),
        );
      },
    );
  }
}

class _CarCard extends StatefulWidget {
  final List<CarDTO> cars;
  final String carTypeImage;

  const _CarCard({required this.cars, required this.carTypeImage});

  @override
  State<_CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<_CarCard> {
  static const int _defaultCount = 3;
  bool _expanded = false;
  CarDTO? _selectedCar;

  @override
  Widget build(BuildContext context) {
    final sample = widget.cars.first;
    final visibleCars = _expanded
        ? widget.cars
        : widget.cars.take(_defaultCount).toList();
    final hiddenCount = widget.cars.length - _defaultCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 차량 기본 정보
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
                    Text(sample.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${sample.type} · ${sample.seats}인승 · ${sample.fuel}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            // 회사별 가격 목록
            ...visibleCars.map((car) => _CompanyPriceTile(
              car: car,
              isSelected: _selectedCar?.id == car.id,
              onTap: () => setState(() {
                _selectedCar = _selectedCar?.id == car.id ? null : car;
              }),
            )),
            // 더보기 버튼
            if (!_expanded && hiddenCount > 0)
              TextButton(
                onPressed: () => setState(() => _expanded = true),
                child: Text('$hiddenCount개 더보기'),
              ),
            if (_expanded && widget.cars.length > _defaultCount)
              TextButton(
                onPressed: () => setState(() => _expanded = false),
                child: const Text('접기'),
              ),
            // 선택된 차량 예약 버튼
            if (_selectedCar != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarReservationScreen(car: _selectedCar!),
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
  final CarDTO car;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyPriceTile({
    required this.car,
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
            Text('${car.companyName} · ${car.year}년', style: const TextStyle(fontSize: 14)),
            Text(
              '${_formatPrice(car.dailyPrice)}원/일',
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

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}