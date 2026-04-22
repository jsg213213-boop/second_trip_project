import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱의 모든 화면에서 공통으로 사용하는 기본 레이아웃 위젯입니다.
/// 상단 AppBar, 배경색, 하단 버튼, 탭바 등을 일관성 있게 관리합니다.
class AppBaseLayout extends StatelessWidget {
  final String title;               // 화면 상단에 표시될 타이틀
  final Widget body;                // 화면의 메인 콘텐츠
  final List<Widget>? actions;       // AppBar 우측에 들어갈 버튼들 (예: 아이콘 버튼)
  final Widget? floatingActionButton; // 화면 우측 하단에 떠 있는 버튼
  final bool showBackButton;         // 뒤로가기 버튼 표시 여부 (기본값: true)
  final Color? backgroundColor;      // 배경색 (미지정 시 AppColors.backgroundWhite)
  final Widget? bottomNavigationBar;  // 하단에 고정될 버튼이나 바 (예: 예약하기 버튼)
  final PreferredSizeWidget? bottom;   // AppBar 하단에 들어갈 위젯 (보통 TabBar 사용)

  const AppBaseLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경색 설정 (null일 경우 기본 배경색 사용)
      backgroundColor: backgroundColor ?? AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false, // 타이틀 왼쪽 정렬
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0, // 그림자 제거
        scrolledUnderElevation: 1, // 스크롤 시 약간의 구분선 효과
        automaticallyImplyLeading: showBackButton, // 뒤로가기 버튼 자동 생성 여부
        actions: actions,
        bottom: bottom, // 탭바 등이 들어가는 영역
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar, // 하단 고정 위젯 영역
    );
  }
}
/*
  [ AppBaseLayout 사용 가이드 ]

  1. 가장 기본적인 페이지 구성
     AppBaseLayout(
       title: '내 정보',
       body: Center(child: Text('콘텐츠')),
     )

  2. 뒤로가기 버튼이 없는 메인 페이지
     AppBaseLayout(
       title: '홈',
       showBackButton: false,
       body: MyHomeWidget(),
     )

  3. 하단에 '예약하기' 버튼이 고정된 페이지 (이미지의 예약 화면 등)
     AppBaseLayout(
       title: '항공권 선택',
       body: ListView(...),
       bottomNavigationBar: CommonButton(
         text: '다음 단계로',
         onPressed: () {},
       ),
     )

  4. 상단에 탭바(TabBar)가 있는 페이지
     AppBaseLayout(
       title: '예약 내역',
       bottom: TabBar(
         tabs: [Tab(text: '다가올 예약'), Tab(text: '지난 예약')],
       ),
       body: TabBarView(children: [...]),
     )
*/
