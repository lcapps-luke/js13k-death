package math;

class CircleIntersect {
	public var ca:Circle;
	public var cb:Circle;

	public var ia(default, null):Vec2 = new Vec2();
	public var ib(default, null):Vec2 = new Vec2();

	private var p = new Vec2();

	public function new() {}

	@:native("u")
	public function update():Bool {
		var d = Line.distance(ca.p.x, ca.p.y, cb.p.x, cb.p.y);

		if (d > ca.r + cb.r) {
			// set centerpoint
			var d = ca.p.dirTo(cb.p);
			ia.set(ca.p.x + Math.cos(d) * ca.r, ca.p.y + Math.sin(d) * ca.r);
			ib.copy(ia);
			return false;
		}

		var a = (ca.r * ca.r - cb.r * cb.r + d * d) / (d * 2);
		var h = Math.sqrt(ca.r * ca.r - a * a);
		p.copy(cb.p).sub(ca.p).mul(a / d).add(ca.p);

		ia.x = p.x + h * (cb.p.y - ca.p.y) / d;
		ia.y = p.y - h * (cb.p.x - ca.p.x) / d;
		ib.x = p.x - h * (cb.p.y - ca.p.y) / d;
		ib.y = p.y + h * (cb.p.x - ca.p.x) / d;

		return true;
	}

	@:native("gr")
	public function getRightmost():Vec2 {
		return ia.x > ib.x ? ia : ib;
	}

	@:native("gl")
	public function getLeftmost():Vec2 {
		return ia.x < ib.x ? ia : ib;
	}

	@:native("c")
	public function getClosest(i:Vec2) {
		return ia.distanceTo(i.x, i.y) < ib.distanceTo(i.x, i.y) ? ia : ib;
	}
}
