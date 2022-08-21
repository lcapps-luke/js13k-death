package play;

import math.AABB;
import play.StageBuilder.Room;

class PlayState extends State {
	@:native("p")
	public var player(default, null):Player;

	@:native("m")
	public var mobs(default, null):Array<Mob> = [];

	@:native("w")
	public var wall(default, null):Array<AABB> = [];

	@:native("s")
	public var shot(default, null) = new Shot();

	@:native("pa")
	public var particle(default, null):Array<Gore> = [];

	public function new(room:Room) {
		super();

		var ps = room.playerSpawns[0];
		player = new Player(this, ps.x, ps.y);

		wall = room.walls;

		for (e in room.enemySpawns) {
			mobs.push(new Zombi(this, e.x, e.y));
		}
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#aaa";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#000";
		for (w in wall) {
			Main.context.fillRect(w.x, w.y, w.w, w.h);
		}

		for (g in particle) {
			g.update(s);
			if (!g.alive) {
				particle.remove(g);
			}
		}

		for (m in mobs) {
			m.update(s);

			if (!m.alive) {
				mobs.remove(m);

				mobs.push(new Zombi(this, 1920 / 2 + 300, 1080 - 264));
			}
		}

		shot.update(s, this);
		player.update(s);

		drawHud();
	}

	private inline function drawHud() {
		Main.context.fillStyle = "#000";
		Main.context.font = "bold 50px Verdana, sans-serif";

		Main.context.fillText('Score: 0000', 10, 60);
		var s = "";
		for (i in 0...8) {
			s += player.ammo > i ? "▮" : "▯";
		}
		s = 'Ammo: $s';

		var sw = Main.context.measureText(s).width;

		Main.context.fillText(s, 1910 - sw, 60);
	}
}
