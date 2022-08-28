package math;

class LineIntersect {
	public var a:Line;
	public var b:Line;

	public var i(default, null):Vec2 = new Vec2();

	private var am:Float = 0;
	private var bm:Float = 0;

	public function new() {}

	@:native("u")
	public function update():Bool {
		if (!calculateMultipliers() || (am < 0 || am > 1) || (bm < 0 || bm > 1)) {
			return false;
		}

		i.x = a.a.x + a.v.x * am;
		i.y = a.a.y + a.v.y * am;

		return true;
	}

	private inline function calculateMultipliers():Bool {
		a.normalize();
		b.normalize();
		var divisor = a.v.x * b.v.y - b.v.x * a.v.y;
		if (divisor == 0) {
			return false;
		}

		am = (b.v.x * (a.a.y - b.a.y) - b.v.y * (a.a.x - b.a.x)) / divisor;
		bm = b.v.x > 0 ? (a.a.x - b.a.x + a.v.x * am) / b.v.x : (a.a.y - b.a.y + a.v.y * am) / b.v.y;

		return true;
	}
}
