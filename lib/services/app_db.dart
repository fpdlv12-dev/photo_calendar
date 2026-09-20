import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/entry.dart';

/// SQLite 저장소. 테이블 하나(entries)에 일정·할 일·메모·사진을 모두 넣는다.
class AppDb {
  Database? _db;

  Future<void> open() async {
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'photo_calendar.db'),
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            type INTEGER NOT NULL,
            title TEXT NOT NULL DEFAULT '',
            body TEXT NOT NULL DEFAULT '',
            time TEXT,
            done INTEGER NOT NULL DEFAULT 0,
            file TEXT,
            thumb TEXT,
            phash INTEGER,
            bg_color INTEGER,
            fg_color INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_entries_date ON entries(date)');
      },
      onUpgrade: (db, from, to) async {
        // v2: 사진 해시(검색용) + 사용자 색상
        if (from < 2) {
          await db.execute('ALTER TABLE entries ADD COLUMN phash INTEGER');
          await db.execute('ALTER TABLE entries ADD COLUMN bg_color INTEGER');
          await db.execute('ALTER TABLE entries ADD COLUMN fg_color INTEGER');
        }
      },
    );
  }

  Database get _d => _db!;

  static const _order = 'date, type, time IS NULL, time, created_at';

  /// [from]..[to] (포함) 범위의 기록을 날짜별로 묶어서 반환. 정렬은 일정(시간순) →
  /// 할 일 → 메모 → 사진, 같은 종류 안에서는 생성순.
  Future<Map<String, List<Entry>>> range(String from, String to) async {
    final rows = await _d.query(
      'entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [from, to],
      orderBy: _order,
    );
    final out = <String, List<Entry>>{};
    for (final r in rows) {
      final e = Entry.fromRow(r);
      (out[e.date] ??= []).add(e);
    }
    return out;
  }

  /// 특정 날짜들의 기록 (검색 결과에 사진·본문을 붙일 때)
  Future<Map<String, List<Entry>>> byDates(Iterable<String> dates) async {
    final list = dates.toSet().toList();
    if (list.isEmpty) return {};
    final rows = await _d.query(
      'entries',
      where: 'date IN (${List.filled(list.length, '?').join(',')})',
      whereArgs: list,
      orderBy: _order,
    );
    final out = <String, List<Entry>>{};
    for (final r in rows) {
      final e = Entry.fromRow(r);
      (out[e.date] ??= []).add(e);
    }
    return out;
  }

  /// 제목·본문에 [q] 가 들어간 텍스트 기록 (최신 날짜 먼저).
  Future<List<Entry>> searchText(String q) async {
    final like = '%${q.replaceAll('%', r'\%').replaceAll('_', r'\_')}%';
    final rows = await _d.query(
      'entries',
      where:
          "type != ? AND (title LIKE ? ESCAPE '\\' OR body LIKE ? ESCAPE '\\')",
      whereArgs: [EntryType.photo.index, like, like],
      orderBy: 'date DESC, type, created_at',
    );
    return rows.map(Entry.fromRow).toList();
  }

  /// 모든 사진 기록 (사진 검색용. 해시 비교는 Dart 에서).
  Future<List<Entry>> allPhotos() async {
    final rows = await _d.query(
      'entries',
      where: 'type = ?',
      whereArgs: [EntryType.photo.index],
      orderBy: 'date DESC, created_at',
    );
    return rows.map(Entry.fromRow).toList();
  }

  Future<void> setHash(int id, int phash) =>
      _d.update('entries', {'phash': phash}, where: 'id = ?', whereArgs: [id]);

  Future<int> insert(Entry e) => _d.insert('entries', e.toRow()..remove('id'));

  Future<void> update(Entry e) =>
      _d.update('entries', e.toRow(), where: 'id = ?', whereArgs: [e.id]);

  Future<void> delete(int id) =>
      _d.delete('entries', where: 'id = ?', whereArgs: [id]);
}
