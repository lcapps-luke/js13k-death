package play;

import math.AABB;

class NextState extends AbstractMenuState {
	private var l:Int;

	public function new(l:Int) {
		super('Stage $l Complete', 1);
		this.l = l;
	}

	override function update(s:Float) {
		super.update(s);

		if (drawOption("Next Stage", 0.5)) {
			var stg = StageBuilder.createStage(4 + l * 2, l + 1);
			Main.setState(new PlayState(stg, stg.resRoom, stg.resPoint));
		}
	}
}
