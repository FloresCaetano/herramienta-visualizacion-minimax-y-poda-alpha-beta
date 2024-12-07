extends Node
@onready var cabeza : Control = $Node
var nodos_ya_revisados : Array = []
var nodos_seleccionados : Array = []

func iniciar_minimax():
	var nodos_por_nivel = recorrer_arbol_y_separar_por_niveles(cabeza)
	actualizar_altura_arbol()
	minimax(nodos_por_nivel, GLOBAL.tree_height)

func minimax(nodos_por_nivel : Dictionary, siguiente_nivel : int):
	var hojas : Array = nodos_por_nivel[siguiente_nivel]
	hojas.sort_custom(Callable(self, "comparar_nodos_por_posicion_x"))
	var hojas_organizadas : Dictionary = separar_en_hermanos(hojas)
	for padre in hojas_organizadas.keys():
		nodos_seleccionados = []
		var mejor_valor : float = hojas_organizadas[padre][0].valor
		var nodo_con_mejor_valor : Control = hojas_organizadas[padre][0]
		for hermano in hojas_organizadas[padre]:
			GLOBAL.pasos.append("seleccionar:" + str(hermano.get_path()))
			nodos_seleccionados.append(hermano)
			if hermano.nivel % 2 != 0: 
				if hermano.valor > mejor_valor:
					mejor_valor = hermano.valor
					nodo_con_mejor_valor = hermano
			else:
				mejor_valor = minf(hermano.valor, mejor_valor)
				if mejor_valor == hermano.valor:
					nodo_con_mejor_valor = hermano
		GLOBAL.pasos.append("seleccionar:" + str(nodo_con_mejor_valor.linea_padre.get_path())) #Busca la linea que une al mejor nodo
		nodos_seleccionados.append(nodo_con_mejor_valor.linea_padre)
		GLOBAL.pasos.append("seleccionar:" + str(nodo_con_mejor_valor.padre.get_path()))
		nodos_seleccionados.append(nodo_con_mejor_valor.padre)
		GLOBAL.pasos.append("CambiarValor:" + str(nodo_con_mejor_valor.padre.get_path()) + ":" + str(mejor_valor))
		var nodos_seleccionados_string : String = ""
		for nodo in nodos_seleccionados:
			nodos_seleccionados_string += str(nodo.get_path()) + ","
		GLOBAL.pasos.append("deseleccionar:" + nodos_seleccionados_string)
		nodo_con_mejor_valor.padre.valor = mejor_valor
	if hojas[0].padre.padre != null:
		minimax(nodos_por_nivel, siguiente_nivel - 1)
	else:
		GLOBAL.finalizo = "MINIMAX"

func alpha_beta_pruning(nodo : Control, direccion : int):
	var nodos_seleccionados_string : String = ""
	if not nodos_seleccionados.size() == 0:
		for nodo_seleccionado in nodos_seleccionados:
				nodos_seleccionados_string += str(nodo_seleccionado.get_path()) + ","
		GLOBAL.pasos.append("deseleccionar:"+ nodos_seleccionados_string)
		nodos_seleccionados.clear()
	if not nodos_ya_revisados.has(nodo):
		if nodo.padre != null and is_nan(nodo.alpha):
			nodo.cambiar_alpha_beta(nodo.padre.alpha, nodo.padre.beta)
			GLOBAL.pasos.append("seleccionar:" + str(nodo.padre.get_path()))
			nodos_seleccionados.append(nodo.padre)
			GLOBAL.pasos.append("seleccionar:" + str(nodo.linea_padre.get_path()))
			nodos_seleccionados.append(nodo.linea_padre)
			GLOBAL.pasos.append("seleccionar:" + str(nodo.get_path()))
			nodos_seleccionados.append(nodo)
			GLOBAL.pasos.append("cambiar_alpha_beta:" + str(nodo.get_path()) + ":" + str(nodo.padre.alpha) + "," + str(nodo.padre.beta))
		nodos_seleccionados.append(nodo)
		if nodo.hijos.size() == 0:
			nodos_seleccionados.append(nodo)
			actualizar_alpha_beta(nodo, direccion)
		else:
			if nodo.alpha > nodo.beta:
				for hijo in nodo.hijos:
					if not nodos_ya_revisados.has(hijo):
						GLOBAL.pasos.append("podar:" + str(hijo.linea_padre.get_path()))
						nodos_ya_revisados.append(hijo)
			if direccion == 1:
				alpha_beta_pruning(nodo.hijos[0], direccion) #Cambiar por size() -1 para empezar desde la iz
			else:
				alpha_beta_pruning(nodo.hijos[nodo.hijos.size()-1], direccion)
	else:
		if direccion == 1 and not nodo.padre.hijos.size() == nodo.padre.hijos.find(nodo) + 1:
			alpha_beta_pruning(nodo.padre.hijos[nodo.padre.hijos.find(nodo) + 1], direccion)
		elif direccion == -1 and nodo.padre.hijos.find(nodo) -1 >= 0:
			alpha_beta_pruning(nodo.padre.hijos[nodo.padre.hijos.find(nodo) - 1], direccion)
		elif nodo.padre != null:
			if nodo.padre.padre != null:
				actualizar_alpha_beta(nodo.padre, direccion)
				nodos_seleccionados.append(nodo)

