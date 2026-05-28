from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math


ROOT = Path(__file__).resolve().parent
SCREENSHOT_DIR = ROOT / "Screenshots" / "iPhone_6_5_Display"
SUBSCRIPTION_DIR = ROOT / "SubscriptionReviewScreenshots"
W, H = 1242, 2688


def font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for candidate in candidates:
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            pass
    return ImageFont.load_default()


F = {
    "hero": font(76, True),
    "h1": font(58, True),
    "h2": font(42, True),
    "h3": font(32, True),
    "body": font(29),
    "small": font(23),
    "tiny": font(18),
    "num": font(50, True),
}


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def background():
    img = Image.new("RGB", (W, H), "#06110d")
    px = img.load()
    for y in range(H):
        for x in range(W):
            g = int(11 + 28 * (1 - y / H))
            b = int(13 + 19 * (x / W))
            px[x, y] = (3, g, b)

    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for i in range(34):
        y = 180 + i * 72
        d.line((0, y, W, y + 120), fill=(43, 255, 167, 13), width=2)
    for i in range(10):
        x = -200 + i * 180
        d.line((x, 0, x + 560, H), fill=(43, 255, 167, 9), width=2)

    for cx in (120, W - 120):
        for r in range(360, 0, -18):
            a = max(0, int(14 * (r / 360)))
            d.ellipse((cx - r, 80 - r, cx + r, 80 + r), fill=(160, 255, 212, a))

    vignette = Image.new("L", (W, H), 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-460, -180, W + 460, H + 220), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(120))
    dark = Image.new("RGBA", (W, H), (0, 0, 0, 155))
    img = Image.composite(img.convert("RGBA"), dark, vignette).convert("RGBA")
    return Image.alpha_composite(img, overlay)


def header(draw, title, kicker="TactiCore AI"):
    draw.text((74, 90), kicker.upper(), fill=(92, 255, 181), font=F["small"])
    draw.text((74, 128), title, fill=(245, 250, 247), font=F["hero"])
    draw.text((74, 222), "Train like a professional club.", fill=(190, 210, 201), font=F["body"])


def card(draw, box, title=None, alpha=212):
    rounded(draw, box, 28, (12, 24, 20, alpha), outline=(79, 255, 178, 55), width=2)
    if title:
        draw.text((box[0] + 28, box[1] + 24), title, fill=(238, 246, 241), font=F["h3"])


def pill(draw, xy, text, fill=(35, 255, 160, 42), outline=(63, 255, 176, 100)):
    x, y = xy
    tw = int(draw.textlength(text, font=F["small"]))
    rounded(draw, (x, y, x + tw + 44, y + 46), 23, fill, outline=outline, width=1)
    draw.text((x + 22, y + 9), text, fill=(220, 252, 235), font=F["small"])
    return x + tw + 58


def silhouette(draw, x, y, scale=1.0, accent=(70, 255, 170, 150)):
    s = scale
    draw.ellipse((x - 36 * s, y - 145 * s, x + 36 * s, y - 73 * s), fill=(24, 34, 31, 230))
    draw.rounded_rectangle((x - 54 * s, y - 76 * s, x + 54 * s, y + 90 * s), radius=int(36 * s), fill=(18, 28, 25, 235))
    draw.line((x - 50 * s, y - 12 * s, x - 115 * s, y + 56 * s), fill=(18, 28, 25, 235), width=int(26 * s))
    draw.line((x + 50 * s, y - 12 * s, x + 112 * s, y + 42 * s), fill=(18, 28, 25, 235), width=int(26 * s))
    draw.line((x - 25 * s, y + 88 * s, x - 80 * s, y + 235 * s), fill=(18, 28, 25, 235), width=int(30 * s))
    draw.line((x + 25 * s, y + 88 * s, x + 82 * s, y + 238 * s), fill=(18, 28, 25, 235), width=int(30 * s))
    draw.arc((x - 95 * s, y - 170 * s, x + 95 * s, y + 32 * s), 202, 338, fill=accent, width=max(2, int(5 * s)))


