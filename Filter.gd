extends Control

signal value_changed(value)
signal enable_effect(is_enabeled)

@export var effect: String
@export var exp_edit : bool
@export var min_value : float
@export var max_value : float
@export var value: float
# Called when the node enters the scene tree for the first time.
func _ready():
	$HSlider.min_value = min_value
	$HSlider.max_value = max_value
	$HSlider.value = value
	$HSlider.exp_edit = exp_edit
	$TextEdit.text = effect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_key_toggled():
	$CheckButton.set_pressed(not $CheckButton.is_pressed())


func _on_h_slider_value_changed(value_slide):
	$TextEdit2.text = str(value_slide)
	value_changed.emit(value_slide)
	



func _on_check_button_toggled(button_pressed):
	enable_effect.emit(button_pressed)
