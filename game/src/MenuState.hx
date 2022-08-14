package;

import math.AABB;
import play.PlayState;

class MenuState extends State {
	private static var TITLE = "Death Game";

	@:native("s")
	private var startAABB:AABB = new AABB(0, 0, 0, 50);

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#F00";
		Main.context.font = "bold 50px Verdana, sans-serif";
		var w = Main.context.measureText(TITLE).width;
		Main.context.fillText(TITLE, 1920 / 2 - w / 2, 120);

		startAABB.w = Main.context.measureText("Start").width;
		startAABB.x = 1920 / 2 - startAABB.w / 2;
		startAABB.y = 1080 / 2 - startAABB.h / 2;
		var txt = startAABB.contains(Ctrl.mx, Ctrl.my) ? "-Start-" : "Start";
		w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, startAABB.y + startAABB.h);

		if (Ctrl.justReleased && startAABB.contains(Ctrl.mx, Ctrl.my)) {
			Main.setState(new PlayState());
		}
	}
}
