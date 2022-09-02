package play;

import math.AABB;

class GameOver extends State {
	@:native("i")
	private static var TITLE = "Game Over";

	@:native("n")
	private static var BACK = "Back";

	private var t:String;

	@:native("a")
	private var n:AABB = new AABB(0, 0, 0, 50);

	public function new(l:Int) {
		super();
		t = 'Reached Stage $l';
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#F00";
		Main.context.font = "bold 50px Verdana, sans-serif";
		var w = Main.context.measureText(TITLE).width;
		Main.context.fillText(TITLE, 1920 / 2 - w / 2, 120);

		w = Main.context.measureText(t).width;
		Main.context.fillText(t, 1920 / 2 - w / 2, 1080 * 0.5);

		n.w = Main.context.measureText(BACK).width;
		n.x = 1920 / 2 - n.w / 2;
		n.y = 1080 * 0.75 - n.h / 2;

		var txt = n.contains(Ctrl.mx, Ctrl.my) ? '-${BACK}-' : BACK;
		var w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, n.y + n.h * 0.75);

		if (Ctrl.justReleased && n.contains(Ctrl.mx, Ctrl.my)) {
			Main.setState(new MenuState());
		}
	}
}
