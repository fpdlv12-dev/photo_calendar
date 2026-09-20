import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/entry.dart';
import '../util/entry_colors.dart';
import '../util/palette.dart';
import '../widgets/color_picker_row.dart';

/// 일정·할 일·메모 편집 시트. 저장했으면 true 를 반환한다.
Future<bool?> showEntryEditor(
  BuildContext context, {
  required String date,
  required EntryType type,
  Entry? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _EntryEditor(date: date, type: type, existing: existing),
  );
}

class _EntryEditor extends StatefulWidget {
  final String date;
  final EntryType type;
  final Entry? existing;
  const _EntryEditor({required this.date, required this.type, this.existing});

  @override
  State<_EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<_EntryEditor> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');
  TimeOfDay? _time;
  bool _error = false;
  late Color? _bg = widget.existing?.bgColor == null
      ? null
      : Color(widget.existing!.bgColor!);
  late Color? _fg = widget.existing?.fgColor == null
      ? null
      : Color(widget.existing!.fgColor!);

  @override
  void initState() {
    super.initState();
    final t = widget.existing?.time;
    if (t != null) {
      final p = t.split(':');
      _time = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  String? get _timeStr => _time == null
      ? null
      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final store = AppScope.of(context).store;
    final isMemo = widget.type == EntryType.memo;
    final title = _title.text.trim();
    final body = _body.text.trim();
    if ((isMemo && body.isEmpty) || (!isMemo && title.isEmpty)) {
      setState(() => _error = true);
      return;
    }
    final existing = widget.existing;
    if (existing == null) {
      await store.add(
        Entry(
          date: widget.date,
          type: widget.type,
          title: title,
          body: body,
          time: widget.type == EntryType.schedule ? _timeStr : null,
          bgColor: _bg?.toARGB32(),
          fgColor: _fg?.toARGB32(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await store.update(
        existing.copyWith(
          title: title,
          body: body,
          time: _timeStr,
          clearTime: _timeStr == null,
          bgColor: _bg?.toARGB32(),
          clearBgColor: _bg == null,
          fgColor: _fg?.toARGB32(),
          clearFgColor: _fg == null,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final t = L10n.of(context);
    final store = AppScope.of(context).store;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await store.remove(widget.existing!);
      if (mounted) Navigator.of(context).pop(false);
    }
  }

  /// 배경색·글자색 선택 + 월 화면 칩 미리보기
  Widget _colorSection(BuildContext context, L10n t, ColorScheme cs) {
    // 실제 칩과 같은 규칙으로 미리보기 색 계산
    final (defBg, defFg) = entryColors(
      Entry(
        date: widget.date,
        type: widget.type,
        bgColor: _bg?.toARGB32(),
        fgColor: _fg?.toARGB32(),
        createdAt: 0,
      ),
      cs,
    );
    final previewText =
        (widget.type == EntryType.memo ? _body.text : _title.text).trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: defBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                previewText.isEmpty
                    ? t.titleHint
                    : previewText.replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: defFg, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ColorPickerRow(
          label: t.bgColor,
          presets: Palette.backgrounds,
          value: _bg,
          onChanged: (c) => setState(() => _bg = c),
        ),
        const SizedBox(height: 8),
        ColorPickerRow(
          label: t.textColor,
          presets: Palette.foregrounds,
          value: _fg,
          onChanged: (c) => setState(() => _fg = c),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final heading = switch (widget.type) {
      EntryType.schedule => t.editSchedule,
      EntryType.todo => t.editTodo,
      _ => t.editMemo,
    };
    final isMemo = widget.type == EntryType.memo;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        // 키보드가 올라오면 시트가 길어지므로 스크롤 가능하게
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(heading, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  if (widget.existing != null)
                    IconButton(
                      tooltip: t.delete,
                      icon: Icon(Icons.delete_outline, color: cs.error),
                      onPressed: _delete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (isMemo)
                TextField(
                  controller: _body,
                  autofocus: widget.existing == null,
                  minLines: 4,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: t.memoHint,
                    border: const OutlineInputBorder(),
                    errorText: _error ? t.titleRequired : null,
                  ),
                  onChanged: (_) => setState(() => _error = false),
                )
              else ...[
                TextField(
                  controller: _title,
                  autofocus: widget.existing == null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: t.titleHint,
                    border: const OutlineInputBorder(),
                    errorText: _error ? t.titleRequired : null,
                  ),
                  onChanged: (_) => setState(() => _error = false),
                  onSubmitted: (_) =>
                      widget.type == EntryType.todo ? _save() : null,
                ),
                if (widget.type == EntryType.schedule) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(t.timeLabel),
                      const Spacer(),
                      if (_time != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _time = null),
                        ),
                      OutlinedButton(
                        onPressed: _pickTime,
                        child: Text(_time == null ? t.allDay : _timeStr!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _body,
                    minLines: 2,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: t.noteHint,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              _colorSection(context, t, cs),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(t.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
