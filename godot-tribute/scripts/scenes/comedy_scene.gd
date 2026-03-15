extends Node2D

# ══════════════════════════════════════════════════════════════════════
#  SCENE 4: COMEDY VIGNETTES (44-64s)
#  Four sub-scenes showing Dr. Meile's personality:
#  A) Coffee addiction (44-49s)
#  B) Trader Joe's frozen food (49-54s)
#  C) Teaching (54-59s)
#  D) Swiss vs. Georgia (59-64s)
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

# Student shirt colors
const STUDENT_COLORS := [
	Color("e74c3c"), Color("3498db"), Color("2ecc71"), Color("f39c12"),
	Color("9b59b6"), Color("1abc9c"), Color("e67e22"), Color("e84393"),
]
const HAIR_COLORS := [
	Color("2c1810"), Color("4a3020"), Color("1a1a1a"), Color("6b4830"),
	Color("3c2a1c"), Color("222222"), Color("553344"), Color("2a1a0a"),
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

	# Warm background for all sub-scenes
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, Color("ede4d4"), Color("ddd4c4"))

	# Tile floor
	for x_tile in range(0, int(W), 40):
		for y_tile in range(380, int(H), 40):
			var is_alt := (int(x_tile / 40) + int(y_tile / 40)) % 2 == 0
			draw_rect(Rect2(x_tile, y_tile, 40, 40),
				Color("c8c0b0") if is_alt else Color("d8d0c0"))

	if t < 5.0:
		_draw_coffee_scene(t, f)
	elif t < 10.0:
		_draw_trader_joes(t - 5.0, f)
	elif t < 15.0:
		_draw_teaching(t - 10.0, f)
	else:
		_draw_swiss_vs_georgia(t - 15.0, f)

# ── SUB-SCENE A: COFFEE ──────────────────────────────────────────

func _draw_coffee_scene(t: float, f: int) -> void:
	# Window
	DrawUtils.draw_gradient_v(self, 700, 30, 200, 140, DrawUtils.SKY_BOTTOM, DrawUtils.SKY_MID)
	DrawUtils.draw_outline_rect(self, 700, 30, 200, 140, DrawUtils.WOOD_DARK, 6.0)
	DrawUtils.draw_px(self, 799, 30, 2, 140, DrawUtils.WOOD_DARK)
	DrawUtils.draw_px(self, 700, 99, 200, 2, DrawUtils.WOOD_DARK)

	# Dr. Meile body
	_draw_simple_body(120, 200, 3.0, f)

	# Coffee cups array
	for i in range(12):
		_draw_coffee_cup(340 + (i % 4) * 80, 250 + int(i / 4) * 40, 2.5, f + i * 15)

	# Animated clock
	_draw_clock(830, 250, 30, f)

	# Time label
	var hours := [8, 10, 12, 14, 16, 18]
	var h: int = hours[int(f / 20) % 6]
	draw_string(_font, Vector2(830, 300), "%d:00 — COFFEE TIME!" % h,
		HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color("333333"))

	# Speech bubble
	DrawUtils.draw_bubble(self, _font, 180, 100, [
		"CAN'T MODEL MICROBES",
		"WITHOUT COFFEE...",
		"IT'S THERMODYNAMICS!"
	])

	# Dialog
	DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 20, 400, 55,
		"COFFEE EVERY 2 HOURS", "Status: CAFFEINATED | Refills: Inf", f)

# ── SUB-SCENE B: TRADER JOE'S ────────────────────────────────────

