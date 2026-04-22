import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/car_format_util.dart';
import '../controller/car_reservation_controller.dart';
import '../model/company_car_dto.dart';
import '../model/car_search_cursor_response.dart';

class CarReservationScreen extends StatelessWidget {
  final CarSearchCursorResponseDTO car;
  final CompanyCarDTO companyCarDTO;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;

  const CarReservationScreen({
    super.key,
    required this.car,
    required this.companyCarDTO,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
  });

  String _toApiDate(DateTime date, String? time) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final parsed = formatTime(time);
    final timeStr = parsed != null
        ? '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:00'
        : '00:00:00';
    return '${dateStr}T$timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final days = endDate.difference(startDate).inDays;
    final totalPrice = companyCarDTO.dailyPrice * days;

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
                  Text(car.carName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${car.type} · ${car.seats}인승 · ${car.fuel} · ${companyCarDTO.year}년',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(companyCarDTO.companyName, style: const TextStyle(fontSize: 14)),
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
                      Text(formatDate(startDate, showWeekDay: false), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (startTime != null)
                        Text(startTime!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('반납일', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(formatDate(endDate, showWeekDay: false), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      if (endTime != null)
                        Text(endTime!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${formatPrice(companyCarDTO.dailyPrice)}원 × $days일'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('총 금액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        '${formatPrice(totalPrice)}원',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF004680)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 예약하기 버튼
            Consumer<CarReservationController>(
              builder: (context, rentalController, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: rentalController.isLoading
                        ? null
                        : () async {
                            final rentalResult = await rentalController.createRental(
                              companyCarDTO.carId,
                              _toApiDate(startDate, startTime),
                              _toApiDate(endDate, endTime),
                            );
                            if (!context.mounted) return;
                            if (rentalResult != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('예약이 완료되었습니다.')),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            } else if (rentalController.errorMessage == '로그인이 필요합니다.') {
                              final loggedIn = await Navigator.pushNamed(context, '/login', arguments: 'returnToPage');
                              if (!context.mounted) return;
                              if (loggedIn == true) {
                                final retryResult = await rentalController.createRental(
                                  companyCarDTO.carId,
                                  _toApiDate(startDate, startTime),
                                  _toApiDate(endDate, endTime),
                                );
                                if (!context.mounted) return;
                                if (retryResult != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('예약이 완료되었습니다.')),
                                  );

                                  Navigator.popUntil(context, (route) => route.isFirst);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(rentalController.errorMessage ?? '예약 실패')),
                                  );
                                }
                              }
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