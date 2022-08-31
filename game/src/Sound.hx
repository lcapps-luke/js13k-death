package;

class Sound {
	@:native("s")
	public static function shoot() {
		ZzFX.zzfx(1.38, .05, 70, .02, .06, .07, 4, .35, -1.6, 0, 0, 0, 0, 1.3, -2.8, .3, .08, .94, .07, .13);
	}

	@:native("r")
	public static function reload() {
		ZzFX.zzfx(2.02, .5, 160, 0, .02, 0, 2, .7, 20, 0, -50, 0, 0, 0, 0, 0, .01, .2, .02, .11);
	}

	@:native("z")
	public static function zombiHit() {
		ZzFX.zzfx(1, .05, 289, 0, 0, .16, 1, 2.8, 0, -3, 0, 0, 0, 2, 0, 0, 0, .88, .07, .19);
	}

	@:native("p")
	public static function playerHit() {
		ZzFX.zzfx(1, .05, 167, .01, .03, .12, 3, 1.53, 0, -6.9, 0, 0, 0, 1.7, 0, .2, 0, .54, .04, 0);
	}

	@:native("t")
	public static function step() {
		ZzFX.zzfx(1, .1, 123.4708, 0, .01, .01, 1, .3, 0, 0, 0, 0, .02, 0, -80, 0, .37, .2, 0, 0);
	}

	@:native("e")
	public static function stageEnd() {
		ZzFX.zzfx(1, .1, 461, .07, .3, .3, 0, 1.2, 0, .1, 107, .2, .1, .1, 0, -0.1, 0, .5, .2, .5);
	}

	@:native("d")
	public static function recoverSpawn() {
		ZzFX.zzfx(2, .05, 461, 0, 0, .2, 0, .7, 0, 3, 481, .05, 0, 0, 0, 0, .02, .5, 0, 0);
	}
}
