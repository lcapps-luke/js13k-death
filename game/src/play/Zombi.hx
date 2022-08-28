package play;

import js.lib.Math;
import math.AABB;
import math.Line;
import resource.Images;

class Zombi extends Mob {
	private static inline var ATTACK_TIMER:Float = 0.5;
	private static inline var ATTACK_FROM:Float = ATTACK_TIMER * 0.15;
	private static inline var SPLAT_RANGE:Float = 200;

	@:native("at")
	private var attackTimer:Float = 0;
	@:native("ab")
	private var attackBox:AABB = new AABB(0, 0, 64, 32);
	@:native("al")
	private var attackLine:Line = new Line();
	@:native("aw")
	private var armWobble:Float = 0;

	public function new(s:PlayState, x:Float, y:Float) {
		super(s, x, y, Images.zombi, 0.8 + Math.random() * 0.2);
	}

	override function update(s:Float) {
		if (!alive) {
			return;
		}

		super.update(s);

		if (onGround && attackTimer <= 0) {
			xSpeed = state.player.x > x ? 100 : -100;
			if (Math.abs(x - state.player.x) < getAttackDistance()) {
				xSpeed = 0;

				attackTimer = ATTACK_TIMER;
			}
			else {
				facingDirection = xSpeed > 0 ? 1 : -1;
			}
		}

		armMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.22);
		armIk.set(aabb.centerX() + (facingDirection * 10), aabb.y + aabb.h);

		if (attackTimer > 0) {
			attackTimer -= s;

			if (attackTimer < 0) {
				attackBox.x = facingDirection > 0 ? x : x - attackBox.w;
				attackBox.y = y - 48;

				if (state.player.aabb.check(attackBox)) {
					state.player.hit(null, x, y);
				}
			}

			// attack anim
			attackLine.a.set(aabb.centerX() + (facingDirection * 42 * scale), aabb.y + aabb.h * 0.23); // out
			attackLine.b.set(aabb.centerX(), aabb.y - aabb.h * 0.15); // above
			attackLine.normalize();

			var p = attackTimer < ATTACK_FROM ? (attackTimer / ATTACK_FROM) : (1 - (attackTimer - ATTACK_FROM) / (ATTACK_TIMER - ATTACK_FROM));

			attackLine.tweenPosition(p, frontHand);
			attackLine.tweenPosition(p, backHand);
		}
		else {
			armWobble += Math.PI * s;

			var awo = Math.sin(armWobble) * aabb.h * 0.05;
			frontHand.set(aabb.centerX() + (facingDirection * 42 * scale), aabb.y + aabb.h * 0.23 + awo);

			awo = Math.cos(armWobble) * aabb.h * 0.05;
			backHand.set(aabb.centerX() + (facingDirection * 42 * scale), aabb.y + aabb.h * 0.23 + awo);
		}

		// render body
		renderLimb(backFoot, legB, legMath, legIk);
		renderLimb(backHand, armB, armMath, armIk);

		bodySpr.c.x = facingDirection * Math.abs(bodySpr.c.x);
		bodySpr.p.set(aabb.x + aabb.w / 2, aabb.y);
		bodySpr.draw();

		renderLimb(frontFoot, legF, legMath, legIk);
		renderLimb(frontHand, armF, armMath, armIk);
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
