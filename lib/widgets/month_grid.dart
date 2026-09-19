import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/entry.dart';
import '../services/settings.dart';
import '../util/dates.dart';

/// 월 화면 그리드. 이 앱의 핵심 — 날짜 칸 안에 사진을 직접 그린다.
///
/// - [PhotoMode.one] / [PhotoMode.four]: 그리드가 화면 높이에 맞춰 고정되고
///   사진이 칸 크기에 맞게 작아진다.
/// - [PhotoMode.all]: 사진 크기(칸 너비의 절반)는 유지하고 행 높이가 늘어난다.
///   전체를 세로 스크롤한다.
class MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<String, List<Entry>> data;
  final PhotoMode mode;
  final int weekStart;
  final bool showText;
  final File Function(String relative) fileOf;
  final ValueChanged<DateTime> onTapDay;

  const MonthGrid({
    super.key,
    required this.month,
    required this.data,
    required this.mode,
    required this.weekStart,
    required this.showText,
    required this.fileOf,
    required this.onTapDay,
  });

  static const _headerH = 26.0;
  static const _dayNumH = 22.0;
  static const _chipH = 15.0;
  static const _pad = 2.0;
  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    final days = gridDays(month, weekStart);
    final rows = days.length ~/ 7;
    final locale = Localizations.localeOf(context).toString();

    return LayoutBuilder(builder: (context, c) {
      final cellW = c.maxWidth / 7;
      final gridH = c.maxHeight - _headerH;
      final baseRowH = gridH / rows;

      final rowHeights = List<double>.generate(rows, (r) {
        if (mode != PhotoMode.all) return baseRowH;
        var h = math.max(64.0, baseRowH);
        for (var i = 0; i < 7; i++) {
          final d = days[r * 7 + i];
          h = math.max(h, _allModeCellHeight(cellW, data[dateKey(d)] ?? const []));
        }
        return h;
      });

      final body = Column(
        children: [
          for (var r = 0; r < rows; r++)
            SizedBox(
              height: rowHeights[r],
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(child: _cell(context, days[r * 7 + i], cellW, rowHeights[r])),
                ],
              ),
            ),
        ],
      );

      return Column(
        children: [
          SizedBox(height: _headerH, child: _weekdayHeader(context, locale)),
          Expanded(
            child: mode == PhotoMode.all
                ? SingleChildScrollView(child: body)
                : body,
          ),
        ],
      );
    });
  }

  double _allModeCellHeight(double cellW, List<Entry> entries) {
    final photos = entries.where((e) => e.type == EntryType.photo).length;
    final items = showText ? entries.length - photos : 0;
    final side = (cellW - _pad * 2 - _gap) / 2;
    final photoRows = (photos + 1) ~/ 2;
    var h = _dayNumH + _pad * 2;
    if (photoRows > 0) h += photoRows * side + (photoRows - 1) * _gap;
    if (items > 0) h += items * _chipH + (photoRows > 0 ? _gap : 0);
    return h.ceilToDouble() + 2; // 소수 픽셀 반올림 오버플로 방지
  }

  Widget _weekdayHeader(BuildContext context, String locale) {
    final cs = Theme.of(context).colorScheme;
    // 2023-01-01 은 일요일. weekStart 부터 7일.
    final base = DateTime(2023, 1, 1 + (weekStart % 7));
    final f = DateFormat.E(locale);
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Center(
              child: Text(
                f.format(base.add(Duration(days: i))),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _weekdayColor(cs, base.add(Duration(days: i)).weekday) ?? cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color? _weekdayColor(ColorScheme cs, int weekday) {
    if (weekday == DateTime.sunday) return cs.error;
    if (weekday == DateTime.saturday) return cs.primary;
    return null;
  }

  Widget _cell(BuildContext context, DateTime day, double cellW, double rowH) {
    final cs = Theme.of(context).colorScheme;
    final t = L10n.of(context);
    final inMonth = day.month == month.month;
    final today = sameDay(day, DateTime.now());
    final entries = data[dateKey(day)] ?? const [];
    final photos = entries.where((e) => e.type == EntryType.photo).toList();
    final items = showText ? entries.where((e) => e.type != EntryType.photo).toList() : const <Entry>[];

    final numColor = today
        ? cs.onPrimary
        : (_weekdayColor(cs, day.weekday) ?? cs.onSurface);

    return InkWell(
      onTap: () => onTapDay(day),
      child: Opacity(
        opacity: inMonth ? 1 : 0.38,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(_pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _dayNumH,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: today
                        ? BoxDecoration(color: cs.primary, shape: BoxShape.circle)
                        : null,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: today ? FontWeight.bold : FontWeight.w500,
                        color: numColor,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: mode == PhotoMode.all
                    ? _allBody(context, t, cellW, photos, items)
                    : _fixedBody(context, t, photos, items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ 고정 높이 모드

  Widget _fixedBody(BuildContext context, L10n t, List<Entry> photos, List<Entry> items) {
    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight;
      if (photos.isEmpty) {
        final fit = math.max(0, (h / _chipH).floor());
        return _chips(context, t, items, fit);
      }
      // 사진 블록은 칸 너비 기준(약 6:7 세로형)까지만 키우고, 남는 높이에 제목을 채운다.
      // 칸이 그보다 낮으면 사진이 칸에 맞게 작아진다 (제목 1줄은 확보).
      var photoH = math.min(h, c.maxWidth * 1.15);
      var fit = ((h - photoH - _gap) / _chipH).floor().clamp(0, items.length);
      if (items.isNotEmpty && fit == 0 && h > _chipH * 3) {
        photoH = h - _chipH - _gap;
        fit = 1;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: math.max(0, photoH), child: _photoBlock(context, t, photos, c.maxWidth, photoH)),
          if (fit > 0) ...[
            const SizedBox(height: _gap),
            _chips(context, t, items, fit),
          ],
        ],
      );
    });
  }

  Widget _photoBlock(BuildContext context, L10n t, List<Entry> photos, double w, double h) {
    if (h <= 4) return const SizedBox.shrink();
    if (mode == PhotoMode.one || photos.length == 1) {
      // 1장 모드: 사진은 그대로 보이고 모서리에 +N 배지만
      return _thumb(photos.first, badge: photos.length > 1 ? t.morePhotos(photos.length - 1) : null);
    }
    // PhotoMode.four: 2장 → 가로 2칸, 3~4장 → 2×2
    if (photos.length == 2) {
      return Row(children: [
        Expanded(child: _thumb(photos[0])),
        const SizedBox(width: _gap),
        Expanded(child: _thumb(photos[1])),
      ]);
    }
    final shown = photos.take(4).toList();
    final more = photos.length - 4;
    return Column(children: [
      Expanded(
        child: Row(children: [
          Expanded(child: _thumb(shown[0])),
          const SizedBox(width: _gap),
          Expanded(child: _thumb(shown[1])),
        ]),
      ),
      const SizedBox(height: _gap),
      Expanded(
        child: Row(children: [
          Expanded(child: _thumb(shown[2])),
          const SizedBox(width: _gap),
          Expanded(
            child: shown.length > 3
                ? _thumb(shown[3], overlay: more > 0 ? t.morePhotos(more) : null)
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    ]);
  }

  // ------------------------------------------------------------ 모두 보기 모드

  Widget _allBody(BuildContext context, L10n t, double cellW, List<Entry> photos, List<Entry> items) {
    final side = (cellW - _pad * 2 - _gap) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < photos.length; i += 2) ...[
          if (i > 0) const SizedBox(height: _gap),
          SizedBox(
            height: side,
            child: Row(children: [
              SizedBox(width: side, child: _thumb(photos[i])),
              const SizedBox(width: _gap),
              SizedBox(width: side, child: i + 1 < photos.length ? _thumb(photos[i + 1]) : null),
            ]),
          ),
        ],
        if (photos.isNotEmpty && items.isNotEmpty) const SizedBox(height: _gap),
        for (final e in items) _chipRow(context, e, more: 0, t: t),
      ],
    );
  }

  // ------------------------------------------------------------ 공통 조각

  /// [overlay]: 사진 전체를 어둡게 덮고 가운데 글자 (2×2 의 마지막 칸용).
  /// [badge]: 오른쪽 아래 작은 배지 (1장 모드용).
  Widget _thumb(Entry e, {String? overlay, String? badge}) {
    final path = e.thumb ?? e.file;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            Image.file(
              fileOf(path),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const ColoredBox(color: Color(0x22000000)),
            ),
          if (overlay != null)
            ColoredBox(
              color: const Color(0x66000000),
              child: Center(
                child: Text(overlay,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          if (badge != null)
            Positioned(
              right: 3,
              bottom: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xAA000000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.3)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chips(BuildContext context, L10n t, List<Entry> items, int fit) {
    if (items.isEmpty || fit == 0) return const SizedBox.shrink();
    final overflow = items.length > fit;
    // 한 줄밖에 못 넣으면 첫 제목 + "+N" 을 같은 줄에
    if (overflow && fit == 1) return _chipRow(context, items.first, more: items.length - 1, t: t);
    final shown = overflow ? items.take(fit - 1).toList() : items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in shown) _chipRow(context, e, more: 0, t: t),
        if (overflow)
          SizedBox(
            height: _chipH,
            child: Text(
              t.moreItems(items.length - shown.length),
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.3),
            ),
          ),
      ],
    );
  }

  Widget _chipRow(BuildContext context, Entry e, {required int more, required L10n t}) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg) = switch (e.type) {
      EntryType.schedule => (cs.primaryContainer, cs.onPrimaryContainer),
      EntryType.todo => (cs.tertiaryContainer, cs.onTertiaryContainer),
      _ => (cs.secondaryContainer, cs.onSecondaryContainer),
    };
    final text = e.type == EntryType.memo && e.title.isEmpty ? e.body : e.title;
    return SizedBox(
      height: _chipH,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.replaceAll('\n', ' '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  color: fg,
                  height: 1.35,
                  decoration: e.type == EntryType.todo && e.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (more > 0)
              Text('+$more', style: TextStyle(fontSize: 9, color: fg, fontWeight: FontWeight.bold, height: 1.35)),
          ],
        ),
      ),
    );
  }
}
