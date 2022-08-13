package math;

class AABB {
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	@:native("c")
	public inline function contains(ox:Float, oy:Float):Bool {
		return !(ox < x || ox > x + w || oy < y || oy > y + h);
	}

	@:native("h")
	public function check(o:AABB):Bool {
		return !(x > o.x + o.w || o.x > x + w || y > o.y + o.h || o.y > y + h);
	}
}
