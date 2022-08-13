package;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.FocusEvent;

class Main {
	@:native("e")
	private static var canvas:CanvasElement;
	public static var c:CanvasRenderingContext2D;

	@:native("l")
	public static var lastFrame:Float = 0;

	@:native("f")
	public static var focusReset:Bool = false;

	private static var playing:Bool = false;

	public static function main() {
		canvas = cast Browser.window.document.getElementById("c");
		c = canvas.getContext2d();

		Browser.window.document.body.onresize = onResize;
		onResize();

		Browser.window.onfocus = function(e:FocusEvent) {
			focusReset = true;
		};

		Browser.window.requestAnimationFrame(update);
	}

	public static function onResize() {
		var l = Math.floor((Browser.window.document.body.clientWidth - canvas.clientWidth) / 2);
		var t = Math.floor((Browser.window.document.body.clientHeight - canvas.clientHeight) / 2);
		canvas.style.left = '${l}px';
		canvas.style.top = '${t}px';
	}

	public static function update(s:Float) {
		if (focusReset) {
			lastFrame = s - 1;
			focusReset = false;
		}

		// Update & Render

		lastFrame = s;
		Browser.window.requestAnimationFrame(update);
	}
}
