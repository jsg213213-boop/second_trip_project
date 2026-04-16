import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:second_trip_project/screen/RoutingScreen.dart';

import 'car/controller/calendar_controller.dart';
import 'car/controller/rent_comp_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RentCompController(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarController(),
        ),
      ],
      child: const RoutingScreen(),
    ),
  );
}