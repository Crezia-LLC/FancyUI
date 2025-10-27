@icon("res://images/fancy_ui.svg")
extends Button
## FancyButton is an interactive button with customizable hover and pressed animations.
class_name FancyButton


@export var focusable: bool = true
@export var button_id: int = 0
@export_group("Hover Animations")
@export var hover_animations: bool = true
@export_subgroup("Hover Scale")
@export var hover_scale: bool = true
## Scale will change relative to the button's scale based on the value entered.
@export var hover_scale_amount: Vector2 = Vector2(1.1, 1.1)
## Duration of the hover scale animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_scale_tween_duration: float = 0.2
@export_subgroup("Hover Move")
@export var hover_move: bool = true
## Position will move relative to the button's position based on the X/Y entered.
@export var hover_move_amount: Vector2 = Vector2(0, 0)
## Duration of the hover move animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_move_tween_duration: float = 0.2
@export_subgroup("Hover Rotate")
@export var hover_rotate: bool = false
## Rotation will change relative to the button's rotation based on the value entered.
@export_range(-360, 360, 0.1, "degrees") var hover_rotate_amount: float = 0.0
## Duration of the hover rotate animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_rotate_tween_duration: float = 0.2
@export_subgroup("Hover Grow")
@export var hover_grow: bool = false
## Size will change relative to the button's size based on the value entered.
@export var hover_grow_amount: Vector2 = Vector2(0, 0)
## Duration of the hover grow animation in seconds.
@export_range(0.01, 2.0, 0.01) var hover_grow_tween_duration: float = 0.2
@export_subgroup("Hover Style")
## Style will change to theme Hover Style
@export var hover_color: bool = true
## Duration of the hover color animation in seconds. This is the default duration for all color animations except for the pressed color animation.
@export_range(0.01, 2.0, 0.01) var hover_color_tween_duration: float = 0.2
## Font Color will change to theme Font Hover Color
@export_subgroup("Hover Font")
@export var hover_font: bool = true

@export_group("Pressed Animations")
@export var pressed_animations: bool = true
@export_subgroup("Pressed Scale")
@export var pressed_scale: bool = true
## Scale will change relative to the button's scale based on the value entered.
@export var pressed_scale_amount: Vector2 = Vector2(1.1, 1.1)
## Duration of the pressed scale animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_scale_tween_duration: float = 0.2
@export_subgroup("Pressed Move")
@export var pressed_move: bool = true
## Position will move relative to the button's position based on the X/Y entered.
@export var pressed_move_amount: Vector2 = Vector2(0, 0)
## Duration of the pressed move animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_move_tween_duration: float = 0.2
@export_subgroup("Pressed Rotate")
@export var pressed_rotate: bool = false
## Rotation will change relative to the button's rotation based on the value entered.
@export_range(-360, 360, 0.1, "degrees") var pressed_rotate_amount: float = 0.0
## Duration of the pressed rotate animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_rotate_tween_duration: float = 0.2
@export_subgroup("Pressed Grow")
@export var pressed_grow: bool = false
## Size will change relative to the button's size based on the value entered.
@export var pressed_grow_amount: Vector2 = Vector2(0, 0)
## Duration of the pressed grow animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_grow_tween_duration: float = 0.2
@export_subgroup("Pressed Style")
## Style will change to theme Pressed Style
@export var pressed_color: bool = true
## Duration of the pressed color animation in seconds.
@export_range(0.01, 2.0, 0.01) var pressed_color_tween_duration: float = 0.2
## Font Color will change to theme Font Pressed Color
@export_subgroup("Pressed Font")
@export var pressed_font: bool = true

@export_group("Audio")
@export var button_clicked_audio: AudioStreamPlayer2D
@export var button_hover_audio: AudioStreamPlayer2D

var direct_children: Array[Node]

# Setup for button color tweening
var tween_stylebox: StyleBoxFlat
var styleboxes: Dictionary = {}
var current_state: int = BaseButton.DRAW_NORMAL
var tween_font_color: Color
var font_colors: Dictionary = {}
var state_tween: Tween
var font_state_tween: Tween

# Set Up tweens
var tween_scale: Tween = create_tween()
var tween_position: Tween = create_tween()
var tween_rotation: Tween = create_tween()
var tween_size: Tween = create_tween()

var loaded: bool = false

