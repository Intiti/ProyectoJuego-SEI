extends PanelContainer

# ==========================================
# MGTS - NIVEL 2: VENTANA DE EJERCICIO DE CÓDIGO Y BANCO DE EJERCICIOS
# LÓGICA DE WHILE, CONTADORES, ACUMULADORES Y CONDICIÓN COMPUESTA
# ==========================================

signal ejercicio_completado(puntos: int, errores: int)

@export var codigo_ejercicio: String = "E2.1"
@export var titulo_ejercicio: String = "E2.1 · El sendero de las huellas"
@export var objetivo_aprendizaje: String = "OA3: ciclo con contador"
@export var contexto_npc: String = "Rastreador Chikí"
@export_multiline var texto_instrucciones: String = "Usa un contador y un ciclo while para contar las huellas del gatito."

# Exportados como PackedStringArray para compatibilidad total con la serialización de escenas Godot 4
@export var plantilla_codigo: PackedStringArray = []
@export var respuestas_correctas: PackedStringArray = []
@export var bloques_disponibles: PackedStringArray = []
@export var explicaciones_error: Dictionary = {}
@export var pistas: PackedStringArray = []

# Referencias
var jugador: CharacterBody2D = null
var barrera_mistica = null
var ventana_completado = null
var npc_gato = null

# Nodos UI
var label_titulo: Label
var label_oa: Label
var label_estado: Label
var label_instrucciones: Label
var contenedor_bloques: VBoxContainer
var contenedor_codigo: VBoxContainer
var label_pista: Label
var panel_pista: PanelContainer
var label_mensaje: Label
var btn_comprobar: Button
var btn_limpiar: Button
var btn_cerrar: Button
var btn_ver_banco: Button

var panel_banco_modal: PanelContainer = null
var contenedor_lista_banco: VBoxContainer = null

# Estado del ejercicio actual
var bloques_en_slots: Array[String] = []
var botones_banco: Array[Button] = []
var botones_slots: Array[Button] = []
var errores: int = 0
var resuelto: bool = false

