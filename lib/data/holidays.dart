/// 한국 공휴일 (2024~2030). 양력 고정 휴일은 규칙으로, 음력 휴일(설날·추석·
/// 부처님오신날)과 대체공휴일·임시공휴일·선거일은 연도별 표로 둔다.
///
/// 표는 2030년까지만 있으므로 그 뒤 연도는 양력 고정 휴일만 표시된다.
/// 새 연도를 추가할 때는 [_lunarAndSubstitute] 에 항목을 넣으면 된다.
library;

class Holiday {
  final String ko;
  final String en;
  const Holiday(this.ko, this.en);
}

class KoreanHolidays {
  KoreanHolidays._();

  /// 매년 같은 날 (월, 일)
  static const _fixed = <(int, int), Holiday>{
    (1, 1): Holiday('신정', "New Year's Day"),
    (3, 1): Holiday('삼일절', 'Independence Movement Day'),
    (5, 5): Holiday('어린이날', "Children's Day"),
    (6, 6): Holiday('현충일', 'Memorial Day'),
    (8, 15): Holiday('광복절', 'Liberation Day'),
    (10, 3): Holiday('개천절', 'National Foundation Day'),
    (10, 9): Holiday('한글날', 'Hangul Day'),
    (12, 25): Holiday('성탄절', 'Christmas Day'),
  };

  static const _seolEve = Holiday('설날 연휴', 'Seollal Holiday');
  static const _seol = Holiday('설날', 'Seollal');
  static const _buddha = Holiday('부처님오신날', "Buddha's Birthday");
  static const _chuseokEve = Holiday('추석 연휴', 'Chuseok Holiday');
  static const _chuseok = Holiday('추석', 'Chuseok');
  static const _sub = Holiday('대체공휴일', 'Substitute Holiday');
  static const _temp = Holiday('임시공휴일', 'Temporary Holiday');
  static const _election = Holiday('선거일', 'Election Day');

  /// 연도별 음력 휴일·대체공휴일·임시공휴일·선거일. key: 'MM-dd'
  static const _lunarAndSubstitute = <int, Map<String, Holiday>>{
    2024: {
      '02-09': _seolEve,
      '02-10': _seol,
      '02-11': _seolEve,
      '02-12': _sub,
      '04-10': _election,
      '05-06': _sub,
      '05-15': _buddha,
      '09-16': _chuseokEve,
      '09-17': _chuseok,
      '09-18': _chuseokEve,
      '10-01': Holiday('국군의 날', 'Armed Forces Day'),
    },
    2025: {
      '01-27': _temp,
      '01-28': _seolEve,
      '01-29': _seol,
      '01-30': _seolEve,
      '03-03': _sub,
      '05-05': _buddha,
      '05-06': _sub,
      '06-03': _election,
      '10-05': _chuseokEve,
      '10-06': _chuseok,
      '10-07': _chuseokEve,
      '10-08': _sub,
    },
    2026: {
      '02-16': _seolEve,
      '02-17': _seol,
      '02-18': _seolEve,
      '03-02': _sub,
      '05-24': _buddha,
      '05-25': _sub,
      '06-03': _election,
      '08-17': _sub,
      '09-24': _chuseokEve,
      '09-25': _chuseok,
      '09-26': _chuseokEve,
      '10-05': _sub,
    },
    2027: {
      '02-05': _seolEve,
      '02-06': _seol,
      '02-07': _seolEve,
      '02-08': _sub,
      '05-13': _buddha,
      '08-16': _sub,
      '09-14': _chuseokEve,
      '09-15': _chuseok,
      '09-16': _chuseokEve,
      '10-04': _sub,
      '10-11': _sub,
      '12-27': _sub,
    },
    2028: {
      '01-25': _seolEve,
      '01-26': _seol,
      '01-27': _seolEve,
      '05-02': _buddha,
      '10-02': _chuseokEve,
      '10-03': _chuseok,
      '10-04': _chuseokEve,
      '10-05': _sub,
    },
    2029: {
      '02-12': _seolEve,
      '02-13': _seol,
      '02-14': _seolEve,
      '05-07': _sub,
      '05-20': _buddha,
      '05-21': _sub,
      '09-21': _chuseokEve,
      '09-22': _chuseok,
      '09-23': _chuseokEve,
      '09-24': _sub,
    },
    2030: {
      '02-02': _seolEve,
      '02-03': _seol,
      '02-04': _seolEve,
      '02-05': _sub,
      '05-06': _sub,
      '05-09': _buddha,
      '09-11': _chuseokEve,
      '09-12': _chuseok,
      '09-13': _chuseokEve,
    },
  };

  /// 해당 날짜의 공휴일. 없으면 null. (설날·개천절이 겹치는 날은 표의 항목이 우선)
  static Holiday? of(DateTime d) {
    final key =
        '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _lunarAndSubstitute[d.year]?[key] ?? _fixed[(d.month, d.day)];
  }

  static String name(Holiday h, String lang) => lang == 'ko' ? h.ko : h.en;
}
