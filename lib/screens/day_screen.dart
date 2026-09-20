import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../ads/ad_manager.dart';
import '../app_scope.dart';
import '../data/holidays.dart';
import '../l10n/app_localizations.dart';
import '../models/entry.dart';
import '../util/dates.dart';
import '../util/entry_colors.dart';
import '../widgets/banner_ad_widget.dart';
import 'entry_editor.dart';
import 'photo_viewer_screen.dart';

/// 하루 상세: 일정 / 할 일 / 메모 / 사진 목록 + 추가 버튼.
class DayScreen extends StatefulWidget {
  final DateTime date;
  const DayScreen({super.key, required this.date});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  late DateTime _date = widget.date;
  bool _busy = false;

  String get _key => dateKey(_date);

  /// 저장이 끝난 뒤 하루 1회 전면 광고.
  void _afterSave() => AdManager.instance.showInterstitialOncePerDayThen(() {});

  Future<void> _openEditor(EntryType type, {Entry? existing}) async {
    final saved = await showEntryEditor(
      context,
      date: _key,
      type: type,
      existing: existing,
    );
    if (saved == true && mounted) _afterSave();
  }

  Future<void> _addPhotos() async {
    if (_busy) return;
    setState(() => _busy = true);
    final t = L10n.of(context);
    final store = AppScope.of(context).store;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await store.addPhotos(_key);
      if (!mounted) return;
      if (n > 0) {
        messenger.showSnackBar(SnackBar(content: Text(t.photosAdded(n))));
        _afterSave();
      }
    } catch (e) {
      debugPrint('addPhotos failed: $e');
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(t.photoAddFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showAddSheet() {
    final t = L10n.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _addTile(
              ctx,
              Icons.event_rounded,
              t.addSchedule,
              () => _openEditor(EntryType.schedule),
            ),
            _addTile(
              ctx,
              Icons.check_circle_outline_rounded,
              t.addTodo,
              () => _openEditor(EntryType.todo),
            ),
            _addTile(
              ctx,
              Icons.sticky_note_2_outlined,
              t.addMemo,
              () => _openEditor(EntryType.memo),
            ),
            _addTile(
              ctx,
              Icons.add_photo_alternate_outlined,
              t.addPhoto,
              _addPhotos,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _addTile(
    BuildContext ctx,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(ctx).pop();
        onTap();
      },
    );
  }

  Future<void> _confirmDelete(Entry e) async {
    final t = L10n.of(context);
    final store = AppScope.of(context).store;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(
          e.type == EntryType.photo
              ? t.deletePhotoConfirmBody
              : t.deleteConfirmBody,
        ),
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
    if (ok == true) await store.remove(e);
  }

  void _shiftDay(int delta) => setState(
    () => _date = DateTime(_date.year, _date.month, _date.day + delta),
  );

  /// 제목 탭 → 날짜 입력(키보드) 또는 달력으로 이동
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2099, 12, 31),
      initialEntryMode: DatePickerEntryMode.input,
      helpText: L10n.of(context).jumpToDate,
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final cs = Theme.of(context).colorScheme;
    final scope = AppScope.of(context);
    final store = scope.store;
    final locale = Localizations.localeOf(context).toString();
    final lang = Localizations.localeOf(context).languageCode;
    final holiday = scope.settings.holidaysEnabled(lang == 'ko')
        ? KoreanHolidays.of(_date)
        : null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _pickDate,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat(t.dateFormatFull, locale).format(_date),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: holiday != null ? cs.error : null),
                ),
                if (holiday != null)
                  Text(
                    KoreanHolidays.name(holiday, lang),
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _shiftDay(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _shiftDay(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _busy ? null : _showAddSheet,
        child: _busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.add),
      ),
      // 배너를 bottomNavigationBar 슬롯에 두면 FAB 가 배너 위에 올라간다.
      bottomNavigationBar: const BannerAdWidget(),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final all = store.dayEntries(_date);
          if (all.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  t.emptyDay,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.6),
                ),
              ),
            );
          }
          final schedules = all
              .where((e) => e.type == EntryType.schedule)
              .toList();
          final todos = all.where((e) => e.type == EntryType.todo).toList();
          final memos = all.where((e) => e.type == EntryType.memo).toList();
          final photos = all.where((e) => e.type == EntryType.photo).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            children: [
              if (photos.isNotEmpty) ...[
                _header(
                  t.sectionPhoto,
                  Icons.photo_outlined,
                  '${photos.length}',
                ),
                _photoGrid(photos, store.photos.fileOf),
              ],
              if (schedules.isNotEmpty) ...[
                _header(t.sectionSchedule, Icons.event_rounded, null),
                for (final e in schedules) _scheduleTile(e, cs),
              ],
              if (todos.isNotEmpty) ...[
                _header(
                  t.sectionTodo,
                  Icons.check_circle_outline_rounded,
                  null,
                ),
                for (final e in todos) _todoTile(e, store, cs),
              ],
              if (memos.isNotEmpty) ...[
                _header(t.sectionMemo, Icons.sticky_note_2_outlined, null),
                for (final e in memos) _memoTile(e, cs),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _header(String title, IconData icon, String? trailing) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: cs.primary),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            Text(
              trailing,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _photoGrid(List<Entry> photos, fileOf) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) {
        final e = photos[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PhotoViewerScreen(photos: photos, initialIndex: i),
            ),
          ),
          onLongPress: () => _confirmDelete(e),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              fileOf(e.thumb ?? e.file!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0x22000000)),
            ),
          ),
        );
      },
    );
  }

  /// 사용자 색이 있으면 카드 배경·글자색에 적용
  Card _card(Entry e, ColorScheme cs, Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    color: e.bgColor == null ? null : Color(e.bgColor!),
    child: child,
  );

  Widget _scheduleTile(Entry e, ColorScheme cs) {
    final t = L10n.of(context);
    final (_, fg) = entryColors(e, cs);
    final custom = e.bgColor != null || e.fgColor != null;
    return _card(
      e,
      cs,
      ListTile(
        leading: SizedBox(
          width: 48,
          child: Text(
            e.time ?? t.allDay,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: e.time == null ? 11 : 14,
              fontWeight: FontWeight.w600,
              color: custom ? fg : cs.primary,
            ),
          ),
        ),
        title: Text(e.title, style: custom ? TextStyle(color: fg) : null),
        subtitle: e.body.isEmpty
            ? null
            : Text(
                e.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: custom
                    ? TextStyle(color: fg.withValues(alpha: 0.8))
                    : null,
              ),
        onTap: () => _openEditor(EntryType.schedule, existing: e),
        onLongPress: () => _confirmDelete(e),
      ),
    );
  }

  Widget _todoTile(Entry e, store, ColorScheme cs) {
    final (_, fg) = entryColors(e, cs);
    final custom = e.bgColor != null || e.fgColor != null;
    return _card(
      e,
      cs,
      CheckboxListTile(
        value: e.done,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          e.title,
          style: TextStyle(
            decoration: e.done ? TextDecoration.lineThrough : null,
            color: custom
                ? fg.withValues(alpha: e.done ? 0.6 : 1)
                : (e.done ? cs.onSurfaceVariant : null),
          ),
        ),
        onChanged: (v) => store.update(e.copyWith(done: v ?? false)),
        secondary: IconButton(
          icon: Icon(Icons.edit_outlined, size: 20, color: custom ? fg : null),
          onPressed: () => _openEditor(EntryType.todo, existing: e),
        ),
      ),
    );
  }

  Widget _memoTile(Entry e, ColorScheme cs) {
    final (_, fg) = entryColors(e, cs);
    final custom = e.bgColor != null || e.fgColor != null;
    return _card(
      e,
      cs,
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openEditor(EntryType.memo, existing: e),
        onLongPress: () => _confirmDelete(e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(
            e.body,
            style: TextStyle(height: 1.5, color: custom ? fg : null),
          ),
        ),
      ),
    );
  }
}
