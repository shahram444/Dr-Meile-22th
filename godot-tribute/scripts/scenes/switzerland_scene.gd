extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  SCENE 1: SWITZERLAND — ETH ZÜRICH (7-18s)
#  Beautiful Alpine landscape with walking Dr. Meile, ETH building,
#  Swiss chalet, and mountains with accurate geography.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0

var _local_time := 0.0
var _frame := 0
var _font: Font

# ── Detailed portrait pixel data ──
# Palette: 0=transparent, 1=skin, 2=skinMid, 3=skinDark, 4=skinShadow,
#   5=hairLight, 6=hair, 7=hairMid, 8=hairDark, 9=white, 10=black,
#   11=shirtLight, 12=shirt, 13=shirtMid, 14=eyeBrown, 15=lip, 16=teeth
const BODY_PALETTE := [
	Color.TRANSPARENT,        # 0
	Color("f2c5a0"),           # 1 skin
	Color("d9a87c"),           # 2 skinMid
	Color("bf8a5e"),           # 3 skinDark
	Color("8c6239"),           # 4 skinShadow
	Color("c8c8d2"),           # 5 hairLight
	Color("a8a8b4"),           # 6 hair
	Color("8e8e9a"),           # 7 hairMid
	Color("6a6a76"),           # 8 hairDark
	Color("f8f8f8"),           # 9 white
	Color("101018"),           # 10 black
	Color("d8e8f4"),           # 11 shirtLight
	Color("b0c8e0"),           # 12 shirt
	Color("90aed0"),           # 13 shirtMid
	Color("5c4830"),           # 14 eyeBrown
	Color("c08070"),           # 15 lip
	Color("f0f0f0"),           # 16 teeth
	Color("4a4a58"),           # 17 pants
	Color("3a2a1a"),           # 18 shoes
]

# Walking sprite: 28 wide x 52 tall
# Simplified but more detailed than the HTML version
const BODY_DATA := [
	# Hair top (rows 0-7)
	[0,0,0,0,0,0,0,0,5,6,7,5,6,7,5,6,7,5,6,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,5,6,7,5,6,7,8,5,6,7,5,6,7,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,5,6,7,5,6,7,8,6,5,7,5,6,7,5,6,0,0,0,0,0,0,0],
	[0,0,0,0,0,5,6,7,5,6,7,8,6,5,7,5,6,7,5,6,7,5,0,0,0,0,0,0],
	[0,0,0,0,0,6,7,5,6,7,8,6,5,7,5,6,7,8,6,5,7,6,0,0,0,0,0,0],
	[0,0,0,0,0,7,5,6,7,5,6,7,8,6,5,7,5,6,7,8,6,7,0,0,0,0,0,0],
	[0,0,0,0,0,8,6,7,5,6,7,8,6,5,7,5,6,7,5,6,7,8,0,0,0,0,0,0],
	[0,0,0,0,0,8,7,5,6,7,8,6,5,7,5,6,7,8,5,6,7,8,0,0,0,0,0,0],
	# Face (rows 8-19)
	[0,0,0,0,0,8,7,1,1,1,1,1,1,1,1,1,1,1,1,1,7,8,0,0,0,0,0,0],
	[0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,2,9,9,14,9,1,1,1,1,9,9,14,9,2,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,2,9,10,10,9,1,1,1,1,9,10,10,9,2,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,1,1,1,1,1,1,3,3,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,1,1,1,1,1,1,3,4,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,2,1,1,15,15,15,15,15,15,15,1,1,2,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,2,1,1,1,16,16,16,16,16,1,1,1,2,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,2,1,1,15,15,15,15,15,1,1,2,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,2,2,1,1,1,1,1,2,2,0,0,0,0,0,0,0,0,0,0,0],
	# Neck (rows 20-21)
	[0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0],
	# Shirt (rows 22-35)
	[0,0,0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0,0],
	[0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0],
	[0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0],
	[0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0],
	[0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0],
	[0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0],
	[0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0],
	[0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0],
	[0,0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,13,12,11,12,11,12,11,12,11,12,11,12,11,12,13,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,12,11,12,11,12,11,12,11,12,11,12,11,12,0,0,0,0,0,0,0,0,0],
	# Pants (rows 36-43)
	[0,0,0,0,0,0,0,17,17,17,17,17,17,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,17,17,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,0,17,17,17,17,0,0,17,17,17,17,17,0,0,0,0,0,0,0,0,0,0],
	# Shoes (rows 44-46)
	[0,0,0,0,0,0,18,18,18,18,18,0,0,18,18,18,18,18,0,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,18,18,18,18,18,0,0,18,18,18,18,18,18,0,0,0,0,0,0,0,0,0],
	[0,0,0,0,0,0,18,18,18,18,18,0,0,18,18,18,18,18,18,0,0,0,0,0,0,0,0,0],
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
	DrawUtils.draw_gradient_v(self, 0, 0, W, H * 0.6, DrawUtils.SKY_TOP, DrawUtils.SKY_BOTTOM)

	# Clouds
	_draw_clouds(t)

	# Alps (accurate mountain range)
	_draw_alps(240)

	# Meadow
	_draw_meadow(340)

	# Swiss chalet
	if t > 0.5:
		_draw_chalet(620, 260)

	# ETH Zürich building
	if t > 3.0:
		var eth_alpha := clampf((t - 3.0) / 1.0, 0, 1)
		_draw_eth_building(50, 270, eth_alpha)

	# Walking Dr. Meile
	var walk_x: float
	if t < 4.0:
		walk_x = 100 + t * 60
	else:
		walk_x = 340 + minf(t - 4.0, 4.0) * 50
	_draw_walking_body(walk_x, 250, 3.0, f)

	# Swiss flag on pole
	DrawUtils.draw_px(self, 580, 240, 3, 100, DrawUtils.WOOD_DARK)
	DrawUtils.draw_swiss_flag(self, 583, 240, 30)

	# Dialog boxes with longer display times
	if t < 4.0:
		DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 20, 400, 60,
			"ZURICH, SWITZERLAND", "Our hero begins his quest...", f)
	elif t < 7.0:
		DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 20, 400, 60,
			"1996: ETH ZURICH", "Dipl. Nat.wiss. EARNED!", f)
	else:
		DrawUtils.draw_dialog_box(self, _font, W / 2 - 200, 20, 400, 60,
			"THE QUEST FOR KNOWLEDGE", "Next destination: AMERICA! >>>", f)

