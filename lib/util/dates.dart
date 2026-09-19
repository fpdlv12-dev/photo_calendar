/// 날짜 키 ('yyyy-MM-dd') 변환. DB 와 캐시 키로 쓴다.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// 월 인덱스 (2000년 1월 = 0). PageView 페이지 번호로 쓴다.
int monthIndex(DateTime d) => (d.year - 2000) * 12 + (d.month - 1);

DateTime monthFromIndex(int i) => DateTime(2000 + i ~/ 12, i % 12 + 1, 1);

/// 월 화면 그리드에 들어가는 날짜들 (앞뒤 달 포함, 7의 배수).
/// [weekStart] 는 DateTime.sunday(7) 또는 DateTime.monday(1).
List<DateTime> gridDays(DateTime month, int weekStart) {
  final first = DateTime(month.year, month.month, 1);
  final offset = (first.weekday - weekStart + 7) % 7;
  final start = first.subtract(Duration(days: offset));
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final rows = ((offset + daysInMonth) / 7).ceil();
  return List.generate(rows * 7, (i) => DateTime(start.year, start.month, start.day + i));
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
