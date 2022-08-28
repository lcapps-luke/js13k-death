package play;

import math.AABB;

abstract class Mob {
	private static inline var GRAVITY = 600;

	public var aabb(default, null):AABB = new AABB(0, 0, 10, 64);

	@:native("a")
	public var alive(default, null) = true;

	public var x(default, null):Float = 0;
	public var y(default, null):Float = 0;

	@:native("g")
	private var gravity:Float = GRAVITY;

	@:native("xs")
	private var xSpeed:Float = 0;
	@:native("ys")
	private var ySpeed:Float = 0;

	@:native("og")
	private var onGround = false;
	@:native("tw")
	private var touchingWall = false;

	@:native("st")
	private var state:PlayState;

	public function new(state:PlayState, x:Float, y:Float) {
		this.x = x;
		this.y = y;
		this.state = state;
	}

	@:native("u")
	public function update(s:Float) {
		touchingWall = false;
		ySpeed += gravity * s;

		var mx = xSpeed * s;
		var my = ySpeed * s;

		if (ySpeed > 20) {
			onGround = false;
		}
		for (p in state.wall) {
			if (p.check(aabb, 0, my)) {
				if (ySpeed > 0) {
					onGround = true;
				}

				ySpeed = 0;
				my = aabb.moveContactY(p, my);
				my = my > 0 ? my - 0.2 : my + 0.2;
			}

			if (p.check(aabb, mx, 0)) {
				mx = aabb.moveContactX(p, mx);
				if (mx != 0) {
					mx = mx > 0 ? mx - 0.2 : mx + 0.2;
				}
				touchingWall = true;
			}
		}

		x += mx;
		y += my;
		aabb.x = x - aabb.w / 2;
		aabb.y = y - aabb.h;
	}

	@:native("h")
	public function hit(shot:Shot, x:Float, y:Float):Void {}
}
