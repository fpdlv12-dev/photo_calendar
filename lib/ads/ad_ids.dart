import 'package:flutter/foundation.dart';

/// AdMob 광고 단위 ID.
///
/// - 디버그 빌드(`flutter run`, `--debug`): 항상 Google 공식 테스트 ID.
///   개발 중 실제 광고를 클릭하면 무효 트래픽으로 계정이 정지될 수 있으므로.
/// - 릴리즈 빌드(`--release`, 스토어 배포): 실제 ID.
///
/// TODO: AdMob 에 앱 등록 후 `_real` 두 값과
/// android/app/src/main/AndroidManifest.xml 의 APPLICATION_ID 를 교체할 것.
class AdIds {
  AdIds._();

  // ── 실제 ID (Android) ──────────────────────────────────────────────
  static const _real = _Ids(
    banner: 'ca-app-pub-3940256099942544/6300978111', // TODO 교체
    interstitial: 'ca-app-pub-3940256099942544/1033173712', // TODO 교체
  );

  // ── Google 공식 테스트 ID (Android) ────────────────────────────────
  static const _test = _Ids(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
  );

  static _Ids get _current => kReleaseMode ? _real : _test;

  static String get banner => _current.banner;
  static String get interstitial => _current.interstitial;
}

class _Ids {
  final String banner;
  final String interstitial;
  const _Ids({required this.banner, required this.interstitial});
}
