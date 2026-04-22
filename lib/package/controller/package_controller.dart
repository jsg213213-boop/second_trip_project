import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/package_item.dart';

class PackageController {
  // 앱 내에서 사용할 패키지 리스트
  List<PackageItem> packageList = [];

  /// assets에 있는 JSON 파일을 읽어와서 객체 리스트로 변환합니다.
  Future<void> loadPackages() async {
    try {
      // 1. JSON 파일 문자열 로드(데이터 가져오기)
      final String response = await rootBundle.loadString('assets/data/packages.json');

      // 2. 문자열을 리스트(Dynamic)로 디코딩
      final List<dynamic> data = json.decode(response);

      // 3. 각 데이터를 PackageItem 객체로 변환하여 리스트에 저장
      packageList = data.map((json) => PackageItem.fromJson(json)).toList();

      print("데이터 로드 성공: ${packageList.length}개");
    } catch (e) {
      print("데이터 로드 중 오류 발생: $e");
    }
  }

  /// 카테고리별로 데이터를 필터링하는 함수 (UI에서 호출할 용도)
  List<PackageItem> getPackagesByCategory(String category) {
    return packageList.where((item) => item.category == category).toList();
  }
}