@icon("res://images/fancy_ui.svg")
extends Button
## FancyButton is an interactive button with customizable hover and pressed animations.
class_name FancyButton

@export var focusable: bool = true
@export var button_id: int = 0
@export_group("Animation Settings")
@export_subgroup("Hover Animations")
@export var hover_animations: bool = true
@export var hover_scale: bool = true
## Scale will change relative to the button's scale based on the value entered.
@export_range(1.0, 2.0, 0.01) var hover_scale_amount: float = 1.1
## Duration of the hover scale animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_scale_tween_duration: float = 0.2
@export var hover_move: bool = true
## Position will move relative to the button's position based on the X/Y entered.
@export var hover_move_amount: Vector2 = Vector2(0, 0)
## Duration of the hover move animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_move_tween_duration: float = 0.2
@export var hover_rotate: bool = false
## Rotation will change relative to the button's rotation based on the value entered.
@export_range(-360, 360, 0.1, "degrees") var hover_rotate_amount: float = 0.0
## Duration of the hover rotate animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_rotate_tween_duration: float = 0.2
## Color will change to theme Hover Color
@export var hover_color: bool = true
## Duration of the hover color animation in seconds. This is the default duration for all color animations except for the pressed color animation.
@export_range(0.01, 2.0, 0.01) var hover_color_tween_duration: float = 0.2
## Font Color will change to theme Font Hover Color
@export var hover_font: bool = true

@export_subgroup("Pressed Animations")
@export var pressed_animations: bool = true
@export var pressed_scale: bool = true
## Scale will change relative to the button's scale based on the value entered.
@export_range(1.0, 2.0, 0.01) var pressed_scale_amount: float = 1.1
## Duration of the pressed scale animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_scale_tween_duration: float = 0.2
@export var pressed_move: bool = true
## Position will move relative to the button's position based on the X/Y entered.
@export var pressed_move_amount: Vector2 = Vector2(0, 0)
## Duration of the pressed move animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_move_tween_duration: float = 0.2
@export var pressed_rotate: bool = false
## Rotation will change relative to the button's rotation based on the value entered.
@export_range(-360, 360, 0.1, "degrees") var pressed_rotate_amount: float = 0.0
## Duration of the pressed rotate animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_rotate_tween_duration: float = 0.2
## Color will change to theme Pressed Color
@export var pressed_color: bool = true
## Duration of the pressed color animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_color_tween_duration: float = 0.2
## Font Color will change to theme Font Pressed Color
@export var pressed_font: bool = true

var direct_children: Array[Node]

# Setup for button color tweening
var tween_stylebox: StyleBoxFlat
var styleboxes: Dictionary = {}
var current_state: int = BaseButton.DRAW_NORMAL
var tween_font_color: Color
var font_colors: Dictionary = {}
var state_tween: Tween
var font_state_tween: Tween

var loaded: bool = false

var starting_position: Vector2
var starting_rotation: float

var button_audio: AudioStreamPlayer2D
var button_hover_audio: AudioStreamPlayer2D

