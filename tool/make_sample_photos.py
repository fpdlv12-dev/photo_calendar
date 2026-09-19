"""에뮬레이터 테스트용 샘플 사진 생성 (개발 전용, 앱에 포함되지 않음).
실행: python tool/make_sample_photos.py  → build/sample_photos/*.jpg
adb push 로 에뮬레이터 /sdcard/Pictures 에 넣고 미디어 스캔하면 포토 피커에 나타난다."""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = os.path.join(os.path.dirname(__file__), "..", "build", "sample_photos")
os.makedirs(OUT, exist_ok=True)
random.seed(7)

PALETTES = [
    [(255, 183, 77), (255, 112, 67), (141, 110, 99)],     # sunset
    [(129, 212, 250), (3, 155, 229), (1, 87, 155)],       # sea
    [(174, 213, 129), (104, 159, 56), (51, 105, 30)],     # forest
    [(244, 143, 177), (233, 30, 99), (136, 14, 79)],      # flowers
    [(255, 241, 118), (255, 193, 7), (255, 111, 0)],      # lemon
    [(179, 157, 219), (126, 87, 194), (69, 39, 160)],     # lavender
    [(255, 204, 188), (255, 138, 101), (216, 67, 21)],    # peach
    [(128, 222, 234), (0, 172, 193), (0, 96, 100)],       # teal
    [(215, 204, 200), (161, 136, 127), (93, 64, 55)],     # coffee
    [(197, 225, 165), (156, 204, 101), (85, 139, 47)],    # grass
    [(255, 224, 178), (255, 167, 38), (230, 81, 0)],      # orange
    [(207, 216, 220), (144, 164, 174), (55, 71, 79)],     # stone
]

SIZES = [(1200, 1600), (1600, 1200), (1400, 1400)]


def gradient(w, h, a, b):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        k = y / (h - 1)
        col = tuple(int(a[i] + (b[i] - a[i]) * k) for i in range(3))
        for x in range(w):
            px[x, y] = col
    return img


for n, pal in enumerate(PALETTES, start=1):
    w, h = SIZES[n % 3]
    img = gradient(w, h, pal[0], pal[1])
    d = ImageDraw.Draw(img, "RGBA")
    # 원/삼각형 몇 개로 사진마다 다른 모양
    for _ in range(6):
        r = random.randint(w // 10, w // 3)
        cx, cy = random.randint(0, w), random.randint(0, h)
        col = pal[2] + (random.randint(70, 150),)
        if random.random() < 0.5:
            d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=col)
        else:
            pts = [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a))) for a in (90, 210, 330)]
            d.polygon(pts, fill=col)
    img = img.filter(ImageFilter.GaussianBlur(2))
    d = ImageDraw.Draw(img)
    try:
        f = ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", w // 6)
    except OSError:
        f = ImageFont.load_default()
    d.text((w * 0.06, h * 0.72), f"{n:02d}", font=f, fill=(255, 255, 255, 230))
    img.save(os.path.join(OUT, f"sample_{n:02d}.jpg"), quality=88)

print("written:", os.path.abspath(OUT))
