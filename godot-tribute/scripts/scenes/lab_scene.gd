extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 3: RESEARCH LAB (32-44s)
#  Whiteboard with equations, pixel portrait, animated microbes,
#  scrolling research topics.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

# ── HIGH-DETAIL PORTRAIT DATA ──
# 32x40 pixel art of Dr. Meile's face
# Palette: 0=transparent, 1-4=skin, 5-9=hair, 10=white, 11=black,
#   12-14=shirt, 15=eyebrown, 16=lip, 17=teeth
const PORTRAIT_PALETTE := [
	Color.TRANSPARENT,        # 0
	Color("fde4c8"),           # 1 skinLight
	Color("f2c5a0"),           # 2 skin
	Color("d9a87c"),           # 3 skinMid
	Color("bf8a5e"),           # 4 skinDark
	Color("c8c8d2"),           # 5 hairLight
	Color("a8a8b4"),           # 6 hair
	Color("8e8e9a"),           # 7 hairMid
	Color("6a6a76"),           # 8 hairDark
	Color("4a4a56"),           # 9 hairShadow
	Color("f0f0f0"),           # 10 white
	Color("101018"),           # 11 black
	Color("d8e8f4"),           # 12 shirtLight
	Color("b0c8e0"),           # 13 shirt
	Color("90aed0"),           # 14 shirtMid
	Color("5c4830"),           # 15 eyeBrown
	Color("c08070"),           # 16 lip/smile
	Color("e8e8e0"),           # 17 teeth
	Color("e8d8c8"),           # 18 highlight
]

