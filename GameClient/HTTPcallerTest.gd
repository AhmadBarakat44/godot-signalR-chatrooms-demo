extends Button
var http_request
var username
var playerID
var currentGameID
var websocket: WebSocketPeer
var ingame:bool
@onready var UsernameField = $%UsernameField
@onready var LoginWindow = $%LoginWindow
@onready var GamesWindow = %GamesWindow
@onready var GameID = %"Game ID Text"
@onready var INgameWindow = %INgameWindow
@onready var ChatEntry = %"chat entry"
@onready var ChatHistory = %"chat History"
@onready var SendButton = %"Send Message Button"


func _on_pressed() -> void:
	username = UsernameField.text
	if username == "":
		print("Please enter a username")
		return
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	add_child(http_request)
	http_request.request_completed.connect(self._on_login_request_complete)
	var _response = http_request.request("http://localhost:5054/test/playerid/" + username)

	
func _on_login_request_complete(_result, _response_code, _headers, body) -> void:
	playerID = body.get_string_from_utf8()
	print(playerID)
	remove_child(http_request)
	http_request.queue_free()
	LoginWindow.hide()
	GamesWindow.show()


func _on_create_game_button_pressed() -> void:
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	add_child(http_request)
	http_request.request_completed.connect(self.on_create_game_request_complete)
	var _response = http_request.request("http://localhost:5054/test/game/" + playerID,[] , HTTPClient.METHOD_POST)

func on_create_game_request_complete(_result, _response_code, _headers, body) -> void:
	print("created and joined game : " + body.get_string_from_utf8())
	currentGameID = body.get_string_from_utf8()
	remove_child(http_request)
	http_request.queue_free()
	_start_websockets()
	ingame = true
	INgameWindow.show()
	GamesWindow.hide()

func _on_join_game_button_pressed() -> void:
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	add_child(http_request)
	http_request.request_completed.connect(self._on_join_game_request_complete)
	var _response = http_request.request("http://localhost:5054/test/game/" + GameID.text + "/" + playerID)

func _on_join_game_request_complete(_result, response_code, _headers, body) -> void:
	if(response_code == 404):
		print(body.get_string_from_utf8())
	if(response_code == 200):
		print("joined game : " + body.get_string_from_utf8())
		currentGameID = body.get_string_from_utf8()
		_start_websockets()
		ingame = true
		INgameWindow.show()
		GamesWindow.hide()
	remove_child(http_request)
	http_request.queue_free()
	

func _start_websockets():
	websocket = WebSocketPeer.new()
	var res = websocket.connect_to_url("ws://localhost:5054/gamechathub")
	if res != OK:
		print("Unable to connect")
		set_process(false)
	else:
		await get_tree().create_timer(.5).timeout
		var connection_json = {
			"protocol":"json",
			"version":1
		}
		var connection_message = JSON.stringify(connection_json) + "\u001E"
		websocket.send_text(connection_message)
		await get_tree().create_timer(.5).timeout
		var join_game_json = {
			"arguments":[currentGameID , username],
			"invocationId":"0",
			"target":"JoinGameChat",
			"type":1
		}
		var join_game_message = JSON.stringify(join_game_json) + "\u001E"
		print(join_game_message)
		websocket.send_text(join_game_message)

func _on_send_message_button_pressed() -> void:
	var message = ChatEntry.text
	var message_json = {
		"arguments":[{
			"Username": username,
			"Message": message,
			"Timestamp":  Time.get_datetime_string_from_system(true)
		},currentGameID],"invocationId":"0","target":"SendMessagetoGroup","type":1
	}
	if websocket:
		if websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			websocket.send_text(JSON.stringify(message_json) + "\u001E")

func _process(delta: float) -> void:
	if websocket:
		websocket.poll()
		var socketState = websocket.get_ready_state()
		if socketState == WebSocketPeer.STATE_OPEN:
			while websocket.get_available_packet_count():
				var websocket_text = websocket.get_packet().get_string_from_utf8()
				var messages = websocket_text.split("\u001E")
				for message in messages:
					if message.is_empty():
						continue
					var websocket_json = JSON.parse_string(message)
					if websocket_json:
						if websocket_json.has("target"):
							if websocket_json["target"] == "ReceiveMessage":
								ChatHistory.text += websocket_json["arguments"][0] + "\n"
		elif socketState == WebSocketPeer.STATE_CLOSING:
			pass
		elif socketState == WebSocketPeer.STATE_CLOSED:
			var code = websocket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false)
