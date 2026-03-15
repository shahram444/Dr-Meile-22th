extends Node

# ══════════════════════════════════════════════════════════════════════
#  DRAW UTILS — Professional Pixel Art Drawing Toolkit
#  Provides reusable drawing primitives for all scenes.
# ══════════════════════════════════════════════════════════════════════

# ── COLOR PALETTE ──────────────────────────────────────────────────
# Carefully chosen limited palette for cohesive retro look

# Skin tones (warm, natural)
const SKIN_LIGHT  := Color("fde4c8")
const SKIN        := Color("f2c5a0")
const SKIN_MID    := Color("d9a87c")
const SKIN_DARK   := Color("bf8a5e")
const SKIN_SHADOW := Color("8c6239")

# Hair (distinguished grey)
const HAIR_LIGHT  := Color("c8c8d2")
const HAIR        := Color("a8a8b4")
const HAIR_MID    := Color("8e8e9a")
const HAIR_DARK   := Color("6a6a76")
const HAIR_SHADOW := Color("4a4a56")

# Shirt (light blue pinstripe)
const SHIRT_LIGHT := Color("d8e8f4")
const SHIRT       := Color("b0c8e0")
const SHIRT_MID   := Color("90aed0")
const SHIRT_DARK  := Color("6888b0")

# UGA colors
const UGA_RED      := Color("ba0c2f")
const UGA_RED_DARK := Color("8a0820")
const UGA_BLACK    := Color("000000")

# Gold / accents
const GOLD       := Color("ffd040")
const GOLD_DARK  := Color("c8a020")
const GOLD_LIGHT := Color("ffe880")

# Swiss
const SWISS_RED := Color("ff0000")

# Nature
const SKY_TOP    := Color("4888d0")
const SKY_MID    := Color("60a8e8")
const SKY_BOTTOM := Color("a0d4f8")
const GRASS_1    := Color("48a848")
const GRASS_2    := Color("389038")
const GRASS_3    := Color("287828")
const GRASS_4    := Color("68c068")
const WATER_1    := Color("2060a0")
const WATER_2    := Color("184880")

# Mountains
const MT_1    := Color("607080")
const MT_2    := Color("506070")
const MT_SNOW := Color("e8f0f8")

# Building materials
const WOOD       := Color("8b6914")
const WOOD_DARK  := Color("6b4e10")
const WOOD_LIGHT := Color("ab8934")
const STONE      := Color("909098")
const STONE_DARK := Color("686870")
const STONE_LT   := Color("b0b0b8")

# Misc
const COFFEE    := Color("6f4e37")
const COFFEE_LT := Color("9f7e57")
const PURE_WHITE := Color("f8f8f8")
const CREAM      := Color("fff8e8")
const DEEP_BLACK := Color("101018")

# ── DRAWING PRIMITIVES ─────────────────────────────────────────────

## Draw a filled rectangle
static func draw_px(canvas: CanvasItem, x: float, y: float, w: float, h: float, color: Color) -> void:
	canvas.draw_rect(Rect2(round(x), round(y), w, h), color)

## Draw a filled circle
static func draw_circle_px(canvas: CanvasItem, cx: float, cy: float, radius: float, color: Color) -> void:
	canvas.draw_circle(Vector2(cx, cy), radius, color)

## Draw a vertical gradient rectangle
static func draw_gradient_v(canvas: CanvasItem, x: float, y: float, w: float, h: float, c1: Color, c2: Color) -> void:
	for row in range(int(h)):
		var t := float(row) / maxf(h - 1, 1)
		canvas.draw_rect(Rect2(x, y + row, w, 1), c1.lerp(c2, t))

## Draw a horizontal gradient rectangle
static func draw_gradient_h(canvas: CanvasItem, x: float, y: float, w: float, h: float, c1: Color, c2: Color) -> void:
	for col in range(int(w)):
		var t := float(col) / maxf(w - 1, 1)
		canvas.draw_rect(Rect2(x + col, y, 1, h), c1.lerp(c2, t))

## Draw outlined rectangle
static func draw_outline_rect(canvas: CanvasItem, x: float, y: float, w: float, h: float, color: Color, width: float = 2.0) -> void:
	canvas.draw_rect(Rect2(x, y, w, h), color, false, width)

