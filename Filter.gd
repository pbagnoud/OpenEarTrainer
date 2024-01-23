extends Control

signal value_changed(value)
signal enable_effect(is_enabeled)

@export var effect: String
@export var exp_edit : bool
@export var min_value : float
@export var max_value : float
@export var value: float
@onready var slider = $HSlider
@onready var sl_value = $HSlider/ValueBox
@onready var sl_name = $HSlider/NameBox
@onready var check = $CheckButton
@export var step : float = 0.01
@export var channel_target = false:
	set(new_value):
		channel_target = new_value
		if not new_value:
			$HSlider.self_modulate = "3d6ce8"
		else:
			$HSlider.self_modulate = "a7091f"
# Called when the node enters the scene tree for the first time.
func _ready():
	slider.step = step
	slider.min_value = min_value
	slider.max_value = max_value
	slider.value = value
	slider.exp_edit = exp_edit
	sl_name.text = effect
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_key_toggled():
	check.set_pressed(not check.is_pressed())
	

func _on_main_channel_changed(is_target):
	channel_target = is_target


func _on_h_slider_value_changed(value_slide):
	sl_value.text = str(value_slide)
	value_changed.emit(value_slide)
	



func _on_check_button_toggled(button_pressed):
	slider.editable = button_pressed
	if not button_pressed:
		slider.modulate ="000000"
	else:
		slider.modulate = "ffffff"
	enable_effect.emit(button_pressed)
