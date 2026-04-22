import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱 전반에서 공통으로 사용하는 버튼 위젯입니다.
/// ElevatedButton(채워진 스타일)과 OutlinedButton(테두리 스타일)을 선택하여 사용할 수 있습니다.
class CommonButton extends StatelessWidget {
  final String text;           // 버튼에 표시될 텍스트
  final VoidCallback onPressed; // 버튼 클릭 시 실행될 함수
  final bool isOutlined;       // true: 테두리만 있는 버튼, false: 배경색이 채워진 버튼
  final Color? color;          // 버튼의 주요 색상 (지정하지 않으면 AppColors.primary 사용)
  final double? width;         // 버튼 너비 (지정하지 않으면 가로 전체 확장)
  final bool isEnabled;        // 버튼 활성화 여부 (false 설정 시 클릭 불가 및 회색 처리)

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.color,
    this.width,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 지정된 색상이 없으면 앱의 기본 브랜드 컬러를 사용합니다.
    final buttonColor = color ?? AppColors.primary;

    // 1. 테두리 스타일 (OutlinedButton) 인 경우
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity, // 너비 미지정 시 가로 꽉 채움
        child: OutlinedButton(
          // isEnabled가 false면 null을 전달하여 버튼을 시스템적으로 비활성화합니다.
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: buttonColor, // 글자 및 아이콘 색상
            side: BorderSide(color: buttonColor), // 테두리 색상
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글기
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 2. 기본 스타일 (ElevatedButton) 인 경우
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // 버튼 배경색
          foregroundColor: Colors.white, // 버튼 텍스트 색상
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
/*
  [ CommonButton 사용 가이드 ]

  1. 기본 버튼 (가득 찬 스타일)
     CommonButton(
       text: '확인',
       onPressed: () => print('클릭'),
     )

  2. 외곽선 버튼 (테두리 스타일)
     CommonButton(
       text: '취소',
       isOutlined: true,
       onPressed: () => Navigator.pop(context),
     )

  3. 버튼 비활성화 (로딩/조건 미충족 시)
     CommonButton(
       text: '전송 중...',
       isEnabled: false,  // 버튼 잠금 및 회색 처리
       onPressed: () {},
     )

  4. 커스텀 (너비/색상 변경)
     CommonButton(
       text: '삭제',
       color: Colors.red,
       width: 150,
       onPressed: () {},
     )
*/