func _draw_trader_joes(t: float, f: int) -> void:
	# Freezer case
	DrawUtils.draw_rounded_rect(self, 400, 80, 480, 280, 8, Color("c8d0d8"))
	DrawUtils.draw_px(self, 405, 85, 470, 130, Color("d8e0e8"))
	DrawUtils.draw_px(self, 405, 220, 470, 130, Color("d0d8e0"))
	DrawUtils.draw_outline_rect(self, 400, 80, 480, 280, Color("a0a8b0"), 3.0)
	# Handle
	DrawUtils.draw_px(self, 395, 180, 6, 40, Color("808890"))
	# Frost effect
	for i in range(30):
		var frost_x := 410 + fmod(i * 47.3, 460)
		var frost_y := 85 + fmod(i * 31.7, 270)
		DrawUtils.draw_px(self, frost_x, frost_y, 3 + fmod(i * 7.1, 4), 3 + fmod(i * 3.3, 4),
			Color(0.86, 0.9, 0.96, 0.5))

	# Frozen pizza boxes
	for r in range(3):
		for c in range(6):
			_draw_frozen_box(420 + c * 70, 95 + r * 50 + (10 if r > 0 else 0), 2.5)

	# Dr. Meile with shopping cart
	_draw_simple_body(200, 200, 3.0, f)

	# Shopping cart
	DrawUtils.draw_px(self, 280, 340, 60, 8, Color("a0a0a0"))
	DrawUtils.draw_px(self, 290, 310, 50, 30, Color("b0b0b0"))
	DrawUtils.draw_circle_px(self, 290, 352, 5, Color("606060"))
	DrawUtils.draw_circle_px(self, 340, 352, 5, Color("606060"))
	# Boxes in cart
	_draw_frozen_box(295, 290, 1.2)
	_draw_frozen_box(315, 285, 1.2)
	_draw_frozen_box(305, 275, 1.2)

	# Speech bubble
	DrawUtils.draw_bubble(self, _font, 100, 100, [
		"AH YES, FROZEN PIZZA",
		"MARGHERITA...",
		"THE SWISS-APPROVED",
		"DINNER OF CHAMPIONS!"
	])

	DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 20, 400, 55,
		"TRADER JOE'S QUEST", "Frozen Food Inventory: LEGENDARY", f)

# ── SUB-SCENE C: TEACHING ────────────────────────────────────────

func _draw_teaching(t: float, f: int) -> void:
	# Chalkboard
	DrawUtils.draw_rounded_rect(self, 80, 40, 800, 220, 4, Color("2a4a2a"))
	DrawUtils.draw_outline_rect(self, 80, 40, 800, 220, DrawUtils.WOOD_DARK, 6.0)
	DrawUtils.draw_px(self, 80, 260, 800, 10, DrawUtils.WOOD_LIGHT)

	# Chalk text on board
	draw_string(_font, Vector2(120, 80), "FINAL EXAM:",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("c8d8c0"))
	draw_string(_font, Vector2(120, 110), "Given: coffee = life",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("c8d8c0"))
	draw_string(_font, Vector2(120, 135), "       frozen_food = energy",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("c8d8c0"))
	draw_string(_font, Vector2(120, 160), "       teaching = passion",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("c8d8c0"))
	draw_string(_font, Vector2(120, 195), "Solve: HAPPINESS = ???",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("c8d8c0"))
	draw_string(_font, Vector2(600, 195), "Inf !",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, DrawUtils.GOLD)

	# Dr. Meile with pointer
	_draw_simple_body(440, 280, 3.0, f)
	draw_line(Vector2(480, 310), Vector2(560, 180), DrawUtils.WOOD_DARK, 3.0)

	# Students in rows
	for r in range(2):
		for c in range(4):
			var sx := 100 + c * 90
			var sy := 360.0 + r * 50
			var bob := sin(f * 0.08 + c + r * 3) * 3
			# Desk
			DrawUtils.draw_px(self, sx - 5, sy + 30, 70, 6, DrawUtils.WOOD_LIGHT)
			# Body
			DrawUtils.draw_px(self, sx + 15, sy + bob, 20, 28, STUDENT_COLORS[(r * 4 + c) % 8])
			# Head
			DrawUtils.draw_circle_px(self, sx + 25, sy - 8 + bob, 10, DrawUtils.SKIN)
			# Hair
			DrawUtils.draw_px(self, sx + 16, sy - 18 + bob, 18, 8, HAIR_COLORS[(r * 4 + c) % 8])
			# Raised hand (some students)
			if (c + r) % 3 == 0:
				DrawUtils.draw_px(self, sx + 35, sy - 20 + bob + sin(f * 0.1 + c) * 5, 6, 18, DrawUtils.SKIN)

	DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 5, 400, 32,
		"22 YEARS OF TEACHING", "1,000+ Students Inspired!", f)

