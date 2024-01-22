extends Control


var target_bandpass = AudioEffectBandPassFilter.new()
var current_bandpass = AudioEffectBandPassFilter.new()
var target_pan = AudioEffectPanner.new()
var current_pan = AudioEffectPanner.new()
var target_gain = AudioEffectAmplify.new()
var current_gain = AudioEffectAmplify.new()
var loop = false
signal toggle1; signal toggle2; signal toggle3
# Called when the node enters the scene tree for the first time.
func _ready():
	$Track.play()
	target_bandpass.resonance = 1
	current_bandpass.resonance = 1
	
	add_Bandpass()
	add_Pan()
	add_Gain()
	
	randomize_parameters()

func randomize_parameters():
	target_bandpass.cutoff_hz = 19970*(pow(2,randf())-1) + 30
	target_pan.pan = 2*randf() - 1
	target_gain.volume_db = 20 * randf() - 10
	$Answer.text = "Answer\n~         ~"
	print(target_bandpass.cutoff_hz,target_pan.pan, target_gain.volume_db)
	
	
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
	if button_pressed:
		AudioServer.set_bus_send(3, "Target")
	else:
		AudioServer.set_bus_send(3, "Current")


func _on_button_pressed():
	$Answer.text = "Answer  \n " + str(snapped(target_bandpass.cutoff_hz,0.01)) + " ~ " + str(snapped(target_pan.pan,0.01)) + " ~ " +str(snapped(target_gain.volume_db,0.01))


func _on_randomize_pressed():
	randomize_parameters()


func _on_image_loader_pressed():
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
