class_name QuanticServer extends Node

signal wakeup_completed(available: bool)
signal measurement_completed(success: bool, measured_value: String)

@export var base_url: String = "https://server-quantico.onrender.com"
@export var execute_endpoint: String = "/ejecutar_circuito"
@export var wakeup_endpoints: Array[String] = ["/health", "/ping", "/"]

@onready var conector: HTTPRequest = $ConectorCuantico

var historial_instrucciones: Array = []
var _pending_mode: String = ""
var _pending_wakeup_endpoints: Array[String] = []

func _ready():
	conector.request_completed.connect(_al_recibir_respuesta)

func _on_boton_prueba_pressed():
	print(">>> ¡BOTÓN FÍSICO PRESIONADO! <<<")
	aplicar_hadamard()

func aplicar_hadamard():
	_enviar_instruccion("h")

func aplicar_rotacion_x():
	_enviar_instruccion("rx", [1.57])

func reiniciar_circuito():
	historial_instrucciones.clear()
	print("--- Circuito reiniciado (Qubit en estado |0>) ---")

func wake_up_server() -> void:
	if conector == null:
		wakeup_completed.emit(false)
		return
	_pending_mode = "wakeup"
	_pending_wakeup_endpoints = wakeup_endpoints.duplicate()
	_try_next_wakeup_endpoint()

func request_measurement(operations: Array, qubit: String = "?") -> void:
	if conector == null:
		measurement_completed.emit(false, _fallback_random_value())
		return
	if _pending_mode != "":
		print("[QuanticServer] Solicitud omitida: ya hay una request en curso.")
		measurement_completed.emit(false, _fallback_random_value())
		return
	_pending_mode = "measurement"
	var payload := {
		"operations": operations,
		"qubits": [qubit],
		"shots": 1
	}
	var headers = ["Content-Type: application/json"]
	var url = _build_url(execute_endpoint)
	var error = conector.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		print("[QuanticServer] Error lanzando request de medida. Código: ", error)
		_pending_mode = ""
		measurement_completed.emit(false, _fallback_random_value())

func _enviar_instruccion(nombre_puerta: String, parametros: Array = []):
	if conector == null:
		print("ERROR FATAL: El nodo 'ConectorCuantico' no está asignado.")
		return
	if _pending_mode != "":
		print("[QuanticServer] No se envía instrucción, hay una request pendiente.")
		return
	historial_instrucciones.append({
		"puerta": nombre_puerta,
		"params": parametros
	})
	_pending_mode = "measurement"
	var payload := {
		"instrucciones": historial_instrucciones
	}
	var headers = ["Content-Type: application/json"]
	var error = conector.request(_build_url(execute_endpoint), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		print("!!! ERROR AL LANZAR REQUEST !!! Código: ", error)
		historial_instrucciones.pop_back()
		_pending_mode = ""
		measurement_completed.emit(false, _fallback_random_value())

func _al_recibir_respuesta(result, response_code, headers, body):
	if _pending_mode == "wakeup":
		_handle_wakeup_response(result, response_code)
		return
	if _pending_mode == "measurement":
		_handle_measurement_response(result, response_code, body)
		return
	print("[QuanticServer] Respuesta recibida sin modo pendiente.")

func _handle_wakeup_response(result: int, response_code: int) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300:
		_pending_mode = ""
		wakeup_completed.emit(true)
		return
	_try_next_wakeup_endpoint()

func _try_next_wakeup_endpoint() -> void:
	if _pending_wakeup_endpoints.is_empty():
		_pending_mode = ""
		wakeup_completed.emit(false)
		return
	var endpoint: String = _pending_wakeup_endpoints.pop_front()
	var error = conector.request(_build_url(endpoint), [], HTTPClient.METHOD_GET)
	if error != OK:
		_try_next_wakeup_endpoint()

func _handle_measurement_response(result: int, response_code: int, body: PackedByteArray) -> void:
	var fallback_value := _fallback_random_value()
	if result != HTTPRequest.RESULT_SUCCESS:
		print("[QuanticServer] Request fallida, usando fallback local.")
		_pending_mode = ""
		measurement_completed.emit(false, fallback_value)
		return
	if response_code < 200 or response_code >= 300:
		print("[QuanticServer] Código HTTP no válido: ", response_code, ". Usando fallback local.")
		_pending_mode = ""
		measurement_completed.emit(false, fallback_value)
		return
	var raw_text: String = body.get_string_from_utf8()
	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		print("[QuanticServer] Respuesta no JSON/diccionario. Fallback local.")
		_pending_mode = ""
		measurement_completed.emit(false, fallback_value)
		return
	var measured_value: String = _extract_measurement_value(parsed)
	if measured_value == "":
		print("[QuanticServer] No se encontró medición en respuesta. Fallback local.")
		_pending_mode = ""
		measurement_completed.emit(false, fallback_value)
		return
	_pending_mode = ""
	measurement_completed.emit(true, measured_value)

func _extract_measurement_value(data: Dictionary) -> String:
	var candidates = [
		"medicion",
		"measurement",
		"result",
		"resultado",
		"bit",
		"value"
	]
	for key in candidates:
		if data.has(key):
			var normalized = _normalize_bit_value(data[key])
			if normalized != "":
				return normalized
	for key in data.keys():
		var nested = data[key]
		if typeof(nested) == TYPE_DICTIONARY:
			var nested_result = _extract_measurement_value(nested)
			if nested_result != "":
				return nested_result
		if typeof(nested) == TYPE_ARRAY:
			for item in nested:
				if typeof(item) == TYPE_DICTIONARY:
					var array_result = _extract_measurement_value(item)
					if array_result != "":
						return array_result
				else:
					var normalized_item = _normalize_bit_value(item)
					if normalized_item != "":
						return normalized_item
	return ""

func _normalize_bit_value(value) -> String:
	if typeof(value) == TYPE_INT:
		if value == 0 or value == 1:
			return str(value)
		return ""
	if typeof(value) == TYPE_FLOAT:
		if int(value) == 0 or int(value) == 1:
			return str(int(value))
		return ""
	if typeof(value) == TYPE_STRING:
		if value == "0" or value == "1":
			return value
		return ""
	return ""

func _fallback_random_value() -> String:
	if randi_range(0, 1) == 1:
		return "1"
	return "0"

func _build_url(path: String) -> String:
	if path.begins_with("http://") or path.begins_with("https://"):
		return path
	if base_url.ends_with("/") and path.begins_with("/"):
		return base_url + path.substr(1)
	if !base_url.ends_with("/") and !path.begins_with("/"):
		return base_url + "/" + path
	return base_url + path
