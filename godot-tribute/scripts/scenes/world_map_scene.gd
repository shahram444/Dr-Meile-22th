extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 2: WORLD MAP JOURNEY (18-32s)
#  Geographically accurate world map showing Dr. Meile's academic path:
#  ETH Zürich → Georgia Tech → Utrecht → UGA
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

# Location data: {name, map_x, map_y, label, color, appear_time}
var _locations := [
	{"name": "ETH Zürich", "x": 530, "y": 155, "label": "ETH ZURICH 1996",
	 "color": Color("ff0000"), "time": 0.5, "detail": "Dipl. Nat.wiss."},
	{"name": "Georgia Tech", "x": 210, "y": 195, "label": "GEORGIA TECH 1999",
	 "color": Color("b3a369"), "time": 3.5, "detail": "M.Sc."},
	{"name": "Utrecht", "x": 520, "y": 142, "label": "UTRECHT 2003",
	 "color": Color("ff6600"), "time": 6.5, "detail": "Ph.D."},
	{"name": "UGA Athens", "x": 215, "y": 200, "label": "UGA PROFESSOR 2003",
	 "color": Color("ba0c2f"), "time": 9.5, "detail": "22 Years!"},
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

	# Ocean background with subtle wave animation
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, DrawUtils.WATER_2, DrawUtils.WATER_1)
	# Animated water lines
	for y_line in range(0, int(H), 6):
		var wave_offset := sin(y_line * 0.02 + f * 0.02) * 8
		draw_rect(Rect2(wave_offset, y_line, W, 2), Color(0.15, 0.4, 0.6, 0.15))

	# Draw continents with proper geography
	_draw_continents()

	# Draw travel paths (dashed lines)
	_draw_travel_paths(t, f)

	# Draw location markers
	_draw_locations(t, f)

	# Draw character at current location
	_draw_character(t, f)

	# Achievement banners
	_draw_achievements(t, f)

	# XP progress bar
	_draw_xp_bar(t)

func _draw_continents() -> void:
	var land_color := Color("4a7a4a")
	var land_light := Color("5a8a5a")

	# ── EUROPE ──
	# British Isles
	_draw_land_mass([Vector2(490, 115), Vector2(495, 105), Vector2(502, 108),
		Vector2(500, 120), Vector2(493, 122)], land_color)
	# Scandinavia
	_draw_land_mass([Vector2(530, 60), Vector2(545, 50), Vector2(555, 55),
		Vector2(550, 80), Vector2(540, 95), Vector2(528, 85)], land_color)
	# Main Europe
	_draw_land_mass([Vector2(500, 125), Vector2(520, 120), Vector2(545, 115),
		Vector2(565, 118), Vector2(575, 130), Vector2(570, 145), Vector2(555, 155),
		Vector2(545, 165), Vector2(530, 170), Vector2(515, 165), Vector2(505, 155),
		Vector2(495, 140)], land_light)
	# Iberian Peninsula
	_draw_land_mass([Vector2(485, 145), Vector2(505, 140), Vector2(510, 155),
		Vector2(505, 170), Vector2(490, 175), Vector2(480, 165)], land_color)
	# Italy
	_draw_land_mass([Vector2(530, 155), Vector2(538, 150), Vector2(545, 165),
		Vector2(540, 180), Vector2(535, 185), Vector2(528, 175)], land_color)

	# ── AFRICA ──
	_draw_land_mass([Vector2(490, 190), Vector2(530, 185), Vector2(570, 195),
		Vector2(590, 220), Vector2(585, 260), Vector2(570, 310), Vector2(555, 340),
		Vector2(540, 360), Vector2(520, 350), Vector2(505, 310), Vector2(490, 270),
		Vector2(480, 230), Vector2(475, 200)], land_color)

	# ── NORTH AMERICA ──
	# Canada + USA
	_draw_land_mass([Vector2(80, 60), Vector2(140, 50), Vector2(200, 55),
		Vector2(260, 65), Vector2(290, 80), Vector2(300, 100), Vector2(290, 130),
		Vector2(280, 160), Vector2(260, 180), Vector2(240, 190), Vector2(220, 205),
		Vector2(200, 210), Vector2(170, 215), Vector2(140, 210), Vector2(120, 195),
		Vector2(100, 180), Vector2(80, 160), Vector2(65, 130), Vector2(60, 100),
		Vector2(65, 75)], land_light)
	# Florida peninsula
	_draw_land_mass([Vector2(210, 200), Vector2(225, 195), Vector2(235, 210),
		Vector2(230, 230), Vector2(218, 235), Vector2(208, 220)], land_color)
	# Mexico / Central America
	_draw_land_mass([Vector2(100, 195), Vector2(140, 210), Vector2(170, 220),
		Vector2(180, 235), Vector2(175, 250), Vector2(160, 255), Vector2(140, 245),
		Vector2(120, 235), Vector2(100, 220)], land_color)

	# ── SOUTH AMERICA ──
	_draw_land_mass([Vector2(195, 260), Vector2(225, 250), Vector2(250, 260),
		Vector2(270, 290), Vector2(265, 330), Vector2(255, 370), Vector2(240, 400),
		Vector2(225, 415), Vector2(210, 400), Vector2(195, 360), Vector2(185, 310),
		Vector2(183, 280)], land_color)

	# ── ASIA ──
	_draw_land_mass([Vector2(580, 60), Vector2(650, 55), Vector2(720, 65),
		Vector2(780, 80), Vector2(820, 100), Vector2(830, 130), Vector2(810, 155),
		Vector2(780, 170), Vector2(740, 175), Vector2(700, 170), Vector2(660, 160),
		Vector2(630, 145), Vector2(600, 130), Vector2(580, 110), Vector2(575, 80)], land_color)
	# India
	_draw_land_mass([Vector2(680, 175), Vector2(710, 170), Vector2(720, 200),
		Vector2(710, 240), Vector2(690, 250), Vector2(675, 230), Vector2(670, 200)], land_color)

	# ── AUSTRALIA ──
	_draw_land_mass([Vector2(760, 310), Vector2(810, 300), Vector2(850, 310),
		Vector2(860, 340), Vector2(845, 370), Vector2(820, 380), Vector2(790, 375),
		Vector2(770, 355), Vector2(755, 335)], land_color)

