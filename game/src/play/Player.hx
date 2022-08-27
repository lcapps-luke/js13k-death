package play;

import math.Circle;
import math.CircleIntersect;
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

	private var legMath = new CircleIntersect();
	private var bodySpr:Sprite;

	private var legF:Leg;
	private var legB:Leg;

	public function new(state:PlayState, x:Float, y:Float) {
		super(state, x, y);
		legMath.ca = new Circle(0, 0, aabb.h * 0.21);
		legMath.cb = new Circle(0, 0, aabb.h * 0.29);

		var sc = aabb.h / 231;
		bodySpr = new Sprite(Images.player, 0, 0, 39, 127);
		bodySpr.o.x = 39 / 2;
		bodySpr.c.set(sc, sc);

		legF = makeLeg(sc);
		legB = makeLeg(sc);
	}

	@:native("ml")
	private function makeLeg(sc:Float):Leg {
		var u = new Sprite(Images.player, 45, 137, 33, 66);
		u.o.x = 33 / 2;
		u.o.y = 10;
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
			state.shot.fire(x, y - aabb.h * 0.75, facingDirection);
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

		Main.context.fillStyle = "#00F";
		// Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		bodySpr.c.x = facingDirection * Math.abs(bodySpr.c.x);
		bodySpr.p.set(aabb.x + aabb.w / 2, aabb.y);
		bodySpr.draw();

		if (onGround && xSpeed != 0) {
			walkCycle += (xSpeed * 0.07) * s;
			frontFoot.x = aabb.x + aabb.w / 2 + Math.cos(walkCycle) * 16;
			frontFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle) * 8, aabb.h);

			backFoot.x = aabb.x + aabb.w / 2 + Math.cos(walkCycle + Math.PI) * 16;
			backFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle + Math.PI) * 8, aabb.h);
		}
		else {
			frontFoot.set(aabb.x + aabb.w / 2, aabb.y + aabb.h);
			backFoot.set(aabb.x + aabb.w / 2, aabb.y + aabb.h);
		}
		legMath.ca.p.set(aabb.x + aabb.w / 2, aabb.y + aabb.h * 0.53);

		renderLeg(backFoot, legB);
		renderLeg(frontFoot, legF);
	}

	@:native("rl")
	private function renderLeg(f:Vec2, l:Leg) {
		legMath.cb.p.copy(f);
		legMath.update();

		var kneePos = facingDirection > 0 ? legMath.getRightmost() : legMath.getLeftmost();

		l.u.c.x = facingDirection * Math.abs(l.u.c.x);
		l.u.p.copy(legMath.ca.p);
		l.u.a = kneePos.dirTo(legMath.ca.p) + Math.PI * 0.5;
		l.u.draw();

		l.l.c.x = facingDirection * Math.abs(l.l.c.x);
		l.l.p.copy(kneePos);
		l.l.a = legMath.cb.p.dirTo(kneePos) + Math.PI * 0.5;
		l.l.draw();

		/*
			Main.context.strokeStyle = "#00F";
			Main.context.lineWidth = 1;
			Main.context.beginPath();
			Main.context.moveTo(legMath.ca.p.x, legMath.ca.p.y);
			Main.context.lineTo(kneePos.x, kneePos.y);
			Main.context.lineTo(f.x, f.y);
			Main.context.stroke();
		 */
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

typedef Leg = {
	var u:Sprite;
	var l:Sprite;
}
