from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import math


ROOT = Path(__file__).resolve().parent
SCREENSHOT_DIR = ROOT / "Screenshots" / "iPhone_6_5_Display"
IPAD_DIR = ROOT / "Screenshots" / "iPad_13_Display"
VISION_DIR = ROOT / "Screenshots" / "Apple_Vision_Pro"
SUBSCRIPTION_DIR = ROOT / "SubscriptionReviewScreenshots"
SUBSCRIPTION_IMAGE_DIR = ROOT / "SubscriptionImages"
W, H = 1242, 2688
IW, IH = 2048, 2732
VW, VH = 3840, 2160
SW, SH = 1024, 1024


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

VF = {
    "hero": font(122, True),
    "h1": font(76, True),
    "h2": font(54, True),
    "h3": font(40, True),
    "body": font(35),
    "small": font(28),
    "tiny": font(22),
    "num": font(72, True),
}

IF = {
    "hero": font(86, True),
    "h1": font(58, True),
    "h2": font(42, True),
    "h3": font(34, True),
    "body": font(30),
    "small": font(24),
    "tiny": font(19),
    "num": font(56, True),
}


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def background(asset_name="premium_training_officials"):
    source_map = {
        "premium_training_officials": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_training_officials.imageset" / "premium_training_officials.png",
        "premium_tactical_duel": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_tactical_duel.imageset" / "premium_tactical_duel.png",
        "premium_analysis_room": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_analysis_room.imageset" / "premium_analysis_room.png",
        "premium_icon_scene": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_icon_scene.imageset" / "premium_icon_scene.png",
    }
    img = Image.new("RGB", (W, H), "#06110d")
    source = source_map.get(asset_name)
    if source and source.exists():
        photo = Image.open(source).convert("RGB")
        scale = max(W / photo.width, H / photo.height)
        resized = photo.resize((round(photo.width * scale), round(photo.height * scale)), Image.Resampling.LANCZOS)
        left = (resized.width - W) // 2
        top = (resized.height - H) // 2
        img = resized.crop((left, top, left + W, top + H))
        img = ImageEnhance.Color(img).enhance(0.86)
        img = ImageEnhance.Contrast(img).enhance(1.08)
        img = Image.blend(img, Image.new("RGB", (W, H), "#020604"), 0.36)
    else:
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
    img = background("premium_training_officials")
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
    img = background("premium_training_officials")
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
    img = background("premium_analysis_room")
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
    img = background("premium_tactical_duel")
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
    img = background("premium_tactical_duel")
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
    img = background("premium_icon_scene")
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


def subscription_art_background(asset_name):
    source_map = {
        "premium_training_officials": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_training_officials.imageset" / "premium_training_officials.png",
        "premium_tactical_duel": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_tactical_duel.imageset" / "premium_tactical_duel.png",
        "premium_analysis_room": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_analysis_room.imageset" / "premium_analysis_room.png",
        "premium_icon_scene": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_icon_scene.imageset" / "premium_icon_scene.png",
    }
    source = source_map.get(asset_name)
    img = Image.new("RGB", (SW, SH), "#06110d")
    if source and source.exists():
        photo = Image.open(source).convert("RGB")
        scale = max(SW / photo.width, SH / photo.height)
        resized = photo.resize((round(photo.width * scale), round(photo.height * scale)), Image.Resampling.LANCZOS)
        left = (resized.width - SW) // 2
        top = (resized.height - SH) // 2
        img = resized.crop((left, top, left + SW, top + SH))
        img = ImageEnhance.Color(img).enhance(0.86)
        img = ImageEnhance.Contrast(img).enhance(1.14)
        img = Image.blend(img, Image.new("RGB", (SW, SH), "#020604"), 0.34)

    vignette = Image.new("L", (SW, SH), 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-250, -180, SW + 260, SH + 220), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(90))
    dark = Image.new("RGBA", (SW, SH), (0, 0, 0, 172))
    return Image.composite(img.convert("RGBA"), dark, vignette)


def subscription_pitch(draw, x0, y0, x1, y1, accent=(64, 255, 174, 180)):
    rounded(draw, (x0, y0, x1, y1), 34, (2, 45, 27, 205), outline=accent, width=3)
    for i in range(1, 6):
        y = y0 + i * (y1 - y0) / 6
        draw.line((x0 + 24, y, x1 - 24, y), fill=(205, 255, 229, 38), width=2)
    draw.rectangle((x0 + 38, y0 + 38, x1 - 38, y1 - 38), outline=(205, 255, 229, 85), width=3)
    mid_y = (y0 + y1) / 2
    draw.line((x0 + 38, mid_y, x1 - 38, mid_y), fill=(205, 255, 229, 70), width=3)
    draw.ellipse(((x0 + x1) / 2 - 86, mid_y - 86, (x0 + x1) / 2 + 86, mid_y + 86), outline=(205, 255, 229, 70), width=3)


