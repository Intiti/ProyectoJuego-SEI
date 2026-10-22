extends PanelContainer

# ==========================================
# MGTS - NIVEL 2: VENTANA DE EJERCICIO DE CÓDIGO Y BANCO DE EJERCICIOS
# LÓGICA DE WHILE, CONTADORES, ACUMULADORES Y CONDICIÓN COMPUESTA
# ==========================================

signal ejercicio_completado(puntos: int, errores: int)

const Estilo = preload("res://scripts/common/ui/ejercicioEstilo.gd")

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
var label_instrucciones: RichTextLabel
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
var botones_slots: Array[Control] = []
var _slots_erroneos: Array[int] = []   # huecos marcados como incorrectos tras Comprobar
var errores: int = 0
var resuelto: bool = false

# Catálogo oficial de respaldo del Banco de Ejercicios Nivel 2 (OA3)
# Enunciados reescritos para que se entiendan mejor (reemplazan al de la escena).
const INSTRUCCIONES_CLARAS := {
	"E2.10": "El constructor arma un puente de troncos. El puente soporta como máximo 20 unidades de peso y 5 troncos.\nLee el peso de cada tronco, acumúlalo y detente cuando el peso total llegue a 20 o ya se hayan colocado 5 troncos; luego muestra el peso total.",
}
# Huecos cuyo orden entre sí no importa (ambas líneas son independientes): E2.10 acepta
# "peso_total = ..." y "piezas = ..." en cualquier orden.
const ORDEN_LIBRE := {"E2.10": [[1, 2]]}

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
		"titulo": "E2.5 · El arroyo de las luciérnagas",
		"oa": "OA3: acumulador con condición de umbral",
		"npc": "Pescador Nyx",
		"instrucciones": "El pescador Nyx necesita reunir al menos 15 unidades de luz para cruzar el arroyo.\nLee el destello de cada luciérnaga con int(input()), acumúlalo en 'luz' mientras sea menor a 15 y al finalizar muestra «Camino iluminado».",
		"plantilla": ["luz = 0", "[?]", "    destello = int(input())", "[?]", "print(\"Camino iluminado\")"],
		"correctas": ["while luz < 15:", "    luz = luz + destello"],
		"disponibles": ["while luz < 15:", "    luz = luz + destello", "while luz <= 0:", "    luz = destello", "while luz > 15:", "    destello = destello + luz"],
		"retroalimentacion": {
			"while luz <= 0:": {
				"error": "La luz inicia en 0. Con '<= 0' solo se ejecutaría en el primer instante y se detendría sin alcanzar la meta de 15.",
				"pista": "El farol debe seguir capturando luciérnagas MIENTRAS la luz sea MENOR a 15 ('while luz < 15:')."
			},
			"    luz = destello": {
				"error": "Esta instrucción sobrescribe el valor de luz en vez de acumular cada destello recibido.",
				"pista": "Para acumular la energía lumínica, suma el valor previo más el nuevo: 'luz = luz + destello'."
			},
			"while luz > 15:": {
				"error": "Como la luz inicial es 0, '0 > 15' es falso desde el primer momento y el ciclo nunca se ejecuta.",
				"pista": "La condición debe permitir el paso mientras el acumulador no haya alcanzado las 15 unidades."
			},
			"    destello = destello + luz": {
				"error": "Estás modificando la variable temporal 'destello' en lugar del acumulador principal 'luz'.",
				"pista": "Actualiza la variable acumuladora sumándole el destello: 'luz = luz + destello'."
			}
		},
		"escena": "res://scenes/nivel_2/5ArroyoDeLuciernagas.tscn"
	},
	"E2.6": {
		"titulo": "E2.6 · La poción de los hongos lunares",
		"oa": "OA3: ciclo con decremento de paso variable",
		"npc": "Alquimista Fael",
		"instrucciones": "La poción mágica hierve a 30 grados y debe enfriarse en agitaciones de a 5 grados.\nUsa un ciclo while para mostrar la temperatura mientras sea mayor que 10; al alcanzar la temperatura ideal muestra «Poción lista».",
		"plantilla": ["temp = 30", "[?]", "    print(temp)", "[?]", "print(\"Poción lista\")"],
		"correctas": ["while temp > 10:", "    temp = temp - 5"],
		"disponibles": ["while temp > 10:", "    temp = temp - 5", "while temp < 10:", "    temp = temp + 5", "while temp == 10:", "    temp = 10"],
		"retroalimentacion": {
			"while temp < 10:": {
				"error": "La poción comienza a 30 grados. La condición '30 < 10' es falsa de inmediato y el ciclo nunca se ejecuta.",
				"pista": "El caldero debe enfriarse MIENTRAS la temperatura sea MAYOR a 10 ('while temp > 10:')."
			},
			"    temp = temp + 5": {
				"error": "Sumar 5 calienta la poción en vez de enfriarla, alejándola del objetivo e iniciando un ciclo infinito.",
				"pista": "Para enfriar la mezcla gradualmente, resta 5 en cada agitación: 'temp = temp - 5'."
			},
			"while temp == 10:": {
				"error": "La temperatura inicial es 30, no 10. La condición es falsa de inicio.",
				"pista": "Utiliza el operador mayor '>' para permitir el enfriamiento desde 30 hacia abajo."
			},
			"    temp = 10": {
				"error": "Fijar 10 de golpe detiene el proceso en una vuelta sin mostrar la reducción gradual requerida.",
				"pista": "Reduce la temperatura de a 5 unidades por vuelta con 'temp = temp - 5'."
			}
		},
		"escena": "res://scenes/nivel_2/6ClaroDeHongos.tscn"
	},
	"E2.7": {
		"titulo": "E2.7 · El despertar del tótem astral",
		"oa": "OA3: ciclo con bandera booleana",
		"npc": "Chamán Zephyr",
		"instrucciones": "El tótem ancestral inicia en reposo (activado = False).\nConsulta orbes con input() mientras no esté activado. Si el orbe es «sagrado», activa la bandera para culminar el ciclo y muestra «Espíritu despierto».",
		"plantilla": ["activado = False", "[?]", "    orbe = input()", "    if orbe == \"sagrado\":", "[?]", "print(\"Espíritu despierto\")"],
		"correctas": ["while not activado:", "        activado = True"],
		"disponibles": ["while not activado:", "        activado = True", "while activado:", "        activado = False", "if not activado:", "        orbe = \"sagrado\""],
		"retroalimentacion": {
			"while activado:": {
				"error": "La bandera 'activado' comienza en False. Como la condición es falsa de inicio, el ciclo nunca comienza.",
				"pista": "El ciclo debe ejecutarse MIENTRAS el tótem NO esté activo ('while not activado:')."
			},
			"        activado = False": {
				"error": "Asignar False mantiene la bandera apagada y el ciclo continuará indefinidamente.",
				"pista": "Al recibir el orbe sagrado, cambia el estado a verdadero: 'activado = True'."
			},
			"if not activado:": {
				"error": "Un condicional 'if' solo evalúa una vez; si el primer orbe no es sagrado, el programa se cierra sin reintentar.",
				"pista": "Para seguir solicitando orbes hasta dar con el correcto, debes emplear un ciclo 'while'."
			},
			"        orbe = \"sagrado\"": {
				"error": "Modificar el texto del orbe no actualiza la bandera booleana 'activado' que controla la salida del ciclo.",
				"pista": "Asigna el valor booleano 'True' a la variable de control 'activado'."
			}
		},
		"escena": "res://scenes/nivel_2/7TotemDeEspiritus.tscn"
	},
	"E2.8": {
		"titulo": "E2.8 · La purga de zarzas espinosas",
		"oa": "OA3: ciclo con contador y filtro condicional",
		"npc": "Exploradora Lyra",
		"instrucciones": "Debes revisar exactamente 4 ramas en el sendero usando el índice 'i'.\nEn cada vuelta lee el tipo de rama por teclado; si el tipo es «veneno», incrementa el contador 'peligros'. Al finalizar muestra el total de peligros.",
		"plantilla": ["i = 0", "peligros = 0", "[?]", "    tipo = input()", "    if tipo == \"veneno\":", "[?]", "    i = i + 1", "print(peligros)"],
		"correctas": ["while i < 4:", "        peligros = peligros + 1"],
		"disponibles": ["while i < 4:", "        peligros = peligros + 1", "while i <= 4:", "        peligros = 1", "while peligros < 4:", "        i = i + 1"],
		"retroalimentacion": {
			"while i <= 4:": {
				"error": "Con '<= 4' el índice 'i' recorre 0, 1, 2, 3 y 4 (5 ramas en total), excediendo las 4 solicitadas.",
				"pista": "Como 'i' comienza en 0, para realizar 4 iteraciones exactas usa 'while i < 4:'."
			},
			"        peligros = 1": {
				"error": "Asignar 1 reinicia la variable en lugar de sumar cada peligro encontrado a lo largo del camino.",
				"pista": "Incrementa el contador sumándole 1 a su valor previo: 'peligros = peligros + 1'."
			},
			"while peligros < 4:": {
				"error": "La repetición debe guiarse por las 4 muestras analizadas ('i'), no por la cantidad de venenos hallados.",
				"pista": "Controla el número de repeticiones con el contador 'i': 'while i < 4:'."
			},
			"        i = i + 1": {
				"error": "Incrementar 'i' dentro del 'if' provocaría un doble avance del índice, saltándose ramas sin inspeccionar.",
				"pista": "Dentro del condicional solo debes incrementar el acumulador 'peligros'."
			}
		},
		"escena": "res://scenes/nivel_2/8LaberintoDeZarzas.tscn"
	},
	"E2.9": {
		"titulo": "E2.9 · El ascenso al risco ventoso",
		"oa": "OA3: ciclo con condición compuesta and",
		"npc": "Centinela Ronin",
		"instrucciones": "La distancia es 20 metros y la energía es 10 unidades.\nMientras la distancia sea mayor a 0 Y la energía sea mayor a 0, avanza restando 5 a distancia y 2 a energía en cada tramo. Al finalizar muestra «Llegada al risco».",
		"plantilla": ["distancia = 20", "energia = 10", "[?]", "    distancia = distancia - 5", "[?]", "print(\"Llegada al risco\")"],
		"correctas": ["while distancia > 0 and energia > 0:", "    energia = energia - 2"],
		"disponibles": ["while distancia > 0 and energia > 0:", "    energia = energia - 2", "while distancia > 0 or energia > 0:", "    energia = energia + 2", "while distancia == 0 and energia == 0:", "    distancia = 0"],
		"retroalimentacion": {
			"while distancia > 0 or energia > 0:": {
				"error": "Con 'or', si la energía llega a 0 pero aún queda distancia, el escalador continuaría sin fuerzas.",
				"pista": "Ambas condiciones deben cumplirse simultáneamente; utiliza el operador lógico 'and'."
			},
			"    energia = energia + 2": {
				"error": "Subir el risco gasta energía, no la regenera; sumar energía generaría un ciclo erróneo.",
				"pista": "Resta 2 a la energía en cada paso: 'energia = energia - 2'."
			},
			"while distancia == 0 and energia == 0:": {
				"error": "Al inicio distancia es 20 y energía es 10; la condición '20 == 0' es falsa de inmediato.",
				"pista": "El ascenso debe operar mientras ambas variables sean mayores a 0: '> 0 and > 0'."
			},
			"    distancia = 0": {
				"error": "Asignar 0 directamente anula el progreso gradual del ascenso.",
				"pista": "La distancia ya se decrementa en la línea superior; en este hueco debes actualizar el consumo de 'energia'."
			}
		},
		"escena": "res://scenes/nivel_2/9RiscoDeLosVientos.tscn"
	},
	"E2.10": {
		"titulo": "E2.10 · El puente de troncos",
		"oa": "OA3: acumulador con condición compuesta",
		"npc": "Constructor Bram",
		"instrucciones": "El constructor arma un puente de troncos. El puente soporta como máximo 20 unidades de peso y 5 troncos.\nLee el peso de cada tronco, acumúlalo y detente cuando el peso total llegue a 20 o ya se hayan colocado 5 troncos; luego muestra el peso total.",
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
		"escena": "res://scenes/nivel_2/10PuenteDeTroncos.tscn"
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
	# Misma pantalla que el puzzle del Nivel 1 (consola a la izquierda, bloques a la derecha);
	# lo único distinto es que aquí se arma todo y se pulsa "Comprobar".
	var ui: Dictionary = Estilo.buildScreen(self, "Bloques disponibles")
	label_titulo = ui["title_right"]
	label_titulo.text = titulo_ejercicio
	label_instrucciones = ui["prompt"]
	Estilo.setPromptText(label_instrucciones, INSTRUCCIONES_CLARAS.get(codigo_ejercicio, texto_instrucciones))
	contenedor_bloques = ui["bank_box"]
	contenedor_codigo = ui["code_box"]
	label_estado = ui["step_label"]
	label_mensaje = ui["feedback"]
	panel_pista = ui["hint_panel"]
	label_pista = ui["hint_label"]
	# El objetivo y el NPC ya no se muestran en pantalla (el nivel 1 tampoco los muestra).
	label_oa = Label.new()
	label_oa.visible = false
	add_child(label_oa)

	var fila: HBoxContainer = ui["buttons"]
	btn_limpiar = Button.new()
	Estilo.styleActionButton(btn_limpiar, "Reiniciar", "neutral")
	btn_limpiar.pressed.connect(limpiar_algoritmo)
	fila.add_child(btn_limpiar)
	btn_comprobar = Button.new()
	Estilo.styleActionButton(btn_comprobar, "Comprobar", "primary")
	btn_comprobar.custom_minimum_size = Vector2(190, 48)
	btn_comprobar.pressed.connect(comprobar_algoritmo)
	fila.add_child(btn_comprobar)

	_construir_panel_banco_modal()

func _construir_panel_banco_modal() -> void:
	panel_banco_modal = PanelContainer.new()
	panel_banco_modal.visible = false
	panel_banco_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_banco_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var style_modal := StyleBoxFlat.new()
	style_modal.bg_color = Estilo.BG
	style_modal.content_margin_left = 32
	style_modal.content_margin_top = 32
	style_modal.content_margin_right = 32
	style_modal.content_margin_bottom = 32
	panel_banco_modal.add_theme_stylebox_override("panel", style_modal)
	add_child(panel_banco_modal)
	
	var vbox_modal = VBoxContainer.new()
	vbox_modal.add_theme_constant_override("separation", 14)
	vbox_modal.mouse_filter = Control.MOUSE_FILTER_PASS
	panel_banco_modal.add_child(vbox_modal)
	
	var fila_modal_top = HBoxContainer.new()
	vbox_modal.add_child(fila_modal_top)
	
	var lbl_modal_titulo = Label.new()
	lbl_modal_titulo.text = "Banco de ejercicios  ·  Nivel 2: El Bosque Profundo"
	lbl_modal_titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_modal_titulo.add_theme_font_size_override("font_size", 26)
	lbl_modal_titulo.add_theme_color_override("font_color", Estilo.TITLE)
	fila_modal_top.add_child(lbl_modal_titulo)
	
	var btn_cerrar_modal = Button.new()
	Estilo.styleActionButton(btn_cerrar_modal, "Volver al ejercicio", "neutral")
	btn_cerrar_modal.custom_minimum_size = Vector2(240, 48)
	btn_cerrar_modal.pressed.connect(func(): panel_banco_modal.visible = false)
	fila_modal_top.add_child(btn_cerrar_modal)
	
	var lbl_modal_sub = Label.new()
	lbl_modal_sub.text = "Catálogo completo de ejercicios pedagógicos para el Objetivo de Aprendizaje OA3 (While, Contadores, Acumuladores)."
	lbl_modal_sub.add_theme_font_size_override("font_size", 18)
	lbl_modal_sub.add_theme_color_override("font_color", Estilo.TEXT)
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
			card_style.bg_color = Estilo.CONSOLE_BG
			card_style.border_color = Estilo.CONSOLE_BORDER
			card_style.set_border_width_all(2)
		else:
			card_style.bg_color = Estilo.CONSOLE_BG
			card_style.border_color = Color(0.35, 0.35, 0.42, 0.8)
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
		lbl_t.text = item["titulo"] + ("  ·  ejercicio actual" if es_actual else "")
		lbl_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_t.add_theme_font_size_override("font_size", 20)
		lbl_t.add_theme_color_override("font_color", Estilo.CONSOLE_TITLE if es_actual else Estilo.TEXT)
		fila_titulo.add_child(lbl_t)
		
		var lbl_est = Label.new()
		if completado:
			lbl_est.text = "Resuelto (+%d pts)" % pts
			lbl_est.add_theme_color_override("font_color", Estilo.OK)
		else:
			lbl_est.text = "Pendiente"
			lbl_est.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
		lbl_est.add_theme_font_size_override("font_size", 17)
		fila_titulo.add_child(lbl_est)
		
		var lbl_detalles = Label.new()
		lbl_detalles.text = item["oa"] + "  ·  " + item["npc"] + "\n" + item["instrucciones"]
		lbl_detalles.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_detalles.add_theme_font_size_override("font_size", 17)
		lbl_detalles.add_theme_color_override("font_color", Color(0.82, 0.78, 1.0))
		vbox_card.add_child(lbl_detalles)
		
		if not es_actual:
			var btn_ir = Button.new()
			Estilo.styleActionButton(btn_ir, "Ir a este ejercicio →", "neutral")
			btn_ir.size_flags_horizontal = Control.SIZE_SHRINK_END
			btn_ir.custom_minimum_size = Vector2(260, 44)
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
	# Un puzzle resuelto queda bloqueado: no vuelve a abrirse.
	var pj_bloqueo = get_node_or_null("/root/PuntajesNivel2")
	if pj_bloqueo and pj_bloqueo.ejercicio_completado(codigo_ejercicio):
		visible = false
		if jugador == null:
			jugador = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if jugador:
			jugador.set_physics_process(true)
		return
	if label_titulo == null:
		_construir_interfaz()
	_cargar_datos_respaldo_si_vacio()
	_resolver_referencias()
	Estilo.setPromptText(label_instrucciones, INSTRUCCIONES_CLARAS.get(codigo_ejercicio, texto_instrucciones))
	visible = true
	resuelto = false
	bloques_en_slots.clear()
	_asegurar_slots()
	_slots_erroneos.clear()
	errores = 0
	label_mensaje.text = ""
	panel_pista.visible = false
	panel_banco_modal.visible = false
	
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and puntajes.ejercicio_completado(codigo_ejercicio):
		var pts = puntajes.obtener_puntos(codigo_ejercicio)
		label_estado.text = "Completado anteriormente (%d pts)" % pts
		label_estado.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
	else:
		label_estado.text = "Pendiente"
		label_estado.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	
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
	
	# Cada opción es un bloque de color, igual que las alternativas del Nivel 1.
	for texto in opciones:
		var btn := Button.new()
		btn.text = String(texto).strip_edges()
		btn.set_meta("raw", String(texto))
		Estilo.styleBankButton(btn, String(texto))
		btn.pressed.connect(_on_bloque_presionado.bind(texto, btn))
		contenedor_bloques.add_child(btn)
		botones_banco.append(btn)

# La lista de huecos siempre tiene un lugar por hueco ("" = vacío), así quitar un bloque deja
# un hueco y los demás no se corren.
func _asegurar_slots() -> void:
	var total: int = respuestas_correctas.size()
	while bloques_en_slots.size() < total:
		bloques_en_slots.append("")
	while bloques_en_slots.size() > total:
		bloques_en_slots.pop_back()

func _on_bloque_presionado(texto: String, btn: Button) -> void:
	if resuelto:
		return
	_asegurar_slots()
	var libre: int = bloques_en_slots.find("")
	if libre == -1:
		mostrar_mensaje("Todos los espacios están ocupados. Haz clic en 'Comprobar' o retira un bloque.", Color("#FFD477"))
		return
	
	bloques_en_slots[libre] = texto
	_slots_erroneos.clear()
	btn.disabled = true
	_renderizar_codigo()

func _on_slot_presionado(indice: int) -> void:
	if resuelto:
		return
	if indice < 0 or indice >= bloques_en_slots.size():
		return
	var texto_removido = bloques_en_slots[indice]
	if texto_removido == "":
		return
	bloques_en_slots[indice] = ""
	_slots_erroneos.clear()
	
	for btn in botones_banco:
		if String(btn.get_meta("raw", btn.text)) == texto_removido and btn.disabled:
			btn.disabled = false
			break
	
	_renderizar_codigo()

func _on_slot_gui_input(event: InputEvent, indice: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_slot_presionado(indice)

func _renderizar_codigo() -> void:
	_asegurar_slots()
	for c in contenedor_codigo.get_children():
		c.queue_free()
	botones_slots.clear()
	
	var slot_index: int = 0
	var flecha_puesta: bool = false
	for linea in plantilla_codigo:
		if linea.begins_with("[?]"):
			var idx: int = slot_index
			var esperado: String = respuestas_correctas[idx] if idx < respuestas_correctas.size() else ""
			var nivel: int = Estilo.indentLevel(esperado)
			var contenido: Control
			var con_flecha: bool = false
			if idx < bloques_en_slots.size() and bloques_en_slots[idx] != "":
				# Bloque colocado: clic para retirarlo; rojo si Comprobar lo marcó incorrecto.
				contenido = Estilo.makeCodeBlock(bloques_en_slots[idx], "wrong" if _slots_erroneos.has(idx) else "locked")
				contenido.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				contenido.gui_input.connect(_on_slot_gui_input.bind(idx))
				botones_slots.append(contenido)
			else:
				contenido = Estilo.makeEmptySlot()
				if not flecha_puesta:
					con_flecha = true
					flecha_puesta = true
			var fila_slot: HBoxContainer = Estilo.makeRow(nivel, contenido, con_flecha)
			contenedor_codigo.add_child(fila_slot)
			if con_flecha:
				Estilo.ensureVisible(fila_slot)
			slot_index += 1
		else:
			# Línea fija del programa (bloque bloqueado, como en el Nivel 1)
			contenedor_codigo.add_child(Estilo.makeRow(Estilo.indentLevel(linea), Estilo.makeCodeBlock(linea, "locked")))
	
	var colocados: int = 0
	for b in bloques_en_slots:
		if b != "":
			colocados += 1
	var texto_estado: String = "Colocados %d de %d" % [colocados, respuestas_correctas.size()]
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	if puntajes and puntajes.ejercicio_completado(codigo_ejercicio):
		texto_estado += "  ·  ya completado (%d pts)" % puntajes.obtener_puntos(codigo_ejercicio)
	label_estado.text = texto_estado

func limpiar_algoritmo() -> void:
	if resuelto:
		return
	bloques_en_slots.clear()
	_asegurar_slots()
	_slots_erroneos.clear()
	_generar_banco_bloques()   # el banco se vuelve a mezclar al reiniciar, igual que en el Nivel 3
	_renderizar_codigo()
	label_mensaje.text = ""

# Un hueco es correcto si tiene el bloque esperado o, en ejercicios con orden libre, si el grupo
# de huecos contiene los mismos bloques (en cualquier orden).
func _hueco_correcto(i: int) -> bool:
	if bloques_en_slots[i] == respuestas_correctas[i]:
		return true
	for grupo in ORDEN_LIBRE.get(codigo_ejercicio, []):
		if grupo.has(i):
			var colocados: Array = []
			var esperados: Array = []
			for g in grupo:
				colocados.append(bloques_en_slots[g])
				esperados.append(respuestas_correctas[g])
			colocados.sort()
			esperados.sort()
			return colocados == esperados
	return false

func comprobar_algoritmo() -> void:
	if resuelto:
		return
	var total_slots = respuestas_correctas.size()
	_asegurar_slots()
	if bloques_en_slots.has(""):
		mostrar_mensaje("Aún faltan bloques por completar en el miaugoritmo.", Color("#FFB74D"))
		return
	
	var es_correcto = true
	var distractor_encontrado: String = ""
	var slot_erroneo: int = -1
	_slots_erroneos.clear()
	
	for i in range(total_slots):
		if not _hueco_correcto(i):
			es_correcto = false
			_slots_erroneos.append(i)
			if slot_erroneo == -1:
				distractor_encontrado = bloques_en_slots[i]
				slot_erroneo = i
	
	if es_correcto:
		_manejar_exito()
	else:
		_renderizar_codigo()   # los bloques incorrectos quedan en rojo
		_manejar_error(distractor_encontrado, slot_erroneo)

func _manejar_exito() -> void:
	resuelto = true
	var num_bloques = respuestas_correctas.size()
	var puntos_ganados = 0
	
	var puntajes = get_node_or_null("/root/PuntajesNivel2")
	var ya_completado: bool = puntajes != null and puntajes.ejercicio_completado(codigo_ejercicio)
	if puntajes:
		puntos_ganados = puntajes.registrar_ejercicio(codigo_ejercicio, num_bloques, errores)
	
	ejercicio_completado.emit(puntos_ganados, errores)
	
	# Igual que el Nivel 1: "¡Correcto!" en verde, sonidito (o RACHA xN), fanfarria y el tablón
	# de MIAUGORITMO COMPLETADO sobre la consola con los bloques en arcoíris.
	panel_pista.visible = false
	mostrar_mensaje("¡Correcto!", Estilo.OK)
	btn_comprobar.disabled = true
	btn_limpiar.disabled = true
	Estilo.playOk(self)
	Estilo.playFanfare()
	var d: Dictionary = GameData.lastBreakdown
	var repetido: bool = ya_completado or String(d.get("code", "")) != codigo_ejercicio
	var lineas: Dictionary = Estilo.scoreLines(2, num_bloques, errores, d, repetido)
	var ultimo: bool = ventana_completado != null and bool(ventana_completado.get("es_ultimo_ejercicio"))
	await Estilo.playTablon(self, Estilo.collectBlocks(contenedor_codigo), {
		"base": lineas["base"], "pen": lineas["pen"], "bonus": lineas["bonus"], "total": lineas["total"],
		"continue_text": "Cruzar el puente hacia el altar →" if ultimo else "Continuar",
	})
	btn_comprobar.disabled = false
	btn_limpiar.disabled = false
	
	# Desbloquear la barrera mística del escenario
	if barrera_mistica and barrera_mistica.has_method("desbloquear_barrera"):
		barrera_mistica.desbloquear_barrera()
	
	visible = false
	_on_completado_cerrado()

func _on_completado_cerrado() -> void:
	if npc_gato and npc_gato.has_method("iniciar_dialogo"):
		npc_gato.iniciar_dialogo(true)
	elif jugador:
		jugador.set_physics_process(true)

func _manejar_error(distractor: String, slot_idx: int = -1) -> void:
	errores += 1
	# Un error reinicia la racha global y queda registrado (misma regla que el Nivel 1).
	var puntajes_err = get_node_or_null("/root/PuntajesNivel2")
	if puntajes_err and puntajes_err.has_method("registrar_error"):
		puntajes_err.registrar_error(codigo_ejercicio, "|".join(bloques_en_slots))
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
	
	mostrar_mensaje(explicacion, Estilo.ERR)
	Estilo.playError(self)
	label_pista.text = "Pista: " + pista_texto
	panel_pista.visible = true

func mostrar_mensaje(texto: String, color: Color) -> void:
	label_mensaje.text = texto
	label_mensaje.add_theme_color_override("font_color", color)

func _unhandled_input(_event: InputEvent) -> void:
	# Sin atajo para cerrar: igual que en el Nivel 1, el puzzle se resuelve y listo.
	pass
