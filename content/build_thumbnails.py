#!/usr/bin/env python3
"""강좌 썸네일(1280x720 PNG) 생성. Pillow 필요. 한글 글꼴 경로는 FONT 환경변수로 바꿀 수 있다."""
import os
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent / "thumbnails"
FONT = os.environ.get("FONT", "/System/Library/Fonts/AppleSDGothicNeo.ttc")
W, H = 1280, 720

COURSES = [
    ("course-2000-python.png", "정보처리기사 실기", "파이썬 프로그래밍", "출력 예측 · 기초 코딩 · 알고리즘", (26, 35, 126), (57, 73, 171), "PY"),
    ("course-2001-sql.png", "정보처리기사 실기", "SQL과 핵심 이론", "SELECT · GROUP BY · JOIN · 단골 용어", (0, 77, 64), (0, 137, 123), "SQL"),
    ("course-2002-pandas.png", "처음 시작하는", "pandas 데이터 분석", "CSV 불러오기 · 필터링 · 그룹 집계", (74, 20, 140), (142, 36, 170), "DF"),
]


def font(size, bold=True):
    try:
        return ImageFont.truetype(FONT, size, index=6 if bold else 2)
    except Exception:
        return ImageFont.truetype(FONT, size)


def render(name, top, title, sub, c1, c2, badge):
    img = Image.new("RGB", (W, H), c1)
    px = img.load()
    for y in range(H):
        for x in range(W):
            t = (x / W * 0.65 + y / H * 0.35)
            px[x, y] = tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    d = ImageDraw.Draw(img, "RGBA")
    d.ellipse((W - 520, -180, W + 140, 480), fill=(255, 255, 255, 22))
    d.ellipse((W - 330, 300, W + 90, 720), fill=(255, 255, 255, 16))
    d.rounded_rectangle((90, 96, 90 + 150, 96 + 76), radius=18, fill=(255, 255, 255, 235))
    bf = font(44)
    bw = d.textlength(badge, font=bf)
    d.text((90 + (150 - bw) / 2, 108), badge, font=bf, fill=c1)
    d.text((90, 250), top, font=font(54, bold=False), fill=(255, 255, 255, 220))
    d.text((90, 330), title, font=font(104), fill=(255, 255, 255, 255))
    d.rectangle((92, 480, 92 + 120, 486), fill=(255, 255, 255, 200))
    d.text((90, 520), sub, font=font(40, bold=False), fill=(255, 255, 255, 215))
    d.text((90, 630), "CODE BOMBA", font=font(30), fill=(255, 255, 255, 150))
    OUT.mkdir(exist_ok=True)
    img.save(OUT / name, optimize=True)


if __name__ == "__main__":
    for row in COURSES:
        render(*row)
        print("wrote", row[0])
