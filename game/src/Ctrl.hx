package;

import js.Browser;
import js.html.CanvasElement;
import js.html.Gamepad;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import js.html.Touch;
import js.html.TouchEvent;
import js.html.Window;
import math.AABB;
import math.Vec2;

class Ctrl {
	private static inline var BUTTON_SIZE:Int = 128;
	private static inline var BUTTON_GAP:Int = 64;
	private static inline var ON_SCREEN_LEFT = 0;
	private static inline var ON_SCREEN_RIGHT = 1;
	private static inline var ON_SCREEN_JUMP = 2;
	private static inline var ON_SCREEN_SHOOT = 3;
	private static inline var ON_SCREEN_RELOAD = 4;

	private static var keys:Map<String, Bool>;
	private static var c:CanvasElement;

	public static var mx(default, null):Float = 0;
	public static var my(default, null):Float = 0;
	private static var mTouch:Int = -1;
	@:native("jr")
	public static var justReleased(default, null):Bool = false;

	@:native("l")
	public static var left(default, null):Bool = false;
	@:native("r")
	public static var right(default, null):Bool = false;
	@:native("j")
	public static var jump(default, null):Bool = false;
	@:native("s")
	public static var shoot(default, null):Bool = false;
	@:native("e")
	public static var reload(default, null):Bool = false;

	@:native("g")
	private static var gamepad:Gamepad = null;

	@:native("osb")
	private static var onScreenButtons:Array<OnScreenButton>;

	@:native("tl")
	private static var touchList = new Map<Int, Vec2>();
	@:native("ut")
	private static var usingTouchscreen:Bool = false;

	public static function init(w:Window, c:CanvasElement) {
		Ctrl.keys = new Map<String, Bool>();
		Ctrl.c = c;

		w.onkeydown = onKeyDown;
		w.onkeyup = onKeyUp;
		c.onmousemove = onMouseMove;
		w.onmouseup = onMouseUp;

		w.ontouchstart = onTouchStart;
		w.ontouchmove = onTouchMove;
		w.ontouchend = onTouchEnd;
		w.ontouchcancel = onTouchEnd;

		if (Browser.navigator.getGamepads != null) {
			var ng = Browser.navigator.getGamepads();
			if (ng.length > 0) {
				gamepad = ng[0];
			}
		}

		w.addEventListener("gamepadconnected", e -> {
			if (gamepad == null) {
				gamepad = e.gamepad;
			}
		});

		onScreenButtons = [
			{
				z: new AABB(BUTTON_GAP, 1080 - BUTTON_SIZE - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
				n: "Left",
				p: 0
			},
			{
				z: new AABB(BUTTON_SIZE + BUTTON_GAP * 2, 1080 - BUTTON_SIZE - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
				n: "Right",
				p: 0
			},
			{
				z: new AABB(1920 - BUTTON_SIZE - BUTTON_GAP, 1080 - BUTTON_SIZE * 2 - BUTTON_GAP * 2, BUTTON_SIZE, BUTTON_SIZE),
				n: "Jump",
				p: 0
			},
			{
				z: new AABB(1920 - BUTTON_SIZE - BUTTON_GAP, 1080 - BUTTON_SIZE - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
				n: "Shoot",
				p: 0
			},
			{
				z: new AABB(1920 - BUTTON_SIZE * 2 - BUTTON_GAP * 2, 1080 - BUTTON_SIZE - BUTTON_GAP, BUTTON_SIZE, BUTTON_SIZE),
				n: "Reload",
				p: 0
			}
		];
	}

	@:native("okd")
	private static function onKeyDown(e:KeyboardEvent) {
		keys.set(e.code, true);
	}

	@:native("oku")
	private static function onKeyUp(e:KeyboardEvent) {
		keys.set(e.code, false);
	}

	@:native("omm")
	private static function onMouseMove(e:MouseEvent) {
		mx = (e.offsetX / c.clientWidth) * c.width;
		my = (e.offsetY / c.clientHeight) * c.height;
	}

	@:native("omu")
	private static function onMouseUp(e:MouseEvent) {
		justReleased = true;
	}

	@:native("ots")
	private static function onTouchStart(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			var x = tpx(t);
			var y = tpy(t);

			if (mTouch < 0) {
				mTouch = t.identifier;
				mx = x;
				my = y;
			}

			touchList[t.identifier] = new Vec2(x, y);
		}

		usingTouchscreen = true;
	}

	@:native("otm")
	private static function onTouchMove(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			var x = tpx(t);
			var y = tpy(t);

			if (mTouch == t.identifier) {
				mx = x;
				my = y;
			}

			touchList[t.identifier].set(tpx(t), tpy(t));
		}
	}

	private static function tpx(t:Touch):Float {
		return ((t.clientX - c.offsetLeft) / c.clientWidth) * c.width;
	}

	private static function tpy(t:Touch):Float {
		return ((t.clientY - c.offsetTop) / c.clientHeight) * c.height;
	}

	@:native("ote")
	private static function onTouchEnd(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			if (t.identifier == mTouch) {
				justReleased = true;
				mTouch = -1;
			}

			touchList.remove(t.identifier);
		}
	}

	@:native("u")
	public static function update() {
		left = checkKeys(["ArrowLeft", "KeyA"]) || checkButtons([14], [0, 2], f -> f < -0.3) || checkOnScreenButton(ON_SCREEN_LEFT);
		right = checkKeys(["ArrowRight", "KeyD"]) || checkButtons([15], [0, 2], f -> f > 0.3) || checkOnScreenButton(ON_SCREEN_RIGHT);
		jump = checkKeys(["ArrowUp", "KeyW"]) || checkButtons([12, 0], []) || checkOnScreenButton(ON_SCREEN_JUMP);
		shoot = checkKeys(["KeyX", "KeyJ"]) || checkButtons([1, 5, 4, 6, 7], []) || checkOnScreenButton(ON_SCREEN_SHOOT);
		reload = checkKeys(["KeyZ", "KeyK", "KeyR"]) || checkButtons([2, 3], []) || checkOnScreenButton(ON_SCREEN_RELOAD);
	}

	@:native("ck")
	private static function checkKeys(kk:Array<String>) {
		for (k in kk) {
			if (keys.get(k)) {
				return true;
			}
		}
		return false;
	}

	@:native("cb")
	private static function checkButtons(b:Array<Int>, a:Array<Int>, c:Float->Bool = null) {
		if (gamepad != null) {
			for (i in b) {
				if (gamepad.buttons[i].pressed) {
					return true;
				}
			}

			for (i in a) {
				if (c(gamepad.axes[i])) {
					return true;
				}
			}
		}

		return false;
	}

	@:native("cosb")
	private static function checkOnScreenButton(id:Int):Bool {
		var b = onScreenButtons[id];

		for (i in touchList.iterator()) {
			if (b.z.contains(i.x, i.y)) {
				return true;
			}
		}

		return false;
	}

	@:native("re")
	public static function reset() {
		justReleased = false;
	}

	@:native("d")
	public static function draw() {
		if (usingTouchscreen) {
			Main.context.font = "bold 35px Verdana, sans-serif";

			for (b in onScreenButtons) {
				Main.context.fillStyle = "#00F8";
				Main.context.fillRect(b.z.x, b.z.y, b.z.w, b.z.h);

				Main.context.fillStyle = "#FFF8";
				var w = Main.context.measureText(b.n).width;
				Main.context.fillText(b.n, b.z.centerX() - w / 2, b.z.centerY() + 35 * 0.25);
			}
		}
	}
}

typedef OnScreenButton = {
	var z:AABB;
	var n:String;
	var p:Int;
}
