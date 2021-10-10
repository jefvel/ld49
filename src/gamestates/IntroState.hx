package gamestates;

import h2d.Bitmap;
import hxd.Key;
import elke.graphics.Transition;
import h2d.Text;
import hxd.Event;
import elke.graphics.Sprite;
import h2d.Object;
import elke.gamestate.GameState;

class IntroState extends GameState {
	public function new() {
	}

	var container : Object;

	var f : Sprite;

	var sounds : Array<hxd.res.Sound>;
	var clickToStartText : Text;

	override function onEvent(e:Event) {
		super.onEvent(e);
		if (container == null) {
			return;
		}

		if (e.kind == EPush) {
			if (!entered) {
				enter();
				return;
			}

			if (exited) {
				return;
			}

			var s = sounds[Std.int(Math.random() * sounds.length)];
			game.sound.playWobble(s, 0.1);

			if (game.s2d.mouseX > game.s2d.width * 0.5) {
				if (f.animation.currentFrame == 8) {
					f.y += 20;
					goToGame();
				} else {
					f.animation.currentFrame ++;
				}
			} else {
				if (f.animation.currentFrame > 0) {
					f.animation.currentFrame --;
				}
			}
		}

		if (e.kind == EKeyDown) {
			if (e.keyCode == Key.ESCAPE) {
				goToGame();
			}
		}
	}

	var music : hxd.snd.Channel;
	override function onEnter() {
		super.onEnter();
		var n = Newgrounds.instance;

		container = new Object(game.s2d);
		game.engine.backgroundColor = 0x000000;

		clickToStartText = new Text(hxd.Res.fonts.futilepro_medium_12.toFont(), container);
		clickToStartText.text = "Click to Start";
		clickToStartText.textAlign = Center;
		clickToStartText.dropShadow = {
			dx: 1, 
			dy: 1,
			alpha: 1.0,
			color: 0x000000,
		};

		clickToStartText.x = Math.round(game.s2d.width * 0.5);
		clickToStartText.y = Math.round(game.s2d.height * 0.45);
	}

	var entered = false;
	function enter() {
		if (entered) {
			return;
		}

		entered = true;

		if (GameSaveData.getCurrent().playedIntro) {
			goToGame(true);
			return;
		}

		music = hxd.Res.sound.intromusic.play(true, 0.2);

		sounds = [
			//hxd.Res.sound.clicks.click1,
			//hxd.Res.sound.clicks.click2,
			hxd.Res.sound.clicks.click3,
			hxd.Res.sound.clicks.click4,
			//hxd.Res.sound.clicks.click5,
			hxd.Res.sound.clicks.click6,
		];

		f = hxd.Res.img.intro_tilesheet.toSprite2D(container);
		f.alpha = 0.0;

		f.x = Math.round((game.s2d.width - 128) * 0.5);
		f.y = Math.round((game.s2d.height - 128) * 0.5 + 5);

		var t = new Text(hxd.Res.fonts.picory.toFont(), f);
		t.y = 130;
		t.x = 2;
		t.textColor = 0xffffff;
		t.alpha = 0.9;
		t.dropShadow = {
			dx: 1, 
			dy: 1,
			alpha: 1.0,
			color: 0x000000,
		};

		t.text = "Esc to skip";

		leftArrow = new Bitmap(hxd.Res.img.smallarrow.toTile(), f);
		leftArrow.scaleX = -1;
		leftArrow.x = -4;

		rightArrow = new Bitmap(hxd.Res.img.smallarrow.toTile(), f);
		rightArrow.x = 128 + 4;
		rightArrow.y = leftArrow.y = 64 - 4;
	}

	var leftArrow: Bitmap;
	var rightArrow: Bitmap;

	var exited = false;
	function goToGame(instant = false) {
		if (exited) {
			return;
		}

		exited = true;

		if (music != null) {
			music.fadeTo(0, 0.4, () -> {
				music.stop();
			});
		}

		if (clickToStartText != null) 
			clickToStartText.remove();

		var inTime = 0.9;
		var outTime = .5;
		if (instant) {
			inTime = 0.4;
			outTime = 0.3;
		}

		hxd.Res.sound.startgame.play(false, 0.2);

		var t = Transition.to(() -> {
			game.states.setState(new PlayState(1));
		}, inTime, outTime);
	}

	override function update(dt:Float) {
		super.update(dt);
		if (clickToStartText != null) {
			clickToStartText.x = Math.round(game.s2d.width * 0.5);
			clickToStartText.y = Math.round(game.s2d.height * 0.45);
		}

		if (f != null) {
			f.x = Math.round((game.s2d.width - 128) * 0.5);
			var dy = Math.round((game.s2d.height - 128) * 0.5) - f.y;
			f.y += dy * 0.3;
			f.alpha += (1 - f.alpha) * 0.2;

			leftArrow.visible = f.animation.currentFrame > 0;
			var m = game.s2d.mouseX;
			if (m > game.s2d.width * 0.5) {
				rightArrow.alpha = 1.0;
				leftArrow.alpha = 0.4;
			} else {
				leftArrow.alpha = 1.0;
				rightArrow.alpha = 0.4;
			}

		}
	}

	override function onLeave() {
		super.onLeave();
		if (container != null) {
			container.remove();
		}

		GameSaveData.getCurrent().playedIntro = true;
		GameSaveData.getCurrent().save();
	}
}