def subscription_marker(draw, x, y, color=(64, 255, 174), size=27):
    glow = Image.new("RGBA", (SW, SH), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((x - size * 2.8, y - size * 2.8, x + size * 2.8, y + size * 2.8), fill=(color[0], color[1], color[2], 34))
    glow = glow.filter(ImageFilter.GaussianBlur(20))
    draw.bitmap((0, 0), glow.split()[-1], fill=(color[0], color[1], color[2], 48))
    draw.ellipse((x - size, y - size, x + size, y + size), fill=(5, 18, 13, 238), outline=color, width=5)


def subscription_arrow(draw, p1, p2, color=(64, 255, 175, 220), width=8):
    draw.line((p1, p2), fill=color, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    for delta in (2.55, -2.55):
        q = (p2[0] + 32 * math.cos(ang + delta), p2[1] + 32 * math.sin(ang + delta))
        draw.line((p2, q), fill=color, width=width)


def subscription_art_pro_monthly():
    img = subscription_art_background("premium_training_officials")
    d = ImageDraw.Draw(img)
    accent = (64, 255, 174, 210)
    subscription_pitch(d, 112, 288, 912, 814, accent)
    for x, y in [(310, 585), (462, 496), (620, 590), (740, 455)]:
        subscription_marker(d, x, y, (64, 255, 174))
    subscription_arrow(d, (310, 585), (462, 496))
    subscription_arrow(d, (462, 496), (620, 590))
    subscription_arrow(d, (620, 590), (740, 455), (255, 214, 89, 230))
    for r in range(330, 40, -22):
        d.ellipse((512 - r, 512 - r, 512 + r, 512 + r), outline=(64, 255, 174, max(10, int(32 * r / 330))), width=2)
    d.arc((260, 116, 764, 620), 210, 330, fill=(64, 255, 174, 132), width=9)
    d.arc((308, 164, 716, 572), 214, 326, fill=(255, 214, 89, 92), width=5)
    subscription_marker(d, 512, 198, (64, 255, 174), size=20)
    return img


def subscription_art_pro_yearly():
    img = subscription_art_background("premium_analysis_room")
    d = ImageDraw.Draw(img)
    accent = (255, 214, 89, 210)
    subscription_pitch(d, 124, 264, 900, 810, accent)
    points = [(270, 632), (400, 520), (536, 606), (670, 490), (788, 590)]
    for point in points:
        subscription_marker(d, *point, color=(255, 214, 89), size=24)
    for a, b in zip(points, points[1:]):
        subscription_arrow(d, a, b, (255, 214, 89, 230), 7)
    for i, month_x in enumerate(range(226, 820, 84)):
        alpha = 160 if i < 7 else 70
        rounded(d, (month_x, 146, month_x + 44, 190), 12, (255, 214, 89, alpha), outline=(255, 242, 164, 120), width=1)
    d.arc((206, 208, 818, 820), 206, 336, fill=(255, 214, 89, 190), width=10)
    d.arc((232, 234, 792, 794), 208, 330, fill=(64, 255, 174, 120), width=6)
    return img


def subscription_art_elite_club():
    img = subscription_art_background("premium_tactical_duel")
    d = ImageDraw.Draw(img)
    accent = (116, 191, 255, 210)
    subscription_pitch(d, 92, 224, 932, 842, accent)
    clusters = [
        [(270, 420), (370, 350), (460, 420), (350, 500)],
        [(560, 620), (665, 550), (770, 630), (670, 720)],
        [(610, 360), (730, 315), (822, 410)],
    ]
    colors = [(64, 255, 174), (116, 191, 255), (255, 214, 89)]
    for cluster, color in zip(clusters, colors):
        for point in cluster:
            subscription_marker(d, *point, color=color, size=22)
        for a, b in zip(cluster, cluster[1:]):
            subscription_arrow(d, a, b, (*color, 215), 6)
    for r in [390, 312, 234, 156]:
        d.ellipse((512 - r, 512 - r, 512 + r, 512 + r), outline=(116, 191, 255, 28), width=3)
    academy_nodes = [(268, 148), (512, 110), (756, 148)]
    d.line((academy_nodes[0], academy_nodes[1], academy_nodes[2]), fill=(116, 191, 255, 118), width=5)
    for point in academy_nodes:
        subscription_marker(d, *point, color=(116, 191, 255), size=20)
    return img


def ipad_background(asset_name="premium_training_officials"):
    source_map = {
        "premium_training_officials": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_training_officials.imageset" / "premium_training_officials.png",
        "premium_tactical_duel": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_tactical_duel.imageset" / "premium_tactical_duel.png",
        "premium_analysis_room": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_analysis_room.imageset" / "premium_analysis_room.png",
        "premium_icon_scene": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_icon_scene.imageset" / "premium_icon_scene.png",
    }
    source = source_map.get(asset_name)
    if source and source.exists():
        photo = Image.open(source).convert("RGB")
        scale = max(IW / photo.width, IH / photo.height)
        resized = photo.resize((round(photo.width * scale), round(photo.height * scale)), Image.Resampling.LANCZOS)
        left = (resized.width - IW) // 2
        top = (resized.height - IH) // 2
        img = resized.crop((left, top, left + IW, top + IH))
        img = ImageEnhance.Color(img).enhance(0.88)
        img = ImageEnhance.Contrast(img).enhance(1.1)
        img = Image.blend(img, Image.new("RGB", (IW, IH), "#020604"), 0.34)
    else:
        img = Image.new("RGB", (IW, IH), "#06110d")

    overlay = Image.new("RGBA", (IW, IH), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for i in range(36):
        y = 170 + i * 76
        d.line((0, y, IW, y + 150), fill=(43, 255, 167, 12), width=2)
    for i in range(12):
        x = -260 + i * 210
        d.line((x, 0, x + 620, IH), fill=(43, 255, 167, 8), width=2)
    for cx, cy in [(160, 120), (IW - 180, 180), (IW - 110, IH - 140)]:
        for r in range(440, 40, -22):
            alpha = max(0, int(13 * (r / 440)))
            d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=(70, 255, 180, alpha), width=2)

    vignette = Image.new("L", (IW, IH), 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-520, -220, IW + 520, IH + 260), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(135))
    dark = Image.new("RGBA", (IW, IH), (0, 0, 0, 165))
    base = Image.composite(img.convert("RGBA"), dark, vignette)
    return Image.alpha_composite(base, overlay)


def ipad_header(draw, title, subtitle="Train like a professional club."):
    draw.text((96, 94), "TACTICORE AI", fill=(82, 255, 178), font=IF["small"])
    draw.text((96, 132), title, fill=(248, 252, 249), font=IF["hero"])
    draw.text((100, 242), subtitle, fill=(194, 214, 205), font=IF["body"])


def ipad_card(draw, box, title=None, alpha=214):
    rounded(draw, box, 34, (8, 22, 18, alpha), outline=(82, 255, 178, 70), width=2)
    if title:
        draw.text((box[0] + 34, box[1] + 28), title, fill=(244, 250, 246), font=IF["h3"])


def ipad_pill(draw, xy, text, fill=(48, 255, 170, 44), outline=(72, 255, 184, 112)):
    x, y = xy
    tw = int(draw.textlength(text, font=IF["small"]))
    rounded(draw, (x, y, x + tw + 50, y + 50), 25, fill, outline=outline, width=1)
    draw.text((x + 25, y + 11), text, fill=(225, 253, 238), font=IF["small"])
    return x + tw + 66


def ipad_pitch(draw, box, title=None):
    x0, y0, x1, y1 = box
    rounded(draw, box, 36, (4, 42, 27, 232), outline=(96, 255, 188, 96), width=3)
    if title:
        draw.text((x0 + 38, y0 + 30), title, fill=(244, 250, 246), font=IF["h3"])
    field_top = y0 + (96 if title else 42)
    field_bottom = y1 - 42
    field_left = x0 + 42
    field_right = x1 - 42
    stripe_h = (field_bottom - field_top) / 8
    for i in range(8):
        fill = (12, 67, 43, 70) if i % 2 == 0 else (6, 52, 35, 70)
        draw.rectangle((field_left, field_top + i * stripe_h, field_right, field_top + (i + 1) * stripe_h), fill=fill)
    draw.rectangle((field_left, field_top, field_right, field_bottom), outline=(205, 255, 229, 94), width=3)
    mid_y = (field_top + field_bottom) / 2
    draw.line((field_left, mid_y, field_right, mid_y), fill=(205, 255, 229, 82), width=3)
    draw.ellipse(((field_left + field_right) / 2 - 110, mid_y - 110, (field_left + field_right) / 2 + 110, mid_y + 110), outline=(205, 255, 229, 82), width=3)
    draw.rectangle((field_left + 250, field_top, field_right - 250, field_top + 165), outline=(205, 255, 229, 62), width=3)
    draw.rectangle((field_left + 250, field_bottom - 165, field_right - 250, field_bottom), outline=(205, 255, 229, 62), width=3)


def ipad_player(draw, x, y, label, color=(64, 255, 174), size=28):
    draw.ellipse((x - size, y - size, x + size, y + size), fill=(6, 17, 13), outline=color, width=5)
    tw = draw.textlength(label, font=IF["tiny"])
    draw.text((x - tw / 2, y - 13), label, fill=(238, 255, 246), font=IF["tiny"])


def ipad_arrow(draw, p1, p2, color=(64, 255, 175, 225), width=8):
    draw.line((p1, p2), fill=color, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    for delta in (2.55, -2.55):
        q = (p2[0] + 32 * math.cos(ang + delta), p2[1] + 32 * math.sin(ang + delta))
        draw.line((p2, q), fill=color, width=width)


def ipad_metric(draw, x, y, label, value, width=850):
    draw.text((x, y), label, fill=(226, 241, 234), font=IF["body"])
    rounded(draw, (x + 300, y + 10, x + 300 + width, y + 40), 15, (27, 45, 38, 220))
    rounded(draw, (x + 300, y + 10, int(x + 300 + width * value), y + 40), 15, (65, 255, 174, 218))


def ipad_footer(draw, text="The modern operating system for elite football coaching."):
    draw.text((96, IH - 118), text, fill=(174, 194, 185), font=IF["small"])
    draw.rectangle((96, IH - 66, IW - 96, IH - 61), fill=(68, 255, 176, 160))


def ipad_command_center():
    img = ipad_background("premium_training_officials")
    d = ImageDraw.Draw(img)
    ipad_header(d, "Elite coaching OS")
    ipad_card(d, (96, 380, 1300, 830), "Training Week")
    d.text((140, 486), "High press identity", fill=(82, 255, 178), font=IF["h1"])
    d.text((142, 565), "4 sessions planned. Recovery load balanced.", fill=(214, 232, 223), font=IF["body"])
    x = 142
    for label in ["Pressing traps", "Build-up angles", "Transition recovery"]:
        x = ipad_pill(d, (x, 660), label)

    ipad_card(d, (1340, 380, 1952, 830), "Completion")
    d.text((1394, 504), "86%", fill=(248, 252, 249), font=IF["num"])
    d.arc((1640, 486, 1810, 656), -90, 238, fill=(64, 255, 174), width=18)
    d.text((1396, 646), "Session completion", fill=(180, 203, 192), font=IF["small"])

    ipad_pitch(d, (96, 900, 1952, 1920), "Live Tactical Focus")
    for x, y, n in [(455, 1390, "6"), (680, 1275, "8"), (915, 1405, "10"), (1240, 1220, "9"), (1445, 1595, "7")]:
        ipad_player(d, x, y, n)
    ipad_arrow(d, (680, 1275), (915, 1405))
    ipad_arrow(d, (915, 1405), (1240, 1220))
    ipad_arrow(d, (1445, 1595), (1120, 1750), (255, 214, 89, 225))

    ipad_card(d, (96, 1995, 1952, 2510), "AI Coach Insight")
    d.text((140, 2110), "Wide press timing is strong.", fill=(248, 252, 249), font=IF["h2"])
    d.text((140, 2180), "Add recovery runs after turnovers and reduce midfield distances.", fill=(180, 203, 192), font=IF["body"])
    ipad_pill(d, (140, 2300), "Generate Session")
    ipad_pill(d, (430, 2300), "Voice Notes")
    ipad_pill(d, (650, 2300), "Tactical Board")
    ipad_footer(d)
    return img


def ipad_session_builder():
    img = ipad_background("premium_training_officials")
    d = ImageDraw.Draw(img)
    ipad_header(d, "AI session builder")
    ipad_card(d, (96, 380, 1952, 760), "Coach Inputs")
    labels = ["U16", "75 min", "18 players", "4-3-3", "High intensity", "Pressing", "Transitions"]
    x = 142
    for label in labels:
        x = ipad_pill(d, (x, 510), label)

    ipad_card(d, (96, 830, 1952, 1310), "AI Generated Plan")
    stages = [("Warm-up", "Pressing reactions"), ("Technical", "First pass under pressure"), ("Tactical", "Wide trap and counter-press"), ("Game", "8v8 + 3 transition zone")]
    y = 940
    for i, (title, desc) in enumerate(stages):
        x = 150 + (i % 2) * 900
        yy = y + (i // 2) * 150
        d.ellipse((x, yy + 8, x + 28, yy + 36), fill=(64, 255, 174))
        d.text((x + 52, yy), title, fill=(245, 250, 247), font=IF["h3"])
        d.text((x + 52, yy + 46), desc, fill=(174, 198, 188), font=IF["small"])

    ipad_pitch(d, (96, 1390, 1952, 2440), "Animated Drill Preview")
    for x, y, n in [(430, 1900, "4"), (660, 1760, "6"), (990, 1610, "8"), (1300, 1770, "11"), (1540, 2060, "9")]:
        ipad_player(d, x, y, n)
    ipad_arrow(d, (430, 1900), (660, 1760))
    ipad_arrow(d, (660, 1760), (990, 1610))
    ipad_arrow(d, (990, 1610), (1300, 1770))
    ipad_arrow(d, (1300, 1770), (1540, 2060), (255, 214, 89, 225))
    ipad_footer(d)
    return img


def ipad_voice_notes():
    img = ipad_background("premium_analysis_room")
    d = ImageDraw.Draw(img)
    ipad_header(d, "Voice coach notes")
    ipad_card(d, (96, 390, 1952, 1015), "Live Transcription")
    d.text((145, 505), "We lost control of zone 14 after turnovers.", fill=(248, 252, 249), font=IF["h2"])
    d.text((145, 575), "Next block should tighten midfield distances and rehearse recovery cues.", fill=(185, 207, 197), font=IF["body"])
    cy = 810
    for i in range(72):
        x = 185 + i * 23
        amp = 30 + 100 * abs(math.sin(i * 0.48))
        d.rounded_rectangle((x, cy - amp, x + 10, cy + amp), radius=5, fill=(60, 255, 174, 112 + (i % 4) * 28))

    ipad_card(d, (96, 1090, 1952, 1530), "AI Coaching Summary")
    y = 1210
    for p in ["Shape stretched in defensive transition", "Midfield cue: scan, recover, compress", "Next session: counter-press rondo to 8v8 game"]:
        d.ellipse((145, y + 12, 175, y + 42), fill=(64, 255, 174))
        d.text((205, y), p, fill=(234, 246, 240), font=IF["body"])
        y += 92

    ipad_pitch(d, (96, 1600, 1952, 2440), "Voice to Tactical Plan")
    for x, y, n in [(520, 2040, "8"), (760, 1940, "6"), (1030, 2040, "10"), (1320, 1890, "9"), (1540, 2050, "7")]:
        ipad_player(d, x, y, n)
    ipad_arrow(d, (1320, 1890), (1100, 1795), (255, 214, 89, 225))
    ipad_arrow(d, (760, 1940), (1030, 2040))
    ipad_arrow(d, (1540, 2050), (1320, 2100))
    ipad_footer(d, "Voice features request microphone and speech recognition permission.")
    return img


def ipad_tactical_board():
    img = ipad_background("premium_tactical_duel")
    d = ImageDraw.Draw(img)
    ipad_header(d, "Tactical board")
    ipad_pitch(d, (96, 380, 1952, 1990), "4-3-3 Pressing Pattern")
    players = [
        (1025, 590, "1"), (450, 830, "3"), (800, 910, "5"), (1230, 910, "4"), (1590, 830, "2"),
        (680, 1190, "6"), (1025, 1110, "8"), (1360, 1190, "10"), (540, 1550, "11"), (1025, 1460, "9"), (1500, 1550, "7"),
    ]
    for p in players:
        ipad_player(d, *p)
    ipad_arrow(d, (1500, 1550), (1310, 1350))
    ipad_arrow(d, (1025, 1460), (1025, 1285))
    ipad_arrow(d, (540, 1550), (735, 1355))
    ipad_arrow(d, (1025, 1110), (1360, 1190), (255, 214, 89, 225))

    ipad_card(d, (96, 2075, 1952, 2510), "Pressing Triggers")
    x = 145
    for label in ["Back pass", "Bad first touch", "Wide receive", "Negative body shape"]:
        x = ipad_pill(d, (x, 2200), label)
    ipad_footer(d)
    return img


def ipad_player_development():
    img = ipad_background("premium_tactical_duel")
    d = ImageDraw.Draw(img)
    ipad_header(d, "Player development")
    ipad_card(d, (96, 390, 1952, 850), "Development Alert")
    d.ellipse((145, 545, 315, 715), fill=(10, 24, 20), outline=(82, 255, 178, 120), width=4)
    d.text((380, 520), "U16 Midfielder", fill=(248, 252, 249), font=IF["h2"])
    d.text((382, 590), "Tactical awareness +12%", fill=(82, 255, 178), font=IF["h3"])
    d.text((382, 655), "Next focus: scan before receiving and protect central lanes.", fill=(185, 207, 197), font=IF["body"])
    ipad_pill(d, (382, 745), "Confidence rising")
    ipad_pill(d, (650, 745), "Stamina watch")

    ipad_card(d, (96, 930, 1952, 1540), "Progression Metrics")
    ipad_metric(d, 145, 1050, "Passing", 0.82)
    ipad_metric(d, 145, 1156, "Positioning", 0.74)
    ipad_metric(d, 145, 1262, "Discipline", 0.88)
    ipad_metric(d, 145, 1368, "Tactical IQ", 0.79)

    ipad_card(d, (96, 1620, 1952, 2440), "Squad Growth Trends")
    bars = [260, 420, 350, 530, 460, 500]
    labels = ["Press", "Poss", "Trans", "Def", "Finish", "Load"]
    for i, h in enumerate(bars):
        x = 260 + i * 270
        rounded(d, (x, 2220 - h, x + 116, 2220), 24, (64, 255, 174, 216))
        d.text((x - 18, 2265), labels[i], fill=(184, 207, 196), font=IF["small"])
    d.text((145, 1740), "AI recommends a compactness block before the next match.", fill=(248, 252, 249), font=IF["h2"])
    d.text((145, 1810), "Use two transition games and one low-load recovery shape review.", fill=(185, 207, 197), font=IF["body"])
    ipad_footer(d)
    return img


def ipad_paywall():
    img = ipad_background("premium_icon_scene")
    d = ImageDraw.Draw(img)
    ipad_header(d, "Pro coaching power", "Unlock voice planning, tactical boards, animated drills and premium exports.")
    plans = [
        ("Pro Coach Monthly", "$14.99", "Unlimited AI sessions and voice notes", True),
        ("Pro Coach Yearly", "$119.99", "Season-long planning with premium exports", False),
        ("Elite Club Monthly", "$49.99", "Academy workflows and advanced tracking", False),
    ]
    y = 470
    for name, price, desc, active in plans:
        fill = (21, 48, 38, 236) if active else (9, 24, 20, 218)
        outline = (82, 255, 178, 210) if active else (82, 255, 178, 76)
        rounded(d, (96, y, 1952, y + 480), 42, fill, outline=outline, width=3)
        d.text((150, y + 70), name, fill=(248, 252, 249), font=IF["h2"])
        d.text((150, y + 150), desc, fill=(184, 207, 196), font=IF["body"])
        d.text((150, y + 275), price, fill=(82, 255, 178), font=IF["num"])
        if active:
            rounded(d, (1600, y + 82, 1840, y + 144), 31, (67, 255, 174, 230))
            d.text((1655, y + 98), "Selected", fill=(5, 17, 12), font=IF["small"])
        y += 550

    rounded(d, (430, 2260, 1618, 2370), 55, (62, 255, 174, 238))
    d.text((848, 2290), "Continue", fill=(3, 20, 12), font=IF["h2"])
    ipad_footer(d, "Coaching and educational tool only. Review AI recommendations.")
    return img


def vision_background(asset_name="premium_training_officials"):
    source_map = {
        "premium_training_officials": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_training_officials.imageset" / "premium_training_officials.png",
        "premium_tactical_duel": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_tactical_duel.imageset" / "premium_tactical_duel.png",
        "premium_analysis_room": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_analysis_room.imageset" / "premium_analysis_room.png",
        "premium_icon_scene": ROOT.parent / "TactiCoreAI" / "Resources" / "Assets.xcassets" / "premium_icon_scene.imageset" / "premium_icon_scene.png",
    }
    source = source_map.get(asset_name)
    if source and source.exists():
        photo = Image.open(source).convert("RGB")
        scale = max(VW / photo.width, VH / photo.height)
        resized = photo.resize((round(photo.width * scale), round(photo.height * scale)), Image.Resampling.LANCZOS)
        left = (resized.width - VW) // 2
        top = (resized.height - VH) // 2
        img = resized.crop((left, top, left + VW, top + VH))
        img = ImageEnhance.Color(img).enhance(0.9)
        img = ImageEnhance.Contrast(img).enhance(1.12)
        img = Image.blend(img, Image.new("RGB", (VW, VH), "#020604"), 0.28)
    else:
        img = Image.new("RGB", (VW, VH), "#05110c")
        d = ImageDraw.Draw(img)
        for y in range(0, VH, 12):
            shade = int(8 + 28 * (1 - y / VH))
            d.rectangle((0, y, VW, y + 12), fill=(3, shade, 12))

    overlay = Image.new("RGBA", (VW, VH), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    for i in range(44):
        y = 120 + i * 62
        d.line((0, y, VW, y + 210), fill=(55, 255, 178, 10), width=3)
    for i in range(18):
        x = -480 + i * 300
        d.line((x, 0, x + 860, VH), fill=(55, 255, 178, 7), width=3)
    for cx, cy in [(620, 310), (VW - 540, 260), (VW - 460, VH - 180)]:
        for r in range(520, 40, -26):
            alpha = max(0, int(13 * (r / 520)))
            d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=(70, 255, 180, alpha), width=3)

    vignette = Image.new("L", (VW, VH), 0)
    vd = ImageDraw.Draw(vignette)
    vd.ellipse((-780, -430, VW + 780, VH + 420), fill=255)
    vignette = vignette.filter(ImageFilter.GaussianBlur(170))
    dark = Image.new("RGBA", (VW, VH), (0, 0, 0, 178))
    base = Image.composite(img.convert("RGBA"), dark, vignette)
    return Image.alpha_composite(base, overlay)


def vision_header(draw, title, subtitle="Train like a professional club."):
    draw.text((170, 128), "TACTICORE AI", fill=(82, 255, 178), font=VF["small"])
    draw.text((170, 175), title, fill=(248, 252, 249), font=VF["hero"])
    draw.text((176, 322), subtitle, fill=(194, 214, 205), font=VF["body"])


def vision_card(draw, box, title=None, alpha=214):
    rounded(draw, box, 44, (8, 22, 18, alpha), outline=(82, 255, 178, 72), width=3)
    if title:
        draw.text((box[0] + 44, box[1] + 34), title, fill=(244, 250, 246), font=VF["h3"])


def vision_pill(draw, xy, text, fill=(48, 255, 170, 44), outline=(72, 255, 184, 118)):
    x, y = xy
    tw = int(draw.textlength(text, font=VF["small"]))
    rounded(draw, (x, y, x + tw + 58, y + 58), 29, fill, outline=outline, width=2)
    draw.text((x + 29, y + 13), text, fill=(225, 253, 238), font=VF["small"])
    return x + tw + 78


def vision_footer(draw, text="The modern operating system for elite football coaching."):
    draw.text((170, VH - 132), text, fill=(174, 194, 185), font=VF["small"])
    draw.rectangle((170, VH - 74, VW - 170, VH - 68), fill=(68, 255, 176, 160))


def vision_pitch(draw, box, title=None):
    x0, y0, x1, y1 = box
    rounded(draw, box, 48, (4, 42, 27, 230), outline=(96, 255, 188, 105), width=4)
    if title:
        draw.text((x0 + 54, y0 + 38), title, fill=(244, 250, 246), font=VF["h3"])
    field_top = y0 + (120 if title else 54)
    field_bottom = y1 - 54
    field_left = x0 + 58
    field_right = x1 - 58
    stripe_h = (field_bottom - field_top) / 8
    for i in range(8):
        fill = (12, 67, 43, 75) if i % 2 == 0 else (6, 52, 35, 75)
        draw.rectangle((field_left, field_top + i * stripe_h, field_right, field_top + (i + 1) * stripe_h), fill=fill)
    draw.rectangle((field_left, field_top, field_right, field_bottom), outline=(205, 255, 229, 105), width=4)
    mid_y = (field_top + field_bottom) / 2
    draw.line((field_left, mid_y, field_right, mid_y), fill=(205, 255, 229, 95), width=4)
    draw.ellipse(((field_left + field_right) / 2 - 150, mid_y - 150, (field_left + field_right) / 2 + 150, mid_y + 150), outline=(205, 255, 229, 95), width=4)
    draw.rectangle((field_left + 420, field_top, field_right - 420, field_top + 220), outline=(205, 255, 229, 72), width=4)
    draw.rectangle((field_left + 420, field_bottom - 220, field_right - 420, field_bottom), outline=(205, 255, 229, 72), width=4)


def vision_player(draw, x, y, label, color=(64, 255, 174), size=38):
    glow = Image.new("RGBA", (VW, VH), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((x - size * 2.2, y - size * 2.2, x + size * 2.2, y + size * 2.2), fill=(color[0], color[1], color[2], 24))
    glow = glow.filter(ImageFilter.GaussianBlur(18))
    draw.bitmap((0, 0), glow.split()[-1], fill=(color[0], color[1], color[2], 42))
    draw.ellipse((x - size, y - size, x + size, y + size), fill=(6, 17, 13), outline=color, width=6)
    tw = draw.textlength(label, font=VF["tiny"])
    draw.text((x - tw / 2, y - 14), label, fill=(238, 255, 246), font=VF["tiny"])


def vision_arrow(draw, p1, p2, color=(64, 255, 175, 225), width=10):
    draw.line((p1, p2), fill=color, width=width)
    ang = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    for delta in (2.55, -2.55):
        q = (p2[0] + 42 * math.cos(ang + delta), p2[1] + 42 * math.sin(ang + delta))
        draw.line((p2, q), fill=color, width=width)


def vision_metric(draw, x, y, label, value, width=660):
    draw.text((x, y), label, fill=(226, 241, 234), font=VF["body"])
    rounded(draw, (x + 310, y + 11, x + 310 + width, y + 44), 17, (27, 45, 38, 220))
    rounded(draw, (x + 310, y + 11, int(x + 310 + width * value), y + 44), 17, (65, 255, 174, 218))


def vision_command_center():
    img = vision_background("premium_training_officials")
    d = ImageDraw.Draw(img)
    vision_header(d, "Spatial coaching command center")
    vision_card(d, (170, 520, 1450, 1120), "Training Week")
    d.text((222, 632), "High press identity", fill=(82, 255, 178), font=VF["h1"])
    d.text((226, 732), "4 sessions planned. Recovery load balanced.", fill=(214, 232, 223), font=VF["body"])
    x = 226
    for label in ["Pressing traps", "Build-up angles", "Transition recovery"]:
        x = vision_pill(d, (x, 852), label)

    vision_card(d, (1540, 520, 2380, 1120), "Completion")
    d.text((1610, 674), "86%", fill=(248, 252, 249), font=VF["num"])
    d.arc((1970, 646, 2224, 900), -90, 238, fill=(64, 255, 174), width=24)
    d.text((1614, 820), "Session completion", fill=(180, 203, 192), font=VF["small"])

    vision_card(d, (2480, 520, 3670, 1120), "AI Coach Insight")
    d.text((2534, 656), "Wide press timing is strong.", fill=(248, 252, 249), font=VF["h3"])
    d.text((2534, 730), "Add recovery runs after turnovers and reduce midfield distances.", fill=(180, 203, 192), font=VF["body"])
    vision_pill(d, (2534, 850), "Next priority")

    vision_pitch(d, (170, 1225, 2380, 1940), "Live Tactical Focus")
    for x, y, n in [(590, 1580, "6"), (850, 1485, "8"), (1130, 1590, "10"), (1505, 1435, "9"), (1710, 1740, "7")]:
        vision_player(d, x, y, n)
    vision_arrow(d, (850, 1485), (1130, 1590))
    vision_arrow(d, (1130, 1590), (1505, 1435))
    vision_arrow(d, (1710, 1740), (1320, 1845), (255, 214, 89, 225))

    vision_card(d, (2480, 1225, 3670, 1940), "Coach Actions")
    y = 1365
    for label, detail in [
        ("Generate Session", "Build a pro-level training plan"),
        ("Voice Notes", "Turn sideline thoughts into structure"),
        ("Tactical Board", "Animate shape, triggers and transitions"),
        ("Player Development", "Spot growth and next-focus alerts"),
    ]:
        d.text((2534, y), label, fill=(246, 252, 248), font=VF["h3"])
        d.text((2534, y + 56), detail, fill=(177, 201, 190), font=VF["small"])
        y += 132
    vision_footer(d)
    return img


def vision_tactical_board():
    img = vision_background("premium_tactical_duel")
    d = ImageDraw.Draw(img)
    vision_header(d, "Elite tactical board", "Animate pressing triggers, transitions and set-piece patterns.")
    vision_card(d, (170, 520, 1120, 1885), "Pattern Controls")
    for y, title, value in [
        (660, "Formation", "4-3-3 high press"),
        (820, "Trigger", "Back pass to fullback"),
        (980, "Transition", "Counter-press within 6 sec"),
        (1140, "Set Piece", "Near-post decoy run"),
    ]:
        d.text((226, y), title, fill=(177, 201, 190), font=VF["small"])
        d.text((226, y + 44), value, fill=(246, 252, 248), font=VF["h3"])
    x = 226
    for label in ["Press", "Recover", "Switch"]:
        x = vision_pill(d, (x, 1370), label)

    vision_pitch(d, (1230, 520, 3670, 1885), "4-3-3 Pressing Simulation")
    players = [
        (2440, 720, "1"), (1740, 940, "3"), (2190, 1020, "5"), (2670, 1020, "4"), (3150, 940, "2"),
        (2000, 1260, "6"), (2440, 1180, "8"), (2860, 1260, "10"), (1840, 1585, "11"), (2440, 1510, "9"), (3040, 1585, "7"),
    ]
    for p in players:
        vision_player(d, *p)
    vision_arrow(d, (3040, 1585), (2810, 1405))
    vision_arrow(d, (2440, 1510), (2440, 1350))
    vision_arrow(d, (1840, 1585), (2090, 1410))
    vision_arrow(d, (2440, 1180), (2860, 1260), (255, 214, 89, 225))
    vision_footer(d)
    return img


def vision_voice_room():
    img = vision_background("premium_analysis_room")
    d = ImageDraw.Draw(img)
    vision_header(d, "Voice coaching studio", "Dictate observations. Convert them into plans, notes and player feedback.")
    vision_card(d, (170, 540, 1795, 1185), "Live Transcription")
    d.text((230, 676), "We lost control of zone 14 after turnovers.", fill=(248, 252, 249), font=VF["h2"])
    d.text((230, 762), "Next block should tighten midfield distances and rehearse recovery cues.", fill=(185, 207, 197), font=VF["body"])
    cy = 1010
    for i in range(72):
        x = 250 + i * 20
        amp = 32 + 118 * abs(math.sin(i * 0.45))
        d.rounded_rectangle((x, cy - amp, x + 9, cy + amp), radius=5, fill=(60, 255, 174, 118 + (i % 4) * 28))

    vision_card(d, (1910, 540, 3670, 1185), "AI Coaching Summary")
    y = 690
    for p in ["Shape stretched in defensive transition", "Midfield cue: scan, recover, compress", "Next session: counter-press rondo to 8v8 game"]:
        d.ellipse((1974, y + 12, 2008, y + 46), fill=(64, 255, 174))
        d.text((2040, y), p, fill=(234, 246, 240), font=VF["body"])
        y += 118

    vision_pitch(d, (170, 1305, 3670, 1910), "Voice to Tactical Plan")
    for x, y, n in [(980, 1640, "8"), (1420, 1540, "6"), (1900, 1640, "10"), (2400, 1500, "9"), (2840, 1650, "7")]:
        vision_player(d, x, y, n)
    vision_arrow(d, (2400, 1500), (2030, 1395), (255, 214, 89, 225))
    vision_arrow(d, (1420, 1540), (1900, 1640))
    vision_arrow(d, (2840, 1650), (2440, 1710))
    vision_footer(d, "Voice features request microphone and speech recognition permission.")
    return img


def vision_player_development_wall():
    img = vision_background("premium_tactical_duel")
    d = ImageDraw.Draw(img)
    vision_header(d, "Player development wall")
    vision_card(d, (170, 520, 1330, 1880), "Development Alert")
    d.ellipse((260, 680, 510, 930), fill=(10, 24, 20), outline=(82, 255, 178, 120), width=5)
    d.text((568, 692), "U16 Midfielder", fill=(248, 252, 249), font=VF["h2"])
    d.text((570, 782), "Tactical awareness +12%", fill=(82, 255, 178), font=VF["h3"])
    d.text((570, 852), "Next focus: scan before receiving and protect central lanes.", fill=(185, 207, 197), font=VF["small"])
    vision_pill(d, (570, 974), "Confidence rising")
    vision_pill(d, (570, 1050), "Stamina watch")
    vision_metric(d, 250, 1230, "Passing", 0.82, 600)
    vision_metric(d, 250, 1338, "Positioning", 0.74, 600)
    vision_metric(d, 250, 1446, "Discipline", 0.88, 600)
    vision_metric(d, 250, 1554, "Tactical IQ", 0.79, 600)

    vision_card(d, (1450, 520, 3670, 1880), "Squad Growth Trends")
    bars = [420, 610, 520, 760, 650, 705]
    labels = ["Press", "Poss", "Trans", "Def", "Finish", "Load"]
    for i, h in enumerate(bars):
        x = 1640 + i * 295
        rounded(d, (x, 1580 - h, x + 128, 1580), 28, (64, 255, 174, 216))
        d.text((x - 18, 1640), labels[i], fill=(184, 207, 196), font=VF["small"])
    d.text((1600, 690), "AI recommends a compactness block before the next match.", fill=(248, 252, 249), font=VF["h2"])
    d.text((1600, 785), "Use two transition games and one low-load recovery shape review.", fill=(185, 207, 197), font=VF["body"])
    vision_footer(d)
    return img


def vision_paywall():
    img = vision_background("premium_icon_scene")
    d = ImageDraw.Draw(img)
    vision_header(d, "Unlock the elite club workflow", "Unlimited AI planning, tactical boards, voice input and premium exports.")
    plans = [
        ("Pro Coach Monthly", "$14.99", "Unlimited AI sessions and voice notes", 170),
        ("Pro Coach Yearly", "$119.99", "Season-long planning with premium exports", 1390),
        ("Elite Club Monthly", "$49.99", "Academy workflows and advanced tracking", 2610),
    ]
    for name, price, desc, x in plans:
        active = name == "Pro Coach Monthly"
        fill = (21, 48, 38, 236) if active else (9, 24, 20, 218)
        outline = (82, 255, 178, 210) if active else (82, 255, 178, 76)
        rounded(d, (x, 600, x + 1060, 1480), 52, fill, outline=outline, width=4)
        d.text((x + 70, 706), name, fill=(248, 252, 249), font=VF["h2"])
        d.text((x + 70, 806), desc, fill=(184, 207, 196), font=VF["body"])
        d.text((x + 70, 994), price, fill=(82, 255, 178), font=VF["num"])
        d.text((x + 70, 1160), "Coaching and educational tool only.", fill=(184, 207, 196), font=VF["small"])
        if active:
            rounded(d, (x + 710, 708, x + 970, 778), 35, (67, 255, 174, 230))
            d.text((x + 760, 725), "Selected", fill=(5, 17, 12), font=VF["small"])

    rounded(d, (1290, 1640, 2550, 1755), 58, (62, 255, 174, 238))
    d.text((1690, 1669), "Continue", fill=(3, 20, 12), font=VF["h2"])
    vision_footer(d, "Review AI recommendations and adapt them to your players and club policies.")
    return img


def save_all():
    SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)
    IPAD_DIR.mkdir(parents=True, exist_ok=True)
    VISION_DIR.mkdir(parents=True, exist_ok=True)
    SUBSCRIPTION_DIR.mkdir(parents=True, exist_ok=True)
    SUBSCRIPTION_IMAGE_DIR.mkdir(parents=True, exist_ok=True)
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

    ipad_screenshots = [
        ("01_ipad_command_center.png", ipad_command_center()),
        ("02_ipad_ai_session_builder.png", ipad_session_builder()),
        ("03_ipad_voice_coach_notes.png", ipad_voice_notes()),
        ("04_ipad_tactical_board.png", ipad_tactical_board()),
        ("05_ipad_player_development.png", ipad_player_development()),
        ("06_ipad_paywall.png", ipad_paywall()),
    ]
    for name, image in ipad_screenshots:
        image.convert("RGB").save(IPAD_DIR / name, optimize=True)

    vision_screenshots = [
        ("01_spatial_command_center.png", vision_command_center()),
        ("02_elite_tactical_board.png", vision_tactical_board()),
        ("03_voice_coaching_studio.png", vision_voice_room()),
        ("04_player_development_wall.png", vision_player_development_wall()),
        ("05_visionos_paywall.png", vision_paywall()),
    ]
    for name, image in vision_screenshots:
        image.convert("RGB").save(VISION_DIR / name, optimize=True)

    subscription_images = [
        ("pro_coach_monthly_review.png", screenshot_paywall("pro-monthly")),
        ("pro_coach_yearly_review.png", screenshot_paywall("pro-yearly")),
        ("elite_club_monthly_review.png", screenshot_paywall("elite-monthly")),
    ]
    for name, image in subscription_images:
        image.convert("RGB").save(SUBSCRIPTION_DIR / name, optimize=True)

    subscription_art_images = [
        ("pro_coach_monthly_1024.png", subscription_art_pro_monthly()),
        ("pro_coach_yearly_1024.png", subscription_art_pro_yearly()),
        ("elite_club_monthly_1024.png", subscription_art_elite_club()),
    ]
    for name, image in subscription_art_images:
        image.convert("RGB").save(SUBSCRIPTION_IMAGE_DIR / name, optimize=True)


if __name__ == "__main__":
    save_all()
    print(f"Created assets in {SCREENSHOT_DIR}")
    print(f"Created assets in {IPAD_DIR}")
    print(f"Created assets in {VISION_DIR}")
    print(f"Created assets in {SUBSCRIPTION_DIR}")
    print(f"Created assets in {SUBSCRIPTION_IMAGE_DIR}")
