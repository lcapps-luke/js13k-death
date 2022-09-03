package play;

class GameOver extends AbstractMenuState {
	public function new(l:Int) {
		super("Game Over", 1, 'Reached Stage $l');
	}

	override function update(s:Float) {
		super.update(s);

		if (drawOption("Back", 0.75)) {
			Main.setState(new MenuState());
		}
	}
}
