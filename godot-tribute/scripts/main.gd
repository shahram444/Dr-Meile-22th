extends Node2D
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  MAIN SCENE MANAGER
#  Controls scene flow, transitions, timing, and the overlay screen.
# ══════════════════════════════════════════════════════════════════════

const W := 960.0
const H := 540.0
const TOTAL_DURATION := 100.0  # seconds — longer so text is readable

# Scene timing: [start_time, end_time]
# Longer durations so everything is readable
const SCENE_TIMES := [
	[0.0, 7.0],      # 0: Title
	[7.0, 18.0],     # 1: Switzerland
	[18.0, 32.0],    # 2: World Map
	[32.0, 44.0],    # 3: Research Lab
	[44.0, 64.0],    # 4: Comedy (4 sub-scenes, 5s each)
	[64.0, 74.0],    # 5: RPG Stats
	[74.0, 84.0],    # 6: UGA Campus
	[84.0, 100.0],   # 7: Finale
]

var _elapsed := 0.0
var _frame := 0
var _playing := false
var _overlay_visible := true
var _font: Font
var _scenes: Array = []  # Child scene nodes
var _current_scene_idx := -1

# ── Video Recording ──
var _recording := false
var _record_frame_idx := 0
var _record_dir := "user://recording"
var _auto_start := false  # Set true when using --write-movie or recording mode

func _ready() -> void:
	# Load pixel font
	_font = ThemeDB.fallback_font

	# Check if launched with --record or --auto-start argument
	for arg in OS.get_cmdline_args():
		if arg == "--record":
			_recording = true
			_auto_start = true
		if arg == "--auto-start" or arg == "--auto_start":
			_auto_start = true

	# When using Godot's built-in --write-movie, auto-start so it captures
	if OS.has_feature("movie"):
		_auto_start = true

	# Add scene nodes
	var scene_scripts := [
		preload("res://scripts/scenes/title_scene.gd"),
		preload("res://scripts/scenes/switzerland_scene.gd"),
		preload("res://scripts/scenes/world_map_scene.gd"),
		preload("res://scripts/scenes/lab_scene.gd"),
		preload("res://scripts/scenes/comedy_scene.gd"),
		preload("res://scripts/scenes/stats_scene.gd"),
		preload("res://scripts/scenes/campus_scene.gd"),
		preload("res://scripts/scenes/finale_scene.gd"),
	]
	for i in range(scene_scripts.size()):
		var node := Node2D.new()
		node.set_script(scene_scripts[i])
		node.name = "Scene_%d" % i
		node.visible = false
		node.set_meta("font", _font)
		add_child(node)
		_scenes.append(node)

	# Create recording directory if needed
	if _recording:
		DirAccess.make_dir_recursive_absolute(_record_dir)
		print("[RECORD] Saving frames to: ", ProjectSettings.globalize_path(_record_dir))

	# Auto-start playback (for recording / movie mode)
	if _auto_start:
		call_deferred("_start_playback")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if _overlay_visible:
			_start_playback()
		elif not _playing:
			# Replay
			_start_playback()

func _start_playback() -> void:
	_overlay_visible = false
	_playing = true
	_elapsed = 0.0
	_frame = 0
	_current_scene_idx = -1
	MusicPlayer.play_soundtrack()
	queue_redraw()

func _process(delta: float) -> void:
	if not _playing:
		if _overlay_visible:
			_frame += 1
			queue_redraw()
		return

	_elapsed += delta
	_frame = int(_elapsed * 30.0)

	# Check which scene we're in
	var new_scene_idx := _get_scene_index(_elapsed)
	if new_scene_idx != _current_scene_idx:
		# Hide old scene
		if _current_scene_idx >= 0 and _current_scene_idx < _scenes.size():
			_scenes[_current_scene_idx].visible = false
		# Show new scene
		_current_scene_idx = new_scene_idx
		if _current_scene_idx >= 0 and _current_scene_idx < _scenes.size():
			_scenes[_current_scene_idx].visible = true
			if _scenes[_current_scene_idx].has_method("enter_scene"):
				_scenes[_current_scene_idx].call("enter_scene")

	# Update current scene
	if _current_scene_idx >= 0 and _current_scene_idx < _scenes.size():
		var scene_start: float = SCENE_TIMES[_current_scene_idx][0]
		var local_time := _elapsed - scene_start
		if _scenes[_current_scene_idx].has_method("update_scene"):
			_scenes[_current_scene_idx].call("update_scene", local_time, _frame)
		_scenes[_current_scene_idx].queue_redraw()

	# Check if done
	if _elapsed >= TOTAL_DURATION:
		_playing = false
		MusicPlayer.stop_soundtrack()
		for s in _scenes:
			s.visible = false
		_current_scene_idx = -1

		if _recording or _auto_start:
			# When recording, quit after playback finishes
			print("[RECORD] Recording complete. %d frames captured." % _record_frame_idx)
			get_tree().quit()
			return
		else:
			_overlay_visible = true

	queue_redraw()

	# Capture frame after rendering (at end of process so draw is done)
	if _recording and _playing:
		# We capture on the next frame via RenderingServer
		await RenderingServer.frame_post_draw
		_capture_frame()

