extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 7: FINALE WITH CREDITS (84-100s)
#  Large portrait, "Thank You Dr. Meile!", scrolling credits,
#  flags, and confetti celebration.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

# Scrolling credit lines
const CREDITS := [
	"22 YEARS OF INSPIRING",
	"MARINE SCIENCE AT UGA",
	"",
	"FROM ZURICH TO ATHENS, GA",
	"A JOURNEY OF DISCOVERY",
	"",
	"SKILLS MASTERED:",
	"* Reactive Transport Modeling",
	"* Biogeochemical Cycling",
	"* Microbial Metabolism",
	"* Being an Amazing Mentor",
	"* Coffee Consumption (LEGENDARY)",
	"* Frozen Food Connoisseurship",
	"* Lattice Boltzmann Methods",
	"",
	"WITH GRATITUDE FROM",
	"THE MEILE LAB FAMILY",
	"",
	"DANKE SCHON, PROFESSOR!",
	"THANK YOU!",
	"",
	"GO DAWGS!",
	"",
	"————————————————————————",
	"Made with love by the Meile Lab",
	"University of Georgia  2025",
]

const CONFETTI_COLORS := [
	Color("ba0c2f"), Color("ffd040"), Color("f8f8f8"),
	Color("48a848"), Color("4080e0"), Color("ff0000"),
]

# Portrait data (same as stats scene)
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

	# Deep space background
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, Color("04040e"), Color("0a0a28"))

	# Nebula glow
	DrawUtils.draw_circle_px(self, W * 0.3, H * 0.4, 200, Color(0.25, 0.12, 0.62, 0.08))
	DrawUtils.draw_circle_px(self, W * 0.7, H * 0.6, 180, Color(0.62, 0.12, 0.37, 0.06))

	# Stars
	for i in range(150):
		var sx := fmod(float(i) * 173.7 + f * (1.0 + fmod(i, 3)) * 0.15, W)
		var sy := fmod(float(i) * 97.3 + f * fmod(i, 2) * 0.05, H)
		var brightness := 0.4 + sin(f * 0.04 + i * 0.7) * 0.4
		if brightness > 0.2:
			draw_rect(Rect2(sx, sy, 1, 1),
				Color(1, 1, 0.85 + fmod(i, 56) / 200.0, brightness))

	# Portrait (visible in first 5 seconds, then fades)
	if t < 5.0:
		DrawUtils.draw_sprite_data(self, W / 2 - 80, 80, 5, PORTRAIT_DATA, PORTRAIT_PALETTE)

	# "THANK YOU" text
	if t > 2.0:
		var alpha := clampf((t - 2.0) * 0.5, 0, 1)
		# Shadow
		draw_string(_font, Vector2(W / 2 + 3, 43), "THANK YOU",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(0, 0, 0, 0.6 * alpha))
		draw_string(_font, Vector2(W / 2, 40), "THANK YOU",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(DrawUtils.GOLD, alpha))
		# "DR. MEILE!"
		draw_string(_font, Vector2(W / 2 + 3, 73), "DR. MEILE!",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(0, 0, 0, 0.6 * alpha))
		draw_string(_font, Vector2(W / 2, 70), "DR. MEILE!",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color(DrawUtils.UGA_RED, alpha))

	# Scrolling credits
	if t > 4.0:
		var credit_y := H - (t - 4.0) * 15.0
		for i in range(CREDITS.size()):
			var line_y := credit_y + i * 20
			if line_y > 85 and line_y < H - 10:
				var line: String = CREDITS[i]
				var color := DrawUtils.PURE_WHITE
				if line.begins_with("*"):
					color = DrawUtils.GOLD
				elif "DANKE" in line or "THANK" in line:
					color = DrawUtils.UGA_RED
				elif "————" in line:
					color = Color("444444")
				draw_string(_font, Vector2(W / 2, line_y), line,
					HORIZONTAL_ALIGNMENT_CENTER, -1, 8, color)

	# Flags in bottom corners
	if t > 3.0:
		DrawUtils.draw_swiss_flag(self, 20, H - 55, 28)
		# UGA emblem
		DrawUtils.draw_circle_px(self, W - 35, H - 40, 14, DrawUtils.UGA_RED)
		DrawUtils.draw_circle_px(self, W - 35, H - 40, 10, DrawUtils.DEEP_BLACK)
		DrawUtils.draw_px(self, W - 35, H - 46, 14, 6, DrawUtils.UGA_RED)

	# Confetti celebration
	if t > 6.0:
		for i in range(60):
			var cx := fmod(float(i) * 37 + f * 2, W)
			var cy := fmod(float(f) * 1.5 + i * 23, H)
			var sz := 2.0 + sin(f * 0.1 + i) * 2.0
			DrawUtils.draw_px(self, cx, cy, sz, sz, CONFETTI_COLORS[i % 6])
