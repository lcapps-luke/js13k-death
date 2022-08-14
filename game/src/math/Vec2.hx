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

	@:native("d")
	public function distanceTo(x:Float, y:Float):Float {
		return Math.sqrt(Math.pow(this.x - x, 2) + Math.pow(this.y - y, 2));
	}

	@:native("c")
	public function clone() {
		return new Vec2(x, y);
	}
}