def pitch(draw, box, title=None):
    x0, y0, x1, y1 = box
    rounded(draw, box, 30, (8, 42, 29, 232), outline=(85, 255, 178, 90), width=2)
    field_top = y0 + 88 if title else y0 + 40
    for i in range(1, 6):
        y = field_top + i * (y1 - field_top - 40) / 6
        draw.line((x0 + 20, y, x1 - 20, y), fill=(135, 255, 196, 38), width=2)
    draw.rectangle((x0 + 40, field_top, x1 - 40, y1 - 40), outline=(194, 255, 222, 80), width=3)
    mid_y = (field_top + y1 - 40) / 2
    draw.line((x0 + 40, mid_y, x1 - 40, mid_y), fill=(194, 255, 222, 65), width=3)
    draw.ellipse(((x0 + x1) / 2 - 95, mid_y - 95, (x0 + x1) / 2 + 95, mid_y + 95), outline=(194, 255, 222, 65), width=3)
    if title:
        draw.text((x0 + 36, y0 + 28), title, fill=(238, 246, 241), font=F["h3"])


def player(draw, x, y, label, color=(60, 255, 169)):
    draw.ellipse((x - 24, y - 24, x + 24, y + 24), fill=(8, 18, 15), outline=color, width=4)
    draw.text((x - 8, y - 15), label, fill=(235, 255, 243), font=F["tiny"])


