extends RichTextLabel
## FancyLabel is an interactive rich text label with customizable render and update animations
class_name FancyLabel

var text_to_display: String = ""

# Animations
@export_group("On Render Animations")
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
@export_group("On Update Animations")
@export var on_update_animations: bool = false
## Typewriter (each individual character being printed animation)
@export var type_writer_update_animation: bool = false
## This is the duration for each character to be printed in the typewriter animation
@export var type_writer_update_tween_duration: float = 0.05
@export_group("Fancy Tooltip Animations")
## This will only function if you have added a FancyTooltip as a child of this node
@export var fancy_tooltip_animations: bool = true
@export var tooltip_fade_animation: bool = true
@export var tooltip_fade_tween_duration: float = 0.15
@export var tooltip_pop_animation: bool = false
@export var tooltip_pop_tween_duration: float = 0.5
@export var tooltip_pop_animation_scale_amount: Vector2 = Vector2(1.0, 1.0)
var fancy_tooltip_node: FancyTooltip

var connected: bool = false

func _ready():
	text_to_display = self.text
	self.text = ""
	if fade_animation:
		self.modulate.a = 0
	on_render_animation()

	if !connected:
		self.mouse_entered.connect(_on_hover)
		self.mouse_exited.connect(_not_hovering)
		connected = true

	for child in self.get_children():
		if child is FancyTooltip:
			fancy_tooltip_node = child as FancyTooltip
			fancy_tooltip_node.tooltip_fade_animation = tooltip_fade_animation
			fancy_tooltip_node.tooltip_fade_tween_duration = tooltip_fade_tween_duration
			fancy_tooltip_node.tooltip_pop_animation = tooltip_pop_animation
			fancy_tooltip_node.tooltip_pop_tween_duration = tooltip_pop_tween_duration
			fancy_tooltip_node.tooltip_pop_animation_scale_amount = tooltip_pop_animation_scale_amount
			fancy_tooltip_node.reset()

func reset(tool_tip_text: String):
	text_to_display = tool_tip_text
	self.text = ""
	if fade_animation:
		self.modulate.a = 0

func _process(_delta):
	if on_update_animations:
		if self.text != text_to_display:
			if type_writer_update_animation:
				type_writer_update_animation_func()
			else:
				self.text = text_to_display

func _on_hover():
	if fancy_tooltip_node:
		fancy_tooltip_node.play_animations()

func _not_hovering():
	if fancy_tooltip_node:
		fancy_tooltip_node.reset()

func on_render_animation() -> void:
	if on_render_animations:
		if type_writer_animation:
			type_writer_animation_func()
		else:
			self.text = text_to_display
		if fade_animation:
			fade_animation_func()
		if pop_animation:
			pop_animation_func()
	else:
		self.text = text_to_display

func trigger_animations() -> void:
	if type_writer_animation:
		type_writer_animation_func()
	else:
		self.text = text_to_display
	if fade_animation:
		fade_animation_func()
	if pop_animation:
		pop_animation_func()

func type_writer_animation_func() -> void:
	if self.text.length() == text_to_display.length():
		return
	for character in text_to_display:
		self.text += character
		var timer = get_tree().create_timer(type_writer_tween_duration)
		await timer.timeout

func type_writer_update_animation_func() -> void:
	if self.text.length() == text_to_display.length():
		return
	var tmp_string: String = text_to_display.replace(self.text, "")
	for character in tmp_string:
		self.text += character
		var timer = get_tree().create_timer(type_writer_update_tween_duration)
		await timer.timeout

func fade_animation_func() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 1, fade_tween_duration)

func pop_animation_func() -> void:
	var timer = get_tree().create_timer(pop_tween_delay)
	await timer.timeout
	if type_writer_animation:
		for chara in text_to_display:
			self.pivot_offset = self.size / 2
			var pop_tween: Tween = create_tween()
			pop_tween.tween_property(self, "scale", pop_scale_amount, pop_tween_duration / 2)
			await pop_tween.finished
			pop_tween = create_tween()
			pop_tween.tween_property(self, "scale", Vector2(1, 1), pop_tween_duration / 2)
			await pop_tween.finished
	else:
		self.pivot_offset = self.size / 2
		var pop_tween: Tween = create_tween()
		pop_tween.tween_property(self, "scale", pop_scale_amount, pop_tween_duration / 2)
		await pop_tween.finished
		pop_tween = create_tween()
		pop_tween.tween_property(self, "scale", Vector2(1, 1), pop_tween_duration / 2)
