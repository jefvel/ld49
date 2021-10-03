package gamestates;

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

	override function onEvent(e:Event) {
		super.onEvent(e);
		if (e.kind == EPush) {
			if (e.button == 0) {
				if (f.animation.currentFrame == 8) {
					goToGame();
				} else {
					f.animation.currentFrame ++;
				}
			} else if (e.button == 1) {
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

	override function onEnter() {
		super.onEnter();
		container = new Object(game.s2d);
		f = hxd.Res.img.intro_tilesheet.toSprite2D(container);
		f.x = Math.round((game.s2d.width - 128) * 0.5);
		f.y = Math.round((game.s2d.height - 128) * 0.5);
		var t = new Text(hxd.Res.fonts.picory.toFont(), f);
		t.y = 130;
		t.textColor = 0xffffff;
		t.alpha = 0.9;
		t.dropShadow = {
			dx: 1, 
			dy: 1,
			alpha: 1.0,
			color: 0x000000,
		};

		t.text = "Click to continue.\nEsc to skip.";
	}

	var exited = false;
	function goToGame() {
		exited = true;
		Transition.to(() -> {
			game.states.setState(new PlayState(1));
		});
	}

	override function update(dt:Float) {
		super.update(dt);

		f.x = Math.round((game.s2d.width - 128) * 0.5);
		f.y = Math.round((game.s2d.height - 128) * 0.5);
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}