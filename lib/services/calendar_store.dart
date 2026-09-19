import 'package:flutter/foundation.dart';

import '../models/entry.dart';
import '../util/dates.dart';
import 'app_db.dart';
import 'photo_store.dart';

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

  static String _mk(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';

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
      await db.insert(Entry(
        date: date,
        type: EntryType.photo,
        file: s.file,
        thumb: s.thumb,
        createdAt: t++,
      ));
    }
    _invalidate(date);
    notifyListeners();
    return saved.length;
  }
}
