import 'package:flutter/foundation.dart';

import '../models/entry.dart';
import '../util/dates.dart';
import 'app_db.dart';
import 'photo_store.dart';

/// 검색 결과 한 줄: 날짜 + 본문 발췌 + 보여줄 사진들(맞은 사진 앞뒤 1장).
class SearchHit {
  final String date;

  /// 키워드 검색이면 맞은 기록, 사진 검색이면 그날 첫 텍스트 기록 (없으면 null)
  final Entry? entry;

  /// 발췌문 (키워드 앞뒤 5자). 사진 검색이면 그날 첫 텍스트의 앞부분.
  final String snippet;
  final List<Entry> photos;

  /// [photos] 중 검색에 맞은 사진 (사진 검색일 때만)
  final Entry? matchedPhoto;

  const SearchHit({
    required this.date,
    required this.entry,
    required this.snippet,
    required this.photos,
    this.matchedPhoto,
  });
}

/// 화면이 쓰는 데이터 캐시. 월 단위로 DB 에서 읽어 두고, 변경이 생기면 해당 월
/// 캐시를 지우고 notifyListeners 한다. 화면은 [monthData]/[dayEntries] 를 동기로
/// 읽되, 캐시가 없으면 빈 값을 받고 로드 완료 후 다시 그려진다.
class CalendarStore extends ChangeNotifier {
  final AppDb db;
  final PhotoStore photos;
  CalendarStore(this.db, this.photos);

  /// key: 'yyyy-MM' → 날짜별 기록
  final _cache = <String, Map<String, List<Entry>>>{};
  final _loading = <String>{};

  static String _mk(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  /// 해당 월(앞뒤 달 며칠 포함)의 데이터. 없으면 로드를 시작하고 빈 맵 반환.
  Map<String, List<Entry>> monthData(DateTime month) {
    final k = _mk(month);
    final cached = _cache[k];
    if (cached != null) return cached;
    _load(month);
    return const {};
  }

  List<Entry> dayEntries(DateTime day) =>
      monthData(DateTime(day.year, day.month, 1))[dateKey(day)] ?? const [];

  Future<void> _load(DateTime month) async {
    final k = _mk(month);
    if (_loading.contains(k)) return;
    _loading.add(k);
    // 그리드에 보이는 앞뒤 달 날짜까지 포함하도록 넉넉히 ±7일
    final first = DateTime(month.year, month.month, 1 - 7);
    final last = DateTime(month.year, month.month + 1, 0 + 7);
    final data = await db.range(dateKey(first), dateKey(last));
    _cache[k] = data;
    _loading.remove(k);
    notifyListeners();
  }

  void _invalidate(String date) {
    final d = parseDateKey(date);
    // 앞뒤 달 그리드에도 보일 수 있으므로 인접 월 캐시까지 지운다.
    for (final m in [-1, 0, 1]) {
      _cache.remove(_mk(DateTime(d.year, d.month + m, 1)));
    }
  }

  Future<Entry> add(Entry e) async {
    final id = await db.insert(e);
    _invalidate(e.date);
    notifyListeners();
    return e.copyWith(id: id);
  }

  Future<void> update(Entry e, {String? oldDate}) async {
    await db.update(e);
    _invalidate(e.date);
    if (oldDate != null) _invalidate(oldDate);
    notifyListeners();
  }

  Future<void> remove(Entry e) async {
    await db.delete(e.id!);
    if (e.type == EntryType.photo) await photos.deleteFiles(e.file, e.thumb);
    _invalidate(e.date);
    notifyListeners();
  }

  /// 포토 피커 → 저장 → DB 등록. 추가된 장수 반환.
  Future<int> addPhotos(String date) async {
    final saved = await photos.pickAndSave();
    if (saved.isEmpty) return 0;
    var t = DateTime.now().millisecondsSinceEpoch;
    for (final s in saved) {
      await db.insert(
        Entry(
          date: date,
          type: EntryType.photo,
          file: s.file,
          thumb: s.thumb,
          phash: s.hash,
          createdAt: t++,
        ),
      );
    }
    _invalidate(date);
    notifyListeners();
    return saved.length;
  }

  // ---------------------------------------------------------------- 검색

  static const _snippetContext = 5;

  /// 키워드 검색. 맞은 기록마다 한 줄. 사진은 그날 사진 앞에서 최대 3장.
  Future<List<SearchHit>> searchText(String q) async {
    final query = q.trim();
    if (query.isEmpty) return const [];
    final hits = await db.searchText(query);
    final days = await db.byDates(hits.map((e) => e.date));
    return [
      for (final e in hits)
        SearchHit(
          date: e.date,
          entry: e,
          snippet: snippetAround(e.text, query),
          photos: (days[e.date] ?? const [])
              .where((x) => x.type == EntryType.photo)
              .take(3)
              .toList(),
        ),
    ];
  }

  /// [text] 에서 [q] 가 처음 나오는 곳 앞뒤 [_snippetContext] 글자를 잘라낸다.
  static String snippetAround(String text, String q) {
    final flat = text.replaceAll('\n', ' ');
    final i = q.isEmpty ? -1 : flat.toLowerCase().indexOf(q.toLowerCase());
    // 키워드가 없거나(사진 검색) 못 찾으면 앞 12자
    if (i < 0) return flat.length > 12 ? '${flat.substring(0, 12)}…' : flat;
    final s = (i - _snippetContext).clamp(0, flat.length);
    final e = (i + q.length + _snippetContext).clamp(0, flat.length);
    return '${s > 0 ? '…' : ''}${flat.substring(s, e)}${e < flat.length ? '…' : ''}';
  }

  /// 사진 검색. [hash] 와 비슷한 사진마다 한 줄 (가까운 순).
  /// 사진은 맞은 사진 앞뒤 1장씩, 본문은 그날 첫 텍스트 기록의 앞부분.
  Future<List<SearchHit>> searchPhoto(int hash) async {
    final all = await db.allPhotos();
    final scored = <(Entry, int)>[];
    for (final p in all) {
      var h = p.phash;
      if (h == null) {
        // 예전 데이터: 썸네일로 해시를 계산해 채워 둔다
        final f = photos.fileOf(p.thumb ?? p.file!);
        if (!await f.exists()) continue;
        try {
          h = await photos.hashOfFile(f);
          await db.setHash(p.id!, h);
        } catch (_) {
          continue;
        }
      }
      final d = PhotoStore.hammingDistance(hash, h);
      if (d <= PhotoStore.similarThreshold) scored.add((p, d));
    }
    scored.sort(
      (a, b) =>
          a.$2 != b.$2 ? a.$2.compareTo(b.$2) : b.$1.date.compareTo(a.$1.date),
    );

    final days = await db.byDates(scored.map((s) => s.$1.date));
    return [
      for (final (p, _) in scored)
        () {
          final dayEntries = days[p.date] ?? const <Entry>[];
          final dayPhotos = dayEntries
              .where((x) => x.type == EntryType.photo)
              .toList();
          final i = dayPhotos.indexWhere((x) => x.id == p.id);
          final from = (i - 1).clamp(0, dayPhotos.length);
          final to = (i + 2).clamp(0, dayPhotos.length);
          final firstText = dayEntries
              .where((x) => x.type != EntryType.photo)
              .firstOrNull;
          return SearchHit(
            date: p.date,
            entry: firstText,
            snippet: firstText == null ? '' : snippetAround(firstText.text, ''),
            photos: i < 0 ? [p] : dayPhotos.sublist(from, to),
            matchedPhoto: p,
          );
        }(),
    ];
  }
}
