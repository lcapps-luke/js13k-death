package play;

import haxe.iterators.ArrayIterator;
import math.AABB;
import math.Rand;
import math.Vec2;
import resource.ResourceBuilder;

class StageBuilder {
	private static inline var LEFT = -1;
	private static inline var RIGHT = 1;
	private static inline var TOP = -2;
	private static inline var BOTTOM = 2;

	@:native("R")
	private static var ROOM:Array<RoomTemplate>;

	@:native("RE")
	private static var ROOM_END:Array<Int>;
	@:native("RLD")
	private static var ROOM_LEFT_DOOR:Array<RoomTemplateDoor>;
	@:native("RRD")
	private static var ROOM_RIGHT_DOOR:Array<RoomTemplateDoor>;
	@:native("RTD")
	private static var ROOM_TOP_DOOR:Array<RoomTemplateDoor>;
	@:native("RBD")
	private static var ROOM_BOTTOM_DOOR:Array<RoomTemplateDoor>;

	@:native("i")
	public static function init() {
		ROOM = new Array<RoomTemplate>();
		ROOM_END = new Array<Int>();
		ROOM_LEFT_DOOR = new Array<RoomTemplateDoor>();
		ROOM_RIGHT_DOOR = new Array<RoomTemplateDoor>();
		ROOM_TOP_DOOR = new Array<RoomTemplateDoor>();
		ROOM_BOTTOM_DOOR = new Array<RoomTemplateDoor>();

		var r = 0;
		for (d in ResourceBuilder.buildLevelDefinitions()) {
			ROOM.push(makeRoomTemplate(d, r, -1));
			r++;
			if (d[0] == 1) {
				ROOM.push(makeRoomTemplate(d, r, 1));
				r++;
			}
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
	private static function makeRoomTemplate(d:Array<Int>, idx:Int, m:Int):RoomTemplate {
		var it = d.iterator();
		it.next();
		var wall = loadAABBs(it, m);
		var player = loadVec2s(it, m);
		var enemy = loadVec2s(it, m);
		var door = loadDoors(it, m);
		var gate = loadAABBs(it, m);
		var trigger = loadAABBs(it, m);

		if (door.length == 1) {
			ROOM_END.push(idx);
		}

		for (d in 0...door.length) {
			var r = {
				r: idx,
				d: d,
				q: 0
			}

			getDoorSet(door[d].p).push(r);
		}

		return {
			w: wall,
			p: player,
			e: enemy,
			d: door,
			g: gate,
			t: trigger
		};
	}

	private static inline function getDoorSet(id:Int):Array<RoomTemplateDoor> {
		return switch (id) {
			case TOP: ROOM_TOP_DOOR;
			case BOTTOM: ROOM_BOTTOM_DOOR;
			case LEFT: ROOM_LEFT_DOOR;
			case RIGHT: ROOM_RIGHT_DOOR;
			default: throw '$id';
		}
	}

	private static inline function invertDoorPos(id:Int):Int {
		return id * -1;
	}

	@:native("la")
	private static function loadAABBs(arr:ArrayIterator<Int>, m:Int):Array<AABB> {
		var qty = arr.next();

		var res = new Array<AABB>();
		for (i in 0...qty) {
			var a = new AABB(arr.next(), arr.next(), arr.next(), arr.next());
			if (m > 0) {
				a.mirrorX(960);
			}
			res.push(a);
		}

		return res;
	}

	@:native("lv")
	private static function loadVec2s(arr:ArrayIterator<Int>, m:Int):Array<Vec2> {
		var qty = arr.next();

		var res = new Array<Vec2>();
		for (i in 0...qty) {
			var a = new Vec2(arr.next(), arr.next());
			if (m > 0) {
				a.mirrorX(960);
			}
			res.push(a);
		}

		return res;
	}

	@:native("ld")
	private static function loadDoors(arr:ArrayIterator<Int>, m:Int):Array<DoorTemplate> {
		return loadAABBs(arr, m).map(a -> {
			var p = 0;

			if (a.x > 1920) {
				p = RIGHT;
			}
			else if (a.x + a.w < 0) {
				p = LEFT;
			}
			else if (a.y > 1080) {
				p = BOTTOM;
			}
			else {
				p = TOP;
			}

			return {
				a: a,
				p: p
			};
		});
	}

	@:native("cs")
	public static function createStage(length:Int, n:Int):Stage {
		var startRooms = ROOM_END.filter(i -> {
			for (r in ROOM_TOP_DOOR) {
				if (r.r == i) {
					return false;
				}
			}
			return true;
		});

		var startTpl = chooseRandomRoomTemplate(startRooms);
		var rooms = new Array<Room>();

		var startDoors = new Array<Door>();
		rooms.push(makeRoom(startTpl, startDoors, 1));
		var roomId = rooms.length - 1;
		rooms[0].e = null;

		for (d in startTpl.d) {
			var spwn = getDoorSpawnPos(d);

			var next = createNextRoom(rooms, d.p, roomId, spwn, length - 1, length);
			startDoors.push({
				aabb: d.a,
				targetRoom: next.r,
				playerSpawn: next.p
			});
		}

		return {
			rooms: rooms,
			resRoom: roomId,
			resPoint: startTpl.p[0],
			deathRoom: -1,
			deathPoint: new Vec2(),
			n: n
		};
	}

	@:native("cnr")
	static function createNextRoom(rooms:Array<Room>, fromPos:Int, fromRoomId:Int, fromRoomSpwn:Vec2, len:Int, sl:Int) {
		var toPos = invertDoorPos(fromPos);
		var set = getDoorSet(toPos);
		if (len == 0) {
			set = set.filter(t -> ROOM_END.contains(t.r));
		}
		else {
			set = set.filter(t -> !ROOM_END.contains(t.r));
		}

		var tgt = Rand.chooseItem(set, (d) -> {
			if (d.q > 0) {
				d.q--;
				return true;
			}
			return false;
		});
		tgt.q++;
		var tpl = ROOM[tgt.r];

		var doors = new Array<Door>();
		rooms.push(makeRoom(tpl, doors, sl - len));
		var roomId = rooms.length - 1;

		var pos = new Vec2();
		for (d in tpl.d) {
			if (d.p == toPos) {
				pos = getDoorSpawnPos(d);
				doors.push({
					aabb: d.a,
					targetRoom: fromRoomId,
					playerSpawn: fromRoomSpwn
				});
				continue;
			}

			var spwn = getDoorSpawnPos(d);
			var next = createNextRoom(rooms, d.p, roomId, spwn, len - 1, sl);
			doors.push({
				aabb: d.a,
				targetRoom: next.r,
				playerSpawn: next.p
			});
		}

		return {
			r: roomId,
			p: pos
		};
	}

	@:native("mkr")
	static function makeRoom(t:RoomTemplate, d:Array<Door>, s:Int):Room {
		var a = t.t.length > 0 && Math.random() > 0.75;

		return {
			walls: t.w,
			enemySpawns: t.e,
			doors: d,
			triggers: t.t,
			gates: t.g,
			isArena: a,
			q: s * 2 + Math.round(Math.random() * (s * 2)),
			e: t.d.length == 1 ? t.p[0] : null
		};
	}

	@:native("dgsp")
	static function getDoorSpawnPos(d:DoorTemplate):Vec2 {
		return switch (d.p) {
			case LEFT:
				new Vec2(d.a.x + d.a.w + 17, d.a.y + d.a.h);
			case RIGHT:
				new Vec2(d.a.x - 17, d.a.y + d.a.h);
			case TOP:
				new Vec2(d.a.x + d.a.w / 2, d.a.y + d.a.h + Mob.BASE_HEIGHT);
			case BOTTOM:
				new Vec2(d.a.x + d.a.w / 2, d.a.y - 1);
			default:
				throw '${d.p}';
		}
	}

	@:native("crrt")
	static function chooseRandomRoomTemplate(ids:Array<Int>) {
		return ROOM[Rand.chooseItem(ids)];
	}
}

typedef Stage = {
	var rooms:Array<Room>;
	var resRoom:Int;
	var resPoint:Vec2;
	var deathRoom:Int;
	var deathPoint:Vec2;
	var n:Int;
}

typedef RoomTemplate = {
	var w:Array<AABB>;
	var p:Array<Vec2>;
	var e:Array<Vec2>;
	var d:Array<DoorTemplate>;
	var g:Array<AABB>;
	var t:Array<AABB>;
}

typedef DoorTemplate = {
	var a:AABB;
	var p:Int;
}

typedef RoomTemplateDoor = {
	var r:Int;
	var d:Int;
	var q:Int;
}

typedef Room = {
	var walls:Array<AABB>;
	var enemySpawns:Array<Vec2>;
	var doors:Array<Door>;
	var gates:Array<AABB>;
	var triggers:Array<AABB>;
	var isArena:Bool;
	var q:Int;
	var e:Vec2;
}

typedef Door = {
	var aabb:AABB;
	var targetRoom:Int;
	var playerSpawn:Vec2;
}