func _draw_land_mass(points: Array, color: Color) -> void:
	var packed := PackedVector2Array()
	for p in points:
		packed.append(p)
	if packed.size() >= 3:
		draw_colored_polygon(packed, color)

func _draw_travel_paths(t: float, f: int) -> void:
	# Draw dashed paths between locations
	var connections := [[0, 1], [1, 2], [2, 3]]
	for conn in connections:
		var to_loc: Dictionary = _locations[conn[1]]
		if t > to_loc.time - 1.0:
			var from_loc: Dictionary = _locations[conn[0]]
			var from_pos := Vector2(from_loc.x, from_loc.y)
			var to_pos := Vector2(to_loc.x, to_loc.y)
			# Curved path (bezier approximation with segments)
			var ctrl := (from_pos + to_pos) / 2.0 + Vector2(0, -60)
			var progress := clampf((t - (to_loc.time - 1.0)) / 1.0, 0, 1)
			var dash_count := 20
			for i in range(int(dash_count * progress)):
				var p := float(i) / dash_count
				var np := float(i + 1) / dash_count
				if i % 2 == 0:
					var p1 := _bezier(from_pos, ctrl, to_pos, p)
					var p2 := _bezier(from_pos, ctrl, to_pos, minf(np, progress))
					draw_line(p1, p2, DrawUtils.GOLD, 3.0)

func _bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var ab := a.lerp(b, t)
	var bc := b.lerp(c, t)
	return ab.lerp(bc, t)

func _draw_locations(t: float, f: int) -> void:
	for i in range(_locations.size()):
		var loc: Dictionary = _locations[i]
		if t > loc.time:
			var pos := Vector2(loc.x, loc.y)
			# Glowing dot
			var glow_r := 4.0 + sin(f * 0.08 + i) * 2.0
			DrawUtils.draw_circle_px(self, pos.x, pos.y, glow_r + 4, Color(loc.color, 0.3))
			DrawUtils.draw_circle_px(self, pos.x, pos.y, glow_r, loc.color)
			DrawUtils.draw_circle_px(self, pos.x, pos.y, 3, DrawUtils.PURE_WHITE)
			# Label
			draw_string(_font, Vector2(pos.x, pos.y - 14), loc.label,
				HORIZONTAL_ALIGNMENT_CENTER, -1, 6, DrawUtils.PURE_WHITE)

func _draw_character(t: float, f: int) -> void:
	# Place character at current location
	var current_idx := 0
	for i in range(_locations.size()):
		if t > _locations[i].time + 1.0:
			current_idx = i
	var loc: Dictionary = _locations[current_idx]
	# Simple walking body at location
	DrawUtils.draw_px(self, loc.x - 6, loc.y + 10, 12, 22, DrawUtils.SHIRT)
	DrawUtils.draw_circle_px(self, loc.x, loc.y + 5, 6, DrawUtils.SKIN)
	# Hair
	DrawUtils.draw_circle_px(self, loc.x, loc.y + 1, 5, DrawUtils.HAIR)

func _draw_achievements(t: float, f: int) -> void:
	# Achievement banners that stay longer
	var banners := [
		[3.5, 6.5, "M.Sc. UNLOCKED!", "Georgia Institute of Technology"],
		[6.5, 9.5, "Ph.D. UNLOCKED!", "Utrecht University, Netherlands"],
		[9.5, 13.0, "PROFESSOR MODE ACTIVATED!", "University of Georgia"],
	]
	for banner in banners:
		if t > banner[0] and t < banner[1]:
			var alpha := 1.0
			if t - banner[0] < 0.5:
				alpha = (t - banner[0]) / 0.5
			elif banner[1] - t < 0.5:
				alpha = (banner[1] - t) / 0.5
			DrawUtils.draw_px(self, W / 2 - 200, H - 70, 400, 55, Color(0.23, 0.17, 0, alpha * 0.95))
			DrawUtils.draw_outline_rect(self, W / 2 - 200, H - 70, 400, 55,
				Color(DrawUtils.GOLD, alpha), 2.0)
			draw_string(_font, Vector2(W / 2, H - 45), banner[2],
				HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(DrawUtils.PURE_WHITE, alpha))
			draw_string(_font, Vector2(W / 2, H - 28), banner[3],
				HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(DrawUtils.GOLD, alpha))

func _draw_xp_bar(t: float) -> void:
	var xp := clampf(t / 12.0, 0, 1)
	DrawUtils.draw_px(self, 20, 15, 300, 16, Color("0a0a28"))
	DrawUtils.draw_outline_rect(self, 20, 15, 300, 16, Color("404060"), 1.0)
	DrawUtils.draw_gradient_h(self, 22, 17, 296 * xp, 12, Color("40b040"), Color("208020"))
	draw_string(_font, Vector2(25, 28), "KNOWLEDGE  %d%%" % int(xp * 100),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 6, DrawUtils.PURE_WHITE)
	var level_text := "Lv.1" if xp < 0.3 else ("Lv.2" if xp < 0.6 else ("Lv.3" if xp < 0.9 else "Lv.MAX"))
	draw_string(_font, Vector2(W - 40, 28), level_text,
		HORIZONTAL_ALIGNMENT_RIGHT, -1, 6, DrawUtils.GOLD)