## Draw a rounded rectangle
static func draw_rounded_rect(canvas: CanvasItem, x: float, y: float, w: float, h: float, r: float, color: Color) -> void:
	# Simple approximation with corner circles + rects
	canvas.draw_rect(Rect2(x + r, y, w - 2*r, h), color)
	canvas.draw_rect(Rect2(x, y + r, w, h - 2*r), color)
	canvas.draw_circle(Vector2(x + r, y + r), r, color)
	canvas.draw_circle(Vector2(x + w - r, y + r), r, color)
	canvas.draw_circle(Vector2(x + r, y + h - r), r, color)
	canvas.draw_circle(Vector2(x + w - r, y + h - r), r, color)

# ── TEXT RENDERING ─────────────────────────────────────────────────

## Draw pixel-style title text with optional shadow
static func draw_title(canvas: CanvasItem, font: Font, text: String, x: float, y: float,
		size: int = 14, color: Color = GOLD, shadow: bool = true) -> void:
	if shadow:
		canvas.draw_string(font, Vector2(x + 2, y + 2), text, HORIZONTAL_ALIGNMENT_CENTER,
			-1, size, Color(0, 0, 0, 0.6))
	canvas.draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_CENTER,
		-1, size, color)

## Draw a dialog box with title and body text
static func draw_dialog_box(canvas: CanvasItem, font: Font, x: float, y: float, w: float, h: float,
		title: String, body: String, _frame: int = 0) -> void:
	# Background
	canvas.draw_rect(Rect2(x, y, w, h), Color(0, 0, 0.08, 0.92))
	# Gold border
	draw_outline_rect(canvas, x + 2, y + 2, w - 4, h - 4, GOLD, 3.0)
	# Inner border
	draw_outline_rect(canvas, x + 6, y + 6, w - 12, h - 12, GOLD_DARK, 1.0)
	# Corner gems
	for corner in [Vector2(x + 4, y + 4), Vector2(x + w - 10, y + 4),
			Vector2(x + 4, y + h - 10), Vector2(x + w - 10, y + h - 10)]:
		draw_px(canvas, corner.x, corner.y, 6, 6, GOLD)
		draw_px(canvas, corner.x + 1, corner.y + 1, 4, 4, GOLD_LIGHT)
		draw_px(canvas, corner.x + 2, corner.y + 2, 2, 2, PURE_WHITE)
	# Title text
	canvas.draw_string(font, Vector2(x + w / 2.0, y + 24), title,
		HORIZONTAL_ALIGNMENT_CENTER, -1, 10, PURE_WHITE)
	# Body text
	canvas.draw_string(font, Vector2(x + w / 2.0, y + 44), body,
		HORIZONTAL_ALIGNMENT_CENTER, -1, 8, GOLD_LIGHT)

## Draw a speech bubble with multiple lines
static func draw_bubble(canvas: CanvasItem, font: Font, x: float, y: float, lines: Array) -> void:
	var max_w := 0.0
	for line in lines:
		max_w = maxf(max_w, line.length() * 7.0 + 24)
	var h := lines.size() * 14.0 + 16
	# Bubble body
	draw_rounded_rect(canvas, x, y, max_w, h, 8, PURE_WHITE)
	draw_outline_rect(canvas, x, y, max_w, h, Color("404048"), 2.0)
	# Tail
	var points := PackedVector2Array([
		Vector2(x + 20, y + h), Vector2(x + 15, y + h + 12), Vector2(x + 30, y + h)
	])
	canvas.draw_colored_polygon(points, PURE_WHITE)
	# Lines
	for i in range(lines.size()):
		canvas.draw_string(font, Vector2(x + 12, y + 16 + i * 14), lines[i],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("202028"))

# ── RPG STAT BAR ──────────────────────────────────────────────────

