package play;

import math.AABB;
import math.Line;
import math.Vec2;
import play.Player.PlayerState;
import play.StageBuilder.Door;
import play.StageBuilder.Stage;

class PlayState extends State {
	private static inline var ENEMY_SPAWN_DISTANCE:Float = 300;

	private var stage:Stage;

	@:native("p")
	public var player(default, null):Player;

	@:native("m")
	public var mobs(default, null):Array<Mob> = [];

	@:native("w")
	public var wall(default, null):Array<AABB> = [];

	@:native("d")
	private var door:Array<Door> = [];

	@:native("s")
	public var shot(default, null) = new Shot();

	@:native("pa")
	public var particle(default, null):Array<Gore> = [];

	public function new(stg:Stage, rid:Int, p:Vec2, ps:PlayerState = null) {
		super();
		this.stage = stg;

		var room = stg.rooms[rid];

		player = new Player(this, p.x, p.y);
		if (ps != null) {
			player.setState(ps);
		}

		wall = room.walls;
		door = room.doors;

		for (e in room.enemySpawns) {
			if (Line.distance(p.x, p.y, e.x, e.y) > ENEMY_SPAWN_DISTANCE) {
				mobs.push(new Zombi(this, e.x, e.y));
			}
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
			}
		}

		shot.update(s, this);
		player.update(s);

		for (d in door) {
			if (d.aabb.check(player.aabb)) {
				Main.setState(new PlayState(stage, d.targetRoom, d.playerSpawn, player.getState()));
			}
		}

		drawHud();
	}

	private inline function drawHud() {
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#FFF";
		Main.context.lineWidth = 5;
		Main.context.font = "bold 50px Verdana, sans-serif";

		Main.context.strokeText('Score: 0000', 10, 60);
		Main.context.fillText('Score: 0000', 10, 60);
		var s = "";
		for (i in 0...8) {
			s += player.ammo > i ? "▮" : "▯";
		}
		s = 'Ammo: $s';

		var sw = Main.context.measureText(s).width;

		Main.context.strokeText(s, 1910 - sw, 60);
		Main.context.fillText(s, 1910 - sw, 60);
	}
}
