// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Photo Calendar';

  @override
  String get onboardingHeadline => 'A calendar that shows your photos';

  @override
  String get onboardingBody =>
      'Keep events, to-dos, notes and photos on any date.\nPhotos appear right on the month view.\nEverything stays on your device.';

  @override
  String get onboardingChoose => 'How many photos per day on the month view?';

  @override
  String get onboardingHint => 'You can change this anytime in Settings.';

  @override
  String get start => 'Get started';

  @override
  String get photoModeOne => 'One photo';

  @override
  String get photoModeOneDesc => 'Fills the day cell with a single photo.';

  @override
  String get photoModeFour => 'Up to 4';

  @override
  String get photoModeFourDesc =>
      'Photos shrink so up to four fit in one cell.';

  @override
  String get photoModeAll => 'All photos';

  @override
  String get photoModeAllDesc =>
      'Photos keep their size and the cell grows taller. Scroll the calendar to see more.';

  @override
  String get today => 'Today';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String morePhotos(int count) {
    return '+$count';
  }

  @override
  String moreItems(int count) {
    return '+$count more';
  }

  @override
  String get sectionSchedule => 'Events';

  @override
  String get sectionTodo => 'To-do';

  @override
  String get sectionMemo => 'Notes';

  @override
  String get sectionPhoto => 'Photos';

  @override
  String get addSchedule => 'Add event';

  @override
  String get addTodo => 'Add to-do';

  @override
  String get addMemo => 'Add note';

  @override
  String get addPhoto => 'Add photos';

  @override
  String get add => 'Add';

  @override
  String get emptyDay => 'Nothing here yet.\nTap + below to add something.';

  @override
  String photoCount(int count) {
    return '$count photos';
  }

  @override
  String get editSchedule => 'Event';

  @override
  String get editTodo => 'To-do';

  @override
  String get editMemo => 'Note';

  @override
  String get titleHint => 'Title';

  @override
  String get memoHint => 'Write something';

  @override
  String get noteHint => 'Notes (optional)';

  @override
  String get timeLabel => 'Time';

  @override
  String get allDay => 'All day';

  @override
  String get setTime => 'Set time';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete?';

  @override
  String get deleteConfirmBody =>
      'This item will be deleted. This can\'t be undone.';

  @override
  String get deletePhotoConfirmBody =>
      'This photo will be removed from the calendar. The original in your gallery is not deleted.';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get photoAddFailed => 'Couldn\'t add photos';

  @override
  String photosAdded(int count) {
    return 'Added $count photos';
  }

  @override
  String get movePhotoTo => 'Move to another date';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsMonthPhotos => 'Photos on month view';

  @override
  String get settingsMonthPhotosSubtitle => 'How many photos to show per day';

  @override
  String get settingsWeekStart => 'Week starts on';

  @override
  String get weekStartSunday => 'Sunday';

  @override
  String get weekStartMonday => 'Monday';

  @override
  String get settingsShowWeekNumbers => 'Show item titles';

  @override
  String get settingsShowTextSubtitle =>
      'Show event, to-do and note titles in day cells';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsLicenses => 'Open source licenses';

  @override
  String get settingsDataNote =>
      'All data is stored only on this device and is removed when you uninstall the app.';

  @override
  String get dateFormatFull => 'EEEE, MMMM d, yyyy';

  @override
  String get monthFormat => 'MMMM yyyy';
}
