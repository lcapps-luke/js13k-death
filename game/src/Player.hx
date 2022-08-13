package;

import js.html.svg.Matrix;
import math.AABB;

class Player {
	private static inline var MOVE_SPEED = 200;
	private static inline var JUMP_SPEED = 300;
	private static inline var GRAVITY = 400;

	public var aabb(default, null):AABB = new AABB(0, 0, 32, 64);

	private var x:Float = 0;
	private var y:Float = 0;
	private var ySpeed:Float = 0;

	private var onGround = false;

	private var state:PlayState;

	public function new(state:PlayState) {
		x = 1920 / 2;
		y = 1080 / 2;
		this.state = state;
	}

	@:native("u")
	public function update(s:Float) {
		var mx:Float = 0;
		var my:Float = 0;

		ySpeed += GRAVITY * s;

		if (Ctrl.right) {
			mx = MOVE_SPEED * s;
		}
		if (Ctrl.left) {
			mx = -MOVE_SPEED * s;
		}
		if (Ctrl.jump && onGround) {
			ySpeed = -JUMP_SPEED;
			onGround = false;
		}

		my += ySpeed * s;

		for (p in state.wall) {
			if (p.check(aabb, 0, my)) {
				if (ySpeed > 0) {
					onGround = true;
				}

				ySpeed = 0;
				my = aabb.moveContactY(p, my);
			}

			if (p.check(aabb, mx, 0)) {
				mx = aabb.moveContactX(p, mx);
			}
		}

		x += mx;
		y += my;
		aabb.x = x;
		aabb.y = y;
		Main.context.fillStyle = "#000";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}
