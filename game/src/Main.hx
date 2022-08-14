package;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;

class Main {
	private static inline var MAX_DELTA = 1000 / 12;

	@:native("e")
	private static var canvas:CanvasElement;

	@:native("c")
	public static var context:CanvasRenderingContext2D;

	@:native("l")
	public static var lastFrame:Float = 0;

	private static var state:State = null;

	public static function main() {
		canvas = cast Browser.window.document.getElementById("c");
		context = canvas.getContext2d();

		Browser.window.document.body.onresize = onResize;
		onResize();

		Ctrl.init(Browser.window, canvas);

		state = new MenuState();

		Browser.window.requestAnimationFrame(update);
	}

	@:native("r")
	private static function onResize() {
		var l = Math.floor((Browser.window.document.body.clientWidth - canvas.clientWidth) / 2);
		var t = Math.floor((Browser.window.document.body.clientHeight - canvas.clientHeight) / 2);
		canvas.style.left = '${l}px';
		canvas.style.top = '${t}px';
	}

	@:native("u")
	private static function update(s:Float) {
		var d = Math.min(MAX_DELTA, s - lastFrame);

		if (state != null) {
			state.update(d / 1000);
		}

		Ctrl.reset();

		lastFrame = s;
		Browser.window.requestAnimationFrame(update);
	}

	@:native("s")
	public static function setState(s:State) {
		state = s;
	}
}