# Catálogo oficial de respaldo del Banco de Ejercicios Nivel 2 (OA3)
const BANCO_DATOS_OFICIAL = {
	"E2.1": {
		"titulo": "E2.1 · El sendero de las huellas",
		"oa": "OA3: ciclo con contador",
		"npc": "Rastreador Chikí",
		"instrucciones": "Ya dentro del Bosque Profundo, un gato te muestra tres huellas frescas de Panko.\nDebes usar una variable contador y un ciclo while para mostrar «Huellas encontradas» una vez por cada huella.",
		"plantilla": ["paso = 0", "[?]", "    print(\"Huellas encontradas\")", "[?]"],
		"correctas": ["while paso < 3:", "    paso = paso + 1"],
		"disponibles": ["while paso < 3:", "    paso = paso + 1", "if paso < 3:", "    paso = paso - 1", "while paso > 3:"],
		"retroalimentacion": {
			"if paso < 3:": {
				"error": "Un condicional 'if' solo se evalúa una única vez; no repite la acción para contar todas las huellas.",
				"pista": "Para repetir instrucciones múltiples veces mientras una condición se cumpla, utiliza la palabra clave 'while'."
			},
			"    paso = paso - 1": {
				"error": "Restar al contador aleja la variable del límite (3) en lugar de acercarla, provocando un ciclo infinito.",
				"pista": "El contador debe avanzar hacia el límite en cada repetición sumando 1 ('paso = paso + 1')."
			},
			"while paso > 3:": {
				"error": "Como 'paso' inicia en 0, la condición '0 > 3' es falsa desde el principio y el ciclo nunca se ejecuta.",
				"pista": "El ciclo debe continuar mientras el número de pasos sea MENOR que 3 ('paso < 3')."
			}
		},
		"escena": "res://scenes/nivel_2/1SenderoDeLasHuellas.tscn"
	},
	"E2.2": {
		"titulo": "E2.2 · La recolección de bayas",
		"oa": "OA3: acumulador",
		"npc": "Druida Sylva (Recolectora)",
		"instrucciones": "La gata recolectora guarda bayas en cuatro cestas: 1, 2, 3 y 4 bayas.\nDebes recorrer las cuatro cestas con un ciclo while y acumular el total para mostrarlo al final.",
		"plantilla": ["total = 0", "cantidad = 1", "[?]", "[?]", "    cantidad = cantidad + 1", "print(total)"],
		"correctas": ["while cantidad <= 4:", "    total = total + cantidad"],
		"disponibles": ["while cantidad <= 4:", "    total = total + cantidad", "while cantidad < 4:", "    total = cantidad", "while cantidad > 4:", "    total = total - cantidad"],
		"retroalimentacion": {
			"while cantidad < 4:": {
				"error": "Con '< 4' el ciclo se detiene en la cesta 3 y deja fuera la cuarta cesta.",
				"pista": "Usa el operador menor o igual '<=' para incluir también la cuarta cesta ('cantidad <= 4')."
			},
			"    total = cantidad": {
				"error": "Esta instrucción sobrescribe el acumulador en cada vuelta en vez de sumar las nuevas bayas al total previo.",
				"pista": "Un acumulador debe sumar su valor previo más la nueva cantidad: 'total = total + cantidad'."
			},
			"while cantidad > 4:": {
				"error": "Como cantidad empieza en 1, la condición '1 > 4' es falsa y el ciclo nunca se ejecuta.",
				"pista": "El ciclo debe comenzar en 1 y continuar mientras la cantidad sea menor o igual a 4."
			},
			"    total = total - cantidad": {
				"error": "Estás restando bayas en lugar de recolectarlas y acumularlas en la cesta.",
				"pista": "Para acumular el total recolectado debes sumar con el operador '+'."
			}
		},
		"escena": "res://scenes/nivel_2/2RecoleccionDeBayas.tscn"
	},
	"E2.3": {
		"titulo": "E2.3 · La linterna de energía",
		"oa": "OA3: condición de parada y decremento",
		"npc": "Guía Milo",
		"instrucciones": "La linterna comienza con 6 unidades de energía y cada paso consume 2.\nDebes mostrar la energía disponible en cada paso mientras sea mayor que 0.",
		"plantilla": ["energia = 6", "[?]", "    print(energia)", "[?]"],
		"correctas": ["while energia > 0:", "    energia = energia - 2"],
		"disponibles": ["while energia > 0:", "    energia = energia - 2", "while energia < 0:", "    energia = energia + 2", "while energia == 0:", "    energia = 0"],
		"retroalimentacion": {
			"while energia < 0:": {
				"error": "La energía inicial es 6. La condición '6 < 0' es falsa de inmediato y la linterna nunca encenderá.",
				"pista": "La linterna debe alumbrar mientras aún le quede energía positiva ('energia > 0')."
			},
			"    energia = energia + 2": {
				"error": "Sumar energía en cada paso aumenta el valor indefinidamente; debe simular el consumo de la linterna.",
				"pista": "Cada paso consume 2 unidades; debes restar 2 a la variable en cada vuelta ('energia = energia - 2')."
			},
			"while energia == 0:": {
				"error": "La energía no empieza en 0, empieza en 6. La condición '6 == 0' es falsa y nunca entraría al ciclo.",
				"pista": "Verifica que el ciclo continúe mientras la energía sea mayor a 0 ('energia > 0')."
			},
			"    energia = 0": {
				"error": "Asignar 0 directamente apaga la linterna en el primer paso sin permitir el consumo gradual.",
				"pista": "Debes reducir la energía paso a paso mediante una resta de 2 en cada iteración."
			}
		},
		"escena": "res://scenes/nivel_2/3LinternaDeEnergia.tscn"
	},
	"E2.4": {
		"titulo": "E2.4 · El guardabosques y los intentos",
		"oa": "OA3: bandera y repetición hasta acertar",
		"npc": "Guardabosques Kaelen",
		"instrucciones": "El guardabosques cuida el paso hacia la espesura y pide la contraseña «hoja» las veces que sea necesario.\nDebes repetir la lectura por teclado hasta que la clave ingresada sea «hoja» y solo entonces mostrar «Acceso permitido».",
		"plantilla": ["clave = \"\"", "[?]", "[?]", "[?]"],
		"correctas": ["while clave != \"hoja\":", "    clave = input()", "print(\"Acceso permitido\")"],
		"disponibles": ["while clave != \"hoja\":", "    clave = input()", "print(\"Acceso permitido\")", "while clave == \"hoja\":", "if clave != \"hoja\":", "    clave = \"hoja\"", "print(\"Acceso bloqueado\")"],
		"retroalimentacion": {
			"while clave == \"hoja\":": {
				"error": "Como 'clave' empieza vacía (''), la condición 'clave == \"hoja\"' es falsa de inicio y nunca se pedirá la contraseña.",
				"pista": "El ciclo debe repetirse MIENTRAS la clave NO sea la correcta ('while clave != \"hoja\":')."
			},
			"if clave != \"hoja\":": {
				"error": "Un 'if' solo evalúa una vez. Si el jugador se equivoca, no permite volver a intentar.",
				"pista": "Para repetir los intentos tantas veces como sea necesario, usa un ciclo 'while'."
			},
			"    clave = \"hoja\"": {
				"error": "Asignar la clave fija en el código no permite que el usuario ingrese su respuesta por teclado.",
				"pista": "Utiliza la función 'input()' para capturar la respuesta del teclado en cada intento."
			},
			"print(\"Acceso bloqueado\")": {
				"error": "Al terminar el ciclo significa que la contraseña fue acertada; no debes mostrar acceso bloqueado.",
				"pista": "Cuando el ciclo termina, el usuario ingresó 'hoja' y corresponde mostrar 'Acceso permitido'."
			}
		},
		"escena": "res://scenes/nivel_2/4GuardabosquesIntentos.tscn"
	},
	"E2.5": {
		"titulo": "E2.5 · El puente de troncos",
		"oa": "OA3: acumulador con condición compuesta",
		"npc": "Constructor Bram",
		"instrucciones": "El constructor arma un puente de troncos que soporta un peso total menor a 20 unidades y un máximo de menos de 5 troncos.\nDebes leer el peso de cada tronco, acumularlo y detenerte cuando el peso total llegue a 20 o se hayan colocado 5 troncos; luego muestra el peso total.",
		"plantilla": ["peso_total = 0", "piezas = 0", "[?]", "    peso = int(input())", "[?]", "[?]", "print(peso_total)"],
		"correctas": ["while peso_total < 20 and piezas < 5:", "    peso_total = peso_total + peso", "    piezas = piezas + 1"],
		"disponibles": ["while peso_total < 20 and piezas < 5:", "    peso_total = peso_total + peso", "    piezas = piezas + 1", "while peso_total < 20 or piezas < 5:", "    peso_total = peso", "    piezas = piezas - 1", "while peso_total >= 20 and piezas >= 5:"],
		"retroalimentacion": {
			"while peso_total < 20 or piezas < 5:": {
				"error": "Con 'or' el ciclo continuaría si se excede el peso mientras las piezas sean < 5, o viceversa, arriesgando el puente.",
				"pista": "Para que el puente sea seguro, el ciclo debe continuar solo mientras AMBOS límites se respeten a la vez; utiliza el operador 'and'."
			},
			"    peso_total = peso": {
				"error": "Sobrescribe el acumulado en vez de sumar el nuevo peso al total previo.",
				"pista": "Para acumular el peso de todos los troncos colocados, debes sumarlo al total: 'peso_total = peso_total + peso'."
			},
			"    piezas = piezas - 1": {
				"error": "Restar piezas aleja el contador del límite de 5 troncos en vez de contabilizar cada tronco colocado.",
				"pista": "Cada nuevo tronco colocado debe sumar 1 al número de piezas: 'piezas = piezas + 1'."
			},
			"while peso_total >= 20 and piezas >= 5:": {
				"error": "Las variables inician en 0. Como 0 no es >= 20 ni >= 5, el ciclo nunca comenzaría.",
				"pista": "El puente comienza vacío; debemos agregar troncos mientras el peso sea menor a 20 y las piezas menores a 5 ('< 20 and < 5')."
			}
		},
		"escena": "res://scenes/nivel_2/5PuenteDeTroncos.tscn"
	}
}

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cargar_datos_respaldo_si_vacio()
	_construir_interfaz()
	call_deferred("_resolver_referencias")

