/// 날짜에 붙는 기록의 종류. DB 에는 index 로 저장되므로 순서를 바꾸면 안 된다.
enum EntryType { schedule, todo, memo, photo }

/// 한 날짜의 기록 한 건. 사진도 Entry 한 건이다 (file/thumb 에 상대 경로).
class Entry {
  final int? id;
  /// 'yyyy-MM-dd'
  final String date;
  final EntryType type;
  final String title;
  final String body;
  /// 'HH:mm' (일정만, 종일이면 null)
  final String? time;
  final bool done;
  /// 앱 문서 폴더 기준 상대 경로 (photos/xxx.jpg)
  final String? file;
  /// 썸네일 상대 경로 (thumbs/xxx.jpg)
  final String? thumb;
  final int createdAt;

  const Entry({
    this.id,
    required this.date,
    required this.type,
    this.title = '',
    this.body = '',
    this.time,
    this.done = false,
    this.file,
    this.thumb,
    required this.createdAt,
  });

  Entry copyWith({
    int? id,
    String? date,
    String? title,
    String? body,
    String? time,
    bool clearTime = false,
    bool? done,
  }) {
    return Entry(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type,
      title: title ?? this.title,
      body: body ?? this.body,
      time: clearTime ? null : (time ?? this.time),
      done: done ?? this.done,
      file: file,
      thumb: thumb,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'date': date,
        'type': type.index,
        'title': title,
        'body': body,
        'time': time,
        'done': done ? 1 : 0,
        'file': file,
        'thumb': thumb,
        'created_at': createdAt,
      };

  static Entry fromRow(Map<String, Object?> r) => Entry(
        id: r['id'] as int?,
        date: r['date'] as String,
        type: EntryType.values[r['type'] as int],
        title: (r['title'] as String?) ?? '',
        body: (r['body'] as String?) ?? '',
        time: r['time'] as String?,
        done: (r['done'] as int? ?? 0) == 1,
        file: r['file'] as String?,
        thumb: r['thumb'] as String?,
        createdAt: r['created_at'] as int,
      );
}
