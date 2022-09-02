package play;

import js.html.svg.ImageElement;
import math.AABB;
import math.Circle;
import math.CircleIntersect;
import math.Vec2;
import resource.Sprite;

abstract class Mob {
	public static inline var BASE_HEIGHT = 124;
	private static inline var GRAVITY = 600;

	public var aabb(default, null):AABB = new AABB(0, 0, 20, BASE_HEIGHT);

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

	@:native("fd")
	private var facingDirection:Int = 1;

	@:native("st")
	private var state:PlayState;

	@:native("wcy")
	private var walkCycle:Float = 0;
	@:native("wfr")
	private var frontFoot = new Vec2();
	@:native("wbk")
	private var backFoot = new Vec2();
	@:native("wfh")
	private var frontHand = new Vec2();
	@:native("wbh")
	private var backHand = new Vec2();
	@:native("wlm")
	private var legMath = new CircleIntersect();
	@:native("wam")
	private var armMath = new CircleIntersect();
	@:native("lik")
	private var legIk = new Vec2();
	@:native("aak")
	private var armIk = new Vec2();

	private var bodySpr:Sprite;
	private var legF:Limb;
	private var legB:Limb;
	private var armF:Limb;
	private var armB:Limb;

	@:native("scl")
	private var scale:Float;

	private var floor:AABB = null;

	public function new(state:PlayState, x:Float, y:Float, img:ImageElement, s:Float = 1) {
		this.x = x;
		this.y = y;
		this.state = state;
		this.scale = s;

		aabb.w *= s;
		aabb.h *= s;
		aabb.x = x - aabb.w / 2;
		aabb.y = y - aabb.h;

		var sc = aabb.h / 231;

		legMath.ca = new Circle(0, 0, aabb.h * 0.21);
		legMath.cb = new Circle(0, 0, aabb.h * 0.29);
		armMath.ca = new Circle(0, 0, 38 * sc);
		armMath.cb = new Circle(0, 0, 43 * sc);

		bodySpr = new Sprite(img, 0, 0, 39, 127);
		bodySpr.o.x = 39 / 2;
		bodySpr.c.set(sc, sc);

		legF = makeLeg(sc, img);
		legB = makeLeg(sc, img);
		armF = makeArm(sc, img);
		armB = makeArm(sc, img);
	}

	@:native("ml")
	private function makeLeg(sc:Float, i:ImageElement):Limb {
		var u = new Sprite(i, 45, 137, 33, 66);
		u.o.set(33 / 2, 10);
		u.c.set(sc, sc);

		var l = new Sprite(i, 0, 133, 35, 74);
		l.o.x = 15;
		l.o.y = 5;
		l.c.set(sc, sc);

		return {
			u: u,
			l: l,
			g: 1
		};
	}

	@:native("ma")
	private function makeArm(sc:Float, i:ImageElement):Limb {
		var u = new Sprite(i, 50, 0, 19, 53);
		u.o.set(19 / 2, 10); // 38 long
		u.c.set(sc, sc);

		var l = new Sprite(i, 50, 65, 10, 51);
		l.o.set(12, 4); // 43 long
		l.c.set(sc, sc);

		return {
			u: u,
			l: l,
			g: 1
		};
	}

	@:native("u")
	public function update(s:Float) {
		touchingWall = false;
		ySpeed += gravity * s;

		var m = new Vec2(xSpeed * s, ySpeed * s);

		if (ySpeed > 20) {
			onGround = false;
		}
		for (p in state.wall) {
			checkCollision(p, m);
		}
		for (p in state.mobs) {
			if (p != this) {
				checkCollision(p.aabb, m);
			}
		}

		x += m.x;
		y += m.y;
		aabb.x = x - aabb.w / 2;
		aabb.y = y - aabb.h;

		// calculate walk cycle
		if (onGround && xSpeed != 0) {
			walkCycle += (xSpeed * (0.035 / scale)) * s;
			frontFoot.x = aabb.centerX() + Math.cos(walkCycle) * (32 * scale);
			frontFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle) * (11 * scale), aabb.h);

			backFoot.x = aabb.centerX() + Math.cos(walkCycle + Math.PI) * (32 * scale);
			backFoot.y = aabb.y + Math.min(aabb.h + Math.sin(walkCycle + Math.PI) * (11 * scale), aabb.h);

			setFootGround(legF, frontFoot.y >= aabb.y + aabb.h ? 1 : 0);
			setFootGround(legB, backFoot.y >= aabb.y + aabb.h ? 1 : 0);
		}
		else {
			frontFoot.set(aabb.centerX(), aabb.y + aabb.h);
			backFoot.set(aabb.centerX(), aabb.y + aabb.h);

			setFootGround(legF, onGround ? 1 : 0);
			setFootGround(legB, onGround ? 1 : 0);
		}
		legMath.ca.p.set(aabb.centerX(), aabb.y + aabb.h * 0.53);
		legIk.set(aabb.centerX() + (200 * scale * facingDirection), aabb.centerY());
	}

	@:native("cc")
	private function checkCollision(p:AABB, m:Vec2) {
		if (p.check(aabb, 0, m.y)) {
			if (ySpeed > 0) {
				onGround = true;
				floor = p;
			}

			ySpeed = 0;
			m.y = aabb.moveContactY(p, m.y);
			m.y = m.y > 0 ? m.y - 0.2 : m.y + 0.2;
		}

		if (p.check(aabb, m.x, 0)) {
			m.x = aabb.moveContactX(p, m.x);
			if (m.x != 0) {
				m.x = m.x > 0 ? m.x - 0.2 : m.x + 0.2;
			}
			touchingWall = true;
		}
	}

	@:native("rl")
	private function renderLimb(f:Vec2, l:Limb, m:CircleIntersect, i:Vec2) {
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
	}

	@:native("sfg")
	private function setFootGround(l:Limb, g:Int) {
		l.g = g;
	}

	@:native("h")
	public function hit(fx:Float, d:Float, x:Float, y:Float):Void {}
}

typedef Limb = {
	var u:Sprite;
	var l:Sprite;
	var g:Int;
}
