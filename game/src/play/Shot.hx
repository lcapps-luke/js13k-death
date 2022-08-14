package play;

import math.AABB;

class Shot {
	public var aabb(default, null):AABB = new AABB(0, 0, 300, 32);

	@:native("a")
	public var active(default, null):Bool = false;
	public var x(default, null):Float = 0;

	@:native("d")
	public var direction(default, null):Float = 0;

	public function new() {}

	@:native("u")
	public function update(s:Float) {
		if (active) {
			active = false;

			Main.context.fillStyle = "#FF0";
			Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
		}
	}

	@:native("f")
	public function fire(x:Float, y:Float, xd:Float) {
		active = true;
		aabb.x = xd > 0 ? x : x - aabb.w;
		aabb.y = y - aabb.h / 2;
		this.x = x;
		this.direction = xd;
	}
}