var starting_position: Vector2
var starting_rotation: float
var starting_scale: Vector2
var starting_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direct_children = get_children()
	self.button_up.connect(on_button_up)
	self.mouse_entered.connect(on_button_hover)

	# Duplicate normal stylebox
	tween_stylebox = get_theme_stylebox("normal").duplicate()
	tween_font_color = get_theme_color("font_color")
	# Save Different Styleboxes
	styleboxes[BaseButton.DRAW_NORMAL] = get_theme_stylebox("normal").duplicate() # Normal = 0
	styleboxes[BaseButton.DRAW_HOVER] = get_theme_stylebox("hover").duplicate() # Hover = 2
	styleboxes[BaseButton.DRAW_PRESSED] = get_theme_stylebox("pressed").duplicate() # Pressed = 1
	styleboxes[BaseButton.DRAW_HOVER_PRESSED] = get_theme_stylebox("pressed").duplicate() # Hover Pressed = 4
	styleboxes[BaseButton.DRAW_DISABLED] = get_theme_stylebox("disabled").duplicate() # Disabled = 3
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
		if button_clicked_audio:
			button_clicked_audio.play()

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
		starting_scale = self.scale
		starting_size = self.size
		loaded = true

	if not focusable:
		self.focus_mode = FOCUS_NONE
	for child in direct_children:
		if (self as Button).is_disabled():
			child.visible = false
		else:
			child.visible = true

	if get_draw_mode() != current_state:
		self.pivot_offset = self.size / 2
		# if draw mode changed
		current_state = get_draw_mode()
		# Kill current tween
		if tween_scale && tween_scale.is_running():
			tween_scale.kill()
		if tween_position && tween_position.is_running():
			tween_position.kill()
		if tween_rotation && tween_rotation.is_running():
			tween_rotation.kill()
		if tween_size && tween_size.is_running():
			tween_size.kill()
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
				state_tween.tween_property(tween_stylebox, "border_color", target.border_color, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_bottom", target.border_width_bottom, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_top", target.border_width_top, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_left", target.border_width_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_right", target.border_width_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_left", target.corner_radius_top_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_right", target.corner_radius_top_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_left", target.corner_radius_bottom_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_right", target.corner_radius_bottom_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_left", target.expand_margin_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_right", target.expand_margin_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_top", target.expand_margin_top, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_bottom", target.expand_margin_bottom, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_size", target.shadow_size, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_offset", target.shadow_offset, hover_color_tween_duration)
			if hover_scale:
				tween_scale = create_tween()
				tween_scale.tween_property(self, "scale", hover_scale_amount, hover_scale_tween_duration)
			if hover_move:
				tween_position = create_tween()
				tween_position.tween_property(self, "position", hover_move_amount, hover_move_tween_duration)
			if hover_rotate:
				tween_rotation = create_tween()
				tween_rotation.tween_property(self, "rotation_degrees", hover_rotate_amount, hover_rotate_tween_duration)
			if hover_grow:
				tween_size = create_tween()
				tween_size.tween_property(self, "size", starting_size + hover_grow_amount, hover_grow_tween_duration)
		elif current_state == BaseButton.DRAW_PRESSED:
			if pressed_font:
				font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				font_state_tween.tween_property(self, "theme_override_colors/font_pressed_color", font_target, pressed_color_tween_duration)
			if pressed_color:
				state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_color", target.border_color, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_bottom", target.border_width_bottom, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_top", target.border_width_top, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_left", target.border_width_left, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_right", target.border_width_right, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_left", target.corner_radius_top_left, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_right", target.corner_radius_top_right, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_left", target.corner_radius_bottom_left, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_right", target.corner_radius_bottom_right, pressed_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_left", target.expand_margin_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_right", target.expand_margin_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_top", target.expand_margin_top, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_bottom", target.expand_margin_bottom, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_size", target.shadow_size, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_offset", target.shadow_offset, hover_color_tween_duration)
			if pressed_scale:
				tween_scale = create_tween()
				tween_scale.tween_property(self, "scale", pressed_scale_amount, pressed_scale_tween_duration)
			if pressed_move:
				tween_position = create_tween()
				tween_position.tween_property(self, "position", pressed_move_amount, pressed_move_tween_duration)
			if pressed_rotate:
				tween_rotation = create_tween()
				tween_rotation.tween_property(self, "rotation_degrees", pressed_rotate_amount, pressed_rotate_tween_duration)
			if pressed_grow:
				tween_size = create_tween()
				tween_size.tween_property(self, "size", starting_size + pressed_grow_amount, pressed_grow_tween_duration)
		elif current_state == BaseButton.DRAW_HOVER_PRESSED:
			if pressed_font and hover_font:
				font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				font_state_tween.tween_property(self, "theme_override_colors/font_hover_pressed_color", font_target, hover_color_tween_duration)
			if pressed_color and hover_color:
				state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
				state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_color", target.border_color, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_bottom", target.border_width_bottom, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_top", target.border_width_top, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_left", target.border_width_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "border_width_right", target.border_width_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_left", target.corner_radius_top_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_top_right", target.corner_radius_top_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_left", target.corner_radius_bottom_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "corner_radius_bottom_right", target.corner_radius_bottom_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_left", target.expand_margin_left, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_right", target.expand_margin_right, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_top", target.expand_margin_top, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "expand_margin_bottom", target.expand_margin_bottom, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_size", target.shadow_size, hover_color_tween_duration)
				state_tween.tween_property(tween_stylebox, "shadow_offset", target.shadow_offset, hover_color_tween_duration)
			if hover_scale:
				tween_scale = create_tween()
				tween_scale.tween_property(self, "scale", hover_scale_amount, hover_scale_tween_duration)
			if hover_move:
				tween_position = create_tween()
				tween_position.tween_property(self, "position", hover_move_amount, hover_move_tween_duration)
			if hover_rotate:
				tween_rotation = create_tween()
				tween_rotation.tween_property(self, "rotation_degrees", hover_rotate_amount, hover_rotate_tween_duration)
			if hover_grow:
				tween_size = create_tween()
				tween_size.tween_property(self, "size", starting_size + hover_grow_amount, hover_grow_tween_duration)
		elif current_state == BaseButton.DRAW_DISABLED:
			font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			font_state_tween.tween_property(self, "theme_override_colors/font_disabled_color", font_target, hover_color_tween_duration)
			state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_color", target.border_color, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_bottom", target.border_width_bottom, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_top", target.border_width_top, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_left", target.border_width_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_right", target.border_width_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_top_left", target.corner_radius_top_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_top_right", target.corner_radius_top_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_bottom_left", target.corner_radius_bottom_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_bottom_right", target.corner_radius_bottom_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_left", target.expand_margin_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_right", target.expand_margin_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_top", target.expand_margin_top, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_bottom", target.expand_margin_bottom, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "shadow_size", target.shadow_size, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "shadow_offset", target.shadow_offset, hover_color_tween_duration)
		elif current_state == BaseButton.DRAW_NORMAL:
			font_state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			font_state_tween.tween_property(self, "theme_override_colors/font_color", font_target, hover_color_tween_duration)
			state_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
			state_tween.tween_property(tween_stylebox, "bg_color", target.bg_color, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_color", target.border_color, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_bottom", target.border_width_bottom, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_top", target.border_width_top, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_left", target.border_width_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "border_width_right", target.border_width_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_top_left", target.corner_radius_top_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_top_right", target.corner_radius_top_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_bottom_left", target.corner_radius_bottom_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "corner_radius_bottom_right", target.corner_radius_bottom_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_left", target.expand_margin_left, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_right", target.expand_margin_right, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_top", target.expand_margin_top, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "expand_margin_bottom", target.expand_margin_bottom, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "shadow_size", target.shadow_size, hover_color_tween_duration)
			state_tween.tween_property(tween_stylebox, "shadow_offset", target.shadow_offset, hover_color_tween_duration)
			tween_scale = create_tween()
			tween_position = create_tween()
			tween_rotation = create_tween()
			tween_size = create_tween()
			if !hover_animations:
				tween_scale.tween_property(self, "scale", starting_scale, pressed_scale_tween_duration)
				tween_position.tween_property(self, "position", starting_position, pressed_move_tween_duration)
				tween_rotation.tween_property(self, "rotation_degrees", starting_rotation, pressed_rotate_tween_duration)
				tween_size.tween_property(self, "size", starting_size, pressed_grow_tween_duration)
			else:
				tween_scale.tween_property(self, "scale", starting_scale, hover_scale_tween_duration)
				tween_position.tween_property(self, "position", starting_position, hover_move_tween_duration)
				tween_rotation.tween_property(self, "rotation_degrees", starting_rotation, hover_rotate_tween_duration)
				tween_size.tween_property(self, "size", starting_size, hover_grow_tween_duration)
