extends Panel


func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click") and GLOBAL.active_node != null:
			GLOBAL.active_node.deseleccionar()
			get_tree().get_first_node_in_group("txt_delay").release_focus()
