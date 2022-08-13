package;

abstract class State {
	public function new() {}

	@:native("u")
	public function update(s:Float) {}
}
