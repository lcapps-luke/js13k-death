package play;

import js.lib.Math;
import math.AABB;
import math.Line;
import resource.Images;

class Zombi extends Mob {
	private static inline var ATTACK_TIMER:Float = 0.5;
	private static inline var ATTACK_FROM:Float = ATTACK_TIMER * 0.15;
	private static inline var SPLAT_RANGE:Float = 200;
	private static inline var JUMP_SPEED = 500;

	@:native("at")
	private var attackTimer:Float = 0;
	@:native("ab")
	private var attackBox:AABB;
	@:native("al")
	private var attackLine:Line = new Line();
	@:native("aw")
	private var armWobble:Float = 0;

	private var wsp:Float;
	@:native("navz")
	private var navZone:AABB;

	public function new(s:PlayState, x:Float, y:Float) {
		super(s, x, y, Images.zombi, 0.8 + Math.random() * 0.2);
		wsp = 100 + Math.random() * 100;
		attackBox = new AABB(0, 0, 48 * scale, 16 * scale);
		navZone = new AABB(0, 0, 20 * scale * 2, 128 * scale);
	}

	override function update(s:Float) {
		if (!alive) {
			return;
		}

		super.update(s);

		attackBox.x = facingDirection > 0 ? x : x - attackBox.w;
		attackBox.y = aabb.y + aabb.h * 0.15;

		if (onGround && attackTimer <= 0) {
			if (state.player.y - y > 64) {
				// above player, move towards edge of floor that is closest to player x
				xSpeed = towardsNearestPlatformEdge();
			}
			else if (Math.abs(x - state.player.x) > 5) {
				xSpeed = state.player.x > x ? wsp : -wsp;
			}
			else {
				xSpeed = 0;
			}

			facingDirection = xSpeed > 0 ? 1 : -1;

			if (touchingWall) {
				ySpeed = -JUMP_SPEED;
				onGround = false;
			}
		}

		if (attackTimer <= 0 && attackBox.check(state.player.aabb)) {
			xSpeed = 0;
			attackTimer = ATTACK_TIMER;
		}

		armMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.22);
		armIk.set(aabb.centerX() + (facingDirection * 10), aabb.y + aabb.h);

		if (attackTimer > 0) {
			attackTimer -= s;

			if (attackTimer < 0) {
				if (state.player.aabb.check(attackBox)) {
					state.player.hit(x, facingDirection, x, y);
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

	private inline function towardsNearestPlatformEdge():Float {
		navZone.y = floor.y - navZone.h - 1;

		navZone.x = floor.x - navZone.w / 2;
		var af = state.spaceFree(navZone);

		navZone.x = floor.x + floor.w - navZone.w / 2;
		var bf = state.spaceFree(navZone);

		// both or neither free, move to closest
		if (af == bf) {
			return Math.abs(floor.x - state.player.x) > Math.abs((floor.x + floor.w) - state.player.x) ? wsp : -wsp;
		}

		return af ? -wsp : wsp;
	}

	private inline function getAttackDistance() {
		return state.player.aabb.w / 2 + aabb.w / 2 + 16;
	}

	override public function hit(fx:Float, d:Float, x:Float, y:Float) {
		Sound.zombiHit();
		if (Math.abs(this.x - fx) < SPLAT_RANGE) {
			alive = false;
			for (i in 0...50) {
				var gx = aabb.randomX();
				var gy = aabb.randomY();

				state.particle.push(Particle.gore(state, gx, gy, d * 300, -200 + Math.random() * 200));
			}
		}
		else {
			onGround = false;
			xSpeed = d * 200;
			ySpeed = -100;

			state.particle.push(Particle.gore(state, x, y, d * 300, -200 + Math.random() * 200));
		}
	}
}
