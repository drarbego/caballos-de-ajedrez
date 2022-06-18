extends Node2D


func on_piece_landed(piece):
	get_tree().call_group("tiles", "toggle")