func _cargar_datos_respaldo_si_vacio() -> void:
	if BANCO_DATOS_OFICIAL.has(codigo_ejercicio):
		var d = BANCO_DATOS_OFICIAL[codigo_ejercicio]
		titulo_ejercicio = d["titulo"]
		objetivo_aprendizaje = d["oa"]
		contexto_npc = d["npc"]
		texto_instrucciones = d["instrucciones"]
		plantilla_codigo = PackedStringArray(d["plantilla"])
		respuestas_correctas = PackedStringArray(d["correctas"])
		bloques_disponibles = PackedStringArray(d["disponibles"])
		if d.has("retroalimentacion"):
			explicaciones_error = {}
			for k in d["retroalimentacion"]:
				explicaciones_error[k] = d["retroalimentacion"][k]["error"]

func _resolver_referencias() -> void:
	jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
	var escena = get_parent().get_parent() if get_parent() else null
	if escena:
		barrera_mistica = escena.get_node_or_null("BarreraMistica")
		npc_gato = escena.get_node_or_null("GatoMistico")
	ventana_completado = get_parent().get_node_or_null("VentanaCompletado") if get_parent() else null

func _construir_interfaz() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	custom_minimum_size = Vector2(1060, 640)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style_panel = StyleBoxFlat.new()
	style_panel.bg_color = Color(0.04, 0.07, 0.12, 0.98)
	style_panel.border_color = Color(0.25, 0.85, 0.75, 1.0)
	style_panel.set_border_width_all(3)
	style_panel.set_corner_radius_all(16)
	style_panel.content_margin_left = 24
	style_panel.content_margin_top = 18
	style_panel.content_margin_right = 24
	style_panel.content_margin_bottom = 18
	add_theme_stylebox_override("panel", style_panel)
	
	var vbox_principal = VBoxContainer.new()
	vbox_principal.add_theme_constant_override("separation", 10)
	vbox_principal.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_principal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_principal.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox_principal)
	
	# 1. Cabecera
	var fila_header = HBoxContainer.new()
	fila_header.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_principal.add_child(fila_header)
	
	label_titulo = Label.new()
	label_titulo.text = titulo_ejercicio
	label_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_titulo.add_theme_font_size_override("font_size", 22)
	label_titulo.add_theme_color_override("font_color", Color(0.3, 0.95, 0.85))
	fila_header.add_child(label_titulo)
	
	btn_ver_banco = Button.new()
	btn_ver_banco.text = "📋 Banco de Ejercicios"
	btn_ver_banco.custom_minimum_size = Vector2(180, 34)
	btn_ver_banco.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_ver_banco.pressed.connect(toggle_banco_modal)
	fila_header.add_child(btn_ver_banco)
	
	btn_cerrar = Button.new()
	btn_cerrar.text = "✕ Cerrar"
	btn_cerrar.custom_minimum_size = Vector2(90, 34)
	btn_cerrar.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_cerrar.pressed.connect(cerrar_reto)
	fila_header.add_child(btn_cerrar)
	
	# 2. Barra de Metadatos
	var fila_meta = HBoxContainer.new()
	fila_meta.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_principal.add_child(fila_meta)
	
	label_oa = Label.new()
	label_oa.text = "🎯 " + objetivo_aprendizaje + "  |  👤 NPC: " + contexto_npc
	label_oa.add_theme_font_size_override("font_size", 14)
	label_oa.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
	label_oa.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_meta.add_child(label_oa)
	
	label_estado = Label.new()
	label_estado.text = "Estado: Pendiente"
	label_estado.add_theme_font_size_override("font_size", 14)
	label_estado.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	fila_meta.add_child(label_estado)
	
	# 3. Instrucciones
	label_instrucciones = Label.new()
	label_instrucciones.text = texto_instrucciones
	label_instrucciones.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_instrucciones.add_theme_font_size_override("font_size", 15)
	label_instrucciones.add_theme_color_override("font_color", Color(0.9, 0.93, 0.98))
	vbox_principal.add_child(label_instrucciones)
	
	# 4. Columnas: Banco de Bloques y Algoritmo
	var split = HBoxContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 18)
	split.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_principal.add_child(split)
	
	# Columna Izquierda: Banco de Bloques
	var col_izq = VBoxContainer.new()
	col_izq.custom_minimum_size = Vector2(460, 320)
	col_izq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_izq.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_izq.mouse_filter = Control.MOUSE_FILTER_PASS
	split.add_child(col_izq)
	
	var lbl_banco = Label.new()
	lbl_banco.text = "📦 Banco de Bloques (haz clic para insertar):"
	lbl_banco.add_theme_font_size_override("font_size", 14)
	lbl_banco.add_theme_color_override("font_color", Color(0.4, 0.95, 0.8))
	col_izq.add_child(lbl_banco)
	
	var scroll_bloques = ScrollContainer.new()
	scroll_bloques.custom_minimum_size = Vector2(440, 300)
	scroll_bloques.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_bloques.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_bloques.mouse_filter = Control.MOUSE_FILTER_PASS
	col_izq.add_child(scroll_bloques)
	
	contenedor_bloques = VBoxContainer.new()
	contenedor_bloques.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor_bloques.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenedor_bloques.add_theme_constant_override("separation", 8)
	contenedor_bloques.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_bloques.add_child(contenedor_bloques)
	
	# Columna Derecha: Algoritmo
	var col_der = VBoxContainer.new()
	col_der.custom_minimum_size = Vector2(460, 320)
	col_der.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_der.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col_der.mouse_filter = Control.MOUSE_FILTER_PASS
	split.add_child(col_der)
	
	var lbl_alg = Label.new()
	lbl_alg.text = "🛠️ Miaugoritmo en Construcción (clic en un bloque para retirar):"
	lbl_alg.add_theme_font_size_override("font_size", 14)
	lbl_alg.add_theme_color_override("font_color", Color(0.4, 0.95, 0.8))
	col_der.add_child(lbl_alg)
	
	var panel_codigo = PanelContainer.new()
	panel_codigo.custom_minimum_size = Vector2(440, 300)
	panel_codigo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_codigo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_codigo.mouse_filter = Control.MOUSE_FILTER_PASS
	var style_cod = StyleBoxFlat.new()
	style_cod.bg_color = Color(0.02, 0.04, 0.07, 0.95)
	style_cod.border_color = Color(0.18, 0.35, 0.45, 1.0)
	style_cod.set_border_width_all(2)
	style_cod.set_corner_radius_all(10)
	style_cod.content_margin_left = 16
	style_cod.content_margin_top = 12
	style_cod.content_margin_right = 16
	style_cod.content_margin_bottom = 12
	panel_codigo.add_theme_stylebox_override("panel", style_cod)
	col_der.add_child(panel_codigo)
	
	var scroll_cod = ScrollContainer.new()
	scroll_cod.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_cod.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_cod.mouse_filter = Control.MOUSE_FILTER_PASS
	panel_codigo.add_child(scroll_cod)
	
	contenedor_codigo = VBoxContainer.new()
	contenedor_codigo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor_codigo.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenedor_codigo.add_theme_constant_override("separation", 6)
	contenedor_codigo.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_cod.add_child(contenedor_codigo)
	
	# 5. Panel de Pistas
	panel_pista = PanelContainer.new()
	panel_pista.visible = false
	panel_pista.mouse_filter = Control.MOUSE_FILTER_PASS
	var style_pista = StyleBoxFlat.new()
	style_pista.bg_color = Color(0.14, 0.1, 0.03, 0.95)
	style_pista.border_color = Color(0.95, 0.75, 0.2, 1.0)
	style_pista.set_border_width_all(2)
	style_pista.set_corner_radius_all(8)
	style_pista.content_margin_left = 14
	style_pista.content_margin_top = 8
	style_pista.content_margin_right = 14
	style_pista.content_margin_bottom = 8
	panel_pista.add_theme_stylebox_override("panel", style_pista)
	vbox_principal.add_child(panel_pista)
	
	label_pista = Label.new()
	label_pista.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_pista.add_theme_font_size_override("font_size", 14)
	label_pista.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45))
	panel_pista.add_child(label_pista)
	
	label_mensaje = Label.new()
	label_mensaje.text = ""
	label_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_mensaje.add_theme_font_size_override("font_size", 15)
	vbox_principal.add_child(label_mensaje)
	
	# 6. Botones de Acción
	var fila_botones = HBoxContainer.new()
	fila_botones.alignment = BoxContainer.ALIGNMENT_END
	fila_botones.add_theme_constant_override("separation", 16)
	fila_botones.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_principal.add_child(fila_botones)
	
	btn_limpiar = Button.new()
	btn_limpiar.text = "↺ Limpiar Algoritmo"
	btn_limpiar.custom_minimum_size = Vector2(170, 42)
	btn_limpiar.mouse_filter = Control.MOUSE_FILTER_STOP
	btn_limpiar.pressed.connect(limpiar_algoritmo)
	fila_botones.add_child(btn_limpiar)
	
	btn_comprobar = Button.new()
	btn_comprobar.text = "✓ Comprobar Algoritmo"
	btn_comprobar.custom_minimum_size = Vector2(210, 42)
	btn_comprobar.add_theme_font_size_override("font_size", 17)
	btn_comprobar.mouse_filter = Control.MOUSE_FILTER_STOP
	var style_btn = StyleBoxFlat.new()
	style_btn.bg_color = Color(0.12, 0.5, 0.4, 1.0)
	style_btn.border_color = Color(0.3, 0.95, 0.8, 1.0)
	style_btn.set_border_width_all(1)
	style_btn.set_corner_radius_all(8)
	btn_comprobar.add_theme_stylebox_override("normal", style_btn)
	btn_comprobar.pressed.connect(comprobar_algoritmo)
	fila_botones.add_child(btn_comprobar)
	
	_construir_panel_banco_modal()

