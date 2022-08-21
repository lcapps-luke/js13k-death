package play;

import haxe.iterators.ArrayIterator;
import math.AABB;
import math.Rand;
import math.Vec2;
import resource.ResourceBuilder;

class StageBuilder {
	private static inline var LEFT = 0;
	private static inline var RIGHT = 1;

	@:native("R")
	private static var ROOM:Array<RoomTemplate>;

	@:native("RE")
	private static var ROOM_END:Array<Int>;
	@:native("RLD")
	private static var ROOM_LEFT_DOOR:Array<RoomTemplateDoor>;
	@:native("RRD")
	private static var ROOM_RIGHT_DOOR:Array<RoomTemplateDoor>;

	@:native("i")
	public static function init() {
		ROOM = new Array<RoomTemplate>();
		ROOM_END = new Array<Int>();
		ROOM_LEFT_DOOR = new Array<RoomTemplateDoor>();
		ROOM_RIGHT_DOOR = new Array<RoomTemplateDoor>();

		var r = 0;
		for (d in ResourceBuilder.buildLevelDefinitions()) {
			ROOM.push(makeRoom(d, r));
			r++;
		}
	}

	/**
	 * wallCount x, y, width, height
	 * playerSpawnCount: x, y
	 * enemySpawnCount: x, y
	 * doorCount: x, y, width, height
	 * gateCount: x, y, width, height
	 * triggerCount: x, y, width, height
	**/
	@:native("mr")
	private static function makeRoom(d:Array<Int>, idx:Int):RoomTemplate {
		var it = d.iterator();
		var wall = loadAABBs(it);
		var player = loadVec2s(it);
		var enemy = loadVec2s(it);
		var door = loadDoors(it);
		var gate = loadAABBs(it);
		var trigger = loadAABBs(it);

		if (door.length == 1) {
			ROOM_END.push(idx);
		}

		for (d in 0...door.length) {
			var r = {
				roomIdx: idx,
				doorIdx: d
			}

			if (door[d].pos == LEFT) {
				ROOM_LEFT_DOOR.push(r);
			}
			else {
				ROOM_RIGHT_DOOR.push(r);
			}
		}

		return {
			walls: wall,
			playerSpawns: player,
			enemySpawns: enemy,
			doors: door,
			gates: gate,
			triggers: trigger
		};
	}

	@:native("la")
	private static function loadAABBs(arr:ArrayIterator<Int>):Array<AABB> {
		var qty = arr.next();

		var res = new Array<AABB>();
		for (i in 0...qty) {
			res.push(new AABB(arr.next(), arr.next(), arr.next(), arr.next()));
		}

		return res;
	}

	@:native("lv")
	private static function loadVec2s(arr:ArrayIterator<Int>):Array<Vec2> {
		var qty = arr.next();

		var res = new Array<Vec2>();
		for (i in 0...qty) {
			res.push(new Vec2(arr.next(), arr.next()));
		}

		return res;
	}

	@:native("ld")
	private static function loadDoors(arr:ArrayIterator<Int>):Array<DoorTemplate> {
		return loadAABBs(arr).map(a -> {
			return {
				aabb: a,
				pos: a.x < 0 ? LEFT : RIGHT
			};
		});
	}

	@:native("cs")
	public static function createStage(length:Int = 4):Stage {
		var startTpl = chooseRandomRoomTemplate(ROOM_END);
		var rooms = new Array<Room>();

		var startDoors = new Array<Door>();
		var start:Room = {
			walls: startTpl.walls,
			enemySpawns: startTpl.enemySpawns,
			doors: startDoors,
			triggers: startTpl.triggers,
			gates: startTpl.gates,
			isArena: false
		}
		rooms.push(start);
		var roomId = rooms.length - 1;

		for (d in startTpl.doors) {
			var spwn = getDoorSpawnPos(d);

			var next = createNextRoom(rooms, d.pos, roomId, spwn, length - 1);
			startDoors.push({
				aabb: d.aabb,
				targetRoom: next.r,
				playerSpawn: next.p
			});
		}

		return {
			rooms: rooms,
			resRoom: roomId,
			resPoint: startTpl.playerSpawns[0]
		};
	}

