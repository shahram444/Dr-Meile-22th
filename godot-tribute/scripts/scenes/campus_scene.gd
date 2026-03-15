extends Node2D

# ══════════════════════════════════════════════════════════════════════
#  SCENE 6: UGA CAMPUS (74-84s)
#  The famous UGA Arch, brick walkway, trees, students, and confetti.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

const STUDENT_COLORS := [
	Color("e74c3c"), Color("3498db"), Color("2ecc71"), Color("f39c12"),
	Color("9b59b6"), Color("1abc9c"), Color("e67e22"), Color("e84393"),
]
const HAIR_COLORS := [
	Color("2c1810"), Color("4a3020"), Color("1a1a1a"), Color("6b4830"),
	Color("3c2a1c"), Color("222222"), Color("553344"), Color("2a1a0a"),
]
const CONFETTI_COLORS := [
	Color("ba0c2f"), Color("40b040"), Color("4080e0"),
	Color("ffd040"), Color("e060c0"), Color("40b0b0"),
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

	# Sky
	DrawUtils.draw_gradient_v(self, 0, 0, W, H * 0.5, DrawUtils.SKY_BOTTOM, DrawUtils.SKY_MID)

	# Trees
	for i in range(8):
		var tx := float(i) * 130 + 20
		# Trunk
		DrawUtils.draw_px(self, tx + 15, 150, 8, 50, DrawUtils.WOOD_DARK)
		# Canopy layers
		DrawUtils.draw_circle_px(self, tx + 19, 140, 25, DrawUtils.GRASS_3)
		DrawUtils.draw_circle_px(self, tx + 22, 135, 18, DrawUtils.GRASS_1)
		DrawUtils.draw_circle_px(self, tx + 16, 130, 12, DrawUtils.GRASS_4)

	# Ground
	DrawUtils.draw_gradient_v(self, 0, 200, W, H - 200, DrawUtils.GRASS_1, DrawUtils.GRASS_3)

	# Brick walkway
	for y_row in range(230, int(H), 8):
		for x_col in range(350, 610, 16):
			var is_alt := (int(x_col / 16) + int(y_row / 8)) % 2 == 0
			DrawUtils.draw_px(self, x_col, y_row, 14, 6,
				Color("c8a890") if is_alt else Color("b89880"))
			DrawUtils.draw_px(self, x_col + 14, y_row, 2, 6, Color("a88870"))

	# UGA Arch
	DrawUtils.draw_uga_arch(self, 400, 130, 2)

	# Dr. Meile walking through the Arch
	var walk_p := sin(t * 2) * 5
	_draw_walking_figure(455 + walk_p, 210, 3.0, f)

	# Students around
	for i in range(8):
		var sx := 60.0 + i * 60 + sin(f * 0.05 + i) * 5
		var sy := 280.0 + sin(f * 0.08 + i * 2) * 3
		# Body
		DrawUtils.draw_px(self, sx + 6, sy, 16, 22, STUDENT_COLORS[i])
		# Head
		DrawUtils.draw_circle_px(self, sx + 14, sy - 10, 8, DrawUtils.SKIN)
		# Hair
		DrawUtils.draw_px(self, sx + 7, sy - 18, 14, 6, HAIR_COLORS[i])

	# Banner
	if t > 2.0:
		var banner_alpha := clampf((t - 2.0) / 0.5, 0, 1)
		DrawUtils.draw_px(self, 80, 30, W - 160, 50, Color(DrawUtils.UGA_RED, 0.9 * banner_alpha))
		DrawUtils.draw_outline_rect(self, 80, 30, W - 160, 50,
			Color(DrawUtils.GOLD, banner_alpha), 2.0)
		DrawUtils.draw_title(self, _font, "22 YEARS OF EXCELLENCE AT UGA",
			W / 2, 55, 9, Color(DrawUtils.PURE_WHITE, banner_alpha))
		draw_string(_font, Vector2(W / 2, 72), "MARINE SCIENCES DEPARTMENT",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(DrawUtils.GOLD, banner_alpha))

	# Confetti
	if t > 4.0:
		for i in range(40):
			var cx := fmod(float(i) * 47 + f * 3, W)
			var cy := fmod(float(f) * 2 + i * 31, H)
			DrawUtils.draw_px(self, cx, cy, 4, 4, CONFETTI_COLORS[i % 6])

func _draw_walking_figure(ox: float, oy: float, sc: float, f: int) -> void:
	# Hair
	DrawUtils.draw_circle_px(self, ox + 14 * sc, oy + 4 * sc, 9 * sc, DrawUtils.HAIR)
	# Face
	DrawUtils.draw_circle_px(self, ox + 14 * sc, oy + 10 * sc, 8 * sc, DrawUtils.SKIN)
	# Eyes
	DrawUtils.draw_px(self, ox + 10 * sc, oy + 9 * sc, 2 * sc, 2 * sc, DrawUtils.DEEP_BLACK)
	DrawUtils.draw_px(self, ox + 16 * sc, oy + 9 * sc, 2 * sc, 2 * sc, DrawUtils.DEEP_BLACK)
	# Smile
	DrawUtils.draw_px(self, ox + 11 * sc, oy + 14 * sc, 6 * sc, 1 * sc, Color("c08070"))
	# Shirt
	for i in range(18):
		for j in range(14):
			var dx := i - 9
			if abs(dx) < 9 + j * 0.2:
				if j < 2 and abs(dx) < 3:
					continue
				DrawUtils.draw_px(self, ox + (i + 5) * sc, oy + (j + 20) * sc, sc, sc,
					DrawUtils.SHIRT_LIGHT if i % 3 == 0 else DrawUtils.SHIRT)
	# Pants
	DrawUtils.draw_px(self, ox + 7 * sc, oy + 34 * sc, 6 * sc, 12 * sc, Color("4a4a58"))
	DrawUtils.draw_px(self, ox + 15 * sc, oy + 34 * sc, 6 * sc, 12 * sc, Color("4a4a58"))
	# Shoes
	var leg_bob := sin(f * 0.15) * 2 * sc
	DrawUtils.draw_px(self, ox + 6 * sc, oy + (46 + leg_bob) * sc, 7 * sc, 2 * sc, Color("3a2a1a"))
	DrawUtils.draw_px(self, ox + 15 * sc, oy + (46 - leg_bob) * sc, 7 * sc, 2 * sc, Color("3a2a1a"))
