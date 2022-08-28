package resource;

import haxe.Resource;
import js.Browser;
import js.html.svg.ImageElement;

class Images {
	@:native("p")
	public static var player:ImageElement;

	@:native("z")
	public static var zombi:ImageElement;

	@:native("q")
	private static var qty = 0;

	@:native("c")
	private static var callback:Void->Void;

	@:native("l")
	public static function load(callback:Void->Void) {
		Images.callback = callback;

		player = loadImage(ResourceBuilder.buildImage("player.svg"));
		zombi = loadImage(ResourceBuilder.buildImage("zombi.svg"));
	}

	@:native("i")
	static function loadImage(str:String) {
		qty++;

		var d = "data:image/svg+xml;base64," + Browser.window.btoa(str);
		var i:ImageElement = cast Browser.window.document.createElement("img");
		i.onload = loadCallback;
		i.onerror = function(e) {
			Browser.console.error(e);
		}
		i.setAttribute("src", d);

		return i;
	}

	@:native("ol")
	private static function loadCallback() {
		qty--;
		if (qty == 0) {
			callback();
		}
	}
}
