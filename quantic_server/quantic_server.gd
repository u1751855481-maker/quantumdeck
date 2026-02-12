class_name QuanticServer extends Node

@onready var conector = $ConectorCuantico

# Lista para guardar el historial de puertas aplicadas
var historial_instrucciones = []

func _ready():
	conector.request_completed.connect(_al_recibir_respuesta)

func _on_boton_prueba_pressed():
	print(">>> ¡BOTÓN FÍSICO PRESIONADO! <<<")
	aplicar_hadamard()

# --- FUNCIONES DE CONTROL ---

func aplicar_hadamard():
	_enviar_instruccion("h")
func aplicar_rotacion_x():
	_enviar_instruccion("rx", [1.57])

# Esto lo que hace es basicamente reiniciar los valores, porque si haces un hadamar de un hadamar es identidad y no tiene sentido
func reiniciar_circuito():
	historial_instrucciones.clear()
	print("--- Circuito reiniciado (Qubit en estado |0>) ---")

# --- LÓGICA DE ENVÍO ---

func _enviar_instruccion(nombre_puerta: String, parametros: Array = []):
	print("\n--- INICIO _enviar_instruccion ---")
	print("1. Preparando puerta: ", nombre_puerta)
	
	if conector == null:
		print("ERROR FATAL: El nodo 'ConectorCuantico' no está asignado.")
		return
	
	# Añadimos al historial
	historial_instrucciones.append({
		"puerta": nombre_puerta,
		"params": parametros
	})
	

	var url = "http://127.0.0.1:8000/ejecutar_circuito"
	var headers = ["Content-Type: application/json"]
	
	var datos = {
		"instrucciones": historial_instrucciones
	}
	
	var json_envio = JSON.stringify(datos)
	print("2. JSON generado: ", json_envio)
	
	var error = conector.request(url, headers, HTTPClient.METHOD_POST, json_envio)
	
	if error != OK:
		print("!!! ERROR AL LANZAR REQUEST !!! Código: ", error)
		historial_instrucciones.pop_back() # Deshacemos si falló el envío
	else:
		print("3. Petición enviada. Esperando el colapso de onda...")

# --- RESPUESTA ---

func _al_recibir_respuesta(result, response_code, headers, body):
	if response_code == 200:
		var respuesta = JSON.parse_string(body.get_string_from_utf8())
		
		# medicion
		if "medicion" in respuesta:
			var bit = respuesta["medicion"] # Esto será 0 o 1
			
			print("\n--- ¡RESULTADO CUÁNTICO RECIBIDO! ---")
			print("El Qubit ha colapsado en: ", bit)
			
			if bit == 1:
				print(">> RESULTADO: 1-CARA)")
				
			else:
				print(">> RESULTADO: 0-CRUZ")
				
		else:
			print("Respuesta completa: ", respuesta)

	else:
		print("Error en servidor. Código: ", response_code)