func actualizar_alpha_beta(nodo, direccion):
	var nodos_seleccionados_string : String = ""
	if not nodos_seleccionados.size() == 0:
		for nodo_seleccionado in nodos_seleccionados:
				nodos_seleccionados_string += str(nodo_seleccionado.get_path()) + ","
		GLOBAL.pasos.append("deseleccionar:"+ nodos_seleccionados_string)
	if nodo.nivel % 2 == 0:
		nodo.cambiar_alpha_beta(nodo.valor, NAN)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.get_path()))
		nodos_seleccionados.append(nodo)
		GLOBAL.pasos.append("cambiar_alpha_beta:" + str(nodo.get_path()) + ":" + str(nodo.valor) + "," + str(NAN))
		
		var mejor_valor = min(nodo.valor, nodo.padre.valor)
		nodo.padre.valor = mejor_valor
		nodo.padre.cambiar_alpha_beta(NAN, mejor_valor)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.linea_padre.get_path()))
		nodos_seleccionados.append(nodo.linea_padre)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.padre.get_path()))
		nodos_seleccionados.append(nodo.padre)
		GLOBAL.pasos.append("CambiarValor:" + str(nodo.padre.get_path()) + ":" + str(mejor_valor))
		GLOBAL.pasos.append("cambiar_alpha_beta:" + str(nodo.padre.get_path()) + ":" + str(NAN) + "," + str(mejor_valor))
	else:
		nodo.cambiar_alpha_beta(NAN, nodo.valor)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.get_path()))
		nodos_seleccionados.append(nodo)
		GLOBAL.pasos.append("cambiar_alpha_beta:" + str(nodo.get_path()) + ":" + str(NAN) + "," + str(nodo.valor))
		
		var mejor_valor = max(nodo.valor, nodo.padre.valor)
		nodo.padre.valor = mejor_valor
		nodo.padre.cambiar_alpha_beta(mejor_valor, NAN)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.linea_padre.get_path()))
		nodos_seleccionados.append(nodo.linea_padre)
		GLOBAL.pasos.append("seleccionar:" + str(nodo.padre.get_path()))
		nodos_seleccionados.append(nodo.padre)
		GLOBAL.pasos.append("CambiarValor:" + str(nodo.padre.get_path()) + ":" + str(mejor_valor))
		GLOBAL.pasos.append("cambiar_alpha_beta:" + str(nodo.padre.get_path()) + ":" + str(mejor_valor) + "," + str(NAN))
	nodos_ya_revisados.append(nodo)
	alpha_beta_pruning(nodo.padre, direccion)

func recorrer_arbol_y_separar_por_niveles(nodo : Control, nodos_por_nivel : Dictionary = {}):
	if not nodos_por_nivel.has(nodo.nivel):
		nodos_por_nivel[nodo.nivel] = []
	nodos_por_nivel[nodo.nivel].append(nodo)
	for hijo in nodo.hijos:
		recorrer_arbol_y_separar_por_niveles(hijo, nodos_por_nivel)
	return nodos_por_nivel

func separar_en_hermanos(hojas : Array) -> Dictionary:
	var hojas_organizadas_por_hermanos : Dictionary
	for hoja in hojas:
		var padre_hoja : Control = hoja.padre
		if hojas_organizadas_por_hermanos.has(padre_hoja):
			hojas_organizadas_por_hermanos[padre_hoja].append(hoja)
		else:
			hojas_organizadas_por_hermanos[padre_hoja] = [hoja]
	return hojas_organizadas_por_hermanos

func comparar_nodos_por_posicion_x(nodoA: Control, nodoB: Control) -> int:
	return nodoA.global_position.x - nodoB.global_position.x

func actualizar_altura_arbol(hojas : Array[Control] = cabeza.get_leaves(cabeza)):
	var nueva_altura_maxima : int = 0
	for hoja in hojas:
		nueva_altura_maxima = max(hoja.nivel, nueva_altura_maxima)
	GLOBAL.tree_height = nueva_altura_maxima

func validar_ultimo_nivel_lleno():
	var hojas = cabeza.get_leaves(cabeza)
	for hoja in hojas:
		if is_nan(hoja.valor):
			return false
	return true

func reiniciar_arbol(nodo : Control = cabeza):
	nodo.deseleccionar()
	nodo.cambiar_alpha_beta(NAN, NAN, true)
	if nodo.linea_padre != null:
		nodo.linea_padre.default_color = Color(1, 1, 1)
	if nodo.hijos.size() != 0:
		nodo.actualizar_valor(NAN)
	for hijo in nodo.hijos:
		reiniciar_arbol(hijo)
