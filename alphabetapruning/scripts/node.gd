extends Control
var valor : float = NAN
var alpha : float = NAN
var beta : float = NAN
var nivel : int = 0
var padre : Control = null
var linea_padre : Line2D = null
var lineas : Array[Line2D] = []
var hijos : Array[Control] = []
var space_from_root_node : int = 1
var child_displacement : float = 0.0

func _ready() -> void:
	var points : PackedVector2Array
	var border : PackedVector2Array
	var border_width : float = 1
	if nivel % 2 == 0:
		points = PackedVector2Array([
			Vector2(20, -10),
			Vector2(40, 40),
			Vector2(0, 40) 
		])
		border = PackedVector2Array([
			Vector2(20, -10 - border_width),
			Vector2(40 + border_width * 0.2, 40 + border_width * 0.2),
			Vector2(-border_width * 0.2, 40+border_width * 0.2)
		])
	else:
		points = PackedVector2Array([
			Vector2(20, 50),
			Vector2(0, 0),
			Vector2(40, 0)
		])
		border = PackedVector2Array([
			Vector2(20, 50 + border_width),
			Vector2(-border_width * 0.2, -border_width * 0.2),
			Vector2(40 + border_width * 0.2, -border_width * 0.2)
		])
	$Polygon2D.polygon = points
	$border/triangle_style.polygon = border

func delete_node():
	var total_childrens_size : int = count_total_childrens()
	if hijos != []:
		if padre != null:
			translate_siblings() #Con cada nivel se encoje un espacio adicional, arregla ese bug
		for i in range(hijos.size()-1, -1, -1):
			hijos[i].delete_node()
	if padre != null:
		var self_index_in_parent = padre.hijos.find(self)
		translate_siblings(-1)
		change_parents_displacement(-30 * total_childrens_size) #Usa una funcion recursiva para propagar la disminucion en el displacement al eliminar un nodo
		padre.hijos.remove_at(self_index_in_parent)
		padre.lineas[self_index_in_parent].queue_free()
		padre.lineas.remove_at(self_index_in_parent)
	else:
		get_tree().get_first_node_in_group("btn_add_first_node").visible = true
	deseleccionar()
	GLOBAL.active_node = null
	self.queue_free()
	$"..".actualizar_altura_arbol()

func change_parents_child_displacement(ammount):
	if padre != null:
		padre.child_displacement -= ammount
		padre.change_parents_child_displacement(ammount)

func count_total_childrens() -> int:
	var total_childrens_count : int = hijos.size()
	for child in hijos:
		total_childrens_count += child.count_total_childrens()
	return total_childrens_count

func create_child():
	var child : Control = load("res://scenes/node.tscn").instantiate()
	var new_position : Vector2 = Vector2.ZERO
	
	child.nivel = nivel+1
	child.padre = self
	
	
	new_position = Vector2(-child_displacement, size.y * 3)
	
	hijos.append(child)
	add_sibling(child)
	child.global_position = global_position + new_position
	
	var line : Line2D = Line2D.new()
	line.width = 2
	line.gradient = null
	line.z_index = -1
	add_child(line)
	line.points = PackedVector2Array([Vector2(20, 20), child.global_position - global_position + Vector2(20, 20)])
	child.linea_padre = line
	child.fix_structure()
	child_displacement += 60
	lineas.append(line)
	update_lines()
	actualizar_valor(NAN)
	
func update_lines():
	for i in range(hijos.size()):
		lineas[i].points = PackedVector2Array([Vector2(20, 20), hijos[i].global_position - global_position + Vector2(20, 20)])

func fix_structure():
	if padre.hijos.size() > 1:
		padre.global_position -= Vector2(30, 0)
		padre.child_displacement -= 30
		padre.translate_self_and_childs(30)
		if padre.padre != null:
			padre.translate_siblings()
			padre.change_parents_displacement(30)

func change_parents_displacement(ammount):
	if padre != null:
		padre.child_displacement += ammount
		padre.change_parents_displacement(ammount)

func translate_siblings(open : int = 1): #1 para abrir, -1 para cerrar
	var siblings : Array[Control] = padre.hijos
	for i in range(siblings.find(self)):
		siblings[i].translate_self_and_childs(+30 * open)
	for i in range(siblings.find(self)+1, siblings.size()):
		siblings[i].translate_self_and_childs(-30 * open)
	padre.update_lines()
	if padre.padre != null:
		padre.translate_siblings(open)

func translate_self_and_childs(distance):
	global_position += Vector2(distance, 0)
	for child in hijos:
		child.translate_self_and_childs(distance)

func get_leaves(node: Control) -> Array[Control]:
	var leaves : Array[Control] = []
	if node.hijos.size() == 0:
		leaves.append(node)
	else:
		for child in node.hijos:
			leaves += get_leaves(child)
	return leaves

func _on_gui_input(_event: InputEvent) -> void:
	if GLOBAL.puede_editar_nodos:
		if Input.is_action_just_pressed("right_click") and hijos.size() == 0:
			if GLOBAL.active_node != null: GLOBAL.active_node.deseleccionar() #Para evitar seleccionar 2 nodos al tiempo
			$border.visible = true
			$LineEdit.visible = true
			$LineEdit.grab_focus()
			GLOBAL.active_node = $"."
		elif Input.is_action_just_released("left_click"):
			if GLOBAL.active_node != null: GLOBAL.active_node.deseleccionar() #Para evitar seleccionar 2 nodos al tiempo
			seleccionar()


func _on_line_edit_text_submitted(new_text: String) -> void:
	var new_value : float = validar_flotante(new_text)
	if is_nan(new_value):
		get_tree().get_first_node_in_group("accept_dialog").popup_centered()
		return
	$CenterContainer/lbl_value.text = new_text
	$LineEdit.text = ""
	$LineEdit.visible = false
	$LineEdit.release_focus()
	valor = new_value

func validar_flotante(text : String):
	if text.is_valid_float():
		return float(text)
	else:
		return NAN

func seleccionar():
	$border.visible = true
	if GLOBAL.puede_editar_nodos:
		GLOBAL.active_node = $"."
		get_tree().get_first_node_in_group("btn_add_node").visible = true
		get_tree().get_first_node_in_group("btn_delete_node").visible = true

func deseleccionar():
	$LineEdit.release_focus()
	$LineEdit.visible = false
	$border.visible = false
	get_tree().get_first_node_in_group("btn_add_node").visible = false
	get_tree().get_first_node_in_group("btn_delete_node").visible = false

func actualizar_valor(nuevo_valor : float):
	valor = nuevo_valor
	if is_nan(valor):
		$CenterContainer/lbl_value.text = ""
	else:
		$CenterContainer/lbl_value.text = str(nuevo_valor)

func regresar_valor():
	valor = NAN
	$CenterContainer/lbl_value.text = ""

func cambiar_alpha_beta(_alpha : float, _beta : float, actualizar_label : bool = false):
	if !is_nan(_alpha) and !is_nan(_beta):
		if actualizar_label:
			$lbl_alphaBeta.text = "α = " + str(_alpha) + "\nβ = " + str(_beta)
		alpha = _alpha
		beta = _beta
		return
	elif !is_nan(_alpha):
		if actualizar_label:
			$lbl_alphaBeta.text = "α = " + str(_alpha) + "\nβ = " + str(beta)
		alpha = _alpha
	elif !is_nan(_beta):
		if actualizar_label:
			$lbl_alphaBeta.text = "α = " + str(alpha) + "\nβ = " + str(_beta)
		beta = _beta
	else:
		$lbl_alphaBeta.text = "α = \nβ = "
		alpha = NAN
		beta = NAN
