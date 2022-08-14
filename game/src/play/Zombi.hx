package play;

class Zombi extends Mob {
	private static inline var SPLAT_RANGE:Float = 128;

	@:native("a")
	private var alive = true;

	override function update(s:Float) {
		if (!alive) {
			return;
		}

		super.update(s);

		if (onGround) {
			xSpeed = state.player.x > x ? 100 : -100;
			if (Math.abs(x - state.player.x) < getAttackDistance()) {
				xSpeed = 0;
			}
		}

		if (state.shot.active && aabb.check(state.shot.aabb)) {
			if (Math.abs(x - state.shot.x) < SPLAT_RANGE) {
				alive = false;

				for (i in 0...10) {
					var g = new Gore(state, x, y - aabb.h / 2, state.shot.direction * 300, -200 + Math.random() * 200);
					state.particle.push(g);
				}
			}
			else {
				onGround = false;
				xSpeed = state.shot.direction * 200;
				ySpeed = -100;
			}
		}

		Main.context.fillStyle = "#0F0";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}

	private inline function getAttackDistance() {
		return state.player.aabb.w / 2 + aabb.w / 2 + 16;
	}
}
