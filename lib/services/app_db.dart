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
      version: 1,
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
            created_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_entries_date ON entries(date)');
      },
    );
  }

  Database get _d => _db!;

  /// [from]..[to] (포함) 범위의 기록을 날짜별로 묶어서 반환. 정렬은 일정(시간순) →
  /// 할 일 → 메모 → 사진, 같은 종류 안에서는 생성순.
  Future<Map<String, List<Entry>>> range(String from, String to) async {
    final rows = await _d.query(
      'entries',
      where: 'date >= ? AND date <= ?',
      whereArgs: [from, to],
      orderBy: 'date, type, time IS NULL, time, created_at',
    );
    final out = <String, List<Entry>>{};
    for (final r in rows) {
      final e = Entry.fromRow(r);
      (out[e.date] ??= []).add(e);
    }
    return out;
  }

  Future<int> insert(Entry e) => _d.insert('entries', e.toRow()..remove('id'));

  Future<void> update(Entry e) =>
      _d.update('entries', e.toRow(), where: 'id = ?', whereArgs: [e.id]);

  Future<void> delete(int id) => _d.delete('entries', where: 'id = ?', whereArgs: [id]);
}
