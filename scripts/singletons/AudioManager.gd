extends Node

## AudioManager Singleton
## Manages SFX playback, ambient audio, lofi music, and motor/cassette loops.

const ProceduralAudio = preload("res://scripts/audio/ProceduralAudio.gd")

var _sfx_players: Array[AudioStreamPlayer] = []
var _motor_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _cassette_player: AudioStreamPlayer

var _snd_click: AudioStreamWAV
var _snd_ratchet: AudioStreamWAV
var _snd_clink: AudioStreamWAV
var _snd_blocked: AudioStreamWAV
var _snd_detach: AudioStreamWAV
var _snd_clean: AudioStreamWAV
var _snd_success: AudioStreamWAV
var _snd_motor: AudioStreamWAV
var _snd_ambient: AudioStreamWAV
var _snd_lofi_music: AudioStreamWAV
var _snd_cassette_playback: AudioStreamWAV

var master_volume: float = 0.85
var music_volume: float = 0.75
var sfx_volume: float = 0.90

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_sounds()
	_init_players()
	start_ambient()
	start_music()

func _init_sounds() -> void:
	_snd_click = ProceduralAudio.create_click_sound()
	_snd_ratchet = ProceduralAudio.create_ratchet_sound()
	_snd_clink = ProceduralAudio.create_clink_sound()
	_snd_blocked = ProceduralAudio.create_blocked_sound()
	_snd_detach = ProceduralAudio.create_detach_sound()
	_snd_clean = ProceduralAudio.create_clean_sound()
	_snd_success = ProceduralAudio.create_success_sound()
	_snd_motor = ProceduralAudio.create_motor_hum_loop()
	_snd_ambient = ProceduralAudio.create_ambient_room_loop()
	_snd_lofi_music = ProceduralAudio.create_lofi_music_track()
	_snd_cassette_playback = ProceduralAudio.create_cassette_playback_track()

func _init_players() -> void:
	# Pool of 6 SFX players for polyphony
	for i in range(6):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_sfx_players.append(p)
		
	# Dedicated looped players
	_motor_player = AudioStreamPlayer.new()
	_motor_player.stream = _snd_motor
	_motor_player.volume_db = -10.0
	add_child(_motor_player)
	
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.stream = _snd_ambient
	_ambient_player.volume_db = -16.0
	add_child(_ambient_player)

	# Lofi background music player
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = _snd_lofi_music
	_music_player.volume_db = linear_to_db(music_volume) - 6.0
	add_child(_music_player)

	# Cassette player for tape recorder
	_cassette_player = AudioStreamPlayer.new()
	_cassette_player.stream = _snd_cassette_playback
	_cassette_player.volume_db = -4.0
	add_child(_cassette_player)

func _play_sfx(stream: AudioStream, vol_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not stream:
		return
	var adjusted_vol: float = vol_db + linear_to_db(sfx_volume * master_volume)
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = adjusted_vol
			p.pitch_scale = pitch_scale
			p.play()
			return
	var fallback: AudioStreamPlayer = _sfx_players[0]
	fallback.stream = stream
	fallback.volume_db = adjusted_vol
	fallback.pitch_scale = pitch_scale
	fallback.play()

func play_click(pitch: float = 1.0) -> void:
	_play_sfx(_snd_click, -4.0, pitch)

func play_ratchet(pitch: float = 1.0) -> void:
	_play_sfx(_snd_ratchet, -2.0, pitch)

func play_clink(pitch: float = 1.0) -> void:
	_play_sfx(_snd_clink, -3.0, pitch)

func play_blocked() -> void:
	_play_sfx(_snd_blocked, 0.0, 1.0)

func play_detach() -> void:
	_play_sfx(_snd_detach, -2.0, 1.0)

func play_clean() -> void:
	_play_sfx(_snd_clean, -4.0, randf_range(0.9, 1.1))

func play_success() -> void:
	_play_sfx(_snd_success, 1.0, 1.0)

func start_motor_hum() -> void:
	if not _motor_player.playing:
		_motor_player.volume_db = -24.0
		_motor_player.play()
		var tween: Tween = create_tween()
		tween.tween_property(_motor_player, "volume_db", -6.0 + linear_to_db(sfx_volume), 1.2)

func stop_motor_hum() -> void:
	if _motor_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_motor_player, "volume_db", -30.0, 0.8)
		tween.tween_callback(_motor_player.stop)

func start_ambient() -> void:
	if not _ambient_player.playing:
		_ambient_player.play()

func stop_ambient() -> void:
	_ambient_player.stop()

func start_music() -> void:
	if not _music_player.playing:
		_music_player.volume_db = linear_to_db(music_volume * master_volume) - 6.0
		_music_player.play()

func stop_music() -> void:
	_music_player.stop()

func start_cassette_playback() -> void:
	# Duck background music slightly for cassette voice message
	if _music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -24.0, 0.5)
	if not _cassette_player.playing:
		_cassette_player.volume_db = linear_to_db(sfx_volume * master_volume) - 2.0
		_cassette_player.play()

func stop_cassette_playback() -> void:
	if _cassette_player.playing:
		_cassette_player.stop()
	if _music_player.playing:
		var tween: Tween = create_tween()
		tween.tween_property(_music_player, "volume_db", linear_to_db(music_volume * master_volume) - 6.0, 0.5)

func set_master_volume(vol: float) -> void:
	master_volume = clampf(vol, 0.0, 1.0)
	_update_volumes()

func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)
	_update_volumes()

func _update_volumes() -> void:
	if _music_player and _music_player.playing:
		_music_player.volume_db = linear_to_db(music_volume * master_volume) - 6.0
	if _ambient_player and _ambient_player.playing:
		_ambient_player.volume_db = linear_to_db(master_volume) - 16.0