func _draw_clouds(t: float) -> void:
	for i in range(5):
		var cx := fmod(float(i) * 220 + t * 20, 1200) - 120
		var cy := 40.0 + i * 30 + sin(i * 2.0) * 20
		DrawUtils.draw_circle_px(self, cx, cy, 25.0 + i * 5, Color(1, 1, 1, 0.5))
		DrawUtils.draw_circle_px(self, cx + 20, cy - 5, 20.0 + i * 3, Color(1, 1, 1, 0.4))
		DrawUtils.draw_circle_px(self, cx - 15, cy + 3, 18.0 + i * 2, Color(1, 1, 1, 0.35))

func _draw_alps(y_base: float) -> void:
	# Far mountains
	var far_peaks := [
		Vector2(80, y_base - 120), Vector2(200, y_base - 80), Vector2(340, y_base - 160),
		Vector2(480, y_base - 90), Vector2(600, y_base - 140), Vector2(750, y_base - 100),
		Vector2(900, y_base - 130), Vector2(960, y_base - 60)
	]
	var far_points := PackedVector2Array([Vector2(0, y_base)])
	far_points.append_array(far_peaks)
	far_points.append(Vector2(W, y_base))
	draw_colored_polygon(far_points, DrawUtils.MT_2)

	# Near mountains
	var near_peaks := [
		Vector2(100, y_base - 60), Vector2(250, y_base - 30), Vector2(400, y_base - 80),
		Vector2(550, y_base - 40), Vector2(700, y_base - 70), Vector2(850, y_base - 30),
		Vector2(960, y_base)
	]
	var near_points := PackedVector2Array([Vector2(0, y_base + 20)])
	near_points.append_array(near_peaks)
	near_points.append(Vector2(W, y_base + 20))
	draw_colored_polygon(near_points, DrawUtils.MT_1)

	# Snow caps on the tallest peaks
	var snow_peaks := [
		[340, y_base - 160, 30], [600, y_base - 140, 25],
		[900, y_base - 130, 20], [80, y_base - 120, 18]
	]
	for sp in snow_peaks:
		var pts := PackedVector2Array([
			Vector2(sp[0] - sp[2], sp[1] + sp[2] * 0.6),
			Vector2(sp[0], sp[1]),
			Vector2(sp[0] + sp[2], sp[1] + sp[2] * 0.6)
		])
		draw_colored_polygon(pts, DrawUtils.MT_SNOW)

