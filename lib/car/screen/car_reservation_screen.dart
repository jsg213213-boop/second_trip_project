import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/calendar_controller.dart';
import '../controller/rental_controller.dart';
import '../model/car_dto.dart';

class CarReservationScreen extends StatelessWidget {
  final CarDTO car;

  const CarReservationScreen({super.key, required this.car});

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _toApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final calendar = context.read<CalendarController>();
    final start = calendar.rangeStart!;
    final end = calendar.rangeEnd!;
    final days = end.difference(start).inDays;
    final totalPrice = car.dailyPrice * days;

    return Scaffold(
      appBar: AppBar(title: const Text('예약 확인')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 차량 정보
            const Text('차량 정보', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${car.type} · ${car.seats}인승 · ${car.fuel} · ${car.year}년',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(car.companyName, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 대여 기간
            const Text('대여 기간', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('인수일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_formatDate(start), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (calendar.startTime != null)
                        Text(calendar.startTime!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('반납일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_formatDate(end), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (calendar.endTime != null)
                        Text(calendar.endTime!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 요금
            const Text('요금', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_formatPrice(car.dailyPrice)}원 × $days일'),
                      Text('${_formatPrice(totalPrice)}원'),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('총 금액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${_formatPrice(totalPrice)}원',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004680)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 예약하기 버튼
            Consumer<RentalController>(
              builder: (context, rentalController, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: rentalController.isLoading
                        ? null
                        : () async {
                            final result = await rentalController.createRental(
                              car.id,
                              _toApiDate(start),
                              _toApiDate(end),
                            );
                            if (!context.mounted) return;
                            if (result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('예약이 완료되었습니다.')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(rentalController.errorMessage ?? '예약 실패')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004680),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: rentalController.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('예약하기', style: TextStyle(fontSize: 18)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}