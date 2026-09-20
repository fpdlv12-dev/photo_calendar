"""에뮬레이터(루트) 에 테스트 데이터 주입 (개발 전용).
실행: python tool/seed_emulator.py [emulator-5554]
- build/sample_photos/*.jpg → 앱 문서 폴더 photos/ + 320px 정방형 thumbs/
- 9월 여러 날짜에 일정·할 일·메모·사진 행을 sqlite3 로 INSERT
앱이 한 번 실행되어 DB 가 만들어진 뒤에 실행할 것. 실행 후 앱을 다시 시작해야 반영된다."""
import os
import subprocess
import sys
import time
from datetime import date

from PIL import Image

SERIAL = sys.argv[1] if len(sys.argv) > 1 else "emulator-5554"
PKG = "com.jun5731.photo_calendar"
ADB = r"C:\Android\Sdk\platform-tools\adb.exe"
ROOT = os.path.join(os.path.dirname(__file__), "..")
SAMPLES = os.path.join(ROOT, "build", "sample_photos")
TMP = os.path.join(ROOT, "build", "seed")
os.makedirs(os.path.join(TMP, "photos"), exist_ok=True)
os.makedirs(os.path.join(TMP, "thumbs"), exist_ok=True)

APP_DIR = f"/data/user/0/{PKG}"
DOCS = f"{APP_DIR}/app_flutter"
DB = f"{APP_DIR}/databases/photo_calendar.db"


def adb(*args, check=True, input_bytes=None):
    r = subprocess.run([ADB, "-s", SERIAL, *args], capture_output=True, input=input_bytes)
    if check and r.returncode != 0:
        raise SystemExit(f"adb {' '.join(args)} failed: {r.stderr.decode(errors='replace')}")
    return r.stdout.decode(errors="replace")


# ---------------------------------------------------------------- 사진 준비
names = sorted(f for f in os.listdir(SAMPLES) if f.endswith(".jpg"))
rel_files = []
for i, n in enumerate(names):
    out_name = f"seed_{i:02d}.jpg"
    im = Image.open(os.path.join(SAMPLES, n)).convert("RGB")
    im.thumbnail((1600, 1600))
    im.save(os.path.join(TMP, "photos", out_name), quality=85)
    side = min(im.size)
    l, t = (im.width - side) // 2, (im.height - side) // 2
    im.crop((l, t, l + side, t + side)).resize((320, 320), Image.LANCZOS).save(
        os.path.join(TMP, "thumbs", out_name), quality=80)
    rel_files.append(out_name)

# ---------------------------------------------------------------- 데이터 (2026년 9월)
Y, M = 2026, 9
SCH, TODO, MEMO, PHOTO = 0, 1, 2, 3


def d(day):
    return date(Y, M, day).isoformat()


rows = []  # (date, type, title, body, time, done, file, thumb)
# 사진: 날짜별 장수 — 1장, 2장, 3장, 4장, 6장(모두 보기 테스트)
photo_plan = {3: 1, 8: 2, 12: 3, 19: 4, 24: 6, 27: 2}
pi = 0
for day, cnt in photo_plan.items():
    for _ in range(cnt):
        f = rel_files[pi % len(rel_files)]
        pi += 1
        rows.append((d(day), PHOTO, "", "", None, 0, f"photos/{f}", f"thumbs/{f}"))

rows += [
    (d(1), SCH, "새 학기 시작", "", "09:00", 0, None, None),
    (d(3), SCH, "치과 예약", "스케일링", "14:30", 0, None, None),
    (d(5), TODO, "장보기", "", None, 1, None, None),
    (d(5), TODO, "택배 반품", "", None, 0, None, None),
    (d(8), SCH, "팀 회의", "3층 회의실", "10:00", 0, None, None),
    (d(8), MEMO, "", "점심에 먹은 파스타 맛집 기억하기", None, 0, None, None),
    (d(12), SCH, "친구 생일", "", None, 0, None, None),
    (d(12), TODO, "선물 포장", "", None, 1, None, None),
    (d(15), SCH, "요가 수업", "", "19:00", 0, None, None),
    (d(15), SCH, "저녁 약속", "강남역", "20:30", 0, None, None),
    (d(15), TODO, "세탁소", "", None, 0, None, None),
    (d(15), MEMO, "", "이번 주는 일찍 자기", None, 0, None, None),
    (d(19), SCH, "가족 나들이", "한강공원 피크닉", "11:00", 0, None, None),
    (d(19), TODO, "도시락 준비", "", None, 1, None, None),
    (d(22), TODO, "보고서 제출", "", None, 0, None, None),
    (d(24), SCH, "제주 여행", "2박 3일", None, 0, None, None),
    (d(24), MEMO, "", "렌터카 예약 확인, 우산 챙기기", None, 0, None, None),
    (d(27), SCH, "영화 보기", "", "18:00", 0, None, None),
    (d(30), MEMO, "", "9월 결산 — 이번 달 사진 정리", None, 0, None, None),
]


def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, int):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"


t0 = int(time.time() * 1000)
sql_lines = ["BEGIN;", "DELETE FROM entries;"]
for i, (dt, ty, title, body, tm, done, f, th) in enumerate(rows):
    sql_lines.append(
        "INSERT INTO entries(date,type,title,body,time,done,file,thumb,created_at) VALUES("
        f"{q(dt)},{ty},{q(title)},{q(body)},{q(tm)},{done},{q(f)},{q(th)},{t0 + i});")
# 사용자 색상 예시 (배경/글자)
sql_lines += [
    "UPDATE entries SET bg_color=%d, fg_color=%d WHERE title='치과 예약';" % (0xFFFFCDD2, 0xFFC62828),
    "UPDATE entries SET bg_color=%d WHERE title='팀 회의';" % 0xFFFFF9C4,
    "UPDATE entries SET bg_color=%d, fg_color=%d WHERE title='제주 여행';" % (0xFF1565C0, 0xFFFFFFFF),
    "UPDATE entries SET fg_color=%d WHERE title='보고서 제출';" % 0xFFC62828,
    "UPDATE entries SET bg_color=%d, fg_color=%d WHERE body LIKE '렌터카%%';" % (0xFFE1BEE7, 0xFF6A1B9A),
]
sql_lines.append("COMMIT;")
sql_path = os.path.join(TMP, "seed.sql")
with open(sql_path, "w", encoding="utf-8", newline="\n") as fp:
    fp.write("\n".join(sql_lines) + "\n")

# ---------------------------------------------------------------- 주입
adb("root", check=False)
time.sleep(2)
adb("wait-for-device")
adb("shell", "am", "force-stop", PKG)
adb("shell", "mkdir", "-p", f"{DOCS}/photos", f"{DOCS}/thumbs")
for sub in ("photos", "thumbs"):
    for f in rel_files:
        adb("push", os.path.join(TMP, sub, f), f"{DOCS}/{sub}/{f}")
adb("push", sql_path, "/data/local/tmp/seed.sql")
out = adb("shell", f"sqlite3 {DB} < /data/local/tmp/seed.sql && sqlite3 {DB} 'SELECT count(*) FROM entries'")
print("entries:", out.strip())
# 앱 uid 로 소유권 복구 (root 로 만든 파일을 앱이 읽을 수 있게)
owner = adb("shell", "stat", "-c", "%U", APP_DIR).strip()
adb("shell", "chown", "-R", f"{owner}:{owner}", APP_DIR)
adb("shell", "restorecon", "-R", APP_DIR, check=False)
print("done. restart the app.")
