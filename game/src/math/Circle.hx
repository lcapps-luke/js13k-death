package math;

class Circle {
	public var p(default, null):Vec2 = new Vec2();
	public var r:Float;

	public function new(x:Float, y:Float, r:Float) {
		p.set(x, y);
		this.r = r;
	}
}
