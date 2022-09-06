package;

import math.AABB;

abstract class AbstractMenuState extends State {
	private static inline var OPT_FROM:Float = 1080 / 2;
	private static inline var INPUT_SELECT_DOWN:Int = 1; // 0000,0001
	private static inline var INPUT_SELECT_UP:Int = 2; // 0000,0010
	private static inline var INPUT_NAV_UP_DOWN:Int = 4; // 0000,0100
	private static inline var INPUT_NAV_UP_UP:Int = 8; // 0000,1000
	private static inline var INPUT_NAV_DOWN_DOWN:Int = 16; // 0001,0000
	private static inline var INPUT_NAV_DOWN_UP:Int = 32; // 0010,0000
	private static inline var INPUT_UP:Int = INPUT_SELECT_UP | INPUT_NAV_UP_UP | INPUT_NAV_DOWN_UP;
	private static inline var INPUT_DOWN:Int = INPUT_SELECT_DOWN | INPUT_NAV_UP_DOWN | INPUT_NAV_DOWN_DOWN;

	@:native("t")
	private var title:String;

	@:native("b")
	private var subTitle:String;

	@:native("z")
	private var aabb = new AABB(0, 0, 0, 50);

	@:native("i")
	private var input:Int = 0;

	public function new(title:String, subTitle:String = null) {
		super();
		this.title = title;
		this.subTitle = subTitle;
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#F00";
		Main.context.font = "bold 50px Verdana, sans-serif";
		var w = Main.context.measureText(title).width;
		Main.context.fillText(title, 1920 / 2 - w / 2, 1080 * 0.25 - 50);

		if (subTitle != null) {
			w = Main.context.measureText(subTitle).width;
			Main.context.fillText(subTitle, 1920 / 2 - w / 2, 1080 * 0.5);
		}

		input &= INPUT_DOWN;
		input |= Ctrl.shoot || Ctrl.checkButtons([0, 1, 2, 3], [], null) ? INPUT_SELECT_DOWN : INPUT_SELECT_UP;
	}

	@:native("d")
	private function drawOption(t:String, y:Float, p:Int) {
		aabb.w = Main.context.measureText(t).width;
		aabb.x = 1920 / 2 - aabb.w / 2;
		aabb.y = aabb.h / 2 + 1080 * y - 25;

		var txt = aabb.contains(Ctrl.mx, Ctrl.my) ? '-${t}-' : t;
		var w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, aabb.y + aabb.h * 0.85);

		return (Ctrl.justReleased && aabb.contains(Ctrl.mx, Ctrl.my))
			|| (isSelected(input, INPUT_SELECT_DOWN | INPUT_SELECT_UP) && p == 1);
	}

	private inline function isSelected(input, mask:Int) {
		return input & mask == mask;
	}
}
