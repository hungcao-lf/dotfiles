#!/usr/bin/env python3
# Vẽ một bé gái anime PIXEL gốc (chibi twin-tail) -> GIF 8 frame động.
# Animation: nhún nhẹ + chớp mắt + ngôi sao lấp lánh.
# Xuất: ~/.config/tmux/art/anime-girl.gif  (và _preview_*.png nếu chạy --preview)
# Hoàn toàn là pixel-art tự tạo, không dùng nhân vật có bản quyền.
import os, sys
from PIL import Image

OUT_DIR = os.path.expanduser("~/.config/tmux/art")
W = 20
SCALE = 14
DUR = 130  # ms / frame

# Bảng màu: ký tự -> (r,g,b). '.' = trong suốt (index 0)
PAL = {
    '.': (30, 30, 46),    # transparent (index 0)
    'o': (54, 46, 66),    # viền tóc
    'H': (214, 94, 142),  # tóc đậm
    'h': (255, 150, 190), # tóc
    'f': (255, 208, 228), # tóc sáng
    's': (255, 224, 196), # da
    'S': (236, 188, 158), # da tối
    'w': (255, 255, 255), # lòng trắng mắt
    'e': (70, 122, 202),  # tròng mắt
    'm': (201, 86, 99),   # miệng
    'b': (255, 168, 180), # má hồng
    'c': (250, 250, 255), # cổ áo
    'd': (122, 206, 196), # váy
    'D': (80, 168, 160),  # váy tối
    'l': (242, 242, 250), # tất
    'k': (92, 92, 132),   # giày
    'g': (255, 92, 122),  # nơ
    'i': (255, 255, 240), # lấp lánh
}
LETTERS = list(PAL.keys())
IDX = {ch: i for i, ch in enumerate(LETTERS)}
FLAT = []
for ch in LETTERS:
    FLAT += list(PAL[ch])
FLAT += [0] * (768 - len(FLAT))

# Mắt MỞ
OPEN = [
    "........oooo........",
    "......oohhhhoo......",
    "....oohhffffhhoo....",
    "...ohhhffffffhhho...",
    "..ohhhhhffffhhhhho..",
    ".ohhhhhhhhhhhhhhho..",
    ".ohhhhhgghhhhhhhho..",
    ".HhhfssssssssssfhhH.",
    ".HhhsswwsssswwsshhH.",
    ".Hhsssee ssss eessshH.",
    ".HhsbssssssssssbshH.",
    ".HhssssssmmsssssshhH.",
    "...Hssssssssssss H...",
    "........ssss........",
    "......cddddddc......",
    "....sdddddddddds....",
    "...sdddddddddddds...",
    "..dddddddddddddddd..",
    ".dDDDDDDDDDDDDDDDDd.",
    ".......ss..ss.......",
    ".......ss..ss.......",
    ".......ll..ll.......",
    "......kkk..kkk......",
]

# Mắt NHẮM (chớp): chỉ khác 2 hàng mắt
BLINK = list(OPEN)
BLINK[8] = ".HhhsssssssssssshhH."
BLINK[9] = ".Hhsssoo ssss oossshH."

def norm(rows):
    out = []
    for r in rows:
        r = r.replace(" ", "")           # cho phép gõ thưa cho dễ nhìn
        if len(r) < W:
            pad = W - len(r)
            r = "." * (pad // 2) + r + "." * (pad - pad // 2)
        out.append(r[:W])
    return out

OPEN_N = norm(OPEN)
BLINK_N = norm(BLINK)
GRID_H = len(OPEN_N)
PAD_TOP = 2
CANVAS_H = GRID_H + PAD_TOP + 1

# vị trí ngôi sao lấp lánh theo frame (x,y) hoặc None
SPARK = [(2, 3), None, (17, 5), None, (3, 2), None, (16, 4), None]
# nhún theo frame (dịch xuống px)
BOB = [0, 0, 1, 1, 0, 0, 1, 1]
BLINK_FRAMES = {3, 6}

def draw_spark(px, x, y):
    for dx, dy in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]:
        xx, yy = x + dx, y + dy
        if 0 <= xx < W and 0 <= yy < CANVAS_H:
            px[xx, yy] = IDX['i']

def frame(i):
    rows = BLINK_N if i in BLINK_FRAMES else OPEN_N
    img = Image.new('P', (W, CANVAS_H), 0)
    img.putpalette(FLAT)
    px = img.load()
    dy = PAD_TOP + BOB[i]
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch != '.':
                px[x, y + dy] = IDX.get(ch, 0)
    if SPARK[i]:
        draw_spark(px, SPARK[i][0], SPARK[i][1])
    img = img.resize((W * SCALE, CANVAS_H * SCALE), Image.NEAREST)
    img.info['transparency'] = 0
    return img

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    frames = [frame(i) for i in range(8)]
    gif = os.path.join(OUT_DIR, "anime-girl.gif")
    frames[0].save(gif, save_all=True, append_images=frames[1:],
                   duration=DUR, loop=0, disposal=2, transparency=0, optimize=False)
    print("đã tạo:", gif, "(8 frame)")
    if "--preview" in sys.argv:
        frames[0].convert('RGB').save(os.path.join(OUT_DIR, "_preview_open.png"))
        frames[3].convert('RGB').save(os.path.join(OUT_DIR, "_preview_blink.png"))
        print("preview: _preview_open.png, _preview_blink.png")

if __name__ == "__main__":
    main()
