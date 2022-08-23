package math;

class Line {
	public var a(default, null):Vec2;
	public var b(default, null):Vec2;
	public var v(default, null) = new Vec2();

	public function new(ax:Float = 0, ay:Float = 0, bx:Float = 0, by:Float = 0) {
		a = new Vec2(ax, ay);
		b = new Vec2(bx, by);
	}

	@:native("s")
	public function set(ax:Float = 0, ay:Float = 0, bx:Float = 0, by:Float = 0) {
		a.x = ax;
		a.y = ay;
		b.x = bx;
		b.y = by;
	}

	@:native("n")
	public function normalize() {
		v.x = b.x - a.x;
		v.y = b.y - a.y;
	}

	@:native("d")
	public static function distance(ax:Float = 0, ay:Float = 0, bx:Float = 0, by:Float = 0) {
		return Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2));
	}
}
