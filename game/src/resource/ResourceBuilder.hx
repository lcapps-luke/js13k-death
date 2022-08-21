package resource;

#if macro
import haxe.Json;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
#end

class ResourceBuilder {
	macro public static function buildLevelDefinitions():ExprOf<Array<Array<Int>>> {
		var res = new Array<Array<Float>>();

		var path = "res/level/";
		for (f in FileSystem.readDirectory(path)) {
			res.push(buildLevel(path + f));
		}

		return Context.makeExpr(res, Context.currentPos());
	}

	#if macro
	private static function buildLevel(path) {
		var json:TiledMap = cast Json.parse(File.getContent(path));

		var walls = new Array<Dynamic>();
		var players = new Array<Dynamic>();
		var enemies = new Array<Dynamic>();

		for (l in json.layers) {
			if (l.type != "objectgroup") {
				continue;
			}

			if (l.name == "wall") {
				for (o in l.objects) {
					walls.push(o);
				}
			}

			if (l.name == "player") {
				for (o in l.objects) {
					players.push(o);
				}
			}

			if (l.name == "enemy") {
				for (o in l.objects) {
					enemies.push(o);
				}
			}
		}

		var level = new Array<Float>();
		level.push(walls.length);
		for (w in walls) {
			level.push(w.x);
			level.push(w.y);
			level.push(w.width);
			level.push(w.height);
		}

		level.push(players.length);
		for (p in players) {
			level.push(p.x);
			level.push(p.y);
		}

		level.push(enemies.length);
		for (e in enemies) {
			level.push(e.x);
			level.push(e.y);
		}

		return level;
	}
	#end
}

typedef TiledMap = {
	var layers:Array<TiledLayer>;
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
