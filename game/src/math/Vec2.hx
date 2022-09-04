package math;

class Vec2 {
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	@:native("s")
	public function set(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}

	@:native("o")
	public function copy(o:Vec2) {
		this.x = o.x;
		this.y = o.y;
		return this;
	}

	@:native("d")
	public function distanceTo(x:Float, y:Float):Float {
		return Math.sqrt(Math.pow(this.x - x, 2) + Math.pow(this.y - y, 2));
	}

	@:native("c")
	public function clone() {
		return new Vec2(x, y);
	}

	@:native("u")
	public function sub(o:Vec2) {
		this.x -= o.x;
		this.y -= o.y;
		return this;
	}

	@:native("m")
	public function mul(v:Float) {
		this.x *= v;
		this.y *= v;
		return this;
	}

	@:native("a")
	public function add(o:Vec2) {
		this.x += o.x;
		this.y += o.y;
		return this;
	}

	@:native("i")
	public function dirTo(o:Vec2) {
		return Math.atan2(o.y - y, o.x - x);
	}

	@:native("mrx")
	public function mirrorX(m:Float) {
		x = m + m - x;
	}
}
