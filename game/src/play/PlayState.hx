package play;

import math.AABB;

class PlayState extends State {
	private var player:Player;

	public var wall(default, null):Array<AABB> = [];

	public function new() {
		super();

		player = new Player(this);
		wall = [
			new AABB(0, 1080 - 64, 1920, 64),
			new AABB(200, 1080 / 2, 64, 1080 - 200),
			new AABB(1920 / 2 + 200, 1080 - 200, 200, 100)
		];
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#aaa";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#000";
		for (w in wall) {
			Main.context.fillRect(w.x, w.y, w.w, w.h);
		}

		player.update(s);
	}
}