func _construir_panel_banco_modal() -> void:
	panel_banco_modal = PanelContainer.new()
	panel_banco_modal.visible = false
	panel_banco_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_banco_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style_modal = StyleBoxFlat.new()
	style_modal.bg_color = Color(0.03, 0.05, 0.09, 0.98)
	style_modal.border_color = Color(0.3, 0.85, 0.95, 1.0)
	style_modal.set_border_width_all(3)
	style_modal.set_corner_radius_all(14)
	style_modal.content_margin_left = 28
	style_modal.content_margin_top = 22
	style_modal.content_margin_right = 28
	style_modal.content_margin_bottom = 22
	panel_banco_modal.add_theme_stylebox_override("panel", style_modal)
	add_child(panel_banco_modal)
	
	var vbox_modal = VBoxContainer.new()
	vbox_modal.add_theme_constant_override("separation", 14)
	vbox_modal.mouse_filter = Control.MOUSE_FILTER_PASS
	panel_banco_modal.add_child(vbox_modal)
	
	var fila_modal_top = HBoxContainer.new()
	vbox_modal.add_child(fila_modal_top)
	
	var lbl_modal_titulo = Label.new()
	lbl_modal_titulo.text = "📚 BANCO DE EJERCICIOS - NIVEL 2: EL BOSQUE PROFUNDO"
	lbl_modal_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_modal_titulo.add_theme_font_size_override("font_size", 22)
	lbl_modal_titulo.add_theme_color_override("font_color", Color(0.35, 0.95, 0.85))
	fila_modal_top.add_child(lbl_modal_titulo)
	
	var btn_cerrar_modal = Button.new()
	btn_cerrar_modal.text = "✕ Volver al Ejercicio"
	btn_cerrar_modal.custom_minimum_size = Vector2(170, 36)
	btn_cerrar_modal.pressed.connect(func(): panel_banco_modal.visible = false)
	fila_modal_top.add_child(btn_cerrar_modal)
	
	var lbl_modal_sub = Label.new()
	lbl_modal_sub.text = "Catálogo completo de ejercicios pedagógicos para el Objetivo de Aprendizaje OA3 (While, Contadores, Acumuladores)."
	lbl_modal_sub.add_theme_font_size_override("font_size", 14)
	lbl_modal_sub.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
	vbox_modal.add_child(lbl_modal_sub)
	
	var scroll_banco = ScrollContainer.new()
	scroll_banco.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_banco.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox_modal.add_child(scroll_banco)
	
	contenedor_lista_banco = VBoxContainer.new()
	contenedor_lista_banco.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contenedor_lista_banco.add_theme_constant_override("separation", 12)
	contenedor_lista_banco.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll_banco.add_child(contenedor_lista_banco)

