package play;

import math.AABB;

class Particle {
	@:native("a")
	public var alive(default, null):Bool = true;

	public var aabb(default, null):AABB = new AABB(0, 0, 16, 16);

	@:native("gr")
	private var gravity:Float = 600;

	@:native("xs")
	private var xSpeed:Float = 0;

	@:native("ys")
	private var ySpeed:Float = 0;

	@:native("st")
	private var state:PlayState;

	private var t:Float;
	private var r:Int;
	private var g:Int;
	private var b:Int;

	public static function gore(state:PlayState, x:Float, y:Float, xs:Float, ys:Float) {
		var s = 6 + Math.random() * 5;
		return new Particle(state, x, y, xs, ys, s, s, 5, 200, 0, 0);
	}

	public static function spawn(state:PlayState, x:Float, y:Float, xs:Float, ys:Float) {
		var s = 6 + Math.random() * 5;
		return new Particle(state, x, y, xs, ys, s, s, 0.5, 0, 255, 0);
	}

	public static function shield(state:PlayState, x:Float, y:Float, xs:Float, ys:Float) {
		var s = 6 + Math.random() * 5;
		return new Particle(state, x, y, xs, ys, s, s, 0.5, 0, 0, 255);
	}

	public function new(state:PlayState, x:Float, y:Float, xs:Float, ys:Float, w:Float, h:Float, t:Float, r:Int, g:Int, b:Int) {
		this.state = state;
		aabb.set(x, y, w, h);

		xSpeed = xs;
		ySpeed = ys;
		this.t = t;
		this.r = r;
		this.g = g;
		this.b = b;
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

		t -= s;
		if (t < 0) {
			alive = false;
		}

		Main.context.fillStyle = 'rgba($r,$g,$b,$t)';
		Main.context.beginPath();
		Main.context.ellipse(aabb.centerX(), aabb.centerY(), aabb.w * 0.8, aabb.h * 0.8, 0, 0, Math.PI * 2);
		Main.context.fill();
	}
}