# ── SUB-SCENE D: SWISS VS GEORGIA ────────────────────────────────

func _draw_swiss_vs_georgia(t: float, f: int) -> void:
	# Split screen
	DrawUtils.draw_px(self, 0, 0, W / 2, H, Color("f0ede8"))
	DrawUtils.draw_px(self, W / 2, 0, W / 2, H, Color("f5e8d8"))

	# ── LEFT: Swiss Precision ──
	DrawUtils.draw_swiss_flag(self, 60, 50, 60)
	DrawUtils.draw_title(self, _font, "SWISS PRECISION", W / 4, 140, 9, Color("333333"))

	# Swiss watch
	DrawUtils.draw_circle_px(self, W / 4, 220, 45, DrawUtils.PURE_WHITE)
	DrawUtils.draw_outline_rect(self, W / 4 - 45, 175, 90, 90, Color("333333"), 3.0)
	# Hour markers
	for i in range(12):
		var angle := float(i) * PI / 6.0
		var x1 := W / 4 + cos(angle) * 38
		var y1 := 220 + sin(angle) * 38
		var x2 := W / 4 + cos(angle) * 42
		var y2 := 220 + sin(angle) * 42
		draw_line(Vector2(x1, y1), Vector2(x2, y2), Color("333333"), 2.0)
	# Hour hand
	draw_line(Vector2(W / 4, 220), Vector2(W / 4, 182), Color("333333"), 3.0)
	# Minute hand
	draw_line(Vector2(W / 4, 220), Vector2(W / 4 + 20, 220), Color("333333"), 2.0)
	# Second hand (animated)
	var sec_angle := f * 0.05
	var sx := W / 4 + cos(sec_angle) * 35
	var sy := 220 + sin(sec_angle) * 35
	draw_line(Vector2(W / 4, 220), Vector2(sx, sy), DrawUtils.SWISS_RED, 1.5)

	DrawUtils.draw_title(self, _font, "ALWAYS ON TIME", W / 4, 300, 7, Color("555555"), false)
	DrawUtils.draw_title(self, _font, "METICULOUS", W / 4, 320, 7, Color("555555"), false)

	# Chocolate bar
	DrawUtils.draw_px(self, W / 4 - 20, 370, 40, 20, Color("5a3a1a"))
	for i in range(4):
		DrawUtils.draw_px(self, W / 4 - 18 + i * 10, 372, 8, 7, Color("7a5a3a"))

	# ── RIGHT: Georgia Soul ──
	DrawUtils.draw_title(self, _font, "GEORGIA SOUL", W * 3 / 4, 60, 9, DrawUtils.UGA_RED)

	# Dr. Meile
	_draw_simple_body(W * 3 / 4 - 20, 120, 3.0, f)

	# Coffee
	_draw_coffee_cup(W * 3 / 4 + 60, 200, 3, f)

	# UGA Bulldog (simple pixel art)
	DrawUtils.draw_circle_px(self, W * 3 / 4 - 50, 280, 18, Color("f0e8e0"))
	DrawUtils.draw_circle_px(self, W * 3 / 4 - 55, 270, 10, Color("f0e8e0"))
	DrawUtils.draw_circle_px(self, W * 3 / 4 - 45, 270, 10, Color("f0e8e0"))
	DrawUtils.draw_px(self, W * 3 / 4 - 58, 275, 5, 5, Color("333333"))
	DrawUtils.draw_px(self, W * 3 / 4 - 45, 275, 5, 5, Color("333333"))
	DrawUtils.draw_px(self, W * 3 / 4 - 55, 283, 12, 4, Color("333333"))
	DrawUtils.draw_px(self, W * 3 / 4 - 60, 290, 22, 5, DrawUtils.UGA_RED)

	DrawUtils.draw_title(self, _font, "GO DAWGS!", W * 3 / 4, 320, 9, DrawUtils.UGA_RED)
	DrawUtils.draw_title(self, _font, "WARM VIBES", W * 3 / 4, 350, 7, Color("8b6914"), false)
	DrawUtils.draw_title(self, _font, "BEST ADVISOR", W * 3 / 4, 370, 7, Color("8b6914"), false)

	# Gold divider
	DrawUtils.draw_gradient_v(self, W / 2 - 3, 0, 6, H, DrawUtils.GOLD, DrawUtils.GOLD_DARK)

	DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 5, 400, 32,
		"BEST OF BOTH WORLDS", "Swiss + Southern = LEGENDARY", f)

