import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:shared_preferences/shared_preferences.dart';

// 라우팅 설정 파일 import
import 'package:second_trip_project/screen/RoutingScreen.dart';

// 각 팀원 컨트롤러 import
import 'package:second_trip_project/package/controller/package_controller.dart';
import 'package:second_trip_project/car/controller/calendar_controller.dart';
import 'package:second_trip_project/car/controller/rent_comp_controller.dart';

// 숙소 파트 import
import 'package:second_trip_project/providers/accommodation_providers.dart';

class PackageController extends ChangeNotifier {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();

  runApp(
    // Riverpod 최상단
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<PackageController>(
              create: (_) => PackageController()),
          ChangeNotifierProvider<RentCompController>(
              create: (_) => RentCompController()),
          ChangeNotifierProvider<CalendarController>(
              create: (_) => CalendarController()),
        ],

        // RoutingScreen에서 라우트 관리
        child: const RoutingScreen(),
      ),
    ),
  );
}