func start_tween(object: Object, property: String, final_val: Variant, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(object, property, final_val, duration)

func btn_hovered_animation(hover_bool: bool, hover_type: String, hover_amount, default_amount, tween_duration: float) -> void:
	if !self.is_disabled():
		if self.is_hovered():
			if hover_bool:
				start_tween(self, hover_type, hover_amount, tween_duration)
			else:
				start_tween(self, hover_type, default_amount, tween_duration)
		else:
			start_tween(self, hover_type, default_amount, tween_duration)

func btn_hovered_scale() -> void:
	self.pivot_offset = self.size / 2
	btn_hovered_animation(hover_scale, "scale", (Vector2.ONE * hover_scale_amount), Vector2.ONE, hover_scale_tween_duration)

func btn_hovered_slide() -> void:
	btn_hovered_animation(hover_move, "position", Vector2(starting_position.x + hover_move_amount.x, starting_position.y + hover_move_amount.y), starting_position, hover_move_tween_duration)

func btn_hovered_rotate() -> void:
	btn_hovered_animation(hover_rotate, "rotation_degrees", hover_rotate_amount, starting_rotation, hover_rotate_tween_duration)

func btn_pressed_animation(hover_bool: bool, pressed_type: String, pressed_amount, default_amount, tween_duration: float) -> void:
	if !self.is_disabled():
		if self.is_pressed():
			if hover_bool:
				start_tween(self, pressed_type, pressed_amount, tween_duration)
			else:
				start_tween(self, pressed_type, default_amount, tween_duration)
		else:
			start_tween(self, pressed_type, default_amount, tween_duration)

func btn_pressed_scale() -> void:
	self.pivot_offset = self.size / 2
	btn_pressed_animation(pressed_scale, "scale", (Vector2.ONE * pressed_scale_amount), Vector2.ONE, pressed_scale_tween_duration)

func btn_pressed_slide() -> void:
	btn_pressed_animation(pressed_move, "position", Vector2(starting_position.x + pressed_move_amount.x, starting_position.y + pressed_move_amount.y), starting_position, pressed_move_tween_duration)

func btn_pressed_rotate() -> void:
	btn_pressed_animation(pressed_rotate, "rotation_degrees", pressed_rotate_amount, starting_rotation, pressed_rotate_tween_duration)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direct_children = get_children()
	self.button_up.connect(on_button_up)
	self.mouse_entered.connect(on_button_hover)

	# Duplicate normal stylebox
	tween_stylebox = get_theme_stylebox("normal").duplicate()
	tween_font_color = get_theme_color("font_color")
	# Save Different Styleboxes
	styleboxes[BaseButton.DRAW_NORMAL] = get_theme_stylebox("normal").duplicate()
	styleboxes[BaseButton.DRAW_HOVER] = get_theme_stylebox("hover").duplicate()
	styleboxes[BaseButton.DRAW_PRESSED] = get_theme_stylebox("pressed").duplicate()
	styleboxes[BaseButton.DRAW_HOVER_PRESSED] = get_theme_stylebox("pressed").duplicate()
	styleboxes[BaseButton.DRAW_DISABLED] = get_theme_stylebox("disabled").duplicate()
	# Save Different Font Colors
	font_colors[BaseButton.DRAW_NORMAL] = get_theme_color("font_color")
	font_colors[BaseButton.DRAW_HOVER] = get_theme_color("font_hover_color")
	font_colors[BaseButton.DRAW_PRESSED] = get_theme_color("font_pressed_color")
	font_colors[BaseButton.DRAW_HOVER_PRESSED] = get_theme_color("font_hover_pressed_color")
	font_colors[BaseButton.DRAW_DISABLED] = get_theme_color("font_disabled_color")
	# Override styleboxes
	add_theme_stylebox_override("normal", tween_stylebox)
	add_theme_stylebox_override("hover", tween_stylebox)
	add_theme_stylebox_override("pressed", tween_stylebox)
	add_theme_stylebox_override("disabled", tween_stylebox)
	# Override Font Colors
	add_theme_color_override("font_color", tween_font_color)
	add_theme_color_override("font_hover_color", tween_font_color)
	add_theme_color_override("font_pressed_color", tween_font_color)
	add_theme_color_override("font_hover_pressed_color", tween_font_color)
	add_theme_color_override("font_disabled_color", tween_font_color)

func on_button_up():
	if !self.is_disabled():
		if button_audio:
			button_audio.play()

func on_button_hover():
	if !self.is_disabled():
		if button_hover_audio:
			button_hover_audio.play()

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		current_state = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not loaded:
		starting_position = self.position
		starting_rotation = self.rotation_degrees
		loaded = true

	if not focusable:
		self.focus_mode = FOCUS_NONE
	for child in direct_children:
		if (self as Button).is_disabled():
			child.visible = false
		else:
			child.visible = true

	if hover_animations:
		btn_hovered_scale()
		btn_hovered_slide()
		btn_hovered_rotate()

	if pressed_animations:
		btn_pressed_scale()
		btn_pressed_slide()
		btn_pressed_rotate()

	if get_draw_mode() != current_state:
		# if draw mode changed
		current_state = get_draw_mode()
		# Kill current tween
		if state_tween and state_tween.is_running():
			state_tween.kill()
		if font_state_tween and font_state_tween.is_running():
			font_state_tween.kill()
		# Create new tween

		var target: StyleBoxFlat = styleboxes[current_state] as StyleBoxFlat
		var font_target: Color = font_colors[current_state] as Color
		if current_state == BaseButton.DRAW_HOVER: # Hover State
			if hover_font:
				font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				font_state_tween.tween_property(self, "theme_override_colors/font_hover_color", font_target, hover_color_tween_duration)
			if hover_color:
				state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
		elif current_state == BaseButton.DRAW_PRESSED:
			if pressed_font:
				font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				font_state_tween.tween_property(self, "theme_override_colors/font_pressed_color", font_target, pressed_color_tween_duration)
			if pressed_color:
				state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, pressed_color_tween_duration)
		elif current_state == BaseButton.DRAW_HOVER_PRESSED:
			if pressed_font and hover_font:
				font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				font_state_tween.tween_property(self, "theme_override_colors/font_hover_pressed_color", font_target, hover_color_tween_duration)
			if pressed_color and hover_color:
				state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
		elif current_state == BaseButton.DRAW_DISABLED:
			font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			font_state_tween.tween_property(self, "theme_override_colors/font_disabled_color", font_target, hover_color_tween_duration)
			state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
		elif current_state == BaseButton.DRAW_NORMAL:
			font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			font_state_tween.tween_property(self, "theme_override_colors/font_color", font_target, hover_color_tween_duration)
			state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
