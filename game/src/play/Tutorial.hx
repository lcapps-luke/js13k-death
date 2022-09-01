package play;

class Tutorial {
	private static inline var MOVE = "Move.⌨️: ⬅️,➡️ / A,D.🎮: ⬅️,➡️ / 🕹️";
	private static inline var JUMP = "Jump.⌨️: ⬆️ / W.🎮: ⬆️ / A";
	private static inline var SHOOT = "Shoot.⌨️: X / J.🎮: Trigger / B";
	private static inline var RELOAD = "Reload.⌨️: Z / K / R.🎮: X / Y";

	@:native("t")
	private static var STEP_TEXT = [MOVE, JUMP, SHOOT, RELOAD];

	@:native("e")
	private static var step:Int = 0;

	public static inline function update(p:PlayState) {
		if (step < STEP_TEXT.length) {
			var x:String = STEP_TEXT[step];

			if ((step == 0 && (Ctrl.left || Ctrl.right))
				|| (step == 1 && (Ctrl.jump))
				|| (step == 2 && (Ctrl.shoot))
				|| (step == 3 && (Ctrl.reload))) {
				step++;
			}

			Main.context.strokeStyle = "#000";
			Main.context.fillStyle = "#FFF";
			Main.context.lineWidth = 5;
			Main.context.font = "bold 30px Verdana, sans-serif";

			var ay = p.player.aabb.y - 120;
			for (d in x.split(".")) {
				var w = Main.context.measureText(d).width;
				Main.context.strokeText(d, p.player.aabb.centerX() - w / 2, ay);
				Main.context.fillText(d, p.player.aabb.centerX() - w / 2, ay);
				ay += 50;
			}
		}
	}
}
