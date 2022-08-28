package play;

import math.AABB;
import math.Line;
import math.Vec2;
import play.Player.PlayerState;
import play.StageBuilder.Door;
import play.StageBuilder.Room;
import play.StageBuilder.Stage;

class PlayState extends State {
	private static inline var ENEMY_SPAWN_DISTANCE:Float = 300;
	private static inline var ARENA_SPAWN_INTERVAL:Float = 5;

	@:native("t")
	private var stage:Stage;

	@:native("r")
	private var room:Room;
	private var roomId:Int;

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

	@:native("a")
	private var arenaTimer:Float = -1;

	@:native("dt")
	private var deathTimer:Float = 1;

	@:native("rp")
	private var resPoint:AABB = null;

	@:native("ep")
	private var endPoint:AABB = null;

	public function new(stg:Stage, rid:Int, p:Vec2, ps:PlayerState = null) {
		super();
		this.stage = stg;
		this.roomId = rid;
		this.room = stg.rooms[rid];

		player = new Player(this, p.x, p.y);
		if (ps != null) {
			player.setState(ps);
		}

		wall = room.walls;
		door = room.doors;

		if (!room.isArena) {
			spawnWave();
		}

		if (stg.deathRoom == rid) {
			resPoint = new AABB(stg.deathPoint.x - 16, stg.deathPoint.y - 32, 32, 32);
		}

		if (room.e != null) {
			endPoint = new AABB(room.e.x - 16, room.e.y - 32, 32, 32);
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

		if (resPoint != null) {
			Main.context.fillStyle = (arenaTimer > 0 || mobs.length > 0) ? "#00F8" : "#00F";
			Main.context.fillRect(resPoint.x, resPoint.y, resPoint.w, resPoint.h);
			Main.context.globalAlpha = 1;

			if (arenaTimer <= 0 && resPoint.check(player.aabb)) {
				stage.resRoom = stage.deathRoom;
				stage.resPoint = stage.deathPoint;
				stage.deathRoom = -1;
				resPoint = null;
			}
		}

		if (endPoint != null) {
			Main.context.fillStyle = "#FF0";
			Main.context.fillRect(endPoint.x, endPoint.y, endPoint.w, endPoint.h);
			if (endPoint.check(player.aabb)) {
				// next stage
				Main.setState(new NextState(stage.n));
			}
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

		if (!player.alive) {
			deathTimer -= s;

			if (deathTimer < 0) {
				restartStage();
			}
		}

		for (d in door) {
			if (d.aabb.check(player.aabb)) {
				Main.setState(new PlayState(stage, d.targetRoom, d.playerSpawn, player.getState()));
			}
		}

		if (room.isArena && room.q > 0 && arenaTimer < 0) {
			for (t in room.triggers) {
				if (t.check(player.aabb)) {
					for (g in room.gates) {
						wall.push(g);
					}

					spawnWave(room.q);
					arenaTimer = ARENA_SPAWN_INTERVAL;
				}
			}
		}

		if (arenaTimer > 0) {
			arenaTimer -= s;

			if (arenaTimer < 0 || mobs.length < 2) {
				spawnWave(room.q);
				arenaTimer = ARENA_SPAWN_INTERVAL;
			}

			if (mobs.length == 0 && room.q == 0) {
				arenaTimer = 0;

				for (g in room.gates) {
					wall.remove(g);
				}
			}
		}

		drawHud();
	}

	private inline function restartStage() {
		this.stage.deathRoom = roomId;
		this.stage.deathPoint.set(player.x, player.y);

		Main.setState(new PlayState(stage, stage.resRoom, stage.resPoint));
	}

	private inline function drawHud() {
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#FFF";
		Main.context.lineWidth = 5;
		Main.context.font = "bold 50px Verdana, sans-serif";

		var stxt = 'Stage: ${stage.n}';
		Main.context.strokeText(stxt, 10, 60);
		Main.context.fillText(stxt, 10, 60);
		var s = "";
		for (i in 0...8) {
			s += player.ammo > i ? "▮" : "▯";
		}
		s = 'Ammo: $s';

		var sw = Main.context.measureText(s).width;

		Main.context.strokeText(s, 1910 - sw, 60);
		Main.context.fillText(s, 1910 - sw, 60);

		if (arenaTimer > 0) {
			s = Std.string(mobs.length + room.q);
			sw = Main.context.measureText(s).width;

			Main.context.strokeText(s, 1910 / 2 - sw / 2, 60);
			Main.context.fillText(s, 1910 / 2 - sw / 2, 60);
		}
	}

	private function spawnWave(m:Int = -1) {
		if (m == 0) {
			return;
		}

		var qty = 0;
		for (e in room.enemySpawns) {
			if (Line.distance(player.x, player.y, e.x, e.y) > ENEMY_SPAWN_DISTANCE) {
				mobs.push(new Zombi(this, e.x, e.y));
				room.q--;
				qty++;
				if (m > 0 && qty == m) {
					return;
				}
			}
		}
	}
}
