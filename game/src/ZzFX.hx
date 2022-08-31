package;

import js.html.audio.AudioBufferSourceNode;

@:native("")
extern class ZzFX {
	public static function zzfx(volume:Float = 1, randomness:Float = .05, frequency:Float = 220, attack:Float = 0, sustain:Float = 0, release:Float = .1,
		shape:Float = 0, shapeCurve:Float = 1, slide:Float = 0, deltaSlide:Float = 0, pitchJump:Float = 0, pitchJumpTime:Float = 0, repeatTime:Float = 0,
		noise:Float = 0, modulation:Float = 0, bitCrush:Float = 0, delay:Float = 0, sustainVolume:Float = 1, decay:Float = 0,
		tremolo:Float = 0):AudioBufferSourceNode;
}
