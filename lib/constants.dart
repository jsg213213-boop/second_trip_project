import 'package:dio/dio.dart';

const String baseUrl = 'http://10.0.2.2:8080';

final dio = Dio(BaseOptions(baseUrl: baseUrl));