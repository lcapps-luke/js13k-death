package play;

class GameOver extends AbstractMenuState {
	public function new(l:Int) {
		super("Game Over", 'Reached Stage $l');
	}

	override function update(s:Float) {
		super.update(s);

		if (drawOption("Back", 0.75, 1)) {
			Main.setState(new MenuState());
		}
	}
}