func toggle_banco_modal() -> void:
	if panel_banco_modal.visible:
		panel_banco_modal.visible = false
	else:
		_poblar_lista_banco_ejercicios()
		panel_banco_modal.visible = true

func _poblar_lista_banco_ejercicios() -> void:
	for c in contenedor_lista_banco.get_children():
		c.queue_free()
	
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	
	for cod in BANCO_DATOS_OFICIAL.keys():
		var item = BANCO_DATOS_OFICIAL[cod]
		var card = PanelContainer.new()
		var card_style = StyleBoxFlat.new()
		var es_actual = (cod == codigo_ejercicio)
		var completado = puntajes.ejercicio_completado(cod) if puntajes else false
		var pts = puntajes.obtener_puntos(cod) if puntajes else 0
		
		if es_actual:
			card_style.bg_color = Color(0.08, 0.18, 0.25, 0.95)
			card_style.border_color = Color(0.3, 0.95, 0.85, 1.0)
			card_style.set_border_width_all(2)
		else:
			card_style.bg_color = Color(0.05, 0.08, 0.13, 0.9)
			card_style.border_color = Color(0.18, 0.35, 0.45, 0.8)
			card_style.set_border_width_all(1)
		
		card_style.set_corner_radius_all(10)
		card_style.content_margin_left = 18
		card_style.content_margin_top = 12
		card_style.content_margin_right = 18
		card_style.content_margin_bottom = 12
		card.add_theme_stylebox_override("panel", card_style)
		
		var vbox_card = VBoxContainer.new()
		vbox_card.add_theme_constant_override("separation", 6)
		card.add_child(vbox_card)
		
		var fila_titulo = HBoxContainer.new()
		vbox_card.add_child(fila_titulo)
		
		var lbl_t = Label.new()
		lbl_t.text = item["titulo"] + (" (📍 Ejercicio actual)" if es_actual else "")
		lbl_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_t.add_theme_font_size_override("font_size", 17)
		lbl_t.add_theme_color_override("font_color", Color(0.35, 0.95, 0.85) if es_actual else Color(0.85, 0.92, 1.0))
		fila_titulo.add_child(lbl_t)
		
		var lbl_est = Label.new()
		if completado:
			lbl_est.text = "★ RESUELTO (+%d pts)" % pts
			lbl_est.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
		else:
			lbl_est.text = "○ PENDIENTE"
			lbl_est.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
		lbl_est.add_theme_font_size_override("font_size", 14)
		fila_titulo.add_child(lbl_est)
		
		var lbl_detalles = Label.new()
		lbl_detalles.text = "🎯 " + item["oa"] + "  |  👤 " + item["npc"] + "\n" + item["instrucciones"]
		lbl_detalles.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_detalles.add_theme_font_size_override("font_size", 14)
		lbl_detalles.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9))
		vbox_card.add_child(lbl_detalles)
		
		if not es_actual:
			var btn_ir = Button.new()
			btn_ir.text = "Ir a este Escenario / Ejercicio →"
			btn_ir.size_flags_horizontal = Control.SIZE_SHRINK_END
			btn_ir.custom_minimum_size = Vector2(230, 32)
			var ruta_escena = item["escena"]
			btn_ir.pressed.connect(func():
				panel_banco_modal.visible = false
				visible = false
				if jugador:
					jugador.set_physics_process(true)
				get_tree().change_scene_to_file(ruta_escena)
			)
			vbox_card.add_child(btn_ir)
		
		contenedor_lista_banco.add_child(card)

