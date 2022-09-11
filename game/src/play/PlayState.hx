package play;

import js.html.Image;
import math.AABB;
import math.Line;
import math.Vec2;
import play.Player.PlayerState;
import play.StageBuilder.Door;
import play.StageBuilder.Room;
import play.StageBuilder.Stage;
import resource.Images;

class PlayState extends State {
	private static inline var ENEMY_SPAWN_DISTANCE:Float = 300;
	private static inline var ARENA_SPAWN_INTERVAL_MIN:Float = 0.5;
	private static inline var ARENA_SPAWN_INTERVAL_MAX:Float = 3;

	@:native("t")
	private var stage:Stage;

	@:native("r")
	private var room:Room;
	@:native("rid")
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
	public var particle(default, null):Array<Particle> = [];

	@:native("a")
	private var arenaTimer:Float = -1;
	@:native("ast")
	private var arenaSpawnTimer:Float = ARENA_SPAWN_INTERVAL_MAX;

	@:native("dt")
	private var deathTimer:Float = 1;

	@:native("rp")
	private var resPoint:AABB = null;

	@:native("ep")
	private var endPoint:AABB = null;

	@:native("rmp")
	private var roomMidPoint:Float = 0;

	@:native("scs")
	public var screenShake:Float = 0;

	public function new(stg:Stage, rid:Int, p:Vec2, ps:PlayerState = null) {
		super();
		this.stage = stg;
		this.roomId = rid;
		this.room = stg.rooms[rid];

		player = new Player(this, p.x, p.y);
		if (ps != null) {
			player.setState(ps);
		}

		var rc = 0;
		for (d in room.doors) {
			if (d.aabb.y > 0 && d.aabb.y < 1080) {
				roomMidPoint += d.aabb.y + d.aabb.h;
				rc++;
			}
		}
		roomMidPoint = rc > 0 ? Math.round(roomMidPoint / rc) : 1080 / 2;

		wall = room.walls.copy();
		door = room.doors;

		if (!room.isArena) {
			spawnWave(room.q, 0);
		}
		else {
			arenaSpawnTimer = ARENA_SPAWN_INTERVAL_MIN + (1 - Math.min(room.q / 100, 1)) * ARENA_SPAWN_INTERVAL_MAX;
		}

		if (stg.deathRoom == rid) {
			resPoint = new AABB(stg.deathPoint.x - 16, stg.deathPoint.y - 64, 32, 64);
		}

		if (room.e != null) {
			endPoint = new AABB(room.e.x - 36, room.e.y - 153, 72, 153);
		}
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.save();

		if (screenShake > 0) {
			screenShake -= s;
			var d = 10 * screenShake;
			Main.context.translate(-d + Math.random() * (d * 2), -d + Math.random() * (d * 2));
		}

		Main.context.fillStyle = "#918299";
		Main.context.fillRect(0, 0, 1920, roomMidPoint);
		Main.context.fillStyle = "#727272";
		Main.context.fillRect(0, roomMidPoint, 1920, 1080 - roomMidPoint);
		Main.context.fillStyle = "#99776B";
		Main.context.fillRect(0, roomMidPoint - 32, 1920, 32);

		Main.context.fillStyle = "#000";
		for (w in wall) {
			Main.context.fillRect(w.x, w.y, w.w, w.h);
		}

		if (resPoint != null) {
			var cc = !(arenaTimer > 0 || mobs.length > 0);

			Main.context.globalAlpha = cc ? 1 : 0.5;
			Main.context.drawImage(Images.phoenix, resPoint.x, resPoint.y, resPoint.w, resPoint.h);
			Main.context.globalAlpha = 1;

			if (cc && player.isAlive() && resPoint.check(player.aabb)) {
				stage.resRoom = stage.deathRoom;
				stage.resPoint = stage.deathPoint;
				stage.deathRoom = -1;
				player.recoverShield();
				resPoint = null;
				Sound.recoverSpawn();
			}
		}

		if (endPoint != null) {
			Main.context.drawImage(Images.door, endPoint.x, endPoint.y, endPoint.w, endPoint.h);
			if (endPoint.check(player.aabb)) {
				// next stage
				Main.setState(new NextState(stage.n));
				Sound.stageEnd();
			}
		}

		for (m in mobs) {
			m.update(s);
			if (!m.isAlive()) {
				mobs.remove(m);
			}
		}

		shot.update(s, this);
		player.update(s);

		if (stage.resRoom == roomId) {
			var lg = Main.context.createLinearGradient(0, stage.resPoint.y - 64, 0, stage.resPoint.y);
			lg.addColorStop(0, "#0F00");
			lg.addColorStop(1, "#0F0");
			Main.context.fillStyle = lg;
			Main.context.fillRect(stage.resPoint.x - 16, stage.resPoint.y - 64, 32, 64);
		}

		for (g in particle) {
			g.update(s);
			if (!g.alive) {
				particle.remove(g);
			}
		}

		if (!player.isAlive()) {
			deathTimer -= s;

			if (deathTimer < 0) {
				restartStage();
			}

			if (resPoint == null) {
				resPoint = new AABB(player.x - 16, player.y - 64, 32, 64);
			}
		}

		for (d in door) {
			if (d.aabb.check(player.aabb)) {
				this.room.q += mobs.length;
				Main.setState(new PlayState(stage, d.targetRoom, d.playerSpawn, player.getState()));
			}
		}

		if (room.isArena && room.q > 0 && arenaTimer < 0) {
			for (t in room.triggers) {
				if (t.check(player.aabb)) {
					for (g in room.gates) {
						wall.push(g);
					}

					spawnWave(room.q, 50);
					arenaTimer = arenaSpawnTimer;
				}
			}
		}

		if (arenaTimer > 0) {
			arenaTimer -= s;

			if (arenaTimer < 0 || mobs.length < 2) {
				spawnWave(room.q, 50);
				arenaTimer = arenaSpawnTimer;
			}

			if (mobs.length == 0 && room.q == 0) {
				arenaTimer = 0;

				for (g in room.gates) {
					wall.remove(g);
				}
			}
		}

		Main.context.restore();

		Tutorial.update(this);
		drawHud();
	}

