extends HBoxContainer


func _on_button_pressed() -> void:
	GLOBAL.active_node.create_child()


func _on_btn_delete_pressed() -> void:
	GLOBAL.active_node.delete_node()


func _on_btn_add_first_node_pressed() -> void:
	var first_node : Control = load("res://scenes/node.tscn").instantiate()
	$"../../../../../arbol".add_child(first_node)
	$"../../../../../arbol".cabeza = first_node
	first_node.position = Vector2(614, 190)
	$btn_container3.visible = false
	GLOBAL.active_node = first_node
	first_node.seleccionar()


func _on_btn_minimax_pressed() -> void:
	if $"../../../../../arbol".validar_ultimo_nivel_lleno():
		get_tree().get_first_node_in_group("btn_poda").visible = false
		get_tree().get_first_node_in_group("btn_llenar").visible = false
		get_tree().get_first_node_in_group("btn_editar").visible = true
		GLOBAL.puede_editar_nodos = false
		
		GLOBAL.pasos = []
		$"../../../../../arbol".iniciar_minimax()
		get_tree().get_first_node_in_group("barra_control").mostrar_barra(GLOBAL.pasos.size())
	else:
		get_tree().get_first_node_in_group("err_ultimo_nivel").popup_centered()

func _on_btn_alpha_beta_pressed() -> void:
	if $"../../../../../arbol".validar_ultimo_nivel_lleno():
		get_tree().get_first_node_in_group("btn_minimax").visible = false
		get_tree().get_first_node_in_group("btn_llenar").visible = false
		get_tree().get_first_node_in_group("btn_editar").visible = true
		GLOBAL.puede_editar_nodos = false
		
		var arbol = $"../../../../../arbol"
		GLOBAL.pasos = []
		arbol.cabeza.cambiar_alpha_beta(-INF, INF, true)
		arbol.alpha_beta_pruning(arbol.cabeza, -1) #-1 inicia por izquierda, 1 por derecha
		get_tree().get_first_node_in_group("barra_control").mostrar_barra(GLOBAL.pasos.size())
	else:
		get_tree().get_first_node_in_group("err_ultimo_nivel").popup_centered()

func _on_btn_alpha_beta_derecha_pressed() -> void:
	if $"../../../../../arbol".validar_ultimo_nivel_lleno():
		get_tree().get_first_node_in_group("btn_minimax").visible = false
		get_tree().get_first_node_in_group("btn_llenar").visible = false
		get_tree().get_first_node_in_group("btn_editar").visible = true
		GLOBAL.puede_editar_nodos = false
		
		var arbol = $"../../../../../arbol"
		GLOBAL.pasos = []
		arbol.cabeza.cambiar_alpha_beta(-INF, INF, true)
		arbol.alpha_beta_pruning(arbol.cabeza, 1) #-1 inicia por izquierda, 1 por derecha
		get_tree().get_first_node_in_group("barra_control").mostrar_barra(GLOBAL.pasos.size())
	else:
		get_tree().get_first_node_in_group("err_ultimo_nivel").popup_centered()


func _on_btn_llenar_pressed() -> void:
	var cabeza = $"../../../../../arbol".cabeza
	var hojas : Array = cabeza.get_leaves(cabeza)
	#hojas.sort_custom(Callable($"../../../../../arbol", "comparar_nodos_por_posicion_x"))
	for hoja in hojas:
		hoja.actualizar_valor(randi_range(-100, 100))


func _on_btn_editar_pressed() -> void:
	get_tree().get_first_node_in_group("animaciones").paso_actual = -1
	get_tree().get_first_node_in_group("animaciones").reproducir = false
	get_tree().get_first_node_in_group("barra_control").visible = false
	get_tree().get_first_node_in_group("barra_control").cambiar_valor_barra(0)
	$"../../../../../arbol".nodos_ya_revisados.clear()
	$"../../../../../arbol".nodos_seleccionados.clear()
	GLOBAL.pasos.clear()
	$"../../../../../arbol".reiniciar_arbol()
	get_tree().get_first_node_in_group("btn_minimax").visible = true
	get_tree().get_first_node_in_group("btn_poda").visible = true
	get_tree().get_first_node_in_group("btn_llenar").visible = true
	get_tree().get_first_node_in_group("btn_editar").visible = false
