# 새 세션용 이어가기 프롬프트

아래 내용을 새 세션 첫 메시지로 붙여넣으면 됩니다. (작업 폴더는 `C:\MakeGame\photo_calendar` 로 열 것)

---

광고 수익용 Flutter 앱 "포토 캘린더"를 Google Play 에 올리는 작업을 이어서 한다. 아래는 이전 세션까지의 상태다. 파일을 다시 읽어 확인하되, 이미 된 것을 다시 하지 마라.

## 이 PC 환경 (2026-09-19 설치, Windows 11 Home, HP Pavilion, RAM 8GB)
- Flutter 3.47.5 stable: `C:\src\flutter` (zip 설치). Android SDK: `C:\Android\Sdk` (cmdline-tools 만, Android Studio 없음. platform-tools, platforms;android-36, build-tools;36.0.0, emulator, system-images;android-36;google_apis;x86_64, ndk r28c, cmake 3.22.1). JDK: `C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot`. Python 3.12 + Pillow, Git 2.55, gh 2.101 (winget).
- 사용자 PATH 와 ANDROID_HOME/JAVA_HOME 은 등록돼 있지만, 도구용 PowerShell 세션엔 반영이 안 될 수 있다 → 명령 앞에 `. tool\dev.ps1` 을 붙이면 PATH/JAVA_HOME/JAVA_TOOL_OPTIONS 가 잡히고 `Build-Install`, `Launch [초]`, `Shot 이름`, `Tap x y`, `Swipe`, `Back` 헬퍼가 생긴다 ($ADB, $SERIAL=emulator-5554, $PKG 변수 포함).
- Gradle "Unable to establish loopback connection" 문제 → `android/gradlew.bat`(git 제외) 와 `android/gradle.properties` 에 `-Djdk.net.unixdomain.tmpdir=C:/tmp` 적용 완료. `C:\tmp` 존재. gradle 힙은 `-Xmx3G`.
- RAM 8GB: Gradle 빌드와 에뮬레이터를 동시에 돌리면 에뮬레이터가 죽는다. 릴리즈 빌드 전엔 `adb -s emulator-5554 emu kill`.
- 에뮬레이터: 전용 AVD `photo_calendar` (Pixel 7, API 36, RAM 2GB, 로케일 ko-KR 로 바꿔둠, root 가능). 실행: `emulator -avd photo_calendar -no-boot-anim -no-audio`. 디버그 콜드 스타트 30초+. 부팅 직후 "시스템 UI 응답 없음" ANR 이 가끔 뜨면 "대기" 탭. 스크린샷은 `adb shell screencap -p /sdcard/shot.png` 후 pull (PowerShell 리디렉션은 바이너리를 깨뜨림). 샘플 사진 12장이 `/sdcard/Pictures/Samples` 에 있고, `python tool/seed_emulator.py` 로 9월 테스트 데이터(사진·일정·할 일·메모) 를 DB 에 직접 주입할 수 있다 (앱 1회 실행 후).
- 실기기: Galaxy S23 (SM-S911N, Android 16) serial `R3CW10E0K5N`, USB 디버깅 켜짐. 디버그 APK 설치돼 있음. 기기 둘 이상이면 항상 `adb -s`.
- gh 는 **fpdlv12-dev** 계정으로 로그인 (참조 저장소 junshiva5732/daily_fortune 과 다른 계정). git identity: fpdlv12-dev / noreply 이메일.
- 파일에 한글/이모지 쓸 때는 셸 heredoc 말고 파일 쓰기 도구. gradle.properties 는 BOM 없이.

