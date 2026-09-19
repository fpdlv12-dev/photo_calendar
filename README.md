# 포토 캘린더 (photo_calendar)

월 화면에서 사진이 바로 보이는 캘린더. 날짜마다 일정·할 일·메모·사진을 기록한다.
Flutter, Android 대상. 한국어 · 영어 · 일본어 · 중국어(간체). AdMob 광고(배너 / 전면)로 수익화.

**차별점**: 다른 캘린더는 날짜를 눌러야 사진이 보이지만, 이 앱은 월 화면 날짜 칸 안에 사진을 직접 그린다.
하루당 보여줄 사진 개수는 설정에서 고른다.

| 옵션 | 동작 |
|---|---|
| 1장만 | 칸을 사진 한 장으로 채움. 더 있으면 모서리에 +N |
| 최대 4장 | 사진이 작아져 한 칸(2×2)에 최대 4장. 더 있으면 마지막 칸에 +N |
| 모든 사진 | 사진 크기(칸 너비의 절반)는 유지, 칸이 아래로 길어짐. 캘린더를 세로 스크롤 |

## 구조

```
lib/
  main.dart                      앱 진입, 테마, 온보딩 분기
  app_scope.dart                 설정·저장소를 트리에 내려주는 InheritedWidget
  ads/ad_ids.dart                AdMob 광고 단위 ID (디버그=테스트 ID, 릴리즈=실제 ID)  ← 출시 전 교체
  ads/ad_manager.dart            전면 광고 로드/노출 싱글톤 (하루 1회 게이트)
  widgets/banner_ad_widget.dart  하단 적응형 배너 (Scaffold.bottomNavigationBar 슬롯에 둠 → FAB 가 위로)
  widgets/month_grid.dart        ★ 월 그리드. 3가지 사진 표시 모드 구현
  widgets/photo_mode_selector.dart 사진 표시 옵션 라디오 카드 (온보딩·설정 공용)
  l10n/app_*.arb                 UI 문자열 (ko/en/ja/zh) → flutter gen-l10n 이 L10n 클래스 생성
  models/entry.dart              기록 1건 (schedule/todo/memo/photo 를 한 테이블에)
  services/app_db.dart           sqflite. entries 테이블 하나
  services/photo_store.dart      사진 복사(1600px) + 320px 정방형 썸네일 (dart:ui 디코더 → isolate JPEG 인코딩)
  services/calendar_store.dart   월 단위 캐시 + ChangeNotifier
  services/settings.dart         SharedPreferences (사진 모드, 주 시작 요일, 텍스트 표시, 온보딩 완료)
  util/dates.dart                날짜 키·월 인덱스·그리드 날짜 계산
  screens/onboarding_screen.dart 첫 실행: 소개 + 사진 모드 선택
  screens/month_screen.dart      홈. PageView 로 월 스와이프
  screens/day_screen.dart        하루 상세 (사진 그리드·일정·할 일·메모) + 추가 시트
  screens/entry_editor.dart      일정·할 일·메모 편집 바텀시트
  screens/photo_viewer_screen.dart 전체 화면 사진 (스와이프·줌·삭제·다른 날짜로 이동)
  screens/settings_screen.dart   설정 + 앱 정보 + 개인정보처리방침 링크
tool/
  make_icon.py                   앱 아이콘 원본 생성 (Pillow) → dart run flutter_launcher_icons
  make_store_assets.py           스토어 이미지 (512 아이콘, 1024×500 피처, 1080×1920 스크린샷)
  make_sample_photos.py          에뮬레이터 테스트용 샘플 사진
  seed_emulator.py               에뮬레이터(루트) DB 에 테스트 데이터 주입
  dev.ps1                        빌드·설치·스크린샷 헬퍼 (Windows)
docs/privacy-policy.html         개인정보처리방침 (GitHub Pages)
store/                           스토어 문구·이미지
```

## 광고 노출 지점

