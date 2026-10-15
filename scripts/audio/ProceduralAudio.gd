class_name ProceduralAudio
extends RefCounted

## Procedural Sound Effects Synthesizer for Memoirs of Technoir
## Generates clean 16-bit PCM WAV streams in-memory with zero external file dependencies.

const SAMPLE_RATE: int = 22050

static func create_click_sound() -> AudioStreamWAV:
	var duration: float = 0.04
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var envelope: float = exp(-t * 90.0)
		var sample_val: float = (sin(2.0 * PI * 2200.0 * t) * 0.5 + (randf() * 2.0 - 1.0) * 0.5) * envelope
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.7), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_ratchet_sound() -> AudioStreamWAV:
	var duration: float = 0.12
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		# Repeating click pulses simulating ratchet teeth
		var click_phase: float = fmod(t * 40.0, 1.0)
		var pulse: float = exp(-click_phase * 25.0)
		var resonance: float = sin(2.0 * PI * (1200.0 + sin(t * 80.0) * 300.0) * t)
		var sample_val: float = pulse * (resonance * 0.7 + (randf() * 2.0 - 1.0) * 0.3)
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.8), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_clink_sound() -> AudioStreamWAV:
	var duration: float = 0.3
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var envelope: float = exp(-t * 18.0)
		# Dual chime harmonics (1800Hz + 3650Hz metallic overtone)
		var tone: float = sin(2.0 * PI * 1840.0 * t) * 0.6 + sin(2.0 * PI * 3680.0 * t) * 0.4
		var sample_val: float = tone * envelope
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.8), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_blocked_sound() -> AudioStreamWAV:
	var duration: float = 0.18
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		# Low dull double-knock
		var t1: float = t
		var t2: float = t - 0.08
		var env1: float = exp(-t1 * 40.0) if t1 >= 0.0 else 0.0
		var env2: float = exp(-t2 * 40.0) if t2 >= 0.0 else 0.0
		var tone: float = sin(2.0 * PI * 140.0 * t) * env1 + sin(2.0 * PI * 110.0 * t) * env2
		var sample_val: float = tone * 0.8
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.9), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_detach_sound() -> AudioStreamWAV:
	var duration: float = 0.22
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var envelope: float = exp(-t * 22.0)
		# Slide up frequency (mechanical release / sliding out of socket)
		var freq: float = 400.0 + (t * 800.0)
		var tone: float = sin(2.0 * PI * freq * t) * 0.7 + (randf() * 2.0 - 1.0) * 0.3
		var sample_val: float = tone * envelope
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.85), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_clean_sound() -> AudioStreamWAV:
	var duration: float = 0.25
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var envelope: float = sin(t / duration * PI)
		# Filtered high noise (soft brush dusting)
		var noise: float = (randf() * 2.0 - 1.0) * 0.8 + sin(2.0 * PI * 850.0 * t) * 0.2
		var sample_val: float = noise * envelope * 0.6
		var int_val: int = clampi(int(sample_val * 32767.0), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_success_sound() -> AudioStreamWAV:
	var duration: float = 0.7
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	# 3-note ascending arpeggio: C5 (523.25), E5 (659.25), G5 (783.99), C6 (1046.5)
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.5]
	var note_dur: float = 0.12
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var sample_val: float = 0.0
		
		for n_idx in range(notes.size()):
			var note_t: float = t - float(n_idx) * note_dur
			if note_t >= 0.0:
				var decay: float = exp(-note_t * 6.0)
				var freq: float = notes[n_idx]
				var tone: float = sin(2.0 * PI * freq * note_t) + 0.3 * sin(2.0 * PI * (freq * 2.0) * note_t)
				sample_val += tone * decay * 0.25
				
		var int_val: int = clampi(int(sample_val * 32767.0 * 0.9), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, false)

