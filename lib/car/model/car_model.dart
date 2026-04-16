import 'dart:math';
import 'car_spec.dart';

class CarModel {
  final String name;
  final String type;
  final int seats;
  final String fuel;
  final int dailyPrice;
  final int year;
  final bool available;

  const CarModel({
    required this.name,
    required this.type,
    required this.seats,
    required this.fuel,
    required this.dailyPrice,
    required this.year,
    required this.available,
  });

  // 회사 ID를 시드로 사용해서 같은 회사는 항상 같은 차량 목록 생성
  static List<CarModel> generateForCompany(int companyId) {
    final rng = Random(companyId);  //랜덤에 시드로 일관된 값이 나오게
    final count = 10 + rng.nextInt(6); // nextInt는 0~5까지 랜덤이지만 시드때문에 일관되게 나옴
    final shuffled = List<CarSpec>.from(carSpecs)..shuffle(rng);  //List<CarSpec> 형식으로 carSpecs로 부터 복사해 와서 랜덤으로 섞음

    return List.generate(count, (i) { //카운트 반큼 반복해서 리스트 생성(i는 0...count-1)
      final spec = shuffled[i % shuffled.length]; //0 % 25 = 0, 1 % 25 = 1 ... 24 % 25 = 24, 25 % 25 = 0
      final price = ((spec.priceMin + rng.nextInt(spec.priceMax - spec.priceMin + 1)) / 1000).round() * 1000;
      return CarModel(
        name: spec.name,
        type: spec.type,
        seats: spec.seats,
        fuel: spec.fuel,
        dailyPrice: price,
        year: 2020 + rng.nextInt(7), // 2020~2026
        available: rng.nextInt(100) < 75,
      );
    });
  }
}