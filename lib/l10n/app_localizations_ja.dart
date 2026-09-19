// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'フォトカレンダー';

  @override
  String get onboardingHeadline => '写真が見えるカレンダー';

  @override
  String get onboardingBody =>
      '予定・やること・メモ・写真を日付に記録。\n写真は月表示にそのまま表示されます。\nデータはすべて端末内にのみ保存されます。';

  @override
  String get onboardingChoose => '月表示に1日あたり何枚の写真を表示しますか？';

  @override
  String get onboardingHint => '設定からいつでも変更できます。';

  @override
  String get start => 'はじめる';

  @override
  String get photoModeOne => '1枚のみ';

  @override
  String get photoModeOneDesc => '日付マスを1枚の写真で埋めます。';

  @override
  String get photoModeFour => '最大4枚';

  @override
  String get photoModeFourDesc => '写真が小さくなり、1マスに最大4枚入ります。';

  @override
  String get photoModeAll => 'すべての写真';

  @override
  String get photoModeAllDesc => '写真の大きさは変えず、マスが縦に伸びます。カレンダーをスクロールして見ます。';

  @override
  String get today => '今日';

  @override
  String get settingsTooltip => '設定';

  @override
  String get previousMonth => '前の月';

  @override
  String get nextMonth => '次の月';

  @override
  String morePhotos(int count) {
    return '+$count';
  }

  @override
  String moreItems(int count) {
    return '+$count件';
  }

  @override
  String get sectionSchedule => '予定';

  @override
  String get sectionTodo => 'やること';

  @override
  String get sectionMemo => 'メモ';

  @override
  String get sectionPhoto => '写真';

  @override
  String get addSchedule => '予定を追加';

  @override
  String get addTodo => 'やることを追加';

  @override
  String get addMemo => 'メモを追加';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get add => '追加';

  @override
  String get emptyDay => 'まだ記録がありません。\n右下の＋ボタンから追加してください。';

  @override
  String photoCount(int count) {
    return '$count枚';
  }

  @override
  String get editSchedule => '予定';

  @override
  String get editTodo => 'やること';

  @override
  String get editMemo => 'メモ';

  @override
  String get titleHint => 'タイトル';

  @override
  String get memoHint => '内容を入力';

  @override
  String get noteHint => 'メモ（任意）';

  @override
  String get timeLabel => '時間';

  @override
  String get allDay => '終日';

  @override
  String get setTime => '時間を設定';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get deleteConfirmTitle => '削除しますか？';

  @override
  String get deleteConfirmBody => 'この項目を削除します。元に戻せません。';

  @override
  String get deletePhotoConfirmBody => 'この写真をカレンダーから削除します。端末内の元の写真は削除されません。';

  @override
  String get titleRequired => 'タイトルを入力してください';

  @override
  String get photoAddFailed => '写真を追加できませんでした';

  @override
  String photosAdded(int count) {
    return '写真を$count枚追加しました';
  }

  @override
  String get movePhotoTo => '別の日付に移動';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsMonthPhotos => '月表示の写真';

  @override
  String get settingsMonthPhotosSubtitle => '1日あたりに表示する写真の枚数';

  @override
  String get settingsWeekStart => '週の始まり';

  @override
  String get weekStartSunday => '日曜日';

  @override
  String get weekStartMonday => '月曜日';

  @override
  String get settingsShowWeekNumbers => '項目のタイトルを表示';

  @override
  String get settingsShowTextSubtitle => '月表示のマスに予定・やること・メモのタイトルを表示';

  @override
  String get settingsAbout => 'アプリ情報';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get settingsLicenses => 'オープンソースライセンス';

  @override
  String get settingsDataNote => 'すべてのデータはこの端末内にのみ保存され、アプリを削除すると一緒に削除されます。';

  @override
  String get dateFormatFull => 'yyyy年M月d日 EEEE';

  @override
  String get monthFormat => 'yyyy年M月';
}
