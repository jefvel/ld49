import gamestates.PlayState.ControlScheme;
import hxd.Save;
import elke.Game;

class GameSaveData {
	public var playedIntro = false;
	public var playTime = 0.0;

	public var controlScheme:ControlScheme = KeyboardQWERTY;


	public function new() {
	}

	#if debug
	static inline final hash = false;
	#else
	static inline final hash = true;
	#end

	public function save() {
		Save.save(current, "save", hash);
	}

	public static function load() {
		current = Save.load(new GameSaveData(), "save", hash);
	}

	static var current: GameSaveData;
	public static function reset() {
		current = null;
		return getCurrent();
	}

	public static function getCurrent() {
		if (current == null) {
			load();
		}

		return current;
	}
}