func abrir_reto() -> void:
	if label_titulo == null:
		_construir_interfaz()
	_cargar_datos_respaldo_si_vacio()
	_resolver_referencias()
	visible = true
	resuelto = false
	bloques_en_slots.clear()
	errores = 0
	label_mensaje.text = ""
	panel_pista.visible = false
	panel_banco_modal.visible = false
	
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and puntajes.ejercicio_completado(codigo_ejercicio):
		var pts = puntajes.obtener_puntos(codigo_ejercicio)
		label_estado.text = "Estado: Completado anteriormente ★ (%d pts)" % pts
		label_estado.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	else:
		label_estado.text = "Estado: Pendiente"
		label_estado.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	
	_generar_banco_bloques()
	_renderizar_codigo()

func cerrar_reto() -> void:
	visible = false
	panel_banco_modal.visible = false
	if jugador:
		jugador.set_physics_process(true)
		jugador.set_process_unhandled_input(true)
		jugador.set_process_input(true)

func _generar_banco_bloques() -> void:
	for c in contenedor_bloques.get_children():
		c.queue_free()
	botones_banco.clear()
	
	# Asegurar que todas las opciones sean únicas sin repeticiones
	var opciones_unicas: Array = []
	for op in bloques_disponibles:
		if not opciones_unicas.has(op):
			opciones_unicas.append(op)
	
	var opciones: Array = opciones_unicas.duplicate()
	opciones.shuffle()
	
	for texto in opciones:
		var btn = Button.new()
		btn.text = texto
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(420, 42)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.add_theme_font_size_override("font_size", 15)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.08, 0.16, 0.24, 0.95)
		style.border_color = Color(0.2, 0.6, 0.75, 1.0)
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 12
		style.content_margin_right = 12
		btn.add_theme_stylebox_override("normal", style)
		
		btn.pressed.connect(_on_bloque_presionado.bind(texto, btn))
		contenedor_bloques.add_child(btn)
		botones_banco.append(btn)

