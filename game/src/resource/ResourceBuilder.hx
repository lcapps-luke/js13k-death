package resource;

#if macro
import haxe.Json;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class ResourceBuilder {
	private static inline var IMG_PATH = "res/img/";
	private static inline var IMG_MIN_PATH = "build/res/img/";
	private static var minifiedImages = false;

	macro public static function buildLevelDefinitions():ExprOf<Array<Array<Int>>> {
		var res = new Array<Array<Int>>();

		var path = "res/level/";
		for (f in FileSystem.readDirectory(path)) {
			res.push(buildLevel(path + f));
		}

		return Context.makeExpr(res, Context.currentPos());
	}

	macro public static function buildImage(name:String):ExprOf<String> {
		if (!minifiedImages) {
			FileSystem.createDirectory(IMG_MIN_PATH);
			cleanDir(IMG_MIN_PATH);

			Sys.command("svgo", [
				      "-f",              IMG_PATH,
				      "-o",          IMG_MIN_PATH,
				      "-p",                   "1",
				"--enable",         "removeTitle",
				"--enable",          "removeDesc",
				"--enable",   "removeUselessDefs",
				"--enable", "removeEditorsNSData",
				"--enable",       "removeViewBox",
				"--enable", "transformsWithOnePath"
			]);

			minifiedImages = true;
		}

		var imgContent = File.getContent(IMG_MIN_PATH + name);

		return Context.makeExpr(imgContent, Context.currentPos());
	}

	#if macro
	private static function buildLevel(path) {
		var json:TiledMap = cast Json.parse(File.getContent(path));

		var canMirror = getCanMirror(json.properties);

		var walls = new Array<TiledObject>();
		var players = new Array<TiledObject>();
		var enemies = new Array<TiledObject>();
		var doors = new Array<TiledObject>();
		var gates = new Array<TiledObject>();
		var triggers = new Array<TiledObject>();

		for (l in json.layers) {
			if (l.type != "objectgroup") {
				continue;
			}

			switch (l.name) {
				case "wall":
					addAll(walls, l.objects);
				case "player":
					addAll(players, l.objects);
				case "enemy":
					addAll(enemies, l.objects);
				case "door":
					addAll(doors, l.objects);
				case "gate":
					addAll(gates, l.objects);
				case "trigger":
					addAll(triggers, l.objects);
			}
		}

		var level = new Array<Int>();
		level.push(canMirror ? 1 : 0);
		pushRects(level, walls);
		pushPoints(level, players);
		pushPoints(level, enemies);
		pushRects(level, doors);
		pushRects(level, gates);
		pushRects(level, triggers);

		return level;
	}

	static function getCanMirror(props:Array<TiledProperty>) {
		if (props != null) {
			for (p in props) {
				if (p.name == "canMirror") {
					return p.value;
				}
			}
		}

		trace("Room doesn't specify 'canMirror' so will not get mirror variant");
		return false;
	}

	private static function addAll(arr:Array<TiledObject>, src:Array<TiledObject>) {
		for (o in src) {
			arr.push(o);
		}
	}

	private static function pushRects(arr:Array<Int>, obj:Array<TiledObject>) {
		arr.push(obj.length);
		for (o in obj) {
			arr.push(Math.round(o.x));
			arr.push(Math.round(o.y));
			arr.push(Math.round(o.width));
			arr.push(Math.round(o.height));
		}
	}

	private static function pushPoints(arr:Array<Int>, obj:Array<TiledObject>) {
		arr.push(obj.length);
		for (o in obj) {
			arr.push(Math.round(o.x));
			arr.push(Math.round(o.y));
		}
	}

	private static function cleanDir(dir) {
		for (f in FileSystem.readDirectory(dir)) {
			if (!FileSystem.isDirectory(dir + f)) {
				FileSystem.deleteFile(dir + f);
			}
		}
	}
	#end
}

typedef TiledMap = {
	var layers:Array<TiledLayer>;
	var properties:Array<TiledProperty>;
}

typedef TiledLayer = {
	var name:String;
	var objects:Array<TiledObject>;
	var type:String;
}

typedef TiledObject = {
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
}

typedef TiledProperty = {
	var name:String;
	var type:String;
	var value:Bool;
}
