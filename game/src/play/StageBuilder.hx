package play;

import math.AABB;
import math.Vec2;
import resource.ResourceBuilder;

class StageBuilder {
	private static var ROOM:Array<Room>;

	public static function init() {
		ROOM = new Array<Room>();

		for (d in ResourceBuilder.buildLevelDefinitions()) {
			ROOM.push(makeRoom(d));
		}
	}

	private static function makeRoom(d:Array<Int>):Room {
		var wallCount = d[0];
		var p = 1;
		var wall = new Array<AABB>();
		for (i in 0...wallCount) {
			wall.push(new AABB(d[p], d[p + 1], d[p + 2], d[p + 3]));
			p += 4;
		}

		var playerSpawnCount = d[p];
		p++;
		var player = new Array<Vec2>();
		for (i in 0...playerSpawnCount) {
			player.push(new Vec2(d[p], d[p + 1]));
			p += 2;
		}

		var enemySpawnCount = d[p];
		p++;
		var enemy = new Array<Vec2>();
		for (i in 0...enemySpawnCount) {
			enemy.push(new Vec2(d[p], d[p + 1]));
			p += 2;
		}

		return {
			walls: wall,
			playerSpawns: player,
			enemySpawns: enemy
		}
	}

	public static function createStage():Stage {
		return [ROOM[0]];
	}
}

typedef Stage = Array<Room>;

typedef Room = {
	var walls:Array<AABB>;
	var playerSpawns:Array<Vec2>;
	var enemySpawns:Array<Vec2>;
}
