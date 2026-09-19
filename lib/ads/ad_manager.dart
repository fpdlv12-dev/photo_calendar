import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_ids.dart';

/// 전면 광고를 미리 로드해 두고 필요할 때 보여주는 싱글톤.
///
/// 배너는 화면마다 붙어야 하므로 [BannerAdWidget] 에서 개별 관리한다.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  static const _kLastShownDate = 'interstitial_last_date';

  InterstitialAd? _interstitial;
  SharedPreferences? _prefs;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    await MobileAds.instance.initialize();
    loadInterstitial();
  }

  // ---------------------------------------------------------------- 전면 광고

  void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial load failed: $err');
          _interstitial = null;
        },
      ),
    );
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  /// 하루에 한 번만 전면 광고를 보여준다 (저장 직후용). 오늘 이미 봤거나
  /// 광고가 아직 로드되지 않았으면 광고 없이 바로 [onDone]. (로드 전이면
  /// "오늘 본 것"으로 치지 않으므로 다음 저장 때 다시 시도한다.)
  void showInterstitialOncePerDayThen(VoidCallback onDone) {
    if (_prefs?.getString(_kLastShownDate) == _today()) {
      onDone();
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      loadInterstitial(); // 다음 기회를 위해 다시 시도
      onDone();
      return;
    }
    _prefs?.setString(_kLastShownDate, _today());
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitial();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        loadInterstitial();
        onDone();
      },
    );
    ad.show();
  }
}
