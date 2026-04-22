import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:second_trip_project/util/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 라우팅 설정 파일 import
import 'package:second_trip_project/screen/RoutingScreen.dart';

import 'package:second_trip_project/car/controller/calendar_controller.dart';
import 'package:second_trip_project/car/controller/car_reservation_controller.dart';

// 숙소 파트 import
import 'package:second_trip_project/providers/accommodation_providers.dart';
import 'airport/controller/flight_controller.dart';
import 'airport/controller/reservation_controller.dart';

class PackageController extends ChangeNotifier {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // SharedPreferences → 찜 목록 저장용 (Riverpod)
  final prefs = await SharedPreferences.getInstance();

  // ApiClient 초기화 → 백엔드 API 호출용
  ApiClient().init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PackageController>(
              create: (_) => PackageController()),
          ChangeNotifierProvider<CalendarController>(
              create: (_) => CalendarController()),
          ChangeNotifierProvider<CarReservationController>(create: (_) => CarReservationController()),
          ChangeNotifierProvider<FlightController>(
              create: (_) => FlightController()),
          ChangeNotifierProvider<ReservationController>(
              create: (_) => ReservationController()),
        ],
        child: const RoutingScreen(),
      ),
    ),
  );
}