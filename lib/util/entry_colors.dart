import 'package:flutter/material.dart';

import '../models/entry.dart';

/// 기록의 (배경색, 글자색). 사용자가 지정한 색이 있으면 그것, 없으면 종류별 기본색.
(Color, Color) entryColors(Entry e, ColorScheme cs) {
  final (defBg, defFg) = switch (e.type) {
    EntryType.schedule => (cs.primaryContainer, cs.onPrimaryContainer),
    EntryType.todo => (cs.tertiaryContainer, cs.onTertiaryContainer),
    _ => (cs.secondaryContainer, cs.onSecondaryContainer),
  };
  final bg = e.bgColor == null ? defBg : Color(e.bgColor!);
  // 배경만 지정하고 글자색은 안 정했으면 배경 밝기에 맞춰 검정/흰색
  final fg = e.fgColor != null
      ? Color(e.fgColor!)
      : (e.bgColor == null
            ? defFg
            : (bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white));
  return (bg, fg);
}
