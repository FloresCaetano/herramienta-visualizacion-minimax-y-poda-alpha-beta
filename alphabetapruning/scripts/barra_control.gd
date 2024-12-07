extends Control
@onready var ControladorAnimaciones = get_tree().get_first_node_in_group("animaciones")

func mostrar_barra(cantidad_pasos : int):
	$CenterContainer/VSplitContainer/HBoxContainer2/ProgressBar.value = 0
	visible = true
	$CenterContainer/VSplitContainer/HBoxContainer2/ProgressBar.max_value = cantidad_pasos

func _on_btn_atras_pressed() -> void:
	var paso_actual : int = ControladorAnimaciones.paso_actual
	if paso_actual >= 0:
		if paso_actual == GLOBAL.pasos.size(): paso_actual -= 1
		ControladorAnimaciones.animar_hacia_atras(GLOBAL.pasos[paso_actual])
		ControladorAnimaciones.paso_actual -= 1


func _on_btn_adelante_pressed() -> void:
	var paso_actual : int = ControladorAnimaciones.paso_actual
	if paso_actual < GLOBAL.pasos.size()-1:
		ControladorAnimaciones.animar(GLOBAL.pasos[paso_actual + 1])
		ControladorAnimaciones.paso_actual += 1


func _on_btn_reproducir_pressed() -> void:
	var paso_actual : int = ControladorAnimaciones.paso_actual
	ControladorAnimaciones.reproducir = true
	ControladorAnimaciones.animar(GLOBAL.pasos[paso_actual + 1])


func _on_btn_detener_pressed() -> void:
	ControladorAnimaciones.reproducir = false

func cambiar_valor_barra(valor):
	$CenterContainer/VSplitContainer/HBoxContainer2/ProgressBar.value += valor


func _on_line_edit_text_submitted(new_text: String) -> void:
	$CenterContainer/VSplitContainer/HBoxContainer2/LineEdit.release_focus()


func _on_line_edit_focus_exited() -> void:
	var new_text = $CenterContainer/VSplitContainer/HBoxContainer2/LineEdit.text
	if new_text.is_valid_float():
		$"../../../../../../ControladorAnimaciones".velocidad_reproduccion = float(new_text)
	else:
		get_tree().get_first_node_in_group("accept_dialog").popup_centered()
