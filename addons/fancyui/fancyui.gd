@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("FancyButton", "Control", preload("fancy_button.gd"), preload("fancy_ui.svg"))
	add_custom_type("FancyLabel", "RichTextLabel", preload("fancy_label.gd"), preload("fancy_ui.svg"))
	add_custom_type("FancyTooltip", "Panel", preload("fancy_tooltip.gd"), preload("fancy_ui.svg"))
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("FancyButton")
	remove_custom_type("FancyLabel")
	remove_custom_type("FancyTooltip")
	pass
