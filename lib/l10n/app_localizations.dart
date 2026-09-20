import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'포토 캘린더'**
  String get appTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In ko, this message translates to:
  /// **'사진이 보이는 캘린더'**
  String get onboardingHeadline;

  /// No description provided for @onboardingBody.
  ///
  /// In ko, this message translates to:
  /// **'일정·할 일·메모·사진을 날짜에 기록하세요.\n사진은 월 화면에서 바로 보입니다.\n모든 데이터는 기기에만 저장됩니다.'**
  String get onboardingBody;

  /// No description provided for @onboardingChoose.
  ///
  /// In ko, this message translates to:
  /// **'월 화면에 하루당 사진을 몇 장 보여줄까요?'**
  String get onboardingChoose;

  /// No description provided for @onboardingHint.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 언제든 바꿀 수 있어요.'**
  String get onboardingHint;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get start;

  /// No description provided for @photoModeOne.
  ///
  /// In ko, this message translates to:
  /// **'1장만'**
  String get photoModeOne;

  /// No description provided for @photoModeOneDesc.
  ///
  /// In ko, this message translates to:
  /// **'날짜 칸을 사진 한 장으로 채웁니다.'**
  String get photoModeOneDesc;

  /// No description provided for @photoModeFour.
  ///
  /// In ko, this message translates to:
  /// **'최대 4장'**
  String get photoModeFour;

  /// No description provided for @photoModeFourDesc.
  ///
  /// In ko, this message translates to:
  /// **'사진이 작아져 한 칸에 최대 4장이 들어갑니다.'**
  String get photoModeFourDesc;

  /// No description provided for @photoModeAll.
  ///
  /// In ko, this message translates to:
  /// **'모든 사진'**
  String get photoModeAll;

  /// No description provided for @photoModeAllDesc.
  ///
  /// In ko, this message translates to:
  /// **'사진 크기는 유지하고 칸이 아래로 길어집니다. 캘린더를 스크롤해서 봅니다.'**
  String get photoModeAllDesc;

  /// No description provided for @today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get today;

  /// No description provided for @settingsTooltip.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTooltip;

  /// No description provided for @previousMonth.
  ///
  /// In ko, this message translates to:
  /// **'이전 달'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In ko, this message translates to:
  /// **'다음 달'**
  String get nextMonth;

  /// No description provided for @morePhotos.
  ///
  /// In ko, this message translates to:
  /// **'+{count}'**
  String morePhotos(int count);

  /// No description provided for @moreItems.
  ///
  /// In ko, this message translates to:
  /// **'+{count}개'**
  String moreItems(int count);

  /// No description provided for @sectionSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정'**
  String get sectionSchedule;

  /// No description provided for @sectionTodo.
  ///
  /// In ko, this message translates to:
  /// **'할 일'**
  String get sectionTodo;

  /// No description provided for @sectionMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get sectionMemo;

  /// No description provided for @sectionPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get sectionPhoto;

  /// No description provided for @addSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정 추가'**
  String get addSchedule;

  /// No description provided for @addTodo.
  ///
  /// In ko, this message translates to:
  /// **'할 일 추가'**
  String get addTodo;

  /// No description provided for @addMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모 추가'**
  String get addMemo;

  /// No description provided for @addPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 추가'**
  String get addPhoto;

  /// No description provided for @add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get add;

  /// No description provided for @emptyDay.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없어요.\n오른쪽 아래 + 버튼으로 추가하세요.'**
  String get emptyDay;

  /// No description provided for @photoCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}장'**
  String photoCount(int count);

  /// No description provided for @editSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정'**
  String get editSchedule;

  /// No description provided for @editTodo.
  ///
  /// In ko, this message translates to:
  /// **'할 일'**
  String get editTodo;

  /// No description provided for @editMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get editMemo;

  /// No description provided for @titleHint.
  ///
  /// In ko, this message translates to:
  /// **'제목'**
  String get titleHint;

  /// No description provided for @memoHint.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력하세요'**
  String get memoHint;

  /// No description provided for @noteHint.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get noteHint;

  /// No description provided for @timeLabel.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get timeLabel;

  /// No description provided for @allDay.
  ///
  /// In ko, this message translates to:
  /// **'종일'**
  String get allDay;

  /// No description provided for @setTime.
  ///
  /// In ko, this message translates to:
  /// **'시간 설정'**
  String get setTime;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'삭제할까요?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'이 항목을 삭제합니다. 되돌릴 수 없어요.'**
  String get deleteConfirmBody;

  /// No description provided for @deletePhotoConfirmBody.
  ///
  /// In ko, this message translates to:
  /// **'이 사진을 삭제합니다. 앱 밖의 원본 사진은 삭제되지 않아요.'**
  String get deletePhotoConfirmBody;

  /// No description provided for @titleRequired.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력하세요'**
  String get titleRequired;

  /// No description provided for @photoAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진을 추가하지 못했어요'**
  String get photoAddFailed;

  /// No description provided for @photosAdded.
  ///
  /// In ko, this message translates to:
  /// **'사진 {count}장을 추가했어요'**
  String photosAdded(int count);

  /// No description provided for @movePhotoTo.
  ///
  /// In ko, this message translates to:
  /// **'다른 날짜로 이동'**
  String get movePhotoTo;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsMonthPhotos.
  ///
  /// In ko, this message translates to:
  /// **'월 화면 사진 표시'**
  String get settingsMonthPhotos;

  /// No description provided for @settingsMonthPhotosSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'하루당 보여줄 사진 개수'**
  String get settingsMonthPhotosSubtitle;

  /// No description provided for @settingsWeekStart.
  ///
  /// In ko, this message translates to:
  /// **'주 시작 요일'**
  String get settingsWeekStart;

  /// No description provided for @weekStartSunday.
  ///
  /// In ko, this message translates to:
  /// **'일요일'**
  String get weekStartSunday;

  /// No description provided for @weekStartMonday.
  ///
  /// In ko, this message translates to:
  /// **'월요일'**
  String get weekStartMonday;

  /// No description provided for @settingsShowWeekNumbers.
  ///
  /// In ko, this message translates to:
  /// **'일정 텍스트 표시'**
  String get settingsShowWeekNumbers;

  /// No description provided for @settingsShowTextSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'월 화면 날짜 칸에 일정·할 일·메모 제목 표시'**
  String get settingsShowTextSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get settingsPrivacy;

  /// No description provided for @settingsLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get settingsLicenses;

  /// No description provided for @settingsDataNote.
  ///
  /// In ko, this message translates to:
  /// **'모든 데이터는 이 기기 안에만 저장됩니다. 앱을 삭제하면 함께 삭제됩니다.'**
  String get settingsDataNote;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In ko, this message translates to:
  /// **'키워드를 입력하세요'**
  String get searchHint;

  /// No description provided for @searchByPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진으로 검색'**
  String get searchByPhoto;

  /// No description provided for @searchGo.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get searchGo;

  /// No description provided for @searchNoResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없어요'**
  String get searchNoResults;

  /// No description provided for @searchResults.
  ///
  /// In ko, this message translates to:
  /// **'결과 {count}개'**
  String searchResults(int count);

  /// No description provided for @searchSimilarPhoto.
  ///
  /// In ko, this message translates to:
  /// **'비슷한 사진'**
  String get searchSimilarPhoto;

  /// No description provided for @searchEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'키워드를 입력하거나 사진을 골라 검색하세요.\n사진은 이 앱에 넣어 둔 사진과 비교합니다.'**
  String get searchEmptyHint;

  /// No description provided for @bgColor.
  ///
  /// In ko, this message translates to:
  /// **'배경색'**
  String get bgColor;

  /// No description provided for @textColor.
  ///
  /// In ko, this message translates to:
  /// **'글자색'**
  String get textColor;

  /// No description provided for @colorDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get colorDefault;

  /// No description provided for @colorCustom.
  ///
  /// In ko, this message translates to:
  /// **'직접 선택'**
  String get colorCustom;

  /// No description provided for @colorPickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'색상 선택'**
  String get colorPickerTitle;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @jumpToDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜로 이동'**
  String get jumpToDate;

  /// No description provided for @settingsHolidays.
  ///
  /// In ko, this message translates to:
  /// **'한국 공휴일 표시'**
  String get settingsHolidays;

  /// No description provided for @settingsHolidaysSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'공휴일을 빨간색으로, 이름과 함께 표시'**
  String get settingsHolidaysSubtitle;

  /// No description provided for @dateFormatFull.
  ///
  /// In ko, this message translates to:
  /// **'yyyy년 M월 d일 EEEE'**
  String get dateFormatFull;

  /// No description provided for @monthFormat.
  ///
  /// In ko, this message translates to:
  /// **'yyyy년 M월'**
  String get monthFormat;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