func _draw_meadow(y_base: float) -> void:
	DrawUtils.draw_gradient_v(self, 0, y_base, W, H - y_base, DrawUtils.GRASS_1, DrawUtils.GRASS_3)
	# Grass blades
	for x in range(0, int(W), 6):
		var h := 4.0 + sin(x * 0.3) * 2.0
		DrawUtils.draw_px(self, x, y_base - h, 3, h + 2, DrawUtils.GRASS_4)
	# Flowers
	var flower_colors := [Color("f8e040"), Color("f060a0"), Color("f0f0f8"), Color("a060f0")]
	for i in range(20):
		var fx := fmod(float(i) * 97, W)
		var fy := y_base + 20 + fmod(float(i) * 53, 80)
		DrawUtils.draw_px(self, fx, fy, 3, 3, flower_colors[i % 4])

func _draw_chalet(x: float, y: float) -> void:
	# Main building
	DrawUtils.draw_px(self, x, y, 120, 80, DrawUtils.WOOD)
	DrawUtils.draw_px(self, x, y, 120, 8, DrawUtils.WOOD_DARK)
	# Roof (triangle)
	var roof := PackedVector2Array([
		Vector2(x - 10, y), Vector2(x + 60, y - 40), Vector2(x + 130, y)
	])
	draw_colored_polygon(roof, DrawUtils.WOOD_DARK)
	# Windows
	DrawUtils.draw_px(self, x + 20, y + 20, 20, 20, DrawUtils.SKY_BOTTOM)
	DrawUtils.draw_px(self, x + 29, y + 20, 2, 20, DrawUtils.WOOD_DARK)
	DrawUtils.draw_px(self, x + 20, y + 29, 20, 2, DrawUtils.WOOD_DARK)
	DrawUtils.draw_px(self, x + 80, y + 20, 20, 20, DrawUtils.SKY_BOTTOM)
	DrawUtils.draw_px(self, x + 89, y + 20, 2, 20, DrawUtils.WOOD_DARK)
	DrawUtils.draw_px(self, x + 80, y + 29, 20, 2, DrawUtils.WOOD_DARK)
	# Door
	DrawUtils.draw_px(self, x + 45, y + 40, 20, 40, DrawUtils.WOOD_DARK)

func _draw_eth_building(x: float, y: float, alpha: float) -> void:
	if alpha < 0.01:
		return
	# ETH main building
	DrawUtils.draw_px(self, x, y, 180, 70, Color(0.85, 0.82, 0.75, alpha))
	DrawUtils.draw_px(self, x, y - 8, 180, 10, Color(0.75, 0.72, 0.66, alpha))
	# Columns
	for i in range(6):
		DrawUtils.draw_px(self, x + 12 + i * 28, y + 5, 8, 60, Color(0.72, 0.69, 0.63, alpha))
		DrawUtils.draw_px(self, x + 14 + i * 28, y + 5, 4, 55, Color(0.78, 0.75, 0.69, alpha))
	# Dome
	DrawUtils.draw_circle_px(self, x + 90, y - 8, 25, Color(0.66, 0.62, 0.58, alpha))
	DrawUtils.draw_circle_px(self, x + 90, y - 8, 20, Color(0.75, 0.72, 0.66, alpha))
	# Label
	draw_string(_font, Vector2(x + 90, y + 85), "ETH ZURICH",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color(0.37, 0.37, 0.31, alpha))

func _draw_walking_body(ox: float, oy: float, sc: float, f: int) -> void:
	# Animate legs with frame
	var leg_offset := sin(f * 0.15) * 2.0 * sc
	DrawUtils.draw_sprite_data(self, ox, oy, sc, BODY_DATA, BODY_PALETTE)
	# Simple arm swing
	var arm_swing := sin(f * 0.15) * 3.0 * sc
	# Left arm
	DrawUtils.draw_px(self, ox + 3 * sc, oy + (24 + arm_swing) * sc, sc * 2, sc * 8, DrawUtils.SHIRT_MID)
	DrawUtils.draw_px(self, ox + 3 * sc, oy + (32 + arm_swing) * sc, sc * 2, sc * 2, DrawUtils.SKIN)
	# Right arm
	DrawUtils.draw_px(self, ox + 23 * sc, oy + (24 - arm_swing) * sc, sc * 2, sc * 8, DrawUtils.SHIRT_MID)
	DrawUtils.draw_px(self, ox + 23 * sc, oy + (32 - arm_swing) * sc, sc * 2, sc * 2, DrawUtils.SKIN)