func _on_bloque_presionado(texto: String, btn: Button) -> void:
	var total_slots = respuestas_correctas.size()
	if bloques_en_slots.size() >= total_slots:
		mostrar_mensaje("Todos los espacios están ocupados. Haz clic en 'Comprobar' o retira un bloque.", Color("#FFD477"))
		return
	
	bloques_en_slots.append(texto)
	btn.disabled = true
	btn.modulate = Color(0.5, 0.5, 0.5, 0.6)
	_renderizar_codigo()

func _on_slot_presionado(indice: int) -> void:
	if indice < 0 or indice >= bloques_en_slots.size():
		return
	var texto_removido = bloques_en_slots[indice]
	bloques_en_slots.remove_at(indice)
	
	for btn in botones_banco:
		if btn.text == texto_removido and btn.disabled:
			btn.disabled = false
			btn.modulate = Color.WHITE
			break
	
	_renderizar_codigo()

func _renderizar_codigo() -> void:
	for c in contenedor_codigo.get_children():
		c.queue_free()
	botones_slots.clear()
	
	var slot_index: int = 0
	for linea in plantilla_codigo:
		if linea.begins_with("[?]"):
			var idx = slot_index
			var slot_btn = Button.new()
			slot_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			slot_btn.custom_minimum_size = Vector2(400, 38)
			slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot_btn.mouse_filter = Control.MOUSE_FILTER_STOP
			
			if idx < bloques_en_slots.size():
				slot_btn.text = bloques_en_slots[idx]
				var style_slot = StyleBoxFlat.new()
				style_slot.bg_color = Color(0.12, 0.35, 0.45, 1.0)
				style_slot.border_color = Color(0.3, 0.9, 0.8, 1.0)
				style_slot.set_border_width_all(2)
				style_slot.set_corner_radius_all(6)
				style_slot.content_margin_left = 14
				slot_btn.add_theme_stylebox_override("normal", style_slot)
				slot_btn.pressed.connect(_on_slot_presionado.bind(idx))
			else:
				slot_btn.text = "   [? Haz clic en un bloque del banco para insertar aquí ]"
				var style_vacio = StyleBoxFlat.new()
				style_vacio.bg_color = Color(0.06, 0.08, 0.12, 0.8)
				style_vacio.border_color = Color(0.4, 0.5, 0.6, 0.8)
				style_vacio.set_border_width_all(1)
				style_vacio.set_corner_radius_all(6)
				style_vacio.content_margin_left = 14
				slot_btn.add_theme_stylebox_override("normal", style_vacio)
				slot_btn.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
			
			contenedor_codigo.add_child(slot_btn)
			botones_slots.append(slot_btn)
			slot_index += 1
		else:
			var lbl = Label.new()
			lbl.text = "  " + linea
			lbl.add_theme_font_size_override("font_size", 16)
			lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
			contenedor_codigo.add_child(lbl)

