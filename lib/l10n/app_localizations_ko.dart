// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '포토 캘린더';

  @override
  String get onboardingHeadline => '사진이 보이는 캘린더';

  @override
  String get onboardingBody =>
      '일정·할 일·메모·사진을 날짜에 기록하세요.\n사진은 월 화면에서 바로 보입니다.\n모든 데이터는 기기에만 저장됩니다.';

  @override
  String get onboardingChoose => '월 화면에 하루당 사진을 몇 장 보여줄까요?';

  @override
  String get onboardingHint => '설정에서 언제든 바꿀 수 있어요.';

  @override
  String get start => '시작하기';

  @override
  String get photoModeOne => '1장만';

  @override
  String get photoModeOneDesc => '날짜 칸을 사진 한 장으로 채웁니다.';

  @override
  String get photoModeFour => '최대 4장';

  @override
  String get photoModeFourDesc => '사진이 작아져 한 칸에 최대 4장이 들어갑니다.';

  @override
  String get photoModeAll => '모든 사진';

  @override
  String get photoModeAllDesc => '사진 크기는 유지하고 칸이 아래로 길어집니다. 캘린더를 스크롤해서 봅니다.';

  @override
  String get today => '오늘';

  @override
  String get settingsTooltip => '설정';

  @override
  String get previousMonth => '이전 달';

  @override
  String get nextMonth => '다음 달';

  @override
  String morePhotos(int count) {
    return '+$count';
  }

  @override
  String moreItems(int count) {
    return '+$count개';
  }

  @override
  String get sectionSchedule => '일정';

  @override
  String get sectionTodo => '할 일';

  @override
  String get sectionMemo => '메모';

  @override
  String get sectionPhoto => '사진';

  @override
  String get addSchedule => '일정 추가';

  @override
  String get addTodo => '할 일 추가';

  @override
  String get addMemo => '메모 추가';

  @override
  String get addPhoto => '사진 추가';

  @override
  String get add => '추가';

  @override
  String get emptyDay => '아직 기록이 없어요.\n오른쪽 아래 + 버튼으로 추가하세요.';

  @override
  String photoCount(int count) {
    return '$count장';
  }

  @override
  String get editSchedule => '일정';

  @override
  String get editTodo => '할 일';

  @override
  String get editMemo => '메모';

  @override
  String get titleHint => '제목';

  @override
  String get memoHint => '내용을 입력하세요';

  @override
  String get noteHint => '메모 (선택)';

  @override
  String get timeLabel => '시간';

  @override
  String get allDay => '종일';

  @override
  String get setTime => '시간 설정';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get deleteConfirmTitle => '삭제할까요?';

  @override
  String get deleteConfirmBody => '이 항목을 삭제합니다. 되돌릴 수 없어요.';

  @override
  String get deletePhotoConfirmBody => '이 사진을 삭제합니다. 앱 밖의 원본 사진은 삭제되지 않아요.';

  @override
  String get titleRequired => '제목을 입력하세요';

  @override
  String get photoAddFailed => '사진을 추가하지 못했어요';

  @override
  String photosAdded(int count) {
    return '사진 $count장을 추가했어요';
  }

  @override
  String get movePhotoTo => '다른 날짜로 이동';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsMonthPhotos => '월 화면 사진 표시';

  @override
  String get settingsMonthPhotosSubtitle => '하루당 보여줄 사진 개수';

  @override
  String get settingsWeekStart => '주 시작 요일';

  @override
  String get weekStartSunday => '일요일';

  @override
  String get weekStartMonday => '월요일';

  @override
  String get settingsShowWeekNumbers => '일정 텍스트 표시';

  @override
  String get settingsShowTextSubtitle => '월 화면 날짜 칸에 일정·할 일·메모 제목 표시';

  @override
  String get settingsAbout => '앱 정보';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String get settingsPrivacy => '개인정보처리방침';

  @override
  String get settingsLicenses => '오픈소스 라이선스';

  @override
  String get settingsDataNote => '모든 데이터는 이 기기 안에만 저장됩니다. 앱을 삭제하면 함께 삭제됩니다.';

  @override
  String get dateFormatFull => 'yyyy년 M월 d일 EEEE';

  @override
  String get monthFormat => 'yyyy년 M월';
}