func _get_scene_index(t: float) -> int:
	for i in range(SCENE_TIMES.size()):
		if t >= SCENE_TIMES[i][0] and t < SCENE_TIMES[i][1]:
			return i
	return SCENE_TIMES.size() - 1

func _draw() -> void:
	if _overlay_visible:
		_draw_overlay()
		return

	# Draw transition fades
	if _current_scene_idx >= 0:
		var scene_start: float = SCENE_TIMES[_current_scene_idx][0]
		var scene_end: float = SCENE_TIMES[_current_scene_idx][1]
		var fade_in := clampf((_elapsed - scene_start) / 0.5, 0, 1)
		var fade_out := clampf((scene_end - _elapsed) / 0.5, 0, 1)
		var alpha := 1.0 - minf(fade_in, fade_out)
		if alpha > 0.01:
			draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, alpha * 0.8))

	# Scanlines and vignette (drawn on top)
	DrawUtils.draw_scanlines(self, W, H)
	DrawUtils.draw_vignette(self, W, H)

	# Progress bar
	DrawUtils.draw_progress_bar(self, _elapsed / TOTAL_DURATION, W, H)

func _draw_overlay() -> void:
	# Dark starfield background
	DrawUtils.draw_gradient_v(self, 0, 0, W, H, Color("04040e"), Color("0a0a28"))

	# Stars
	for i in range(100):
		var sx := fmod(float(i) * 173.7 + _frame * (1.0 + fmod(i, 3)) * 0.15, W)
		var sy := fmod(float(i) * 97.3 + _frame * fmod(i, 2) * 0.05, H)
		var brightness := 0.4 + sin(_frame * 0.04 + i * 0.7) * 0.4
		if brightness > 0.1:
			draw_rect(Rect2(sx, sy, 1, 1), Color(1, 1, 0.9, brightness))

	# Title
	var pulse := 1.0 + sin(_frame * 0.06) * 0.02
	draw_string(_font, Vector2(W / 2, 140), "THE LEGEND OF",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 16, DrawUtils.GOLD)

	# "MEILE" in large text
	draw_string(_font, Vector2(W / 2 + 3, 198), "MEILE",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 42, Color("400818"))
	draw_string(_font, Vector2(W / 2, 195), "MEILE",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 42, DrawUtils.UGA_RED)

	# Subtitle
	draw_string(_font, Vector2(W / 2, 240), "22 YEARS AT UGA",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 12, DrawUtils.GOLD_LIGHT)
	draw_string(_font, Vector2(W / 2, 265), "2003 — 2025",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color("8888a0"))

	# Flags
	DrawUtils.draw_swiss_flag(self, W / 2 - 80, 290, 28)
	# UGA bulldog silhouette (simple)
	DrawUtils.draw_circle_px(self, W / 2 + 65, 304, 14, DrawUtils.UGA_RED)
	DrawUtils.draw_circle_px(self, W / 2 + 65, 304, 10, DrawUtils.DEEP_BLACK)

	# Subtitle
	draw_string(_font, Vector2(W / 2, 370), "A 16-BIT TRIBUTE",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color("606080"))

	# Bottom bar
	DrawUtils.draw_px(self, 0, H - 40, W, 40, Color(DrawUtils.UGA_RED, 0.85))
	DrawUtils.draw_px(self, 0, H - 42, W, 3, DrawUtils.GOLD)
	draw_string(_font, Vector2(W / 2, H - 16), "FROM THE MEILE LAB WITH LOVE",
		HORIZONTAL_ALIGNMENT_CENTER, -1, 8, DrawUtils.PURE_WHITE)

	# Blinking "CLICK TO START"
	if fmod(_frame, 60) < 30:
		draw_string(_font, Vector2(W / 2, 420), "CLICK TO START",
			HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("aaaaaa"))

# ── VIDEO RECORDING ─────────────────────────────────────────────────

func _capture_frame() -> void:
	var image := get_viewport().get_texture().get_image()
	if image == null:
		return
	var filename := "%s/frame_%05d.png" % [_record_dir, _record_frame_idx]
	image.save_png(filename)
	_record_frame_idx += 1
	if _record_frame_idx % 30 == 0:
		print("[RECORD] Captured frame %d (%.1fs)" % [_record_frame_idx, _elapsed])
