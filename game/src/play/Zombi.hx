package play;

import math.AABB;

class Zombi extends Mob {
	private static inline var SPLAT_RANGE:Float = 200;

	@:native("at")
	private var attackTimer:Float = 2;
	@:native("ab")
	private var attackBox:AABB = new AABB(0, 0, 64, 32);

	override function update(s:Float) {
		if (!alive) {
			return;
		}

		super.update(s);

		if (onGround) {
			xSpeed = state.player.x > x ? 100 : -100;
			if (Math.abs(x - state.player.x) < getAttackDistance()) {
				xSpeed = 0;
				attackTimer -= s;
			}
		}

		if (attackTimer < 0) {
			attackTimer = 2;
			attackBox.x = state.player.x < x ? x - 80 : x + 16;
			attackBox.y = y - 48;

			if (state.player.aabb.check(attackBox)) {
				state.player.hit(null, x, y);
			}
		}

		Main.context.fillStyle = "#0F0";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}

	private inline function getAttackDistance() {
		return state.player.aabb.w / 2 + aabb.w / 2 + 16;
	}

	override public function hit(shot:Shot, x:Float, y:Float) {
		if (Math.abs(this.x - shot.x) < SPLAT_RANGE) {
			alive = false;
			for (i in 0...50) {
				var gx = aabb.x + Math.random() * aabb.w;
				var gy = aabb.y + Math.random() * aabb.h;

				var g = new Gore(state, gx, gy, shot.direction * 300, -200 + Math.random() * 200);
				state.particle.push(g);
			}
		}
		else {
			onGround = false;
			xSpeed = shot.direction * 200;
			ySpeed = -100;

			var g = new Gore(state, x, y, shot.direction * 300, -200 + Math.random() * 200);
			state.particle.push(g);
		}
	}
}
