package play;

import math.Circle;
import math.CircleIntersect;
import math.Line;
import math.Vec2;
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

	@:native("fd")
	private var facingDirection:Int = 1;

	@:native("am")
	public var ammo(default, null):Int = MAX_AMMO;

	@:native("rt")
	private var reloadTimer:Float = 0;

	@:native("it")
	private var invincibilityTimer:Float = -1;

	@:native("sh")
	private var shield:Bool = true;

	private var walkCycle:Float = 0;
	private var frontFoot = new Vec2();
	private var backFoot = new Vec2();
	private var frontHand = new Vec2();
	private var backHand = new Vec2();
	private var legMath = new CircleIntersect();
	private var armMath = new CircleIntersect();
	private var legIk = new Vec2();
	private var armIk = new Vec2();

	private var bodySpr:Sprite;
	private var legF:Limb;
	private var legB:Limb;
	private var armF:Limb;
	private var armB:Limb;
	private var gun:Sprite;
	private var reloadLine:Line = new Line();

	public function new(state:PlayState, x:Float, y:Float) {
		super(state, x, y);
		var sc = aabb.h / 231;

		legMath.ca = new Circle(0, 0, aabb.h * 0.21);
		legMath.cb = new Circle(0, 0, aabb.h * 0.29);
		armMath.ca = new Circle(0, 0, 38 * sc);
		armMath.cb = new Circle(0, 0, 43 * sc);

		bodySpr = new Sprite(Images.player, 0, 0, 39, 127);
		bodySpr.o.x = 39 / 2;
		bodySpr.c.set(sc, sc);

		legF = makeLeg(sc);
		legB = makeLeg(sc);
		armF = makeArm(sc);
		armB = makeArm(sc);

		gun = new Sprite(Images.player, 80, 0, 64, 34);
		gun.o.set(5, 16);
		gun.c.set(sc, sc);
	}

	@:native("ml")
	private function makeLeg(sc:Float):Limb {
		var u = new Sprite(Images.player, 45, 137, 33, 66);
		u.o.set(33 / 2, 10);
		u.c.set(sc, sc);

		var l = new Sprite(Images.player, 0, 133, 35, 74);
		l.o.x = 12;
		l.o.y = 5;
		l.c.set(sc, sc);

		return {
			u: u,
			l: l
		};
	}

	@:native("ma")
	private function makeArm(sc:Float):Limb {
		var u = new Sprite(Images.player, 50, 0, 19, 53);
		u.o.set(19 / 2, 10); // 38 long
		u.c.set(sc, sc);

		var l = new Sprite(Images.player, 50, 65, 10, 51);
		l.o.set(12, 4); // 43 long
		l.c.set(sc, sc);

		return {
			u: u,
			l: l
		};
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
				if (ammo != MAX_AMMO) {
					reloadTimer = RELOAD_TIME;
				}
			}
		}

		// Main.context.fillStyle = "#00F";
		// Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		// calculate limb targets
		if (onGround && xSpeed != 0) {
			walkCycle += (xSpeed * 0.07) * s;
			frontFoot.x = aabb.centerX() + Math.cos(walkCycle) * 16;
			frontFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle) * 8, aabb.h);

			backFoot.x = aabb.centerX() + Math.cos(walkCycle + Math.PI) * 16;
			backFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle + Math.PI) * 8, aabb.h);
		}
		else {
			frontFoot.set(aabb.centerX(), aabb.y + aabb.h);
			backFoot.set(aabb.centerX(), aabb.y + aabb.h);
		}
		legMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.53);
		legIk.set(aabb.centerX() + (100 * facingDirection), aabb.centerY());

		armMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.22);
		armIk.set(aabb.centerX() + (facingDirection * -10), aabb.y + aabb.h);

		if (reloadTimer > 0) {
			reloadLine.a.set(aabb.centerX() + (facingDirection * 10), aabb.y + aabb.h * 0.20); // gun
			reloadLine.b.set(aabb.centerX(), aabb.y + aabb.h * 0.53); // pocket
			reloadLine.normalize();

			var rh = RELOAD_TIME / 2;
			var rp = reloadTimer > rh ? RELOAD_TIME - reloadTimer : reloadTimer;
			reloadLine.tweenPosition(rp / rh, frontHand);

			backHand.set(aabb.centerX() + (facingDirection * 10), aabb.y + aabb.h * 0.20);

			gun.p.copy(backHand);
			gun.a = facingDirection * -Math.PI / 2;
			gun.o.set(52, 8);
		}
		else {
			frontHand.set(aabb.centerX() + (facingDirection * 10), aabb.y + aabb.h * 0.27);
			backHand.set(aabb.centerX() + (facingDirection * 18), aabb.y + aabb.h * 0.23);
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

	@:native("rl")
	private function renderLimb(f:Vec2, l:Limb, m:CircleIntersect, i:Vec2, d:Bool = false) {
		m.cb.p.copy(f);
		m.update();

		var jPos = m.getClosest(i);

		l.u.c.x = facingDirection * Math.abs(l.u.c.x);
		l.u.p.copy(m.ca.p);
		l.u.a = jPos.dirTo(m.ca.p) + Math.PI * 0.5;
		l.u.draw();

		l.l.c.x = facingDirection * Math.abs(l.l.c.x);
		l.l.p.copy(jPos);
		l.l.a = m.cb.p.dirTo(jPos) + Math.PI * 0.5;
		l.l.draw();

		if (d) {
			Main.context.strokeStyle = "#00F";
			Main.context.lineWidth = 1;
			Main.context.beginPath();
			Main.context.ellipse(m.ca.p.x, m.ca.p.y, m.ca.r, m.ca.r, 0, 0, Math.PI * 2);
			Main.context.stroke();
			Main.context.beginPath();
			Main.context.ellipse(m.cb.p.x, m.cb.p.y, m.cb.r, m.cb.r, 0, 0, Math.PI * 2);
			Main.context.stroke();
		}
	}

	override function hit(shot:Shot, x:Float, y:Float) {
		if (invincibilityTimer < 0) {
			invincibilityTimer = 0.5;

			if (shield) {
				shield = false;
				// TODO shield destroy effect
			}
			else {
				// die
				alive = false;
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
}

typedef PlayerState = {
	var a:Int;
	var xs:Float;
	var ys:Float;
	var s:Bool;
}

typedef Limb = {
	var u:Sprite;
	var l:Sprite;
}
