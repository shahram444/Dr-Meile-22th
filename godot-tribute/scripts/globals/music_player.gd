extends Node
@warning_ignore("inferred_declaration", "unsafe_property_access", "unsafe_method_access", "unsafe_cast", "unsafe_call_argument", "untyped_declaration", "integer_division")

# ══════════════════════════════════════════════════════════════════════
#  CHIPTUNE MUSIC ENGINE
#  Generates a beautiful multi-channel chiptune soundtrack using
#  AudioStreamGenerator. Four channels: Lead, Harmony, Bass, Drums.
# ══════════════════════════════════════════════════════════════════════

const SAMPLE_RATE := 44100.0
const BPM := 120.0
const BEAT_LEN := 60.0 / BPM  # seconds per beat

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _phase := 0.0
var _sample_idx := 0
var _playing := false

# Note frequencies (Hz)
const NOTES := {
	"C3": 130.81, "D3": 146.83, "Eb3": 155.56, "E3": 164.81, "F3": 174.61,
	"G3": 196.00, "Ab3": 207.65, "A3": 220.00, "Bb3": 233.08, "B3": 246.94,
	"C4": 261.63, "D4": 293.66, "Eb4": 311.13, "E4": 329.63, "F4": 349.23,
	"Fs4": 369.99, "G4": 392.00, "Ab4": 415.30, "A4": 440.00, "Bb4": 466.16,
	"B4": 493.88,
	"C5": 523.25, "D5": 587.33, "Eb5": 622.25, "E5": 659.25, "F5": 698.46,
	"G5": 783.99, "A5": 880.00, "B5": 987.77,
	"C6": 1046.50,
	"R": 0.0  # rest
}

# Song structure: array of sections, each section has tracks
# Each note: [note_name, start_beat, duration_beats]
var _song_data: Array = []
var _song_length_beats := 0.0

# Active voices for mixing
var _voices: Array = []  # [{freq, start_sample, end_sample, wave, vol, env}]

func _ready() -> void:
	_build_song()
	_player = AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = 0.5
	_player.stream = stream
	_player.bus = "Master"
	add_child(_player)

func play_soundtrack() -> void:
	if _playing:
		return
	_playing = true
	_sample_idx = 0
	_voices.clear()
	_schedule_all_notes()
	_player.play()
	_playback = _player.get_stream_playback()

func stop_soundtrack() -> void:
	_playing = false
	_player.stop()
	_voices.clear()

func _process(_delta: float) -> void:
	if not _playing or _playback == null:
		return
	_fill_buffer()

func _fill_buffer() -> void:
	var frames_available := _playback.get_frames_available()
	if frames_available <= 0:
		return

	for _i in range(frames_available):
		var sample := _mix_sample(_sample_idx)
		_playback.push_frame(Vector2(sample, sample))
		_sample_idx += 1

	# Check if song is done
	var elapsed_beats := float(_sample_idx) / SAMPLE_RATE / BEAT_LEN
	if elapsed_beats > _song_length_beats + 4.0:
		# Loop the song
		_sample_idx = 0
		_voices.clear()
		_schedule_all_notes()

func _mix_sample(idx: int) -> float:
	var out := 0.0
	var t := float(idx) / SAMPLE_RATE
	var to_remove := []

	for vi in range(_voices.size()):
		var v: Dictionary = _voices[vi]
		if idx < v.start_sample:
			continue
		if idx > v.end_sample:
			to_remove.append(vi)
			continue

		var local_t := float(idx - v.start_sample) / SAMPLE_RATE
		var dur := float(v.end_sample - v.start_sample) / SAMPLE_RATE
		var env := _envelope(local_t, dur, v.env)
		var wave_val := _wave(v.wave, v.freq, t)
		out += wave_val * env * v.vol

	# Remove expired voices (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		if to_remove[i] < _voices.size():
			_voices.remove_at(to_remove[i])

	# Soft clip
	out = clampf(out * 0.35, -0.8, 0.8)
	return out

func _wave(type: String, freq: float, t: float) -> float:
	if freq <= 0:
		return 0.0
	var phase := fmod(t * freq, 1.0)
	match type:
		"square":
			return 1.0 if phase < 0.5 else -1.0
		"pulse25":
			return 1.0 if phase < 0.25 else -1.0
		"triangle":
			return 4.0 * absf(phase - 0.5) - 1.0
		"sine":
			return sin(phase * TAU)
		"sawtooth":
			return 2.0 * phase - 1.0
		"noise":
			# Pseudo-random noise based on sample index
			var n := sin(t * freq * 6.283) * 43758.5453
			return fmod(n, 1.0) * 2.0 - 1.0
		_:
			return 0.0