def arrow(draw, p1, p2, color=(64, 255, 175, 210), width=7):
    draw.line((p1, p2), fill=color, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    for delta in (2.55, -2.55):
        q = (p2[0] + 28 * math.cos(ang + delta), p2[1] + 28 * math.sin(ang + delta))
        draw.line((p2, q), fill=color, width=width)


def footer(draw, text="The modern operating system for elite football coaching."):
    draw.text((74, H - 132), text, fill=(170, 190, 181), font=F["small"])
    draw.rectangle((74, H - 72, W - 74, H - 68), fill=(68, 255, 176, 150))


def screenshot_dashboard():
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "Elite coaching OS")
    silhouette(d, 1030, 352, 1.25)
    card(d, (74, 342, 1168, 760), "This Week")
    d.text((108, 430), "High press identity", fill=(78, 255, 178), font=F["h1"])
    d.text((108, 510), "4 sessions planned", fill=(225, 238, 231), font=F["body"])
    for i, t in enumerate(["Pressing traps", "Build-up angles", "Transition recovery"]):
        pill(d, (108 + (i % 2) * 430, 595 + (i // 2) * 68), t)

    card(d, (74, 820, 548, 1174), "Completion")
    d.text((124, 915), "86%", fill=(245, 250, 247), font=F["num"])
    d.arc((300, 900, 466, 1066), -90, 235, fill=(64, 255, 174), width=18)
    d.text((124, 1030), "Session completion", fill=(171, 196, 185), font=F["small"])

    card(d, (598, 820, 1168, 1174), "AI Insight")
    d.text((632, 902), "Your wide press is strong.", fill=(245, 250, 247), font=F["body"])
    d.text((632, 954), "Add more recovery runs after turnovers.", fill=(171, 196, 185), font=F["small"])

    pitch(d, (74, 1238, 1168, 2130), "Tactical Focus")
    for x, y, n in [(315, 1560, "6"), (465, 1455, "8"), (620, 1565, "10"), (815, 1390, "9"), (890, 1720, "7")]:
        player(d, x, y, n)
    arrow(d, (465, 1455), (620, 1565))
    arrow(d, (620, 1565), (815, 1390))
    arrow(d, (890, 1720), (690, 1840), (255, 214, 89, 220))

    card(d, (74, 2190, 1168, 2472), "Quick Actions")
    x = 108
    for label in ["Generate Session", "Voice Notes", "Tactical Board"]:
        x = pill(d, (x, 2285), label)
    footer(d)
    return img


def screenshot_generator():
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "AI session builder")
    card(d, (74, 342, 1168, 742), "Coach Inputs")
    labels = ["U16", "75 min", "18 players", "4-3-3", "High intensity", "Pressing"]
    x, y = 112, 435
    for label in labels:
        x = pill(d, (x, y), label)
        if x > 890:
            x, y = 112, y + 72

    card(d, (74, 806, 1168, 1268), "AI Generated Plan")
    stages = [("Warm-up", "Pressing reactions"), ("Technical", "First pass under pressure"), ("Tactical", "Wide trap and counter-press"), ("Game", "8v8 + 3 transition zone")]
    y = 900
    for title, desc in stages:
        d.ellipse((112, y + 6, 140, y + 34), fill=(64, 255, 174))
        d.text((164, y), title, fill=(245, 250, 247), font=F["h3"])
        d.text((164, y + 44), desc, fill=(174, 198, 188), font=F["small"])
        y += 92

    pitch(d, (74, 1330, 1168, 2260), "Animated Drill Preview")
    for x, y, n in [(260, 1760, "4"), (430, 1645, "6"), (640, 1515, "8"), (850, 1640, "11"), (958, 1885, "9")]:
        player(d, x, y, n)
    arrow(d, (260, 1760), (430, 1645))
    arrow(d, (430, 1645), (640, 1515))
    arrow(d, (640, 1515), (850, 1640))
    arrow(d, (850, 1640), (958, 1885), (255, 214, 89, 220))
    card(d, (74, 2320, 1168, 2490), "Coaching Points")
    d.text((112, 2396), "Lock the sideline. Press on backwards pass. Recover central spaces.", fill=(222, 239, 230), font=F["small"])
    footer(d)
    return img


def screenshot_voice():
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "Voice coach notes")
    card(d, (74, 350, 1168, 950), "Live Transcription")
    d.text((116, 440), "We struggled to protect zone 14 after losing the ball.", fill=(245, 250, 247), font=F["h2"])
    d.text((116, 545), "Next session: transition recovery, midfield distances and pressing cues.", fill=(178, 202, 191), font=F["body"])
    cx, cy = 621, 788
    for i in range(44):
        x = 130 + i * 23
        amp = 40 + 85 * abs(math.sin(i * 0.57))
        d.rounded_rectangle((x, cy - amp, x + 11, cy + amp), radius=5, fill=(59, 255, 171, 130 + (i % 3) * 35))

    card(d, (74, 1020, 1168, 1465), "AI Coaching Summary")
    points = ["Shape stretched after turnovers", "Central midfielder needs recovery cue", "Build next block around compact pressing"]
    y = 1118
    for p in points:
        d.ellipse((116, y + 8, 138, y + 30), fill=(64, 255, 174))
        d.text((164, y), p, fill=(230, 244, 237), font=F["body"])
        y += 92

    pitch(d, (74, 1532, 1168, 2345), "Voice to Tactical Plan")
    for x, y, n in [(320, 1900, "8"), (515, 1790, "6"), (682, 1900, "10"), (840, 1740, "9")]:
        player(d, x, y, n)
    arrow(d, (840, 1740), (680, 1650), (255, 214, 89, 220))
    arrow(d, (515, 1790), (682, 1900))
    footer(d)
    return img


def screenshot_tactical_board():
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "Tactical board")
    pitch(d, (74, 350, 1168, 2098), "4-3-3 Pressing Pattern")
    players = [(610, 570, "1"), (290, 850, "3"), (510, 920, "5"), (710, 920, "4"), (930, 850, "2"),
               (420, 1270, "6"), (610, 1180, "8"), (800, 1270, "10"), (330, 1640, "11"), (610, 1560, "9"), (890, 1640, "7")]
    for p in players:
        player(d, *p)
    arrow(d, (890, 1640), (760, 1440))
    arrow(d, (610, 1560), (610, 1390))
    arrow(d, (330, 1640), (470, 1450))
    arrow(d, (610, 1180), (800, 1270), (255, 214, 89, 220))

    card(d, (74, 2170, 1168, 2475), "Pressing Triggers")
    x = 116
    for label in ["Back pass", "Bad first touch", "Wide receive", "Negative body shape"]:
        x = pill(d, (x, 2265), label)
        if x > 890:
            x = 116
    footer(d)
    return img


def screenshot_development():
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "Player development")
    card(d, (74, 348, 1168, 795), "Development Alerts")
    silhouette(d, 245, 630, 0.8)
    d.text((380, 465), "Midfielder: Tactical awareness +12%", fill=(246, 252, 248), font=F["h2"])
    d.text((380, 548), "Next focus: scan before receiving and protect central lanes.", fill=(176, 202, 190), font=F["body"])
    pill(d, (380, 655), "Confidence rising")
    pill(d, (650, 655), "Stamina watch")

    card(d, (74, 868, 1168, 1560), "Progression Metrics")
    metrics = [("Passing", 0.82), ("Positioning", 0.74), ("Pace", 0.68), ("Strength", 0.61), ("Tactical IQ", 0.79), ("Discipline", 0.88)]
    y = 965
    for label, value in metrics:
        d.text((116, y), label, fill=(232, 242, 237), font=F["body"])
        rounded(d, (395, y + 7, 1070, y + 36), 14, (30, 45, 39, 220))
        rounded(d, (395, y + 7, int(395 + 675 * value), y + 36), 14, (65, 255, 174, 210))
        y += 88

    card(d, (74, 1624, 1168, 2380), "Analytics")
    bars = [280, 520, 430, 690, 610]
    names = ["Press", "Poss", "Trans", "Def", "Finish"]
    for i, h in enumerate(bars):
        x = 150 + i * 190
        rounded(d, (x, 2200 - h, x + 92, 2200), 20, (64, 255, 174, 210))
        d.text((x - 5, 2235), names[i], fill=(180, 204, 193), font=F["small"])
    footer(d)
    return img