## 프로젝트
- `C:\MakeGame\photo_calendar`, 패키지 `com.jun5731.photo_calendar`, GitHub https://github.com/fpdlv12-dev/photo_calendar (main, 2커밋 푸시). 참조 프로젝트 `C:\MakeGame\daily_fortune`.
- 구조·광고 배치·체크리스트는 `README.md` 에 정리돼 있다. 스토어 문구와 Play Console 양식 답변은 `store/listing.md`(ko) + `store/listing_i18n.md`(en/ja/zh).
- 앱: 월 화면 날짜 칸에 사진을 직접 표시. 설정으로 하루당 1장 / 최대 4장(2×2) / 모든 사진(칸이 길어지고 세로 스크롤) 선택. 일정·할 일·메모·사진(시스템 포토 피커, 권한 불필요). ko/en/ja/zh ARB. sqflite + 앱 문서 폴더, 서버 없음. 알림 기능은 1차에서 제외.
- 광고: 하단 배너 상시(`Scaffold.bottomNavigationBar` 슬롯), 전면은 저장/사진 추가 직후 **하루 1회**. 보상형 없음. `google_mobile_ads` 9.1.0 (AGP 9.1 템플릿과 맞추기 위해 6.x 에서 올림). 아직 **테스트 ID** — `lib/ads/ad_ids.dart` 의 `_real` 2개와 `AndroidManifest.xml` 의 `APPLICATION_ID` 를 실제 ID 로 교체해야 한다.
- 완료: 구현 + 에뮬레이터·실기기 검증, 아이콘(`tool/make_icon.py` → flutter_launcher_icons), 릴리즈 키스토어(`android/upload-keystore.jks` + `android/key.properties`, git 제외, 사용자에게 백업 요청함), `flutter build appbundle --release` 성공 (`build/app/outputs/bundle/release/app-release.aab`, 57MB, targetSdk 36), 개인정보처리방침 GitHub Pages https://fpdlv12-dev.github.io/photo_calendar/privacy-policy.html (200 확인), 스토어 이미지(`store/icon-512.png`, `feature-graphic.png`, `screenshots/01~04.png`) + 4개 언어 문구.
- pubspec `version: 1.0.0+1`. Play 에 새 AAB 를 올릴 때마다 +N 을 올린다.

## 남은 일 (순서대로)
1. **AdMob** (계정 jun5731@gmail.com, Chrome 로그인은 사용자가): 앱 추가(Android, 포토 캘린더) → 광고 단위 배너 1개 + 전면 1개. **"파트너 입찰" 체크박스는 절대 켜지 말 것**. 앱 ID(~), 배너 ID(/), 전면 ID(/) 3개를 코드에 반영 → `flutter build appbundle --release` 재빌드.
2. **Play Console** (개발자 ID 6377501318049789563, jun5731@gmail.com; 여러 계정 로그인 시 URL 의 /u/N/ 확인): 앱 만들기(약관 3개·IARC 약관 체크는 사용자가 직접 — 그 화면에서 멈추고 물어볼 것) → 스토어 등록정보(이미지 12장: 폰 4 + 7" 4 + 10" 4 같은 파일 재사용, 문구 4개 언어) → 스토어 설정(카테고리 생산성, 연락처 jun5731@gmail.com) → 앱 콘텐츠 11개 항목(`store/listing.md` 가이드대로: 개인정보처리방침 URL, 광고 예, 앱 액세스 제한 없음, 콘텐츠 등급, 타겟층 18+, 데이터 보안 = 기기 ID + 앱 상호작용 수집·공유, 광고/사기예방 목적, 정부·금융·건강 아니요) → 광고 ID 선언 예 → **비공개 테스트** 트랙(국가 전체, 테스터 이메일 목록에 jun5731@gmail.com, 의견 이메일) → AAB 는 40MB+ 라 사용자가 직접 업로드(파일 경로 알려주기) → 검토 제출은 사용자 확인 후. 신규 개인 계정이라 프로덕션 전 비공개 테스트 12명 × 14일 필수.
   Play Console 폼은 form_input 으로 값을 넣은 뒤 필드를 클릭·키 입력해야 검증이 풀린다. 파일 업로드는 "애셋 추가" 클릭 → 우측 패널의 업로드 input 에 file_upload.
3. 끝나면 README 의 체크리스트 상태를 갱신하고 커밋·푸시.

각 단계 끝날 때마다 짧게 보고하고, 사용자가 직접 해야 하는 것(약관·결제·AAB 업로드·로그인)은 그때그때 알려줘.
