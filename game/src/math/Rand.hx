package math;

class Rand {
	@:native("a")
	public static function chooseItem<T>(array:Array<T>, reroll:T->Bool = null):T {
		var i = array[Math.floor(Math.random() * array.length)];
		return reroll != null && reroll(i) ? chooseItem(array, reroll) : i;
	}
}
