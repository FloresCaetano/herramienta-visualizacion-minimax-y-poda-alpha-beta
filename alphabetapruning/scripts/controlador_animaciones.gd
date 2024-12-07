extends Node
var paso_actual : int = -1
var reproducir : bool = false
var velocidad_reproduccion = 0.4

func seleccionar(nodo):
	if nodo is Control:
		nodo.seleccionar()
	elif nodo is Line2D:
		nodo.default_color = Color(1, 0, 0)

func deseleccionar(nodo):
	if nodo is Control:
		nodo.deseleccionar()
	elif nodo is Line2D:
		nodo.default_color = Color(1, 1, 1)

func animar(paso : String):
	get_tree().get_first_node_in_group("barra_control").cambiar_valor_barra(+1)
	var paso_dividido = paso.split(":")
	var instruccion : String = paso_dividido[0]
	GLOBAL.historial.append(paso)
	match instruccion:
		"seleccionar":
			seleccionar(get_tree().root.get_node(paso_dividido[1]))
		"deseleccionar":
			var nodos_a_deseleccionar = path_string_a_arreglo(paso_dividido[1])
			for nodo in nodos_a_deseleccionar:
				deseleccionar(nodo)
		"CambiarValor":
			get_tree().root.get_node(paso_dividido[1]).actualizar_valor(float(paso_dividido[2]))
		"cambiar_alpha_beta":
			var nodo = get_tree().root.get_node(paso_dividido[1])
			var alpha : float = string_to_float(paso_dividido[2].split(",")[0])
			var beta : float = string_to_float(paso_dividido[2].split(",")[1])
			nodo.cambiar_alpha_beta(alpha, beta, true)
		"podar":
			var linea = get_tree().root.get_node(paso_dividido[1])
			linea.default_color = Color(0, 0, 0)
	if reproducir:
		$paso.start(velocidad_reproduccion)

func animar_hacia_atras(paso : String):
	get_tree().get_first_node_in_group("barra_control").cambiar_valor_barra(-1)
	var paso_dividido = paso.split(":")
	var instruccion : String = paso_dividido[0]
	match instruccion:
		"deseleccionar":
			var nodos_a_seleccionar = path_string_a_arreglo(paso_dividido[1])
			for nodo in nodos_a_seleccionar:
				seleccionar(nodo)
		"seleccionar":
			deseleccionar(get_tree().root.get_node(paso_dividido[1]))
		"CambiarValor":
			var nodo = get_tree().root.get_node(paso_dividido[1])
			var nuevo_paso = buscar_valores_anteriores(paso)
			var nuevo_paso_dividido = nuevo_paso.split(":")
			nodo.actualizar_valor(string_to_float(nuevo_paso_dividido[2]))
		"cambiar_alpha_beta":
			var nodo = get_tree().root.get_node(paso_dividido[1])
			var nuevo_paso = buscar_valores_anteriores(paso)
			var nuevo_paso_dividido = nuevo_paso.split(":")
			var alpha : float = string_to_float(nuevo_paso_dividido[2].split(",")[0])
			var beta : float = string_to_float(nuevo_paso_dividido[2].split(",")[1])
			nodo.cambiar_alpha_beta(alpha, beta, true)
		"podar":
			var linea = get_tree().root.get_node(paso_dividido[1])
			linea.default_color = Color(1, 1, 1)

func _on_paso_timeout() -> void:
	if reproducir:
		paso_actual += 1
		if paso_actual < GLOBAL.pasos.size():
			animar(GLOBAL.pasos[paso_actual])

func path_string_a_arreglo(path_string : String):
	var nodos : Array
	var path_string_separado = path_string.split(",")
	path_string_separado.resize(path_string_separado.size()-1)
	for path in path_string_separado:
		if path != "":
			nodos.append(get_tree().root.get_node(path))
	return nodos

func string_to_float(numero : String) -> float:
	if numero == "-inf":
		return -INF
	elif numero == "inf":
		return INF
	elif numero == "nan":
		return NAN
	else:
		return float(numero)

func buscar_valores_anteriores(paso : String):
	var paso_dividido = paso.split(":")
	var instruccion = paso_dividido[0] + ":" + paso_dividido[1]
	for i in range(GLOBAL.pasos.find(paso)-1, -1, -1):
		var paso_dividio_en_global = GLOBAL.pasos[i].split(":")
		var instruccion_en_global = paso_dividio_en_global[0] + ":" + paso_dividio_en_global[1]
		if instruccion_en_global == instruccion:
			return GLOBAL.pasos[i]
	if paso_dividido[0] == "CambiarValor":
		return "cambiar_alpha_beta:nodo:nan"
	return "cambiar_alpha_beta:nodo:nan,nan"
	
