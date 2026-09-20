import 'package:flutter/material.dart';

/// 일정·할 일·메모 색상 팔레트 (사용자가 고르는 프리셋). ARGB int 로 DB 에 저장.
class Palette {
  Palette._();

  /// 배경색 프리셋 — 파스텔 (라이트/다크 모두에서 글자가 읽히는 밝기)
  static const backgrounds = <Color>[
    Color(0xFFFFCDD2), // 빨강
    Color(0xFFFFE0B2), // 주황
    Color(0xFFFFF9C4), // 노랑
    Color(0xFFDCEDC8), // 연두
    Color(0xFFC8E6C9), // 초록
    Color(0xFFB2DFDB), // 청록
    Color(0xFFBBDEFB), // 파랑
    Color(0xFFC5CAE9), // 남색
    Color(0xFFE1BEE7), // 보라
    Color(0xFFF8BBD0), // 분홍
    Color(0xFFD7CCC8), // 갈색
    Color(0xFFE0E0E0), // 회색
  ];

  /// 글자색 프리셋 — 진한 색
  static const foregrounds = <Color>[
    Color(0xFF212121), // 검정
    Color(0xFFFFFFFF), // 흰색
    Color(0xFFC62828), // 빨강
    Color(0xFFEF6C00), // 주황
    Color(0xFF2E7D32), // 초록
    Color(0xFF00838F), // 청록
    Color(0xFF1565C0), // 파랑
    Color(0xFF6A1B9A), // 보라
    Color(0xFFAD1457), // 분홍
    Color(0xFF5D4037), // 갈색
    Color(0xFF616161), // 회색
  ];
}
