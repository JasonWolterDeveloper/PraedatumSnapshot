class_name SoundMaster extends Node3D

## A simple class that acts as a middleman for playing sound effects: it plays an AudioStreamPlayer 
## of the provided sound effect category. Instance the SoundMaster as a child, then instance
## any number of AudioStreamPlayers (or derivative classes) and point them to the appropriate audio 
## files to be played. 

signal finished_playback(audio_player_name:String)

## Repeat the last issued play() call once the current stream has finished
@export var continuous_play:bool = false 
@export var overlapping_streams:bool = false

var now_playing:String = ""

# Private variables:
var audio_players:Dictionary ## [child_name, child]
var last_audio_player_name:String


## Automatically adds all instanced child AudioStreamPlayers to dict
func _ready():
	for child in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer3D or child is AudioStreamPlayer2D:
			audio_players[child.name] = child
			
			if continuous_play:
				child.finished.connect(replay)
			child.finished.connect(signal_finished_playback)


## Plays a sound from the AudioStreamPlayer corresponding with the provided category. Can be either 
## called explicitly or used as a signal callback. Returns true if the provided audio stream player
## was found.
func play(audio_player_name:String) -> bool:
	if not overlapping_streams:
		for player_name in audio_players:
			audio_players[player_name].stop()
	
	last_audio_player_name = audio_player_name
	var target_audio_player = audio_players.get(audio_player_name)

	if target_audio_player and target_audio_player.has_method("play"):
		target_audio_player.play()
		now_playing = audio_player_name
		return true
	else:
		return false


## Simply replays the last play() call
func replay() -> bool:
	if last_audio_player_name:
		return play(last_audio_player_name)
	return false


func signal_finished_playback() -> void:
	finished_playback.emit(now_playing)
	now_playing = ""
