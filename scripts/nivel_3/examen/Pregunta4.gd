extends "res://scripts/nivel_3/examen/PreguntaExamenBase.gd"

# ==========================================
# MGTS - NIVEL 3 - BANCO EXAMEN PREGUNTA 4
# CLASIFICADOR TÉRMICO MULTIZONA
# ==========================================

const NUMERO_BANCO: int = 4
const ID_PREGUNTA: String = "EX3.P4"
const OA_PREGUNTA: String = "OA2 / OA3: Ciclo while con condicional encadenado if / elif / else y contador"
const TITULO_PREGUNTA: String = "Clasificador térmico multizona"
const INSTRUCCIONES_PREGUNTA: String = (
	"El clasificador revisa 3 zonas térmicas, una por una. Usa un contador llamado zona, que parte en 0, y tres contadores de resultados: criticas, alertas y normales, todos en 0.\n"
	+ "Un ciclo debe repetirse mientras la zona sea menor que 3. En cada vuelta se lee por teclado la temperatura de la zona y se clasifica con una cadena de condiciones, donde solo se ejecuta UNA rama.\n"
	+ "Primera rama: si la temperatura es mayor que 80, la zona es crítica. Segunda rama: si no se cumple la primera, pero la temperatura es mayor que 40, la zona está en alerta. Tercera rama: en cualquier otro caso, la zona es normal. Cada rama suma 1 a su propio contador.\n"
	+ "Al final de cada vuelta se avanza a la siguiente zona. Se muestra el resultado de las 3 zonas al terminar."
)

const PLANTILLA_CODIGO: String = (
	"zona = 0\n"
	+ "criticas = 0\n"
	+ "alertas = 0\n"
	+ "normales = 0\n\n"
	+ "[ Espacio 1 ]\n"
	+ "    temp = int(input(\"Temp: \"))\n"
	+ "    [ Espacio 2 ]\n"
	+ "        criticas = criticas + 1\n"
	+ "    [ Espacio 3 ]\n"
	+ "        alertas = alertas + 1\n"
	+ "    [ Espacio 4 ]\n"
	+ "        normales = normales + 1\n"
	+ "    zona = zona + 1\n\n"
	+ "print(\"Críticas:\", criticas, \"Alertas:\", alertas, \"Normales:\", normales)"
)

const RESPUESTA_CORRECTA: Array[String] = [
	"while zona < 3:",
	"if temp > 80:",
	"elif temp > 40:",
	"else:"
]

const BLOQUES_DISPONIBLES: Array[String] = [
	"while zona < 3:",
	"while zona > 3:",
	"if temp > 80:",
	"if temp < 40:",
	"elif temp > 40:",
	"elif temp > 80:",
	"else:",
	"zona = 0"
]

const TIPOS_ERROR: Dictionary = {
	"while zona > 3:": "condicion_ciclo",
	"if temp < 40:": "orden_rangos",
	"elif temp > 80:": "condicion_elif",
	"zona = 0": "estructura_else"
}
