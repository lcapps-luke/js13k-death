package play;

import math.AABB;
import math.Line;
import math.LineIntersect;
import math.Vec2;

class Shot {
	private static inline var SHOT_QTY = 5;

	public var aabb(default, null):AABB = new AABB(0, 0, 300, 32);

	@:native("a")
	public var active(default, null):Bool = false;
	public var x(default, null):Float = 0;
	public var y(default, null):Float = 0;

	@:native("d")
	public var direction(default, null):Float = 0;

	@:native("l")
	private var collisionLine:LineIntersect = new LineIntersect();

	public function new() {
		collisionLine.a = new Line();
		collisionLine.b = new Line();
	}

	@:native("u")
	public function update(s:Float, state:PlayState) {
		if (active) {
			active = false;
			Main.context.strokeStyle = "#FF0";

			// find wall collision candidates
			var walls:Array<AABB> = [];
			for (w in state.wall) {
				if (aabb.check(w)) {
					walls.push(w);
				}
			}
			// find mob collision candidates
			var mobs:Array<Mob> = [];
			for (m in state.mobs) {
				if (m.alive && aabb.check(m.aabb)) {
					mobs.push(m);
				}
			}

			collisionLine.a.a.set(x, y);
			for (i in 0...SHOT_QTY) {
				var hit = new Vec2(direction > 0 ? x + aabb.w : x - aabb.w, aabb.y + (aabb.h / SHOT_QTY) * i);
				collisionLine.a.b.set(hit.x, hit.y);

				// check ray collision with walls
				var wallHit = getHitPointw(walls);
				if (wallHit != null) {
					hit.x = wallHit.x;
					hit.y = wallHit.y;
				}

				// check ray collision with mobs
				var mobHit = getHitPointm(mobs);
				if (mobHit.h != null && mobHit.h.distanceTo(x, y) < hit.distanceTo(x, y)) {
					hit.x = mobHit.h.x;
					hit.y = mobHit.h.y;
					mobHit.m.hit(this, hit.x, hit.y);
				}

				Main.context.beginPath();
				Main.context.moveTo(x, y);
				Main.context.lineTo(hit.x, hit.y);
				Main.context.stroke();
			}
		}
	}

	@:native("ghpw")
	function getHitPointw(walls:Array<AABB>) {
		var hit:Vec2 = null;
		for (w in walls) {
			eachLine(w, () -> {
				if (collisionLine.update()) {
					if (hit == null || hit.distanceTo(x, y) > collisionLine.i.distanceTo(x, y)) {
						hit = collisionLine.i.clone();
					}
				}
			});
		}

		return hit;
	}

	@:native("ghpm")
	function getHitPointm(mobs:Array<Mob>) {
		var hit:Vec2 = null;
		var mob:Mob = null;
		for (m in mobs) {
			eachLine(m.aabb, () -> {
				if (collisionLine.update()) {
					if (hit == null || hit.distanceTo(x, y) > collisionLine.i.distanceTo(x, y)) {
						hit = collisionLine.i.clone();
						mob = m;
					}
				}
			});
		}

		return {
			h: hit,
			m: mob
		};
	}

	@:native("el")
	private function eachLine(a:AABB, callback:Void->Void) {
		collisionLine.b.set(a.x, a.y, a.x + a.w, a.y); // top
		callback();
		collisionLine.b.set(a.x + a.w, a.y, a.x + a.w, a.y + a.h); // right
		callback();
		collisionLine.b.set(a.x, a.y + a.h, a.x + a.w, a.y + a.h); // bottom
		callback();
		collisionLine.b.set(a.x, a.y, a.x, a.y + a.h); // left
		callback();
	}

	@:native("f")
	public function fire(x:Float, y:Float, xd:Float) {
		active = true;
		aabb.x = xd > 0 ? x : x - aabb.w;
		aabb.y = y - aabb.h / 2;
		this.x = x;
		this.y = y;
		this.direction = xd;
	}
}
