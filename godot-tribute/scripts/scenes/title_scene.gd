extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 0: TITLE SCREEN (0-7s)
#  Starfield with animated title, sparkles, and dramatic entrance.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

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
	draw_rect(Rect2(0, 0, W, H), Color(0.25, 0.12, 0.62, 0.08))
	DrawUtils.draw_circle_px(self, W * 0.3, H * 0.4, 200, Color(0.25, 0.12, 0.62, 0.12))
	DrawUtils.draw_circle_px(self, W * 0.7, H * 0.3, 150, Color(0.62, 0.12, 0.37, 0.10))

	# Stars with twinkling
	for i in range(120):
		var sx := fmod(float(i) * 173.7 + f * (1.0 + fmod(i, 3)) * 0.15, W)
		var sy := fmod(float(i) * 97.3 + f * fmod(i, 2) * 0.05, H)
		var brightness := 0.4 + sin(f * 0.04 + i * 0.7) * 0.4
		if brightness > 0.2:
			var sz := 1.0 if fmod(i, 3) != 0 else 2.0
			draw_rect(Rect2(sx, sy, sz, sz),
				Color(1, 1, 0.85 + fmod(i, 56) / 200.0, brightness))

	# Shooting stars
	for i in range(8):
		var sx2 := fmod(float(i) * 251 + f * 0.3, W)
		var sy2 := fmod(float(i) * 167, H)
		var b := sin(f * 0.06 + i * 1.2)
		if b > 0.5:
			var alpha := b - 0.3
			draw_rect(Rect2(sx2 - 3, sy2, 7, 1), Color(1, 1, 1, alpha))
			draw_rect(Rect2(sx2, sy2 - 3, 1, 7), Color(1, 1, 1, alpha))

	# Fade-in effect
	var title_alpha := clampf(t / 2.0, 0, 1)

	# "THE LEGEND OF" subtitle
	if t > 0.5:
		var sub_alpha := clampf((t - 0.5) / 1.0, 0, 1)
		draw_string(_font, Vector2(W / 2, 140), "THE LEGEND OF",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 16,
			Color(DrawUtils.GOLD, sub_alpha))

	# "MEILE" main title with pulse
	if t > 1.0:
		var main_alpha := clampf((t - 1.0) / 1.0, 0, 1)
		# Shadow
		draw_string(_font, Vector2(W / 2 + 3, 198), "MEILE",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 42,
			Color(0.25, 0.03, 0.09, main_alpha * 0.8))
		# Main text
		draw_string(_font, Vector2(W / 2, 195), "MEILE",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 42,
			Color(DrawUtils.UGA_RED, main_alpha))

	# Subtitle
	if t > 2.0:
		var sub2_alpha := clampf((t - 2.0) / 1.0, 0, 1)
		draw_string(_font, Vector2(W / 2, 240), "22 YEARS AT THE UNIVERSITY OF GEORGIA",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 10,
			Color(DrawUtils.GOLD_LIGHT, sub2_alpha))
		draw_string(_font, Vector2(W / 2, 265), "2003 — 2025",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 9,
			Color(0.53, 0.53, 0.63, sub2_alpha))

	# Flags
	if t > 3.0:
		var flag_alpha := clampf((t - 3.0) / 0.5, 0, 1)
		modulate.a = flag_alpha
		DrawUtils.draw_swiss_flag(self, W / 2 - 80, 290, 28)
		# UGA emblem
		DrawUtils.draw_circle_px(self, W / 2 + 65, 304, 14, DrawUtils.UGA_RED)
		DrawUtils.draw_circle_px(self, W / 2 + 65, 304, 10, DrawUtils.DEEP_BLACK)
		DrawUtils.draw_px(self, W / 2 + 65, 298, 14, 6, DrawUtils.UGA_RED)
		modulate.a = 1.0

	# "A 16-BIT TRIBUTE"
	if t > 3.5:
		draw_string(_font, Vector2(W / 2, 370), "A 16-BIT TRIBUTE",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 9,
			Color(0.37, 0.37, 0.5, clampf((t - 3.5) / 1.0, 0, 1)))

	# Gold divider line
	if t > 3.0:
		DrawUtils.draw_gradient_h(self, W * 0.2, 340, W * 0.6, 2,
			DrawUtils.GOLD_DARK, DrawUtils.GOLD)

	# Bottom bar
	DrawUtils.draw_px(self, 0, H - 40, W, 40, Color(DrawUtils.UGA_RED, 0.85))
	DrawUtils.draw_px(self, 0, H - 42, W, 3, DrawUtils.GOLD)
	draw_string(_font, Vector2(W / 2, H - 16), "FROM THE MEILE LAB WITH LOVE",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 8, DrawUtils.PURE_WHITE)

	# Sparkle ring around title
	if t > 2.0:
		for i in range(8):
			var angle := f * 0.03 + i * PI / 4.0
			var r := 80.0 + sin(f * 0.05 + i) * 10.0
			var sx3 := W / 2.0 + cos(angle) * r * 1.5
			var sy3 := 190.0 + sin(angle) * r * 0.4
			var b2 := sin(f * 0.08 + i * 0.9)
			if b2 > 0.3:
				var sparkle_alpha := b2 * 0.6
				draw_rect(Rect2(sx3 - 1, sy3 - 4, 2, 8),
					Color(1, 0.86, 0.31, sparkle_alpha))
				draw_rect(Rect2(sx3 - 4, sy3 - 1, 8, 2),
					Color(1, 0.86, 0.31, sparkle_alpha))