	@:native("cnr")
	static function createNextRoom(rooms:Array<Room>, fromPos:Int, fromRoomId:Int, fromRoomSpwn:Vec2, len:Int) {
		var toPos = fromPos == LEFT ? RIGHT : LEFT;
		var set = fromPos == LEFT ? ROOM_RIGHT_DOOR : ROOM_LEFT_DOOR;
		if (len == 0) {
			set = set.filter(t -> ROOM_END.contains(t.roomIdx));
		}
		else {
			set = set.filter(t -> !ROOM_END.contains(t.roomIdx));
		}

		var tgt = Rand.chooseItem(set);
		var tpl = ROOM[tgt.roomIdx];

		var doors = new Array<Door>();
		var room:Room = {
			walls: tpl.walls,
			enemySpawns: tpl.enemySpawns,
			doors: doors,
			triggers: tpl.triggers,
			gates: tpl.gates,
			isArena: false
		};
		rooms.push(room);
		var roomId = rooms.length - 1;

		var pos = new Vec2();
		for (d in tpl.doors) {
			if (d.pos == toPos) {
				pos = getDoorSpawnPos(d);
				doors.push({
					aabb: d.aabb,
					targetRoom: fromRoomId,
					playerSpawn: fromRoomSpwn
				});
				continue;
			}

			var spwn = getDoorSpawnPos(d);
			var next = createNextRoom(rooms, d.pos, roomId, spwn, len - 1);
			doors.push({
				aabb: d.aabb,
				targetRoom: next.r,
				playerSpawn: next.p
			});
		}

		return {
			r: roomId,
			p: pos
		};
	}

	@:native("dgsp")
	static function getDoorSpawnPos(d:DoorTemplate):Vec2 {
		return switch (d.pos) {
			case LEFT:
				new Vec2(d.aabb.x + d.aabb.w + 17, d.aabb.y + d.aabb.h);
			case RIGHT:
				new Vec2(d.aabb.x - 17, d.aabb.y + d.aabb.h);
			default:
				throw 'Unknown position ${d.pos}';
		}
	}

	@:native("crrt")
	static function chooseRandomRoomTemplate(ids:Array<Int>) {
		var i = ids[Math.floor(Math.random() * ids.length)];
		return ROOM[i];
	}
}

typedef Stage = {
	@:native("r")
	var rooms:Array<Room>;
	@:native("o")
	var resRoom:Int;
	@:native("p")
	var resPoint:Vec2;
}

typedef RoomTemplate = {
	@:native("w")
	var walls:Array<AABB>;
	@:native("p")
	var playerSpawns:Array<Vec2>;
	@:native("e")
	var enemySpawns:Array<Vec2>;
	@:native("d")
	var doors:Array<DoorTemplate>;
	@:native("g")
	var gates:Array<AABB>;
	@:native("t")
	var triggers:Array<AABB>;
}

typedef DoorTemplate = {
	@:native("a")
	var aabb:AABB;
	@:native("p")
	var pos:Int;
}

typedef RoomTemplateDoor = {
	@:native("r")
	var roomIdx:Int;
	@:native("d")
	var doorIdx:Int;
}

typedef Room = {
	@:native("w")
	var walls:Array<AABB>;
	@:native("e")
	var enemySpawns:Array<Vec2>;
	@:native("d")
	var doors:Array<Door>;
	@:native("g")
	var gates:Array<AABB>;
	@:native("t")
	var triggers:Array<AABB>;
	@:native("a")
	var isArena:Bool;
}

typedef Door = {
	@:native("a")
	var aabb:AABB;
	@:native("t")
	var targetRoom:Int;
	@:native("p")
	var playerSpawn:Vec2;
}