def screenshot_paywall(selected="pro-monthly"):
    img = background()
    d = ImageDraw.Draw(img)
    header(d, "Pro coaching power")
    d.text((74, 310), "Unlock voice planning, tactical boards, animated drills and premium exports.", fill=(190, 211, 202), font=F["body"])
    plans = [
        ("Pro Coach Monthly", "$14.99", "month", "Unlimited AI sessions and tactical tools", "pro-monthly"),
        ("Pro Coach Yearly", "$119.99", "year", "Best value for season-long planning", "pro-yearly"),
        ("Elite Club Monthly", "$49.99", "month", "Club-level workflows and advanced tracking", "elite-monthly"),
    ]
    y = 520
    for name, price, period, desc, key in plans:
        active = key == selected
        fill = (22, 47, 37, 236) if active else (11, 24, 20, 218)
        outline = (82, 255, 178, 210) if active else (82, 255, 178, 70)
        rounded(d, (74, y, 1168, y + 375), 32, fill, outline=outline, width=3)
        d.text((118, y + 48), name, fill=(248, 253, 250), font=F["h2"])
        d.text((118, y + 125), desc, fill=(176, 202, 190), font=F["body"])
        d.text((118, y + 225), price, fill=(78, 255, 178), font=F["num"])
        d.text((360, y + 245), "/" + period, fill=(176, 202, 190), font=F["body"])
        if active:
            rounded(d, (870, y + 62, 1105, y + 122), 30, (67, 255, 174, 230))
            d.text((918, y + 78), "Selected", fill=(5, 17, 12), font=F["small"])
        y += 420

    pitch(d, (74, 1845, 1168, 2350), "Included")
    for x, y, n in [(275, 2085, "AI"), (505, 2025, "VB"), (735, 2085, "TB"), (960, 2020, "PDF")]:
        player(d, x, y, n, (255, 214, 89) if n == "PDF" else (64, 255, 174))
    arrow(d, (275, 2085), (505, 2025))
    arrow(d, (505, 2025), (735, 2085))
    arrow(d, (735, 2085), (960, 2020), (255, 214, 89, 220))

    rounded(d, (170, 2415, 1072, 2505), 45, (62, 255, 174, 235))
    d.text((398, 2439), "Continue", fill=(3, 20, 12), font=F["h2"])
    footer(d, "Coaching and educational tool only. Review AI recommendations.")
    return img


def save_all():
    SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)
    SUBSCRIPTION_DIR.mkdir(parents=True, exist_ok=True)
    screenshots = [
        ("01_dashboard.png", screenshot_dashboard()),
        ("02_ai_session_builder.png", screenshot_generator()),
        ("03_voice_coach_notes.png", screenshot_voice()),
        ("04_tactical_board.png", screenshot_tactical_board()),
        ("05_player_development.png", screenshot_development()),
        ("06_paywall.png", screenshot_paywall("pro-monthly")),
    ]
    for name, image in screenshots:
        image.convert("RGB").save(SCREENSHOT_DIR / name, optimize=True)

    subscription_images = [
        ("pro_coach_monthly_review.png", screenshot_paywall("pro-monthly")),
        ("pro_coach_yearly_review.png", screenshot_paywall("pro-yearly")),
        ("elite_club_monthly_review.png", screenshot_paywall("elite-monthly")),
    ]
    for name, image in subscription_images:
        image.convert("RGB").save(SUBSCRIPTION_DIR / name, optimize=True)


if __name__ == "__main__":
    save_all()
    print(f"Created assets in {SCREENSHOT_DIR}")
    print(f"Created assets in {SUBSCRIPTION_DIR}")
