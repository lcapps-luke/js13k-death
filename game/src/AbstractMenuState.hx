package;

import math.AABB;

abstract class AbstractMenuState extends State {
	private static inline var OPT_FROM:Float = 1080 / 2;

	@:native("t")
	private var title:String;

	@:native("b")
	private var subTitle:String;

	@:native("o")
	private var optGap:Float;

	@:native("z")
	private var aabb = new AABB(0, 0, 0, 50);

	public function new(title:String, optQty:Int, subTitle:String = null) {
		super();
		this.title = title;
		this.subTitle = subTitle;
		this.optGap = OPT_FROM / (optQty + 1) - 50;
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
	}

	@:native("d")
	private function drawOption(t:String, y:Float) {
		aabb.w = Main.context.measureText(t).width;
		aabb.x = 1920 / 2 - aabb.w / 2;
		aabb.y = aabb.h / 2 + 1080 * y - 25;

		var txt = aabb.contains(Ctrl.mx, Ctrl.my) ? '-${t}-' : t;
		var w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, aabb.y + aabb.h * 0.85);

		return Ctrl.justReleased && aabb.contains(Ctrl.mx, Ctrl.my);
	}
}
