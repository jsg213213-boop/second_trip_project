import 'package:flutter/material.dart';

class AppTheme {
  // ─── 컬러 상수 ───────────────────────────────────────────────
  static const Color primary = Color(0xFFFF4E64);      // 여기어때 빨간색
  static const Color background = Color(0xFFF5F5F5);   // 배경 회색
  static const Color surface = Color(0xFFFFFFFF);      // 카드 흰색
  static const Color textPrimary = Color(0xFF222222);  // 제목 텍스트
  static const Color textSecondary = Color(0xFF888888);// 서브 텍스트
  static const Color textHint = Color(0xFFBBBBBB);     // 힌트 텍스트
  static const Color border = Color(0xFFE8E8E8);       // 테두리
  static const Color star = Color(0xFFFA8C00);         // 별점 색

  // ─── 테마 설정 ───────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
    scaffoldBackgroundColor: background,

    // 앱바 스타일
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 카드 스타일
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 0.5),
      ),
    ),

    // 하단 네비게이션 스타일
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 1,
    ),

    // 버튼 스타일
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}