func _envelope(local_t: float, dur: float, env_type: String) -> float:
	var t_norm := local_t / maxf(dur, 0.001)
	match env_type:
		"pluck":
			# Quick attack, exponential decay
			if local_t < 0.005:
				return local_t / 0.005
			return exp(-local_t * 6.0)
		"sustain":
			# Quick attack, sustain, fade out
			if local_t < 0.01:
				return local_t / 0.01
			if t_norm > 0.8:
				return (1.0 - t_norm) / 0.2
			return 1.0
		"soft":
			# Gentle attack and release
			if local_t < 0.05:
				return local_t / 0.05
			if t_norm > 0.7:
				return (1.0 - t_norm) / 0.3
			return 1.0
		"kick":
			return exp(-local_t * 25.0)
		"snare":
			return exp(-local_t * 18.0)
		"hat":
			return exp(-local_t * 40.0)
		_:
			return maxf(0.0, 1.0 - t_norm)

func _add_voice(freq: float, start_beat: float, dur_beats: float,
		wave: String = "square", vol: float = 0.15, env: String = "sustain") -> void:
	var start_s := int(start_beat * BEAT_LEN * SAMPLE_RATE)
	var end_s := int((start_beat + dur_beats) * BEAT_LEN * SAMPLE_RATE)
	_voices.append({
		"freq": freq, "start_sample": start_s, "end_sample": end_s,
		"wave": wave, "vol": vol, "env": env
	})

func _schedule_all_notes() -> void:
	for section in _song_data:
		for note_data in section:
			var freq: float = NOTES.get(note_data[0], 0.0)
			var start_beat: float = note_data[1]
			var dur_beats: float = note_data[2]
			var wave: String = note_data[3] if note_data.size() > 3 else "square"
			var vol: float = note_data[4] if note_data.size() > 4 else 0.15
			var env: String = note_data[5] if note_data.size() > 5 else "sustain"
			_add_voice(freq, start_beat, dur_beats, wave, vol, env)

