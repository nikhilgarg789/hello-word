"""Generate a Kite-style app icon: an orange kite mark on white."""
from PIL import Image, ImageDraw

SS = 4                      # supersample factor for anti-aliasing
N = 1024
S = N * SS

ORANGE = (255, 87, 34)      # #FF5722
ORANGE_DK = (222, 74, 24)   # lower panels
WHITE = (255, 255, 255)

img = Image.new("RGB", (S, S), WHITE)
d = ImageDraw.Draw(img)

def P(x, y):
    return (x * SS, y * SS)

# Kite diamond (in 1024 space)
top    = (512, 205)
left   = (198, 470)
right  = (826, 470)
mid    = (512, 545)
bottom = (512, 835)

# Body
d.polygon([P(*top), P(*left), P(*bottom), P(*right)], fill=ORANGE)
# Lower two-tone panels for depth
d.polygon([P(*mid), P(*left), P(*bottom)], fill=ORANGE_DK)
d.polygon([P(*mid), P(*right), P(*bottom)], fill=ORANGE_DK)

# White struts (spine + cross bar)
lw = int(16 * SS)
d.line([P(*top), P(*bottom)], fill=WHITE, width=lw)
d.line([P(*left), P(*right)], fill=WHITE, width=lw)

# Tail with two little bows
tail_pts = [(512, 835), (556, 895), (508, 950), (548, 1002)]
d.line([P(*p) for p in tail_pts], fill=ORANGE, width=int(11 * SS), joint="curve")

def bow(cx, cy, r):
    d.polygon([P(cx, cy - r), P(cx + r, cy), P(cx, cy + r), P(cx - r, cy)], fill=ORANGE)

bow(556, 895, 26)
bow(508, 950, 24)

# Downscale for smooth edges
icon = img.resize((N, N), Image.LANCZOS)
out = "KiteClone/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
icon.save(out, "PNG")
print("wrote", out, icon.size, icon.mode)