| 위치 | 종류 | 동작 |
|---|---|---|
| 월·상세·설정 하단 | 배너 | 항상 표시 (적응형) |
| 일정·할 일·메모 저장 직후, 사진 추가 직후 | 전면 | **하루 첫 1회만** (`AdManager.showInterstitialOncePerDayThen`, 날짜를 prefs 에 기록) |

보상형 광고는 쓰지 않는다.

## 데이터

- 모든 데이터는 기기 안에만 (sqflite + 앱 문서 폴더). 서버 없음, 로그인 없음.
- 사진은 시스템 포토 피커(`image_picker.pickMultiImage`)로 고르므로 저장소 권한을 요구하지 않는다.
- 삭제해도 갤러리 원본은 건드리지 않는다 (앱 안 복사본만 삭제).

## 개발 빌드

```bash
flutter pub get
flutter build apk --debug
```

에뮬레이터(이 프로젝트 전용 AVD `photo_calendar`, Pixel 7 / API 36):
```
emulator -avd photo_calendar
python tool/make_sample_photos.py   # 샘플 사진 → adb push /sdcard/Pictures/Samples
python tool/seed_emulator.py        # 앱을 한 번 실행한 뒤. 9월 테스트 데이터 주입
```
Windows 에서는 `. tool\dev.ps1` 후 `Build-Install`, `Launch`, `Shot 이름`, `Tap x y` 를 쓴다.

### 이 PC 전용 메모
Java 의 AF_UNIX 소켓이 `%TEMP%` 아래에서 실패해 Gradle 이 "Unable to establish loopback connection" 으로
죽는 문제가 있어, `android/gradle.properties` 와 `android/gradlew.bat`(git 제외) 에
`-Djdk.net.unixdomain.tmpdir=C:/tmp` 를 넣어 두었다. `C:\tmp` 폴더가 있어야 한다.
RAM 8GB 라 `gradle.properties` 의 힙은 `-Xmx3G`. 빌드 중 에뮬레이터를 같이 띄우면 에뮬레이터가 죽을 수 있다.

## 릴리즈

```bash
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab
```
- 서명: `android/upload-keystore.jks` + `android/key.properties` (git 제외 — **반드시 백업**)
- Play 에 새 버전을 올릴 때마다 `pubspec.yaml` 의 `version: x.y.z+N` 에서 N 을 올린다.
- `compileSdk`/`targetSdk` 36 (Play 2026 요구사항), `minSdk` 23.

## 출시 체크리스트 / 상태

### 1. AdMob
- [ ] https://admob.google.com 에서 앱 등록 (Android)
- [ ] 광고 단위: 배너 / 전면 — 만들 때 "파트너 입찰" 체크 **끄기**. 보상형은 사용 안 함
- [ ] `lib/ads/ad_ids.dart` 의 `_real` 테스트 ID → 실제 ID 교체
- [ ] `android/app/src/main/AndroidManifest.xml` 의 `APPLICATION_ID` 교체 (지금은 Google 테스트 앱 ID)
- [ ] 개발 중 실제 ID 로 광고 클릭 금지 (계정 정지 사유)

### 2. 개인정보 / 정책
- [ ] 개인정보처리방침: https://fpdlv12-dev.github.io/photo_calendar/privacy-policy.html (원본 `docs/privacy-policy.html`, GitHub Pages)

### 3. Android 출시
- [x] 릴리즈 서명 키 생성
- [x] 앱 아이콘 (`tool/make_icon.py` → `dart run flutter_launcher_icons`)
- [x] `flutter build appbundle --release` 성공
- [ ] 스토어 자산 (`tool/make_store_assets.py`)
- [ ] Play Console: 앱 만들기 → 스토어 등록정보 → 앱 콘텐츠 → 비공개 테스트 트랙에 AAB 업로드
- [ ] 비공개 테스트 12명 × 14일 → 프로덕션 신청
