import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../l10n/app_localizations.dart';

/// 색상 선택 한 줄: [기본] + 프리셋 원들 + [직접 선택]. 가로 스크롤.
class ColorPickerRow extends StatelessWidget {
  final String label;
  final List<Color> presets;
  final Color? value;
  final ValueChanged<Color?> onChanged;

  const ColorPickerRow({
    super.key,
    required this.label,
    required this.presets,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pickCustom(BuildContext context) async {
    final t = L10n.of(context);
    var picked = value ?? presets.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.colorPickerTitle),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.ok),
          ),
        ],
      ),
    );
    if (ok == true) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final isPreset =
        value != null && presets.any((c) => c.toARGB32() == value!.toARGB32());
    final isCustom = value != null && !isPreset;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Swatch(
                  color: null,
                  selected: value == null,
                  tooltip: t.colorDefault,
                  onTap: () => onChanged(null),
                  child: Icon(
                    Icons.format_color_reset_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                for (final c in presets)
                  _Swatch(
                    color: c,
                    selected: value?.toARGB32() == c.toARGB32(),
                    onTap: () => onChanged(c),
                  ),
                _Swatch(
                  color: isCustom ? value : null,
                  selected: isCustom,
                  tooltip: t.colorCustom,
                  onTap: () => _pickCustom(context),
                  child: Icon(
                    Icons.colorize,
                    size: 18,
                    color: isCustom ? _onColor(value!) : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Color _onColor(Color c) =>
      c.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
}

class _Swatch extends StatelessWidget {
  final Color? color;
  final bool selected;
  final String? tooltip;
  final VoidCallback onTap;
  final Widget? child;
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tooltip,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color ?? cs.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          child:
              child ??
              (selected
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: ColorPickerRow._onColor(color!),
                    )
                  : null),
        ),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}
