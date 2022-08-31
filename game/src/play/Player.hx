package play;

import math.Line;
import play.Mob.Limb;
import resource.Images;
import resource.Sprite;

class Player extends Mob {
	private static inline var MOVE_SPEED = 300;
	private static inline var JUMP_SPEED = 500;
	private static inline var RELOAD_TIME = 0.5;
	private static inline var MAX_AMMO = 8;

	@:native("wgt")
	private var wallGrabTimer:Float = 0;

	@:native("cs")
	private var canShoot:Bool = true;

	@:native("am")
	public var ammo(default, null):Int = MAX_AMMO;

	@:native("rt")
	private var reloadTimer:Float = 0;

	@:native("it")
	private var invincibilityTimer:Float = -1;

	@:native("sh")
	private var shield:Bool = true;

	private var gun:Sprite;
	private var reloadLine:Line = new Line();

	public function new(state:PlayState, x:Float, y:Float) {
		super(state, x, y, Images.player);
		var sc = aabb.h / 231;

		gun = new Sprite(Images.player, 80, 0, 64, 34);
		gun.o.set(5, 16);
		gun.c.set(sc, sc);
	}

	override public function update(s:Float) {
		if (!alive) {
			return;
		}

		if (invincibilityTimer > 0) {
			invincibilityTimer -= s;
		}
		else {
			xSpeed = 0;
		}
		if (Ctrl.right) {
			xSpeed = MOVE_SPEED;
			facingDirection = 1;
		}
		if (Ctrl.left) {
			xSpeed = -MOVE_SPEED;
			facingDirection = -1;
		}
		if (Ctrl.jump && (onGround || (touchingWall && wallGrabTimer > 0))) {
			ySpeed = -JUMP_SPEED;

			if (!onGround) {
				wallGrabTimer = 0;
			}

			onGround = false;
		}

		if (onGround && !touchingWall) {
			wallGrabTimer = 0.5;
		}

		if (!onGround && touchingWall && ySpeed > 0 && wallGrabTimer > 0) {
			ySpeed = 0;
			wallGrabTimer -= s;
		}

		super.update(s);

		if (Ctrl.shoot && canShoot && ammo > 0) {
			canShoot = false;
			state.shot.fire(x + facingDirection * 20, y - aabb.h * 0.77, facingDirection);
			Sound.shoot();
			ammo--;
			reloadTimer = 0;
		}

		if (!Ctrl.shoot) {
			canShoot = true;
		}

		if (Ctrl.reload && ammo < MAX_AMMO && reloadTimer <= 0) {
			reloadTimer = RELOAD_TIME;
		}

		if (reloadTimer > 0) {
			reloadTimer -= s;
			if (reloadTimer < 0) {
				ammo++;
				Sound.reload();
				if (ammo != MAX_AMMO) {
					reloadTimer = RELOAD_TIME;
				}
			}
		}

		if (!onGround) {
			reloadTimer = -1;
		}

		// Main.context.fillStyle = "#00F";
		// Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		// calculate limb targets
		armMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.22);
		armIk.set(aabb.centerX() + (facingDirection * -10), aabb.y + aabb.h);

		if (reloadTimer > 0) {
			reloadLine.a.set(aabb.centerX() + (facingDirection * 20 * scale), aabb.y + aabb.h * 0.20); // gun
			reloadLine.b.set(aabb.centerX(), aabb.y + aabb.h * 0.53); // pocket
			reloadLine.normalize();

			var rh = RELOAD_TIME / 2;
			var rp = reloadTimer > rh ? RELOAD_TIME - reloadTimer : reloadTimer;
			reloadLine.tweenPosition(rp / rh, frontHand);

			backHand.set(aabb.centerX() + (facingDirection * 20 * scale), aabb.y + aabb.h * 0.20);

			gun.p.copy(backHand);
			gun.a = facingDirection * -Math.PI / 2;
			gun.o.set(52, 8);
		}
		else {
			frontHand.set(aabb.centerX() + (facingDirection * 20 * scale), aabb.y + aabb.h * 0.27);
			backHand.set(aabb.centerX() + (facingDirection * 36 * scale), aabb.y + aabb.h * 0.23);
			gun.p.copy(frontHand);
			gun.a = 0;
			gun.o.set(5, 16);
		}
		gun.c.x = facingDirection * Math.abs(gun.c.x);

		// render body
		renderLimb(backFoot, legB, legMath, legIk);
		renderLimb(facingDirection > 0 ? backHand : frontHand, facingDirection > 0 ? armB : armF, armMath, armIk);

		bodySpr.c.x = facingDirection * Math.abs(bodySpr.c.x);
		bodySpr.p.set(aabb.x + aabb.w / 2, aabb.y);
		bodySpr.draw();
		gun.draw();

		renderLimb(frontFoot, legF, legMath, legIk);
		renderLimb(facingDirection > 0 ? frontHand : backHand, facingDirection > 0 ? armF : armB, armMath, armIk);
	}

	override function hit(fx:Float, d:Float, x:Float, y:Float) {
		if (invincibilityTimer < 0) {
			invincibilityTimer = 0.5;
			Sound.playerHit();

			if (shield) {
				shield = false;
				state.particleBurst(Particle.shield, aabb, 50);
			}
			else {
				// die
				alive = false;
				for (i in 0...50) {
					state.particle.push(Particle.gore(state, aabb.randomX(), aabb.randomY(), d * 300, -200 + Math.random() * 200));
				}
			}

			onGround = false;
			xSpeed = x > this.x ? -200 : 200;
			ySpeed = -100;
		}
	}

	@:native("gs")
	public function getState():PlayerState {
		return {
			a: ammo,
			s: shield,
			ys: ySpeed,
			xs: xSpeed
		}
	}

	@:native("ss")
	public function setState(s:PlayerState) {
		this.ammo = s.a;
		this.shield = s.s;
		this.ySpeed = s.ys;
		this.xSpeed = s.xs;
	}

	override function setFootGround(l:Limb, g:Int) {
		if (l.g == 0 && g == 1) {
			Sound.step();
		}
		super.setFootGround(l, g);
	}
}

typedef PlayerState = {
	var a:Int;
	var xs:Float;
	var ys:Float;
	var s:Bool;
}
