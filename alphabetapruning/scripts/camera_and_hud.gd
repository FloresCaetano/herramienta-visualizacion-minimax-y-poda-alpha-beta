extends Node2D

func _ready() -> void:
	get_viewport().size_changed.connect(on_window_size_changed)
	$CanvasLayer/VSplitContainer.size = get_viewport().get_window().size

func on_window_size_changed():
	$CanvasLayer/VSplitContainer.size = get_viewport().get_window().size

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("mouse_wheel_click"):
			translate(-event.relative)
	
	if Input.is_action_pressed("mouse_wheel_up"):
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "zoom", self.zoom+Vector2(0.4, 0.4) , 0.3)
		
	elif Input.is_action_pressed("mouse_wheel_down"):
		var tween : Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "zoom", self.zoom-Vector2(0.4, 0.4) , 0.3)
