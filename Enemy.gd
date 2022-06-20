extends Piece

class_name Enemy

var ORIGIN = Vector2(32, 32)
var dir = Vector2.ZERO

func _ready():
	self.attacks = true

func set_dir(new_dir: Vector2):
	self.dir = new_dir

func _draw():
	var tip = ORIGIN + (self.dir * 64)
	draw_line(ORIGIN, tip, Color.black, 3.0)
	var left = tip + ((ORIGIN - tip).normalized() * 16).rotated(deg2rad(30))
	draw_line(tip, left, Color.red, 3.0)
	var right = tip + ((ORIGIN - tip).normalized() * 20).rotated(deg2rad(-30))
	draw_line(tip, right, Color.red, 3.0)

func _process(delta):
	update()
