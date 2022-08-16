package play;

class Player extends Mob {
	private static inline var MOVE_SPEED = 300;
	private static inline var JUMP_SPEED = 500;
	private static inline var RELOAD_TIME = 0.5;
	private static inline var MAX_AMMO = 8;

	@:native("wgt")
	private var wallGrabTimer:Float = 0;

	@:native("cs")
	private var canShoot:Bool = true;

	@:native("fd")
	private var facingDirection:Int = 1;

	@:native("am")
	public var ammo(default, null):Int = MAX_AMMO;

	@:native("rt")
	private var reloadTimer:Float = 0;

	public function new(state:PlayState) {
		super(state, 1920 / 2, 1080 / 2);
	}

	override public function update(s:Float) {
		xSpeed = 0;
		if (Ctrl.right) {
			xSpeed = MOVE_SPEED;
			facingDirection = 1;
		}
		if (Ctrl.left) {
			xSpeed = -MOVE_SPEED;
			facingDirection = -1;
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
			wallGrabTimer -= s;
		}

		super.update(s);

		if (Ctrl.shoot && canShoot && ammo > 0) {
			canShoot = false;
			state.shot.fire(x, y - aabb.h * 0.75, facingDirection);
			ammo--;
			reloadTimer = 0;
		}

		if (!Ctrl.shoot) {
			canShoot = true;
		}

		if (Ctrl.reload && ammo < MAX_AMMO && reloadTimer <= 0) {
			reloadTimer = RELOAD_TIME;
		}

		if (reloadTimer > 0) {
			reloadTimer -= s;
			if (reloadTimer < 0) {
				ammo++;
				if (ammo != MAX_AMMO) {
					reloadTimer = RELOAD_TIME;
				}
			}
		}

		Main.context.fillStyle = "#000";
		Main.context.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}
