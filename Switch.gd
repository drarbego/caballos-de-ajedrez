extends Node2D


func on_piece_landed(piece):
	print("on_piece_landed")
	get_tree().call_group("tiles", "toggle")
