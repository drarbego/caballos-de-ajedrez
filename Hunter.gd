extends Enemy

var ORIGIN = Vector2(32, 32)

func on_clash(_piece):
	if self.tile:
		self.tile.set_piece(null)
	self.queue_free()

func _draw():
	var tip = ORIGIN + (self.dir * 64)
	draw_line(ORIGIN, tip, Color.black, 3.0)
	var left = tip + ((ORIGIN - tip).normalized() * 16).rotated(deg2rad(30))
	draw_line(tip, left, Color.red, 3.0)
	var right = tip + ((ORIGIN - tip).normalized() * 20).rotated(deg2rad(-30))
	draw_line(tip, right, Color.red, 3.0)

func _process(delta):
	update()

