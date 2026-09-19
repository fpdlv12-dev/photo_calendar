// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '照片日历';

  @override
  String get onboardingHeadline => '能看到照片的日历';

  @override
  String get onboardingBody =>
      '在任意日期记录日程、待办、备忘和照片。\n照片直接显示在月视图上。\n所有数据仅保存在您的设备中。';

  @override
  String get onboardingChoose => '月视图中每天显示几张照片？';

  @override
  String get onboardingHint => '随时可以在设置中更改。';

  @override
  String get start => '开始使用';

  @override
  String get photoModeOne => '仅1张';

  @override
  String get photoModeOneDesc => '用一张照片填满日期格。';

  @override
  String get photoModeFour => '最多4张';

  @override
  String get photoModeFourDesc => '照片缩小，一格最多放4张。';

  @override
  String get photoModeAll => '全部照片';

  @override
  String get photoModeAllDesc => '照片大小不变，日期格向下拉长。上下滚动日历查看。';

  @override
  String get today => '今天';

  @override
  String get settingsTooltip => '设置';

  @override
  String get previousMonth => '上个月';

  @override
  String get nextMonth => '下个月';

  @override
  String morePhotos(int count) {
    return '+$count';
  }

  @override
  String moreItems(int count) {
    return '+$count项';
  }

  @override
  String get sectionSchedule => '日程';

  @override
  String get sectionTodo => '待办';

  @override
  String get sectionMemo => '备忘';

  @override
  String get sectionPhoto => '照片';

  @override
  String get addSchedule => '添加日程';

  @override
  String get addTodo => '添加待办';

  @override
  String get addMemo => '添加备忘';

  @override
  String get addPhoto => '添加照片';

  @override
  String get add => '添加';

  @override
  String get emptyDay => '还没有记录。\n点击右下角的 + 按钮添加。';

  @override
  String photoCount(int count) {
    return '$count张';
  }

  @override
  String get editSchedule => '日程';

  @override
  String get editTodo => '待办';

  @override
  String get editMemo => '备忘';

  @override
  String get titleHint => '标题';

  @override
  String get memoHint => '输入内容';

  @override
  String get noteHint => '备注（可选）';

  @override
  String get timeLabel => '时间';

  @override
  String get allDay => '全天';

  @override
  String get setTime => '设置时间';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleteConfirmTitle => '要删除吗？';

  @override
  String get deleteConfirmBody => '将删除此项目，无法撤销。';

  @override
  String get deletePhotoConfirmBody => '将从日历中删除此照片。相册中的原图不会被删除。';

  @override
  String get titleRequired => '请输入标题';

  @override
  String get photoAddFailed => '无法添加照片';

  @override
  String photosAdded(int count) {
    return '已添加$count张照片';
  }

  @override
  String get movePhotoTo => '移动到其他日期';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsMonthPhotos => '月视图照片显示';

  @override
  String get settingsMonthPhotosSubtitle => '每天显示的照片数量';

  @override
  String get settingsWeekStart => '每周开始于';

  @override
  String get weekStartSunday => '星期日';

  @override
  String get weekStartMonday => '星期一';

  @override
  String get settingsShowWeekNumbers => '显示项目标题';

  @override
  String get settingsShowTextSubtitle => '在月视图的日期格中显示日程、待办、备忘标题';

  @override
  String get settingsAbout => '关于';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get settingsLicenses => '开源许可';

  @override
  String get settingsDataNote => '所有数据仅保存在本设备中，卸载应用时会一并删除。';

  @override
  String get dateFormatFull => 'yyyy年M月d日 EEEE';

  @override
  String get monthFormat => 'yyyy年M月';
}
