package;

import gamestates.IntroState;
import elke.Game;
import gamestates.PlayState;

class Main {
	static var game:Game;

	static function main() {
		game = new Game({
			initialState: new IntroState(),
			onInit: () -> {},
			tickRate: Const.TICK_RATE,
			pixelSize: Const.PIXEL_SIZE,
			backgroundColor: 0x312c3b,
		});
	}
}
