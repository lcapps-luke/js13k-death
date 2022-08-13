package play;

class Player extends Mob {
	private static inline var MOVE_SPEED = 300;
	private static inline var JUMP_SPEED = 500;

	@:native("wgt")
	private var wallGrabTimer:Float = 0;

	private var canWallGrab:Bool = false;

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
		if (Ctrl.jump && (onGround || (touchingWall && wallGrabTimer > 0))) {
			ySpeed = -JUMP_SPEED;

			if (!onGround) {
				wallGrabTimer = 0;
			}

			onGround = false;
		}

		if (onGround && !touchingWall) {
			wallGrabTimer = 0.5;
		}

		if (!onGround && touchingWall && ySpeed > 0 && wallGrabTimer > 0) {
			ySpeed = 0;
			gravity = 0;
			wallGrabTimer -= s;
		}

		if (gravity == 0 && !touchingWall) {
			gravity = Mob.GRAVITY;
		}

		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}
