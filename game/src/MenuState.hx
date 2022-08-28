package;

import js.Browser;
import math.AABB;
import play.PlayState;
import play.StageBuilder;

class MenuState extends State {
	private static var TITLE = "Death Game";
	private static inline var OPT_FROM:Float = 1080 / 2;
	private static inline var OPT_GAP:Float = OPT_FROM / 2 - 50;

	@:native("st")
	private static var START_TEXT = "Start";
	@:native("ft")
	private static var FULL_TEXT = "Full Screen";

	@:native("s")
	private var startAABB:AABB = new AABB(0, 0, 0, 50);
	@:native("f")
	private var fullAABB:AABB = new AABB(0, 0, 0, 50);

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#F00";
		Main.context.font = "bold 50px Verdana, sans-serif";
		var w = Main.context.measureText(TITLE).width;
		Main.context.fillText(TITLE, 1920 / 2 - w / 2, 120);

		drawOption(startAABB, START_TEXT, 0);
		drawOption(fullAABB, FULL_TEXT, 1);

		if (Ctrl.justReleased) {
			if (startAABB.contains(Ctrl.mx, Ctrl.my)) {
				var stg = StageBuilder.createStage();
				Main.setState(new PlayState(stg, stg.resRoom, stg.resPoint));
			}

			if (fullAABB.contains(Ctrl.mx, Ctrl.my)) {
				Browser.document.body.requestFullscreen();
			}
		}
	}

	private function drawOption(aabb:AABB, t:String, i:Int) {
		aabb.w = Main.context.measureText(t).width;
		aabb.x = 1920 / 2 - aabb.w / 2;
		aabb.y = OPT_FROM - aabb.h / 2 + OPT_GAP * i;

		var txt = aabb.contains(Ctrl.mx, Ctrl.my) ? '-${t}-' : t;
		var w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, aabb.y + aabb.h * 0.85);
	}
}
