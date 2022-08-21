package math;

class Rand {
	public static inline function chooseItem<T>(array:Array<T>):T {
		return array[Math.floor(Math.random() * array.length)];
	}
}
