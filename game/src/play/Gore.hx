package play;

import math.AABB;

class Gore {
	@:native("a")
	public var alive(default, null):Bool = true;

	public var aabb(default, null):AABB = new AABB(0, 0, 16, 16);

	@:native("g")
	private var gravity:Float = 600;

	@:native("xs")
	private var xSpeed:Float = 0;

	@:native("ys")
	private var ySpeed:Float = 0;

	@:native("st")
	private var state:PlayState;

	public function new(state:PlayState, x:Float, y:Float, xs:Float = 0, ys:Float = 0, w:Float = 16, h:Float = 16) {
		this.state = state;
		aabb.x = x;
		aabb.y = y;
		aabb.w = w;
		aabb.h = h;

		xSpeed = xs;
		ySpeed = ys;
	}

	@:native("u")
	public function update(s:Float) {
		ySpeed += gravity * s;

		var mx = xSpeed * s;
		var my = ySpeed * s;

		for (p in state.wall) {
			if (p.check(aabb, mx, my)) {
				ySpeed = 0;
				xSpeed = 0;
				my = aabb.moveContactY(p, my);
				mx = aabb.moveContactX(p, mx);
			}
		}

		aabb.x += mx;
		aabb.y += my;

		Main.context.fillStyle = "#F00";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}