static func create_motor_hum_loop() -> AudioStreamWAV:
	# 1.0-second seamless loop of warm motor hum + subtle blade air flutter
	var duration: float = 1.0
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		# 60Hz mains hum + 120Hz harmonic + 180Hz harmonic + wind whoosh (8Hz modulation)
		var hum: float = sin(2.0 * PI * 60.0 * t) * 0.5 + sin(2.0 * PI * 120.0 * t) * 0.3 + sin(2.0 * PI * 180.0 * t) * 0.15
		var flutter: float = (0.7 + 0.3 * sin(2.0 * PI * 14.0 * t)) * ((randf() * 2.0 - 1.0) * 0.15)
		var sample_val: float = (hum * 0.7 + flutter) * 0.7
		var int_val: int = clampi(int(sample_val * 32767.0), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, true)

static func create_ambient_room_loop() -> AudioStreamWAV:
	# 2.0-second warm cozy late-night lofi ambient tone loop
	var duration: float = 2.0
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		# Deep warm room resonance (55Hz drone, subtle lofi vinyl noise texture)
		var room_drone: float = sin(2.0 * PI * 55.0 * t) * 0.4 + sin(2.0 * PI * 110.0 * t) * 0.2
		var vinyl: float = (randf() * 2.0 - 1.0) * 0.05
		if randf() < 0.0008:
			vinyl += (randf() * 2.0 - 1.0) * 0.4 # warm vinyl crackle
		var sample_val: float = (room_drone + vinyl) * 0.35
		var int_val: int = clampi(int(sample_val * 32767.0), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, true)

static func create_lofi_music_track() -> AudioStreamWAV:
	# 6.0-second seamless lofi electric piano chord progression
	var duration: float = 6.0
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	# Chord root frequencies: C3, A2, D3, G2
	var chords: Array = [
		[130.81, 164.81, 196.00, 246.94, 293.66], # Cmaj9
		[110.00, 130.81, 164.81, 196.00, 261.63], # Am9
		[146.83, 174.61, 220.00, 261.63, 329.63], # Dm9
		[98.00, 123.47, 174.61, 220.00, 293.66]   # G13
	]
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var chord_idx: int = int(fmod(t / 1.5, 4.0))
		var chord_t: float = fmod(t, 1.5)
		var env: float = exp(-chord_t * 1.8) * 0.7 + 0.3 # soft piano decay
		
		var notes = chords[chord_idx]
		var val: float = 0.0
		for n in notes:
			val += sin(2.0 * PI * n * t) * 0.14
			val += sin(4.0 * PI * n * t) * 0.04 # warm 2nd harmonic
			
		# Gentle vinyl warmth
		val += (randf() * 2.0 - 1.0) * 0.015
		var sample_val: float = val * env * 0.8
		var int_val: int = clampi(int(sample_val * 32767.0), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, true)

static func create_cassette_playback_track() -> AudioStreamWAV:
	# 4.0-second nostalgic cassette tape recording with tape hiss & acoustic melody
	var duration: float = 4.0
	var total_samples: int = int(duration * SAMPLE_RATE)
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(total_samples * 2)
	
	var melody_notes: Array[float] = [261.63, 293.66, 329.63, 392.00, 440.00, 392.00, 329.63, 293.66]
	
	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var note_idx: int = int(fmod(t * 2.0, 8.0))
		var note_t: float = fmod(t, 0.5)
		var env: float = exp(-note_t * 4.0)
		
		var freq: float = melody_notes[note_idx]
		var acoustic: float = sin(2.0 * PI * freq * t) * 0.4 + sin(4.0 * PI * freq * t) * 0.2 + sin(6.0 * PI * freq * t) * 0.08
		
		# Analog tape hiss & wow/flutter
		var flutter: float = 1.0 + sin(2.0 * PI * 4.5 * t) * 0.005
		var tape_hiss: float = (randf() * 2.0 - 1.0) * 0.04
		
		var sample_val: float = (acoustic * env * flutter + tape_hiss) * 0.75
		var int_val: int = clampi(int(sample_val * 32767.0), -32767, 32767)
		byte_array.encode_s16(i * 2, int_val)
		
	return _make_wav(byte_array, true)

static func _make_wav(data: PackedByteArray, loop: bool) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav
