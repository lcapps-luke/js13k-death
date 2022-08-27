package resource;

import js.html.svg.ImageElement;
import math.AABB;
import math.Vec2;

class Sprite {
	private var i:ImageElement;
	private var s:AABB;

	public var p(default, null):Vec2 = new Vec2();
	public var o(default, null):Vec2 = new Vec2();
	public var c(default, null):Vec2 = new Vec2(1, 1);
	public var a:Float = 0;

	public function new(i:ImageElement, sx:Float, sy:Float, sw:Float, sh:Float) {
		this.i = i;
		this.s = new AABB(sx, sy, sw, sh);
	}

	@:native("d")
	public function draw() {
		Main.context.save();

		Main.context.translate(p.x, p.y);
		Main.context.rotate(a);

		Main.context.scale(c.x, c.y);

		Main.context.drawImage(i, s.x, s.y, s.w, s.h, -o.x, -o.y, s.w, s.h);

		Main.context.restore();
	}
}