func _build_song() -> void:
	# The song has 4 sections matching the emotional arc:
	# 1. INTRO (gentle, hopeful) — bars 0-16
	# 2. ADVENTURE (upbeat, driving) — bars 16-48
	# 3. WARMTH (emotional, slower) — bars 48-64
	# 4. FINALE (triumphant, grand) — bars 64-80+

	var lead: Array = []    # Main melody (square wave)
	var harmony: Array = [] # Counter-melody (pulse25 wave)
	var bass: Array = []    # Bass line (triangle wave)
	var drums: Array = []   # Percussion (noise)

	# ── SECTION 1: INTRO (Gentle, in C major) ──
	# Bars 0-16, gentle melody with arpeggiated feel
	# Lead melody
	var intro_melody := [
		["G4", 0, 2], ["C5", 2, 1], ["E5", 3, 1],
		["D5", 4, 3], ["C5", 7, 1],
		["E5", 8, 2], ["D5", 10, 1], ["C5", 11, 1],
		["B4", 12, 2], ["A4", 14, 2],
		# Repeat with variation
		["G4", 16, 2], ["C5", 18, 1], ["E5", 19, 1],
		["G5", 20, 2], ["E5", 22, 2],
		["D5", 24, 2], ["C5", 26, 1], ["B4", 27, 1],
		["C5", 28, 4],
		# Extension
		["E5", 32, 1], ["D5", 33, 1], ["C5", 34, 1], ["B4", 35, 1],
		["A4", 36, 2], ["G4", 38, 2],
		["A4", 40, 1], ["B4", 41, 1], ["C5", 42, 2],
		["D5", 44, 2], ["C5", 46, 1], ["B4", 47, 1],
		["C5", 48, 2], ["E5", 50, 2],
		["D5", 52, 3], ["C5", 55, 1],
		["B4", 56, 2], ["A4", 58, 1], ["G4", 59, 1],
		["A4", 60, 4],
	]
	for n in intro_melody:
		lead.append([n[0], n[1], n[2], "square", 0.12, "sustain"])
		# Subtle octave below
		var low_note := n[0].replace("5", "4").replace("4", "3")
		if NOTES.has(low_note):
			harmony.append([low_note, n[1], n[2], "triangle", 0.04, "soft"])

	# Bass for intro
	var intro_bass_notes := ["C3", "G3", "A3", "E3", "C3", "G3", "A3", "C3",
		"C3", "E3", "F3", "G3", "C3", "E3", "F3", "G3"]
	for i in range(intro_bass_notes.size()):
		bass.append([intro_bass_notes[i], i * 4, 3.5, "triangle", 0.14, "soft"])

	# Gentle drums for intro
	for i in range(64):
		if i % 4 == 0:
			drums.append(["C3", i, 0.3, "noise", 0.06, "kick"])
		if i % 4 == 2:
			drums.append(["A4", i, 0.15, "noise", 0.04, "hat"])

	# ── SECTION 2: ADVENTURE (Upbeat, driving) ──
	# Bars 16-48 (beats 64-192)
	var adv_offset := 64.0
	var adventure_melody := [
		["E4", 0, 1], ["G4", 1, 0.5], ["A4", 1.5, 0.5], ["B4", 2, 1], ["G4", 3, 1],
		["A4", 4, 1.5], ["G4", 5.5, 0.5], ["E4", 6, 2],
		["D4", 8, 1], ["E4", 9, 1], ["G4", 10, 2],
		["A4", 12, 2], ["G4", 14, 1], ["E4", 15, 1],
		# Second phrase
		["C5", 16, 1], ["B4", 17, 1], ["A4", 18, 1], ["G4", 19, 1],
		["E5", 20, 2], ["D5", 22, 2],
		["C5", 24, 2], ["B4", 26, 1], ["A4", 27, 1],
		["G4", 28, 4],
	]
	# Play adventure melody 4 times with variations
	for rep in range(4):
		var off := adv_offset + rep * 32
		for n in adventure_melody:
			lead.append([n[0], off + n[1], n[2], "square", 0.12, "sustain"])
			# Add harmony on repeats
			if rep >= 1:
				var h_note := _harmony_note(n[0])
				if h_note != "":
					harmony.append([h_note, off + n[1], n[2], "pulse25", 0.06, "sustain"])

	# Adventure bass (more driving)
	var adv_bass := ["C3", "A3", "F3", "G3", "C3", "E3", "F3", "G3"]
	for rep in range(4):
		for i in range(adv_bass.size()):
			var off := adv_offset + rep * 32 + i * 4
			bass.append([adv_bass[i], off, 1.5, "triangle", 0.16, "pluck"])
			bass.append([adv_bass[i], off + 2, 1.5, "triangle", 0.12, "pluck"])

	# Adventure drums (energetic)
	for i in range(128):
		var beat := adv_offset + i
		if i % 4 == 0:
			drums.append(["C3", beat, 0.25, "noise", 0.10, "kick"])
		if i % 4 == 2:
			drums.append(["E4", beat, 0.12, "noise", 0.08, "snare"])
		if i % 2 == 0:
			drums.append(["A5", beat + 0.5, 0.08, "noise", 0.04, "hat"])

	# ── SECTION 3: WARMTH (Emotional, slower feel) ──
	# Bars 48-64 (beats 192-256)
	var warm_offset := 192.0
	var warm_melody := [
		["C5", 0, 3], ["E5", 3, 1],
		["D5", 4, 2], ["C5", 6, 1], ["B4", 7, 1],
		["A4", 8, 3], ["G4", 11, 1],
		["A4", 12, 2], ["B4", 14, 2],
		["C5", 16, 4],
		["E5", 20, 2], ["D5", 22, 2],
		["C5", 24, 2], ["A4", 26, 2],
		["G4", 28, 4],
		# Second half
		["C5", 32, 2], ["D5", 34, 2],
		["E5", 36, 3], ["D5", 39, 1],
		["C5", 40, 2], ["B4", 42, 1], ["A4", 43, 1],
		["G4", 44, 4],
		["A4", 48, 2], ["C5", 50, 2],
		["B4", 52, 2], ["A4", 54, 2],
		["G4", 56, 2], ["A4", 58, 2],
		["C5", 60, 4],
	]
	for n in warm_melody:
		lead.append([n[0], warm_offset + n[1], n[2], "square", 0.10, "soft"])
		# Warm harmony
		var h_note := _harmony_note(n[0])
		if h_note != "":
			harmony.append([h_note, warm_offset + n[1], n[2], "triangle", 0.05, "soft"])

	# Warm bass
	var warm_bass := ["C3", "F3", "A3", "G3", "C3", "E3", "F3", "G3",
		"C3", "D3", "E3", "G3", "A3", "F3", "G3", "C3"]
	for i in range(warm_bass.size()):
		bass.append([warm_bass[i], warm_offset + i * 4, 3.8, "triangle", 0.12, "soft"])

	# Warm drums (lighter)
	for i in range(64):
		var beat := warm_offset + i
		if i % 4 == 0:
			drums.append(["C3", beat, 0.3, "noise", 0.06, "kick"])
		if i % 8 == 4:
			drums.append(["E4", beat, 0.15, "noise", 0.05, "snare"])
		if i % 4 == 2:
			drums.append(["A5", beat, 0.06, "noise", 0.03, "hat"])

	# ── SECTION 4: FINALE (Triumphant, grand) ──
	# Bars 64-80+ (beats 256-320+)
	var fin_offset := 256.0
	var finale_melody := [
		["C4", 0, 1], ["E4", 1, 1], ["G4", 2, 1], ["C5", 3, 1],
		["E5", 4, 2], ["D5", 6, 2],
		["C5", 8, 4],
		["G4", 12, 1], ["A4", 13, 1], ["B4", 14, 1], ["C5", 15, 1],
		["D5", 16, 2], ["E5", 18, 2],
		["C5", 20, 4],
		# Build up
		["G4", 24, 1], ["A4", 25, 1], ["B4", 26, 1], ["C5", 27, 1],
		["D5", 28, 2], ["E5", 30, 2],
		["C5", 32, 4],
		["E5", 36, 2], ["G5", 38, 2],
		# Grand ending
		["C5", 40, 4],
		["E5", 44, 2], ["G5", 46, 2],
		["C5", 48, 2], ["E5", 50, 2], ["G5", 52, 2], ["C6", 54, 2],
		["C5", 56, 8],
	]
	for n in finale_melody:
		lead.append([n[0], fin_offset + n[1], n[2], "square", 0.14, "sustain"])
		# Octave above for sparkle
		var hi := n[0].replace("4", "5").replace("5", "6")
		if NOTES.has(hi):
			harmony.append([hi, fin_offset + n[1], n[2] * 0.5, "sine", 0.04, "pluck"])
		# Third below for richness
		var h_note := _harmony_note(n[0])
		if h_note != "":
			harmony.append([h_note, fin_offset + n[1], n[2], "pulse25", 0.06, "sustain"])

	# Finale bass (powerful)
	var fin_bass := ["C3", "C3", "A3", "C3", "G3", "C3", "C3", "G3",
		"A3", "C3", "C3", "C3", "C3", "C3", "C3", "C3"]
	for i in range(fin_bass.size()):
		bass.append([fin_bass[i], fin_offset + i * 4, 3.5, "triangle", 0.16, "soft"])

	# Finale drums (building)
	for i in range(64):
		var beat := fin_offset + i
		if i % 4 == 0:
			drums.append(["C3", beat, 0.3, "noise", 0.12, "kick"])
		if i % 4 == 2:
			drums.append(["E4", beat, 0.15, "noise", 0.10, "snare"])
		drums.append(["A5", beat, 0.06, "noise", 0.04, "hat"])
		# Extra energy in last 16 beats
		if i >= 48:
			if i % 2 == 1:
				drums.append(["E4", beat, 0.1, "noise", 0.06, "snare"])

	_song_data = [lead, harmony, bass, drums]
	_song_length_beats = 320.0

func _harmony_note(note: String) -> String:
	# Return a note a third below (simplified)
	var harmonies := {
		"C4": "A3", "D4": "B3", "E4": "C4", "F4": "D4", "G4": "E4", "A4": "F4", "B4": "G4",
		"C5": "A4", "D5": "B4", "E5": "C5", "F5": "D5", "G5": "E5", "A5": "F5", "B5": "G5",
		"C6": "A5"
	}
	return harmonies.get(note, "")

func get_current_beat() -> float:
	if not _playing:
		return 0.0
	return float(_sample_idx) / SAMPLE_RATE / BEAT_LEN
