extends Panel
## FancyTooltip is an interactive Panel/Tooltip with customizable render animations
class_name FancyTooltip


var tool_tip_text: String = ""

var tool_tip_fancy_label: FancyLabel

var parent_node: Node

@export_enum("Left", "Center", "Right", "Fill") var horizontal_alignment: int = 0
@export_enum("Top", "Center", "Bottom", "Fill") var vertical_alignment: int = 0

@export_group("Fancy Label Animations")
@export var on_render_animations: bool = true
## Typewriter (each individual character being printed animation)
@export var type_writer_animation: bool = false
## This is the duration for each character to be printed in the typewriter animation
@export var type_writer_tween_duration: float = 0.05
## Fade (fade in/out animation)
@export var fade_animation: bool = false
## This is the duration for the fade in/out animation.
@export var fade_tween_duration: float = 0.05
## Pop (pop in/out animation)
@export var pop_animation: bool = false
## This is the duration for the pop in/out animation. if type_writer is on it will be the duration of each letter.
@export var pop_tween_duration: float = 0.5
## This is the delay for the pop in/out animation.
@export var pop_tween_delay: float = 0.0
@export var pop_scale_amount: Vector2 = Vector2(1.0, 1.0)

var fancy_tooltip_animations: bool = true
var tooltip_fade_animation: bool = false
var tooltip_fade_tween_duration: float = 0.15
var tooltip_pop_animation: bool = false
var tooltip_pop_tween_duration: float = 0.5
var tooltip_pop_animation_scale_amount: Vector2 = Vector2(1.0, 1.0)

func _ready() -> void:
	self.visible = false
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tooltip_fade_animation:
		self.modulate.a = 0
	parent_node = get_parent()
	tool_tip_text = parent_node.tooltip_text
	parent_node.tooltip_text = ""
	tool_tip_fancy_label = FancyLabel.new()
	tool_tip_fancy_label.text = tool_tip_text
	tool_tip_fancy_label.size = self.size
	tool_tip_fancy_label.position = Vector2(0, 0)
	@warning_ignore("int_as_enum_without_cast")
	tool_tip_fancy_label.horizontal_alignment = horizontal_alignment
	@warning_ignore("int_as_enum_without_cast")
	tool_tip_fancy_label.vertical_alignment = vertical_alignment
	# Feed animation info
	tool_tip_fancy_label.on_render_animations = false
	tool_tip_fancy_label.type_writer_animation = type_writer_animation
	tool_tip_fancy_label.type_writer_tween_duration = type_writer_tween_duration
	tool_tip_fancy_label.fade_animation = fade_animation
	tool_tip_fancy_label.fade_tween_duration = fade_tween_duration
	tool_tip_fancy_label.pop_animation = pop_animation
	tool_tip_fancy_label.pop_tween_duration = pop_tween_duration
	tool_tip_fancy_label.pop_tween_delay = pop_tween_delay
	tool_tip_fancy_label.pop_scale_amount = pop_scale_amount
	tool_tip_fancy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Create Label
	add_child(tool_tip_fancy_label)
	reset()

func _process(_delta) -> void:
	pass

func reset() -> void:
	tool_tip_fancy_label.reset(tool_tip_text)
	if fancy_tooltip_animations:
		if on_render_animations:
			tool_tip_fancy_label.trigger_animations()
		if tooltip_fade_animation:
			var fade_tween: Tween = create_tween()
			fade_tween.tween_property(self, "modulate:a", 0, tooltip_fade_tween_duration)
			await fade_tween.finished
			self.visible = false
		else:
			self.visible = false
		if tooltip_pop_animation:
			self.pivot_offset = self.size / 2
			var pop_tween: Tween = create_tween()
			pop_tween.tween_property(self, "scale", tooltip_pop_animation_scale_amount, tooltip_pop_tween_duration / 2)
			await pop_tween.finished
			pop_tween = create_tween()
			pop_tween.tween_property(self, "scale", Vector2(1.0, 1.0), tooltip_pop_tween_duration / 2)
	else:
		self.visible = false
		self.scale = Vector2(1.0, 1.0)

func play_animations() -> void:
	if fancy_tooltip_animations:
		if on_render_animations:
			tool_tip_fancy_label.trigger_animations()
		if tooltip_fade_animation:
			self.visible = true
			var fade_tween: Tween = create_tween()
			fade_tween.tween_property(self, "modulate:a", 1, tooltip_fade_tween_duration)
		else:
			self.visible = true
		if tooltip_pop_animation:
			self.pivot_offset = self.size / 2
			var pop_tween: Tween = create_tween()
			pop_tween.tween_property(self, "scale", tooltip_pop_animation_scale_amount, tooltip_pop_tween_duration / 2)
			await pop_tween.finished
			pop_tween = create_tween()
			pop_tween.tween_property(self, "scale", Vector2(1.0, 1.0), tooltip_pop_tween_duration / 2)
	else:
		self.visible = true
