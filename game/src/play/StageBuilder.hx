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
			ROOM.push(makeRoomTemplate(d, r));
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
	private static function makeRoomTemplate(d:Array<Int>, idx:Int):RoomTemplate {
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
				r: idx,
				d: d
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
			default: throw 'Unknown Door set $id';
		}
	}

	private static inline function invertDoorPos(id:Int):Int {
		return id * -1;
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
	public static function createStage(length:Int = 4):Stage {
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
		rooms.push(makeRoom(startTpl, startDoors));
		var roomId = rooms.length - 1;

		for (d in startTpl.d) {
			var spwn = getDoorSpawnPos(d);

			var next = createNextRoom(rooms, d.p, roomId, spwn, length - 1);
			startDoors.push({
				aabb: d.a,
				targetRoom: next.r,
				playerSpawn: next.p
			});
		}

		return {
			rooms: rooms,
			resRoom: roomId,
			resPoint: startTpl.p[0]
		};
	}

	@:native("cnr")
	static function createNextRoom(rooms:Array<Room>, fromPos:Int, fromRoomId:Int, fromRoomSpwn:Vec2, len:Int) {
		var toPos = invertDoorPos(fromPos);
		var set = getDoorSet(toPos);
		if (len == 0) {
			set = set.filter(t -> ROOM_END.contains(t.r));
		}
		else {
			set = set.filter(t -> !ROOM_END.contains(t.r));
		}

		var tgt = Rand.chooseItem(set);
		var tpl = ROOM[tgt.r];

		var doors = new Array<Door>();
		rooms.push(makeRoom(tpl, doors));
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
			var next = createNextRoom(rooms, d.p, roomId, spwn, len - 1);
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
	static function makeRoom(t:RoomTemplate, d:Array<Door>, a:Bool = false):Room {
		return {
			walls: t.w,
			enemySpawns: t.e,
			doors: d,
			triggers: t.t,
			gates: t.g,
			isArena: a
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
				new Vec2(d.a.x + d.a.w / 2, d.a.y + d.a.h + 65);
			case BOTTOM:
				new Vec2(d.a.x + d.a.w / 2, d.a.y - 1);
			default:
				throw 'Unknown position ${d.p}';
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
}

typedef Room = {
	var walls:Array<AABB>;
	var enemySpawns:Array<Vec2>;
	var doors:Array<Door>;
	var gates:Array<AABB>;
	var triggers:Array<AABB>;
	var isArena:Bool;
}

typedef Door = {
	var aabb:AABB;
	var targetRoom:Int;
	var playerSpawn:Vec2;
}
