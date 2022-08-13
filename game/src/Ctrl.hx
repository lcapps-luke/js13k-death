package;

import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.Window;

class Ctrl {
	private static var keys:Map<String, Bool>;
	private static var c:CanvasElement;

	public static var mx(default, null):Float = 0;
	public static var my(default, null):Float = 0;
	private static var mTouch:Int = -1;
	public static var justReleased(default, null):Bool = false;

	public static function init(w:Window, c:CanvasElement) {
		Ctrl.keys = new Map<String, Bool>();
		Ctrl.c = c;

		w.onkeydown = onKeyDown;
		w.onkeyup = onKeyUp;
		c.onmousemove = onMouseMove;
		w.onmouseup = onMouseUp;

		w.ontouchmove = onTouchMove;
		w.ontouchend = onTouchEnd;
		w.ontouchcancel = onTouchEnd;
	}

	private static function onKeyDown(e:KeyboardEvent) {
		keys.set(e.code, true);
		updateKeys();
	}

	private static function onKeyUp(e:KeyboardEvent) {
		keys.set(e.code, false);
		updateKeys();
	}

	private static function onMouseMove(e:MouseEvent) {
		mx = (e.offsetX / c.clientWidth) * c.width;
		my = (e.offsetY / c.clientHeight) * c.height;
	}

	private static function onMouseUp(e:MouseEvent) {
		justReleased = true;
	}

	private static function onTouchMove(e:TouchEvent) {
		for (t in e.changedTouches) {
			mx = ((t.clientX - c.offsetLeft) / c.clientWidth) * c.width;
			my = ((t.clientY - c.offsetTop) / c.clientHeight) * c.height;

			if (mTouch < 0) {
				mTouch = t.identifier;
			}
		}
	}

	private static function onTouchEnd(e:TouchEvent) {
		for (t in e.changedTouches) {
			if (t.identifier == mTouch) {
				justReleased = true;
				mTouch = -1;
			}
		}
	}

	private static function updateKeys() {}

	public static function reset() {
		justReleased = false;
	}
}