	private inline function restartStage() {
		if (stage.deathRoom > -1) {
			Main.setState(new GameOver(stage.n));
			return;
		}

		this.stage.deathRoom = roomId;
		this.stage.deathPoint = new Vec2(player.x, player.y);

		this.room.q += mobs.length;

		player.recoverShield();
		Main.setState(new PlayState(stage, stage.resRoom, stage.resPoint, player.getState()));
	}

	private inline function drawHud() {
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#FFF";
		Main.context.lineWidth = 5;
		Main.context.font = "bold 50px Verdana, sans-serif";

		var stxt = 'Stage: ${stage.n}';
		Main.context.strokeText(stxt, 10, 60);
		Main.context.fillText(stxt, 10, 60);

		var s = "Ammo: ";
		for (i in 0...8) {
			s += player.ammo > i ? "▮" : "▯";
		}

		var sw = Main.context.measureText(s).width;

		Main.context.strokeText(s, 1910 - sw, 60);
		Main.context.fillText(s, 1910 - sw, 60);

		if (arenaTimer > 0) {
			s = Std.string(mobs.length + room.q);
			sw = Main.context.measureText(s).width;

			Main.context.strokeText(s, 1910 / 2 - sw / 2, 135);
			Main.context.fillText(s, 1910 / 2 - sw / 2, 135);
		}

		if (stage.deathRoom == -1) {
			Main.context.drawImage(Images.phoenix, 1920 / 2 - 25, 25, 50, 50);
		}
	}

	private function spawnWave(m:Int, p:Int) {
		if (m == 0 || mobs.length > 10) {
			return;
		}

		var qty = 0;
		for (e in room.enemySpawns) {
			if (Line.distance(player.x, player.y, e.x, e.y) > ENEMY_SPAWN_DISTANCE) {
				var h = Zombi.HEALTH_NORMAL;
				if (Math.random() < (stage.n - 1) * 0.05) {
					h = Zombi.HEALTH_HARD;
				}

				var z = new Zombi(this, e.x, e.y - 1, h);
				mobs.push(z);
				particleBurst(Particle.spawn, z.aabb, p);

				room.q--;
				qty++;
				if (m > 0 && qty == m) {
					return;
				}
			}
		}
	}

	public function particleBurst(pf:PlayState->Float->Float->Float->Float->Particle, a:AABB, q:Int) {
		for (i in 0...q) {
			var sp = 200 + Math.random() * 100;
			var dir = Math.random() * (Math.PI * 2);
			var p = pf(this, a.randomX(), a.randomY(), Math.cos(dir) * sp, Math.cos(dir) * sp);
			particle.push(p);
		}
	}

	public function spaceFree(z:AABB) {
		if (z.x < 0 || z.x + z.w > 1920) {
			return false;
		}

		for (w in wall) {
			if (w.check(z)) {
				return false;
			}
		}
		return true;
	}
}
