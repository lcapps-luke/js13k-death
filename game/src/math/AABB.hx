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

	@:native("cx")
	public function centerX():Float {
		return x + w / 2;
	}

	@:native("cy")
	public function centerY():Float {
		return y + h / 2;
	}

	@:native("c")
	public inline function contains(ox:Float, oy:Float):Bool {
		return !(ox < x || ox > x + w || oy < y || oy > y + h);
	}

	@:native("ch")
	public function check(o:AABB, xs:Float = 0, ys:Float = 0):Bool {
		return !(x > o.x + o.w + xs || o.x + xs > x + w || y > o.y + ys + o.h || o.y + ys > y + h);
	}

	@:native("mx")
	public function moveContactX(o:AABB, m:Float):Float {
		return moveContact(x, x + w, o.x, o.x + o.w, m);
	}

	@:native("my")
	public function moveContactY(o:AABB, m:Float):Float {
		return moveContact(y, y + h, o.y, o.y + o.h, m);
	}

	@:native("mc")
	private static function moveContact(l:Float, h:Float, ol:Float, oh:Float, m:Float):Float {
		var d:Float = m > 0 ? ol - h : oh - l;
		return m > 0 ? Math.min(Math.abs(d), Math.abs(m)) : -Math.min(Math.abs(d), Math.abs(m));
	}
}
