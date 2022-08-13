package play;

class Player extends Mob {
	private static inline var MOVE_SPEED = 300;
	private static inline var JUMP_SPEED = 500;

	public function new(state:PlayState) {
		super(state, 1920 / 2, 1080 / 2);
	}

	override public function update(s:Float) {
		xSpeed = 0;
		if (Ctrl.right) {
			xSpeed = MOVE_SPEED;
		}
		if (Ctrl.left) {
			xSpeed = -MOVE_SPEED;
		}
		if (Ctrl.jump && onGround) {
			ySpeed = -JUMP_SPEED;
			onGround = false;
		}

		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}
