# 개발용 헬퍼 (Windows). 사용: . tool\dev.ps1 ; Build-Install ; Shot name ; Tap x y
$env:Path = "C:\src\flutter\bin;" + [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot"
$env:JAVA_TOOL_OPTIONS = "-Djdk.net.unixdomain.tmpdir=C:/tmp"
$global:ADB = "C:\Android\Sdk\platform-tools\adb.exe"
$global:SERIAL = "emulator-5554"
$global:PKG = "com.jun5731.photo_calendar"

function Build-Install {
    flutter build apk --debug 2>&1 | Select-Object -Last 1
    & $ADB -s $SERIAL install -r build\app\outputs\flutter-apk\app-debug.apk | Select-Object -Last 1
}
function Launch([int]$wait = 30) {
    & $ADB -s $SERIAL shell am force-stop $PKG
    & $ADB -s $SERIAL shell am start -n "$PKG/.MainActivity" | Out-Null
    Start-Sleep $wait
}
function Shot([string]$name) {
    & $ADB -s $SERIAL shell screencap -p /sdcard/shot.png
    & $ADB -s $SERIAL pull /sdcard/shot.png "store\raw\$name.png" | Out-Null
}
function Tap([int]$x, [int]$y, [double]$wait = 2) {
    & $ADB -s $SERIAL shell input tap $x $y
    Start-Sleep $wait
}
function Swipe([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$ms = 300, [double]$wait = 2) {
    & $ADB -s $SERIAL shell input swipe $x1 $y1 $x2 $y2 $ms
    Start-Sleep $wait
}
function Back([double]$wait = 2) {
    & $ADB -s $SERIAL shell input keyevent KEYCODE_BACK
    Start-Sleep $wait
}