# 32 wide x 40 tall portrait
const PORTRAIT_DATA := [
	# Row 0-5: Hair top
	[0,0,0,0,0,0,0,0,0,5,6,7,5,6,7,5,6,7,5,6,7,5,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,5,6,7,8,5,6,7,8,5,6,7,8,5,6,7,8,5,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,5,6,7,5,6,8,5,7,6,8,5,6,7,5,8,6,7,5,6,0,0,0,0,0,0,0],
	[0,0,0,0,0,5,6,7,8,6,5,7,6,8,5,7,6,5,8,7,6,5,7,8,6,5,0,0,0,0,0,0],
	[0,0,0,0,0,6,7,5,6,7,8,6,5,7,6,8,5,7,6,5,8,7,6,5,7,6,0,0,0,0,0,0],
	[0,0,0,0,0,8,6,7,5,8,6,7,5,6,8,7,5,6,8,7,5,6,7,8,6,8,0,0,0,0,0,0],
	# Row 6-7: Hair sides + forehead
	[0,0,0,0,0,9,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,9,0,0,0,0,0,0],
	[0,0,0,0,0,9,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,9,0,0,0,0,0,0],
	# Row 8-9: Upper face
	[0,0,0,0,0,0,8,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,8,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,0,0,0,0,0,0,0,0,0],
	# Row 10: Brow line
	[0,0,0,0,0,0,0,3,8,8,8,8,2,2,2,2,8,8,8,8,2,2,3,0,0,0,0,0,0,0,0,0],
	# Row 11-13: Eyes
	[0,0,0,0,0,0,0,3,10,10,15,10,2,2,2,2,10,10,15,10,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,10,11,11,10,2,2,2,2,10,11,11,10,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,18,10,10,18,2,2,2,2,18,10,10,18,2,2,3,0,0,0,0,0,0,0,0,0],
	# Row 14-15: Nose
	[0,0,0,0,0,0,0,0,3,2,2,2,2,4,4,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,3,2,2,2,4,4,4,4,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0],
	# Row 16: Nasolabial fold
	[0,0,0,0,0,0,0,0,3,3,2,2,2,2,2,2,2,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0],
	# Row 17-19: Mouth (smile)
	[0,0,0,0,0,0,0,0,0,3,16,16,16,16,16,16,16,3,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,16,17,17,17,17,17,16,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,3,16,16,16,16,16,3,0,0,0,0,0,0,0,0,0,0,0,0,0],
	# Row 20-21: Chin
	[0,0,0,0,0,0,0,0,0,0,0,3,3,2,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	# Row 22-23: Neck
	[0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,10,10,10,10,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0],
	# Row 24-31: Shirt (blue pinstripe)
	[0,0,0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0],
	[0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0],
	[0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0],
	[0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0],
	[0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0],
	[0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0],
]

var _equations := [
	{"text": "dC/dt = D * nabla^2 C - v * nabla C + R", "color": Color("1840a0"), "y": 60},
	{"text": "f_i(x+e_i dt, t+dt) = f_i(x,t)", "color": Color("1840a0"), "y": 85},
	{"text": "  + Omega_i [f_i^eq - f_i]", "color": Color("1840a0"), "y": 105},
	{"text": "CH4 + SO4(2-) -> HCO3- + HS-", "color": Color("a02020"), "y": 135},
	{"text": "BIOFILM <-> PORE NETWORK", "color": Color("208020"), "y": 165},
	{"text": "Pe = vL/D    Da = kL/v", "color": Color("1840a0"), "y": 190},
]

var _topics := [
	"Reactive Transport", "Biogeochemical Cycling", "Microbial Metabolism",
	"Salt Marsh Carbon", "Iron Cycling", "Hydrothermal Vents",
	"Oil Spill Impacts", "Bioturbation", "Pore-Scale Modeling",
	"Nutrient Dynamics", "Redox Oscillations"
]

func _ready() -> void:
	_font = get_meta("font") if has_meta("font") else ThemeDB.fallback_font

func enter_scene() -> void:
	_local_time = 0.0

func update_scene(lt: float, f: int) -> void:
	_local_time = lt
	_frame = f

func _draw() -> void:
	var t := _local_time
	var f := _frame

	# Lab background
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, Color("f0ece0"), Color("e0d8c8"))

	# Tile floor
	for x_tile in range(0, int(W), 30):
		for y_tile in range(int(H * 0.7), int(H), 30):
			var is_alt := (int(x_tile / 30) + int(y_tile / 30)) % 2 == 0
			draw_rect(Rect2(x_tile, y_tile, 30, 30),
				Color("d8d0c0") if is_alt else Color("e8e0d0"))

	# Whiteboard
	_draw_whiteboard(40, 30, 400, 180, t)

	# Portrait
	DrawUtils.draw_sprite_data(self, 580, 100, 5, PORTRAIT_DATA, PORTRAIT_PALETTE)

	# Desk
	DrawUtils.draw_px(self, 500, 340, 400, 12, DrawUtils.WOOD)
	DrawUtils.draw_px(self, 510, 352, 12, 60, DrawUtils.WOOD_DARK)
	DrawUtils.draw_px(self, 880, 352, 12, 60, DrawUtils.WOOD_DARK)

	# Laptop
	_draw_laptop(600, 310, 3)

	# Coffee cup
	_draw_coffee(740, 310, 3, f)

	# Papers stack
	for i in range(5):
		DrawUtils.draw_px(self, 790 + i * 2, 320 - i * 3, 40, 35, Color("f8f8f0"))
		DrawUtils.draw_px(self, 792 + i * 2, 322 - i * 3, 36, 2, Color("888888"))

	# Animated microbes
	for i in range(5):
		var mx := 80.0 + i * 100 + sin(f * 0.015 + i * 1.7) * 30
		var my := 330.0 + cos(f * 0.02 + i * 1.3) * 20
		_draw_microbe(mx, my, f + i * 40, 1.5)

	# Scrolling research topics bar
	DrawUtils.draw_px(self, 0, H - 45, W, 45, Color(0.04, 0.04, 0.12, 0.88))
	DrawUtils.draw_px(self, 0, H - 47, W, 3, DrawUtils.GOLD)
	var scroll_x := W - fmod(f * 1.5, _topics.size() * 200 + W)
	for i in range(_topics.size()):
		draw_string(_font, Vector2(scroll_x + i * 200, H - 18), "* " + _topics[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, DrawUtils.GOLD)

	# Header
	DrawUtils.draw_px(self, 0, 0, W, 28, Color(DrawUtils.UGA_RED, 0.9))
	DrawUtils.draw_title(self, _font, "RESEARCH SKILLS — ALL MAXED OUT",
		W / 2, 18, 9, DrawUtils.PURE_WHITE)

func _draw_whiteboard(x: float, y: float, w: float, h: float, t: float) -> void:
	# White surface
	DrawUtils.draw_px(self, x, y, w, h, DrawUtils.PURE_WHITE)
	# Frame
	DrawUtils.draw_outline_rect(self, x, y, w, h, Color("999999"), 4.0)
	# Tray
	DrawUtils.draw_px(self, x, y + h, w, 8, Color("c0c0c0"))
	# Markers
	DrawUtils.draw_px(self, x + 20, y + h - 2, 20, 4, Color("2040c0"))
	DrawUtils.draw_px(self, x + 50, y + h - 2, 20, 4, Color("c02020"))
	DrawUtils.draw_px(self, x + 80, y + h - 2, 20, 4, Color("20a020"))

	# Equations (appear one by one)
	for i in range(_equations.size()):
		if t > i * 1.2:
			var eq: Dictionary = _equations[i]
			var eq_alpha := clampf((t - i * 1.2) / 0.5, 0, 1)
			draw_string(_font, Vector2(x + 20, eq.y), eq.text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(eq.color, eq_alpha))

func _draw_laptop(x: float, y: float, s: float) -> void:
	# Screen
	DrawUtils.draw_rounded_rect(self, x, y, 32 * s, 22 * s, 2 * s, Color("303038"))
	DrawUtils.draw_gradient_v(self, x + 2 * s, y + 2 * s, 28 * s, 18 * s,
		Color("0a1428"), Color("102040"))
	# Code lines
	var code_colors := [Color("60f060"), Color("40a0f0"), Color("f0e040"),
		Color("f08040"), Color("a070f0")]
	for j in range(7):
		var line_w := (6.0 + fmod(j * 7, 12)) * s
		DrawUtils.draw_px(self, x + 4 * s, y + (4 + j * 2) * s,
			line_w, s * 0.8, code_colors[j % 5])
	# Base
	DrawUtils.draw_rounded_rect(self, x - 2 * s, y + 22 * s, 36 * s, 3 * s, 1 * s, Color("484850"))

func _draw_coffee(x: float, y: float, s: float, f: int) -> void:
	# Saucer
	DrawUtils.draw_circle_px(self, x + 8 * s, y + 18 * s, 10 * s, Color("e0d8d0"))
	# Cup
	DrawUtils.draw_rounded_rect(self, x, y, 16 * s, 16 * s, 3 * s, Color("f8f0e8"))
	DrawUtils.draw_rounded_rect(self, x + 2 * s, y + 3 * s, 12 * s, 10 * s, 2 * s, DrawUtils.COFFEE)
	DrawUtils.draw_px(self, x + 4 * s, y + 5 * s, 6 * s, 2 * s, DrawUtils.COFFEE_LT)
	# Handle
	DrawUtils.draw_px(self, x + 16 * s, y + 4 * s, 4 * s, 2 * s, Color("e8e0d8"))
	DrawUtils.draw_px(self, x + 18 * s, y + 4 * s, 2 * s, 8 * s, Color("e8e0d8"))
	DrawUtils.draw_px(self, x + 16 * s, y + 10 * s, 4 * s, 2 * s, Color("e8e0d8"))
	# Steam
	for i in range(3):
		var sx := x + (4 + i * 4) * s
		var sy := y - 6 * s + sin(f * 0.08 + i * 2.0) * 3 * s
		var steam_alpha := 0.3 + sin(f * 0.05 + i) * 0.2
		DrawUtils.draw_px(self, sx, sy, 2 * s, 4 * s, Color(1, 1, 1, steam_alpha))

func _draw_microbe(x: float, y: float, f: int, sc: float) -> void:
	var wobble := sin(f * 0.06) * 3 * sc
	# Body
	DrawUtils.draw_circle_px(self, x + wobble, y, 10 * sc, Color("40a848"))
	DrawUtils.draw_circle_px(self, x + wobble, y, 7 * sc, Color("60c868"))
	# Flagella
	for i in range(3):
		var angle := i * 2.1 + f * 0.04
		var fx := x + wobble + cos(angle) * 14 * sc
		var fy := y + sin(angle) * 14 * sc
		draw_line(Vector2(x + wobble, y), Vector2(fx, fy), Color("40a848"), 2 * sc)
	# Eyes
	DrawUtils.draw_circle_px(self, x - 3 * sc + wobble, y - 2 * sc, 2.5 * sc, DrawUtils.PURE_WHITE)
	DrawUtils.draw_circle_px(self, x + 3 * sc + wobble, y - 2 * sc, 2.5 * sc, DrawUtils.PURE_WHITE)
	DrawUtils.draw_circle_px(self, x - 2 * sc + wobble, y - 1 * sc, 1.2 * sc, DrawUtils.DEEP_BLACK)
	DrawUtils.draw_circle_px(self, x + 4 * sc + wobble, y - 1 * sc, 1.2 * sc, DrawUtils.DEEP_BLACK)
