package play;

import math.AABB;

class NextState extends State {
	@:native("n")
	private static var NEXT_TEXT = "Next Stage";

	private var t:String;

	@:native("a")
	private var n:AABB = new AABB(0, 0, 0, 50);

	private var l:Int;

	public function new(l:Int) {
		super();
		this.l = l;
		t = 'Stage $l Complete';
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(0, 0, 1920, 1080);

		Main.context.fillStyle = "#F00";
		Main.context.font = "bold 50px Verdana, sans-serif";
		var w = Main.context.measureText(t).width;
		Main.context.fillText(t, 1920 / 2 - w / 2, 120);

		n.w = Main.context.measureText(NEXT_TEXT).width;
		n.x = 1920 / 2 - n.w / 2;
		n.y = 1080 / 2 - n.h / 2;

		var txt = n.contains(Ctrl.mx, Ctrl.my) ? '-${NEXT_TEXT}-' : NEXT_TEXT;
		var w = Main.context.measureText(txt).width;
		Main.context.fillText(txt, 1920 / 2 - w / 2, n.y + n.h * 0.85);

		if (Ctrl.justReleased && n.contains(Ctrl.mx, Ctrl.my)) {
			var stg = StageBuilder.createStage(4 + l * 2, l + 1);
			Main.setState(new PlayState(stg, stg.resRoom, stg.resPoint));
		}
	}
}
