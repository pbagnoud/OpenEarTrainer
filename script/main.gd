extends Control


var target_bandpass = AudioEffectBandPassFilter.new()
var current_bandpass = AudioEffectBandPassFilter.new()
var target_pan = AudioEffectPanner.new()
var current_pan = AudioEffectPanner.new()
var target_gain = AudioEffectAmplify.new()
var current_gain = AudioEffectAmplify.new()
var loop = true
signal toggle1; signal toggle2; signal toggle3; signal channel_changed(is_target)
var gray_noise_playing: bool = false:
	set(value):
		gray_noise_playing = value
		if value:
			$GrayNoise.text = "Pause"
		else:
			$GrayNoise.text = "Gray Noise"
# Called when the node enters the scene tree for the first time.
func _ready():
	$Track.play()
	target_bandpass.resonance = 1
	current_bandpass.resonance = 1
	
	add_Bandpass()
	add_Pan()
	add_Gain()
	initialize_help_window()
	randomize_parameters()
	

func randomize_parameters():
	var x = randf()
	target_bandpass.cutoff_hz = snapped(19970*((pow(700,x)-1)/699-0.04*x*(x-1)) + 30,$BandPass.step)
	target_pan.pan = snapped(2*randf() - 1,$Panner.step)
	target_gain.volume_db = snapped(20 * randf() - 10, $Gain.step)
	$Answer.text = "Answer\n~         ~"
	print(target_bandpass.cutoff_hz,target_pan.pan, target_gain.volume_db)
	
func initialize_help_window():
	var file = FileAccess.open("res://README.MD", FileAccess.READ)
	$Help/TextHelp.text = file.get_as_text()
	file.close()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("toggle"):
		$CheckTarget.set_pressed(not $CheckTarget.is_pressed())
	if Input.is_action_just_pressed("toggle1"):
		toggle1.emit()
	if Input.is_action_just_pressed("toggle2"):
		toggle2.emit()
	if Input.is_action_just_pressed("toggle3"):
		toggle3.emit()



func _on_filter_value_changed(value):
	current_bandpass.cutoff_hz = value


func _on_filter_2_value_changed(value):
	current_pan.pan = value


func _on_filter_3_value_changed(value):
	current_gain.volume_db = value


func _on_check_button_toggled(button_pressed):
	print(button_pressed)
	channel_changed.emit(button_pressed)
	color_CheckTarget(button_pressed)
	if button_pressed:
		AudioServer.set_bus_send(3, "Target")
	else:
		AudioServer.set_bus_send(3, "Current")


func _on_button_pressed():
	$Answer.text = "Answer  \n " + str(snapped(target_bandpass.cutoff_hz,1)) + " ~ " + str(snapped(target_pan.pan,0.01)) + " ~ " +str(snapped(target_gain.volume_db,0.01))


func _on_randomize_pressed():
	randomize_parameters()


func _on_image_loader_pressed():
	$Track.stop()
	gray_noise_playing = false
	$ImageLoader/FileDialog.popup()


func _on_file_dialog_file_selected(path):
	var custom_track
	if path.ends_with(".mp3"):
		custom_track = AudioStreamMP3.new()
		var file = FileAccess.open(path, FileAccess.READ)
		var bytes = file.get_buffer(file.get_length())
		custom_track.data = bytes
	else:
		custom_track = load(path)
	$Track.stream = custom_track
	$Track.play()


func color_CheckTarget(is_target):
	if not is_target:
		$CheckTarget.self_modulate = "3d6ce8"
	else:
		$CheckTarget.self_modulate = "a7091f"

func add_Bandpass():
	AudioServer.add_bus_effect(1, target_bandpass)
	AudioServer.add_bus_effect(2, current_bandpass)

func add_Pan():
	AudioServer.add_bus_effect(1, target_pan)
	AudioServer.add_bus_effect(2, current_pan)

func add_Gain():
	AudioServer.add_bus_effect(1, target_gain)
	AudioServer.add_bus_effect(2, current_gain)
	

	
func _on_band_pass_enable_effect(is_enabeled):
	AudioServer.set_bus_effect_enabled(1,0,is_enabeled)
	AudioServer.set_bus_effect_enabled(2,0,is_enabeled)



func _on_panner_enable_effect(is_enabeled):
	AudioServer.set_bus_effect_enabled(1,1,is_enabeled)
	AudioServer.set_bus_effect_enabled(2,1,is_enabeled)


func _on_gain_enable_effect(is_enabeled):
	AudioServer.set_bus_effect_enabled(1,2,is_enabeled)
	AudioServer.set_bus_effect_enabled(2,2,is_enabeled)


func _on_loop_toggled(button_pressed):
	loop = button_pressed


func _on_track_finished():
	if loop: 
		$Track.play()


func _on_gray_noise_pressed():
	if gray_noise_playing:
		$Track.stop()
		gray_noise_playing = false
	else:
		$Track.stream = load("res://Gray_noise.wav")
		$Track.play()
		gray_noise_playing = true


func _on_help_button_pressed():
	$Help.popup()
