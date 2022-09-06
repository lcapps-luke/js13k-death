package;

import js.Browser;
import play.PlayState;
import play.StageBuilder;

class MenuState extends AbstractMenuState {
	public function new() {
		super("Death Game");
	}

	override function update(s:Float) {
		super.update(s);

		if (drawOption("Start", 0.5, 1)) {
			var stg = StageBuilder.createStage(4, 1);
			Main.setState(new PlayState(stg, stg.resRoom, stg.resPoint));
		}

		if (drawOption("Full Screen", 0.75, 2)) {
			Browser.document.body.requestFullscreen();
		}
	}
}