# ── HELPER DRAWING FUNCTIONS ─────────────────────────────────────

func _draw_simple_body(ox: float, oy: float, sc: float, f: int) -> void:
	# Hair
	DrawUtils.draw_circle_px(self, ox + 14 * sc, oy + 4 * sc, 9 * sc, DrawUtils.HAIR)
	for i in range(3):
		DrawUtils.draw_px(self, ox + (8 + i * 5) * sc, oy - 3 * sc, 3 * sc, 4 * sc,
			[DrawUtils.HAIR_LIGHT, DrawUtils.HAIR_MID, DrawUtils.HAIR_LIGHT][i])
	# Face
	DrawUtils.draw_circle_px(self, ox + 14 * sc, oy + 10 * sc, 8 * sc, DrawUtils.SKIN)
	# Eyes
	DrawUtils.draw_px(self, ox + 10 * sc, oy + 9 * sc, 2 * sc, 2 * sc, DrawUtils.DEEP_BLACK)
	DrawUtils.draw_px(self, ox + 16 * sc, oy + 9 * sc, 2 * sc, 2 * sc, DrawUtils.DEEP_BLACK)
	# Smile
	DrawUtils.draw_px(self, ox + 11 * sc, oy + 14 * sc, 6 * sc, 1 * sc, Color("c08070"))
	DrawUtils.draw_px(self, ox + 12 * sc, oy + 15 * sc, 4 * sc, 1 * sc, Color("f0f0f0"))
	# Neck
	DrawUtils.draw_px(self, ox + 12 * sc, oy + 18 * sc, 4 * sc, 3 * sc, DrawUtils.SKIN)
	# White tee
	DrawUtils.draw_px(self, ox + 11 * sc, oy + 20 * sc, 6 * sc, 2 * sc, DrawUtils.PURE_WHITE)
	# Shirt
	for i in range(20):
		for j in range(14):
			var dx := i - 10
			if abs(dx) < 10 + j * 0.2:
				if j < 2 and abs(dx) < 3:
					continue
				var is_stripe := i % 3 == 0
				DrawUtils.draw_px(self, ox + (i + 4) * sc, oy + (j + 22) * sc, sc, sc,
					DrawUtils.SHIRT_LIGHT if is_stripe else DrawUtils.SHIRT)
	# Arms
	var arm_swing := sin(f * 0.15) * 3 * sc
	DrawUtils.draw_px(self, ox + 3 * sc, oy + (24 + arm_swing) * sc, 2 * sc, 8 * sc, DrawUtils.SHIRT_MID)
	DrawUtils.draw_px(self, ox + 23 * sc, oy + (24 - arm_swing) * sc, 2 * sc, 8 * sc, DrawUtils.SHIRT_MID)
	# Hands
	DrawUtils.draw_px(self, ox + 3 * sc, oy + (32 + arm_swing) * sc, 2 * sc, 2 * sc, DrawUtils.SKIN)
	DrawUtils.draw_px(self, ox + 23 * sc, oy + (32 - arm_swing) * sc, 2 * sc, 2 * sc, DrawUtils.SKIN)
	# Pants
	DrawUtils.draw_px(self, ox + 7 * sc, oy + 36 * sc, 6 * sc, 12 * sc, Color("4a4a58"))
	DrawUtils.draw_px(self, ox + 15 * sc, oy + 36 * sc, 6 * sc, 12 * sc, Color("4a4a58"))
	# Shoes
	DrawUtils.draw_px(self, ox + 6 * sc, oy + 48 * sc, 7 * sc, 2 * sc, Color("3a2a1a"))
	DrawUtils.draw_px(self, ox + 15 * sc, oy + 48 * sc, 7 * sc, 2 * sc, Color("3a2a1a"))

