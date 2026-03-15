extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 5: RPG STAT SCREEN (64-74s)
#  Classic RPG character status screen with animated stat bars,
#  detailed portrait, and character info.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

var _stats := [
	{"name": "TEACHING",    "value": 99,  "color": Color("40c040")},
	{"name": "RESEARCH",    "value": 97,  "color": Color("4080e0")},
	{"name": "COFFEE LV",   "value": 100, "color": Color("6f4e37")},
	{"name": "KINDNESS",    "value": 100, "color": Color("e060c0")},
	{"name": "MODELING",    "value": 98,  "color": Color("40b0b0")},
	{"name": "FROZEN FOOD", "value": 95,  "color": Color("e06040")},
	{"name": "MENTORING",   "value": 99,  "color": Color("ffd040")},
]

# Reuse portrait from lab scene
const PORTRAIT_PALETTE := [
	Color.TRANSPARENT,
	Color("fde4c8"), Color("f2c5a0"), Color("d9a87c"), Color("bf8a5e"),
	Color("c8c8d2"), Color("a8a8b4"), Color("8e8e9a"), Color("6a6a76"), Color("4a4a56"),
	Color("f0f0f0"), Color("101018"),
	Color("d8e8f4"), Color("b0c8e0"), Color("90aed0"),
	Color("5c4830"), Color("c08070"), Color("e8e8e0"), Color("e8d8c8"),
]

const PORTRAIT_DATA := [
	[0,0,0,0,0,0,0,0,0,5,6,7,5,6,7,5,6,7,5,6,7,5,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,5,6,7,8,5,6,7,8,5,6,7,8,5,6,7,8,5,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,5,6,7,5,6,8,5,7,6,8,5,6,7,5,8,6,7,5,6,0,0,0,0,0,0,0],
	[0,0,0,0,0,5,6,7,8,6,5,7,6,8,5,7,6,5,8,7,6,5,7,8,6,5,0,0,0,0,0,0],
	[0,0,0,0,0,6,7,5,6,7,8,6,5,7,6,8,5,7,6,5,8,7,6,5,7,6,0,0,0,0,0,0],
	[0,0,0,0,0,8,6,7,5,8,6,7,5,6,8,7,5,6,8,7,5,6,7,8,6,8,0,0,0,0,0,0],
	[0,0,0,0,0,9,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,9,0,0,0,0,0,0],
	[0,0,0,0,0,9,8,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,8,9,0,0,0,0,0,0],
	[0,0,0,0,0,0,8,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,8,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,8,8,8,8,2,2,2,2,8,8,8,8,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,10,10,15,10,2,2,2,2,10,10,15,10,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,10,11,11,10,2,2,2,2,10,11,11,10,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,3,18,10,10,18,2,2,2,2,18,10,10,18,2,2,3,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,3,2,2,2,2,4,4,2,2,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,3,2,2,2,4,4,4,4,2,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,3,3,2,2,2,2,2,2,2,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,3,16,16,16,16,16,16,16,3,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,16,17,17,17,17,17,16,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,3,16,16,16,16,16,3,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,3,3,2,2,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,0,10,10,10,10,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0,0],
	[0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0],
	[0,0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0,0],
	[0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0],
	[0,0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0,0],
	[0,14,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,12,13,14,0,0,0,0,0,0],
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

	# Dark grid background
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, Color("08081e"), Color("0e0e2e"))
	# Grid lines
	for x_line in range(0, int(W), 24):
		draw_line(Vector2(x_line, 0), Vector2(x_line, H), Color("16163e"), 1.0)
	for y_line in range(0, int(H), 24):
		draw_line(Vector2(0, y_line), Vector2(W, y_line), Color("16163e"), 1.0)

	# Portrait (large, left side)
	DrawUtils.draw_sprite_data(self, 30, 50, 5, PORTRAIT_DATA, PORTRAIT_PALETTE)

	# Stats panel (right side)
	DrawUtils.draw_px(self, 310, 25, 620, 490, Color(0.06, 0.06, 0.18, 0.95))
	DrawUtils.draw_outline_rect(self, 310, 25, 620, 490, DrawUtils.GOLD, 3.0)
	DrawUtils.draw_outline_rect(self, 316, 31, 608, 478, DrawUtils.GOLD_DARK, 1.0)

	# Name banner
	DrawUtils.draw_gradient_h(self, 330, 40, 580, 30, DrawUtils.UGA_RED_DARK, DrawUtils.UGA_RED)
	DrawUtils.draw_title(self, _font, "PROF. DR. CHRISTOF MEILE", 620, 62, 9, DrawUtils.PURE_WHITE)

	# Divider
	DrawUtils.draw_px(self, 330, 80, 580, 2, DrawUtils.GOLD)

	# Character info
	draw_string(_font, Vector2(340, 100), "CLASS: Legendary Professor",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, DrawUtils.GOLD_LIGHT)
	draw_string(_font, Vector2(340, 116), "ORIGIN: Zurich, Switzerland",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("8888a0"))
	draw_string(_font, Vector2(340, 132), "BASE: Athens, Georgia, USA",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("8888a0"))
	draw_string(_font, Vector2(340, 148), "YEARS ACTIVE: 22 (2003-2025)",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("8888a0"))

	# Divider
	DrawUtils.draw_px(self, 330, 158, 580, 2, Color("303060"))

	# Stat bars (animated)
	for i in range(_stats.size()):
		if t > i * 0.5:
			var stat: Dictionary = _stats[i]
			var anim_val := minf(float(stat.value), t * 20.0)
			DrawUtils.draw_stat_bar(self, _font, 340, 182 + i * 38, 200,
				stat.name, stat.value, anim_val, stat.color)

	# Total XP
	if t > 4.0:
		var xp_alpha := clampf((t - 4.0) / 0.5, 0, 1)
		draw_string(_font, Vector2(620, 480), "TOTAL XP: Inf  |  RANK: LEGENDARY",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(DrawUtils.GOLD, xp_alpha))

	# Sparkle particles
	for i in range(10):
		if randf() > 0.92:
			var spark_x := 100 + randf() * 800
			var spark_y := randf() * H
			DrawUtils.draw_px(self, spark_x, spark_y, 2, 2, Color(DrawUtils.GOLD, 0.4))