func limpiar_algoritmo() -> void:
	bloques_en_slots.clear()
	for btn in botones_banco:
		btn.disabled = false
		btn.modulate = Color.WHITE
	_renderizar_codigo()
	label_mensaje.text = ""

func comprobar_algoritmo() -> void:
	var total_slots = respuestas_correctas.size()
	if bloques_en_slots.size() < total_slots:
		mostrar_mensaje("Aún faltan bloques por completar en el miaugoritmo.", Color("#FFB74D"))
		return
	
	var es_correcto = true
	var distractor_encontrado: String = ""
	var slot_erroneo: int = -1
	
	for i in range(total_slots):
		if bloques_en_slots[i] != respuestas_correctas[i]:
			es_correcto = false
			distractor_encontrado = bloques_en_slots[i]
			slot_erroneo = i
			break
	
	if es_correcto:
		_manejar_exito()
	else:
		_manejar_error(distractor_encontrado, slot_erroneo)

func _manejar_exito() -> void:
	resuelto = true
	var num_bloques = respuestas_correctas.size()
	var puntos_ganados = 0
	
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes:
		puntos_ganados = puntajes.registrar_ejercicio(codigo_ejercicio, num_bloques, errores)
	
	ejercicio_completado.emit(puntos_ganados, errores)
	
	# Desbloquear la barrera mística del escenario
	if barrera_mistica and barrera_mistica.has_method("desbloquear_barrera"):
		barrera_mistica.desbloquear_barrera()
	
	visible = false
	
	if ventana_completado and ventana_completado.has_method("mostrar_celebracion"):
		if not ventana_completado.completado_cerrado.is_connected(_on_completado_cerrado):
			ventana_completado.completado_cerrado.connect(_on_completado_cerrado, CONNECT_ONE_SHOT)
		ventana_completado.mostrar_celebracion(codigo_ejercicio, titulo_ejercicio, puntos_ganados, errores)
	else:
		_on_completado_cerrado()

func _on_completado_cerrado() -> void:
	if npc_gato and npc_gato.has_method("iniciar_dialogo"):
		npc_gato.iniciar_dialogo(true)
	elif jugador:
		jugador.set_physics_process(true)

func _manejar_error(distractor: String, slot_idx: int = -1) -> void:
	errores += 1
	var explicacion: String = ""
	var pista_texto: String = ""
	
	# 1. Buscar en el catálogo de retroalimentación específica del ejercicio
	var retro: Dictionary = {}
	if BANCO_DATOS_OFICIAL.has(codigo_ejercicio) and BANCO_DATOS_OFICIAL[codigo_ejercicio].has("retroalimentacion"):
		retro = BANCO_DATOS_OFICIAL[codigo_ejercicio]["retroalimentacion"]
	
	if retro.has(distractor):
		var info: Dictionary = retro[distractor]
		explicacion = info.get("error", "")
		pista_texto = info.get("pista", "")
	elif explicaciones_error.has(distractor):
		explicacion = explicaciones_error[distractor]
	
	# 2. Si el bloque colocado es una de las respuestas correctas pero en la ranura equivocada:
	if explicacion.is_empty() and respuestas_correctas.has(distractor):
		explicacion = "Orden incorrecto: El bloque '%s' es válido, pero no corresponde a este paso del miaugoritmo." % distractor.strip_edges()
		pista_texto = "Revisa la secuencia: primero la cabecera while con su condición, luego las acciones dentro del ciclo y finalmente el acumulador/contador."
	
	# 3. Fallbacks
	if explicacion.is_empty():
		explicacion = "Revisa la condición de parada y la actualización de las variables en este paso."
	
	if pista_texto.is_empty():
		if pistas.size() > 0:
			var idx_p = clampi(errores - 1, 0, pistas.size() - 1)
			pista_texto = pistas[idx_p]
		else:
			pista_texto = "Comprueba que la condición permita repetir y que las variables se modifiquen en cada vuelta."
	
	mostrar_mensaje("Error en el algoritmo: " + explicacion, Color("#FF6E6E"))
	label_pista.text = "💡 Pista: " + pista_texto
	panel_pista.visible = true

func mostrar_mensaje(texto: String, color: Color) -> void:
	label_mensaje.text = texto
	label_mensaje.add_theme_color_override("font_color", color)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo):
		get_viewport().set_input_as_handled()
		cerrar_reto()
