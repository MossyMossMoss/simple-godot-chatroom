extends Control

const PORT = 3000
const MAX_USERS = 4 #not including host
const MAX_LINES = 25

var Username = ""
var HostIp = ""

func _ready():
	var ips = IP.get_local_addresses()
	$Login/MyIp.text = "My IP - " + str(ips)
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			send_message()

func host_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	message("Room created")
	enter_room()
	$Chat/HostIpLabel.text = "Host IP - " + str(IP.get_local_addresses())

func enter_room():
	message("Room entered")
	$Chat.visible = true
	$Login.visible = false

func join_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_client(HostIp, PORT)
	get_tree().set_network_peer(host)
	rpc("user_entered", Username)
	$Chat/HostIpLabel.text = "Host IP - " + HostIp

func leave_room():
	rpc("user_exited", Username)
	get_tree().set_network_peer(null)
	$Chat.visible = false
	$Login.visible = true

func send_message():
	var message = $Chat/LineEdit.text
	$Chat/LineEdit.text = ""
	rpc("receive_message", Username, message)

func message(text):
	if $Chat/Label.get_line_count() > MAX_LINES:
		$Chat/Label.remove_line(0)
	$Chat/Label.text += text + "\n"

func _server_disconnected():
	leave_room()
	message("Disconnected from server")

sync func user_entered(username):
	message(str(username) + " joined the room")

sync func user_exited(username):
	message(str(username) + " left the room")

sync func receive_message(username, message):
	message(str(username) + ": " + message)

func _on_UsernameLineEdit_text_changed(new_text):
	Username = new_text

func _on_IpLineEdit_text_changed(new_text):
	HostIp = new_text

func _on_HostButton_pressed():
	if Username != "":
		host_room()

func _on_JoinButton_pressed():
	if Username != "" and HostIp != "":
		join_room()

func _on_ExitButton_pressed():
	print("yes")
	leave_room()