static func draw_stat_bar(canvas: CanvasItem, font: Font, x: float, y: float, w: float,
		label: String, value: int, anim_value: float, color: Color) -> void:
	var fill := minf(value, anim_value) / 100.0
	# Label
	canvas.draw_string(font, Vector2(x, y), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("b0b0c0"))
	# Background bar
	draw_px(canvas, x + 140, y - 8, w, 12, Color("1a1a30"))
	draw_outline_rect(canvas, x + 140, y - 8, w, 12, Color("404060"), 1.0)
	# Fill bar
	if fill > 0:
		var fill_w: float = floor((w - 2) * fill)
		draw_gradient_v(canvas, x + 141, y - 7, fill_w, 10, color, Color(0, 0, 0))
		draw_px(canvas, x + 141, y - 7, fill_w, 3, Color(color, 0.25))
	# Value text
	canvas.draw_string(font, Vector2(x + 140 + w + 10, y), str(int(anim_value)),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 7, PURE_WHITE)
	if anim_value >= 95:
		canvas.draw_string(font, Vector2(x + 140 + w + 50, y), "MAX!",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 7, GOLD)

# ── SCANLINE / CRT EFFECT ─────────────────────────────────────────

static func draw_scanlines(canvas: CanvasItem, w: float, h: float) -> void:
	for y_line in range(0, int(h), 2):
		canvas.draw_rect(Rect2(0, y_line, w, 1), Color(0, 0, 0, 0.05))

static func draw_vignette(canvas: CanvasItem, w: float, h: float) -> void:
	# Approximate vignette with overlapping dark rects at edges
	for i in range(20):
		var alpha := 0.012 * float(i)
		var margin := float(20 - i) * maxf(w, h) * 0.02
		canvas.draw_rect(Rect2(0, 0, margin, h), Color(0, 0, 0, alpha))
		canvas.draw_rect(Rect2(w - margin, 0, margin, h), Color(0, 0, 0, alpha))
		canvas.draw_rect(Rect2(0, 0, w, margin), Color(0, 0, 0, alpha))
		canvas.draw_rect(Rect2(0, h - margin, w, margin), Color(0, 0, 0, alpha))

# ── PIXEL ART SPRITE FROM DATA ────────────────────────────────────
# Draws a sprite from a 2D array of color indices using a palette

static func draw_sprite_data(canvas: CanvasItem, ox: float, oy: float, scale: float,
		data: Array, palette: Array) -> void:
	for y_idx in range(data.size()):
		var row: Array = data[y_idx]
		for x_idx in range(row.size()):
			var idx: int = row[x_idx]
			if idx < 0:
				continue  # transparent
			if idx < palette.size():
				draw_px(canvas, ox + x_idx * scale, oy + y_idx * scale, scale, scale, palette[idx])

# ── SWISS FLAG ─────────────────────────────────────────────────────

static func draw_swiss_flag(canvas: CanvasItem, x: float, y: float, sz: float) -> void:
	draw_px(canvas, x, y, sz, sz, SWISS_RED)
	draw_px(canvas, x + sz * 0.375, y + sz * 0.125, sz * 0.25, sz * 0.75, PURE_WHITE)
	draw_px(canvas, x + sz * 0.125, y + sz * 0.375, sz * 0.75, sz * 0.25, PURE_WHITE)

# ── UGA ARCH ───────────────────────────────────────────────────────

static func draw_uga_arch(canvas: CanvasItem, x: float, y: float, sc: float) -> void:
	var s := sc
	# Left pillar
	draw_px(canvas, x, y + 30*s, 20*s, 80*s, STONE)
	# Right pillar
	draw_px(canvas, x + 80*s, y + 30*s, 20*s, 80*s, STONE)
	# Center pillar
	draw_px(canvas, x + 30*s, y + 30*s, 12*s, 80*s, STONE_DARK)
	# Top beam
	draw_px(canvas, x - 5*s, y + 15*s, 110*s, 18*s, STONE_LT)
	draw_px(canvas, x - 2*s, y + 8*s, 104*s, 10*s, STONE)
	# Iron bars
	for i in range(7):
		draw_px(canvas, x + (15 + i * 10)*s, y + 33*s, 2*s, 77*s, Color("282828"))
	# Cross bar
	draw_px(canvas, x + 12*s, y + 60*s, 78*s, 2*s, Color("282828"))
	# Top cap
	draw_px(canvas, x + 10*s, y + 5*s, 80*s, 5*s, STONE_DARK)

# ── PROGRESS BAR ───────────────────────────────────────────────────

static func draw_progress_bar(canvas: CanvasItem, progress: float, w: float, h: float) -> void:
	draw_px(canvas, 0, h - 3, w, 3, Color("222222"))
	draw_px(canvas, 0, h - 3, w * clampf(progress, 0, 1), 3, UGA_RED)
