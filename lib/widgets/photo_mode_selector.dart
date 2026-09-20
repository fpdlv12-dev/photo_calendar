import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/settings.dart';

/// 월 화면 사진 표시 옵션 (1장 / 최대 4장 / 모두) 라디오 카드 목록.
/// 온보딩과 설정 화면에서 같이 쓴다.
class PhotoModeSelector extends StatelessWidget {
  final PhotoMode value;
  final ValueChanged<PhotoMode> onChanged;
  const PhotoModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final items = [
      (
        PhotoMode.one,
        t.photoModeOne,
        t.photoModeOneDesc,
        Icons.crop_square_rounded,
      ),
      (
        PhotoMode.four,
        t.photoModeFour,
        t.photoModeFourDesc,
        Icons.grid_view_rounded,
      ),
      (
        PhotoMode.all,
        t.photoModeAll,
        t.photoModeAllDesc,
        Icons.view_agenda_rounded,
      ),
    ];
    return Column(
      children: [
        for (final (mode, title, desc, icon) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: mode == value
                  ? cs.primaryContainer
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onChanged(mode),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: mode == value
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        mode == value
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: mode == value ? cs.primary : cs.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
