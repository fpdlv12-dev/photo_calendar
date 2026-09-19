"""앱 아이콘 생성 스크립트. 실행: python tool/make_icon.py
assets/icon/icon.png (1024x1024, 배경 포함) 과
assets/icon/icon_fg.png (Android adaptive 전경, 투명 배경) 을 만든다.
모티프: 달력 카드 안에 사진(산·해) 이 들어 있는 모양."""
import os

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
os.makedirs(OUT, exist_ok=True)

# 앱 시드 컬러(0xFF1E88E5) 계열
TOP = (66, 165, 245)
BOTTOM = (21, 101, 192)
CARD = (255, 255, 255)
HEADER = (25, 118, 210)
SKY_TOP = (144, 202, 249)
SKY_BOTTOM = (255, 224, 178)
SUN = (255, 193, 7)
HILL_BACK = (102, 187, 106)
HILL_FRONT = (56, 142, 60)


def gradient(w, h, a, b, diag=0.3):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        for x in range(w):
            k = (y / max(h - 1, 1)) * (1 - diag) + (x / max(w - 1, 1)) * diag
            px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * k) for i in range(3))
    return img


def rounded_mask(size, radius):
    m = Image.new("L", size, 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return m


def draw_symbol(layer, scale=1.0):
    """달력 카드 + 사진. layer 는 RGBA 1024."""
    s = SIZE * scale
    cx, cy = SIZE / 2, SIZE / 2 + s * 0.02
    cw, ch = s * 0.62, s * 0.60
    x0, y0 = cx - cw / 2, cy - ch / 2
    r = s * 0.075

    # 그림자
    sh = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle([x0, y0 + s * 0.03, x0 + cw, y0 + ch + s * 0.03], radius=r, fill=(0, 0, 0, 90))
    sh = sh.filter(ImageFilter.GaussianBlur(s * 0.03))
    layer.alpha_composite(sh)

    d = ImageDraw.Draw(layer)
    # 카드
    d.rounded_rectangle([x0, y0, x0 + cw, y0 + ch], radius=r, fill=CARD + (255,))
    # 헤더 바 (위쪽 모서리만 둥글게: 카드 위에 겹쳐 그리고 아래를 직선으로)
    hh = ch * 0.22
    header = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    hd = ImageDraw.Draw(header)
    hd.rounded_rectangle([x0, y0, x0 + cw, y0 + hh + r], radius=r, fill=HEADER + (255,))
    hd.rectangle([x0, y0 + hh, x0 + cw, y0 + hh + r], fill=(0, 0, 0, 0))
    layer.alpha_composite(header)
    # 링 (고리) 2개
    for fx in (0.30, 0.70):
        rx = x0 + cw * fx
        ry = y0
        rw, rh = s * 0.035, s * 0.09
        d.rounded_rectangle([rx - rw / 2, ry - rh * 0.55, rx + rw / 2, ry + rh * 0.45], radius=rw / 2,
                            fill=(255, 255, 255, 255), outline=BOTTOM + (255,), width=int(s * 0.008))

    # 사진 영역 (카드 몸통 안쪽)
    pad = cw * 0.09
    px0, py0 = x0 + pad, y0 + hh + pad * 0.9
    px1, py1 = x0 + cw - pad, y0 + ch - pad
    pw, ph = int(px1 - px0), int(py1 - py0)
    photo = gradient(pw, ph, SKY_TOP, SKY_BOTTOM, diag=0.0).convert("RGBA")
    pd = ImageDraw.Draw(photo)
    # 해
    sr = pw * 0.13
    pd.ellipse([pw * 0.68 - sr, ph * 0.30 - sr, pw * 0.68 + sr, ph * 0.30 + sr], fill=SUN + (255,))
    # 언덕
    pd.polygon([(0, ph), (0, ph * 0.72), (pw * 0.28, ph * 0.42), (pw * 0.55, ph * 0.70), (pw * 0.70, ph * 0.58),
                (pw, ph * 0.80), (pw, ph)], fill=HILL_BACK + (255,))
    pd.polygon([(0, ph), (0, ph * 0.86), (pw * 0.40, ph * 0.58), (pw * 0.75, ph * 0.90), (pw, ph * 0.78), (pw, ph)],
               fill=HILL_FRONT + (255,))
    layer.paste(photo, (int(px0), int(py0)), rounded_mask((pw, ph), int(r * 0.5)))


# 1) 풀 아이콘 (스토어용, 불투명)
bg = gradient(SIZE, SIZE, TOP, BOTTOM).convert("RGBA")
sym = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw_symbol(sym)
bg.alpha_composite(sym)
bg.convert("RGB").save(os.path.join(OUT, "icon.png"))

# 2) Adaptive 전경 (Android, 투명 배경). flutter_launcher_icons 가 인셋을 넣으므로 그대로.
fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
draw_symbol(fg, scale=1.0)
fg.save(os.path.join(OUT, "icon_fg.png"))

print("written:", os.path.abspath(OUT))