func _draw_coffee_cup(x: float, y: float, s: float, f: int) -> void:
	DrawUtils.draw_circle_px(self, x + 8 * s, y + 18 * s, 10 * s, Color("e0d8d0"))
	DrawUtils.draw_rounded_rect(self, x, y, 16 * s, 16 * s, 3 * s, Color("f8f0e8"))
	DrawUtils.draw_rounded_rect(self, x + 2 * s, y + 3 * s, 12 * s, 10 * s, 2 * s, DrawUtils.COFFEE)
	DrawUtils.draw_px(self, x + 4 * s, y + 5 * s, 6 * s, 2 * s, DrawUtils.COFFEE_LT)
	# Steam
	for i in range(3):
		var sx := x + (4 + i * 4) * s
		var sy := y - 6 * s + sin(f * 0.08 + i * 2.0) * 3 * s
		DrawUtils.draw_px(self, sx, sy, 2 * s, 4 * s, Color(1, 1, 1, 0.3 + sin(f * 0.05 + i) * 0.2))

func _draw_frozen_box(x: float, y: float, s: float) -> void:
	DrawUtils.draw_rounded_rect(self, x, y, 20 * s, 24 * s, 2 * s, Color("e84040"))
	DrawUtils.draw_px(self, x + 2 * s, y + 2 * s, 16 * s, 8 * s, Color("f8f0e0"))
	DrawUtils.draw_px(self, x + 4 * s, y + 4 * s, 12 * s, 4 * s, DrawUtils.UGA_RED)
	# Frozen dots
	for i in range(4):
		DrawUtils.draw_px(self, x + (3 + i * 4) * s, y + (14 + fmod(i, 2) * 3) * s, 2 * s, 2 * s, Color("c8d8f0"))
	DrawUtils.draw_px(self, x + 2 * s, y + 18 * s, 16 * s, 4 * s, Color("f8d848"))

func _draw_clock(cx: float, cy: float, radius: float, f: int) -> void:
	DrawUtils.draw_circle_px(self, cx, cy, radius, DrawUtils.PURE_WHITE)
	DrawUtils.draw_outline_rect(self, cx - radius, cy - radius, radius * 2, radius * 2,
		Color("333333"), 3.0)
	# Numbers
	draw_string(_font, Vector2(cx, cy - radius + 12), "12",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color("333333"))
	draw_string(_font, Vector2(cx, cy + radius - 4), "6",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color("333333"))
	draw_string(_font, Vector2(cx + radius - 8, cy + 4), "3",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color("333333"))
	draw_string(_font, Vector2(cx - radius + 8, cy + 4), "9",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 6, Color("333333"))
	# Hour hand
	var hours := [8, 10, 12, 14, 16, 18]
	var h: int = hours[int(f / 20) % 6]
	var angle := float(h) / 12.0 * TAU - PI / 2.0
	draw_line(Vector2(cx, cy), Vector2(cx + cos(angle) * 20, cy + sin(angle) * 20),
		Color("333333"), 3.0)
