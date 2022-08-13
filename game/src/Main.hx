package;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.FocusEvent;

class Main {
	@:native("e")
	private static var canvas:CanvasElement;

	@:native("c")
	public static var context:CanvasRenderingContext2D;

	@:native("l")
	public static var lastFrame:Float = 0;

	@:native("f")
	public static var focusReset:Bool = false;

	private static var playing:Bool = false;

	private static var state:State = null;

	public static function main() {
		canvas = cast Browser.window.document.getElementById("c");
		context = canvas.getContext2d();

		Browser.window.document.body.onresize = onResize;
		onResize();

		Browser.window.onfocus = function(e:FocusEvent) {
			focusReset = true;
		};

		Ctrl.init(Browser.window, canvas);

		state = new MenuState();

		Browser.window.requestAnimationFrame(update);
	}

	private static function onResize() {
		var l = Math.floor((Browser.window.document.body.clientWidth - canvas.clientWidth) / 2);
		var t = Math.floor((Browser.window.document.body.clientHeight - canvas.clientHeight) / 2);
		canvas.style.left = '${l}px';
		canvas.style.top = '${t}px';
	}

	private static function update(s:Float) {
		if (focusReset) {
			lastFrame = s - 1;
			focusReset = false;
		}

		if (state != null) {
			state.update(s);
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
