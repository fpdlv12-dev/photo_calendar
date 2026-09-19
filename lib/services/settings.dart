import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 월 화면에서 하루당 보여줄 사진 개수.
enum PhotoMode {
  /// 1장 — 칸을 사진 한 장으로 채움
  one,
  /// 최대 4장 — 사진이 작아져 한 칸(2×2)에 들어감
  four,
  /// 모든 사진 — 사진 크기는 유지, 칸이 아래로 길어져 캘린더를 스크롤
  all,
}

class AppSettings extends ChangeNotifier {
  static const _kPhotoMode = 'photo_mode';
  static const _kWeekStart = 'week_start';
  static const _kShowText = 'show_text';
  static const _kOnboarded = 'onboarded';

  final SharedPreferences _prefs;
  AppSettings(this._prefs);

  PhotoMode get photoMode => PhotoMode.values[_prefs.getInt(_kPhotoMode) ?? PhotoMode.four.index];
  set photoMode(PhotoMode v) {
    _prefs.setInt(_kPhotoMode, v.index);
    notifyListeners();
  }

  /// DateTime.sunday(7) 또는 DateTime.monday(1)
  int get weekStart => _prefs.getInt(_kWeekStart) ?? DateTime.sunday;
  set weekStart(int v) {
    _prefs.setInt(_kWeekStart, v);
    notifyListeners();
  }

  /// 월 화면 날짜 칸에 일정·할 일·메모 제목을 표시할지
  bool get showText => _prefs.getBool(_kShowText) ?? true;
  set showText(bool v) {
    _prefs.setBool(_kShowText, v);
    notifyListeners();
  }

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> finishOnboarding() async {
    await _prefs.setBool(_kOnboarded, true);
    notifyListeners();
  }
}
