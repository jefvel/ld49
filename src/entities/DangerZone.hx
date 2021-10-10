package entities;

import elke.graphics.Sprite;
import gamestates.PlayState;
import h2d.col.Point;
import elke.Game;
import h2d.Tile;
import elke.T;
import h2d.Bitmap;
import elke.entity.Entity2D;

class DangerZone extends Entity2D {
	var onDone: DangerZone -> Void;
	var delay = 1.0;

	var bm : Bitmap;

	static var t: Tile;
	static var arrowTile: Tile;

	var silent = false;
	var arrow: Sprite;
	var horizontal = false;
	var fromLeft = false;

	public function new(delay: Float = 2.0, onDone: DangerZone -> Void, width = 100., height = 100., horizontal = false, silent = false, leftToRight = false, ?p) {
		super(p);
		this.delay = delay;
		this.onDone = onDone;
		this.silent = silent;

		this.fromLeft = leftToRight;

		this.horizontal = horizontal;

		if (t == null) {
			t = Tile.fromColor(0xbf6767, 1, 1, 0.6);
		}

		bm = new Bitmap(t, this);
		bm.width = width;
		bm.height = height;

		arrow = hxd.Res.img.dangerarrow_tilesheet.toSprite2D();
		arrow.originX = 16;
		arrow.originY = 32;
		arrow.visible = false;
		if (!horizontal) {
			arrow.animation.currentFrame = 0;
		} else {
			if (!leftToRight) {
				arrow.animation.currentFrame = 1;
			} else {
				arrow.animation.currentFrame = 2;
			}
		}

		if (horizontal) {
			bm.y = -Math.round(height * 0.5);
		} else {
			bm.x = -Math.round(width * 0.5);
		}

		alpha = 0.;

		/*
		var s = new elke.graphics.SineDeformShader();

		s.speed = 1;
		s.amplitude = .1;
		s.frequency = .5;
		s.texture = bmp.tile.getTexture();

		bm.addShader(s);
		*/
		if (!this.silent) {
			Game.instance.sound.playSfx(hxd.Res.sound.dangerzone, 0.3);
		}
	}

	override function onRemove() {
		super.onRemove();
		arrow.remove();
	}

	override function update(dt:Float) {
		if (alpha < 1) {
			alpha += (dt * (1 / 0.2));
			alpha = Math.min(1, alpha);
		}

		var s = getScene();
		var p = localToGlobal();
		s.camera.cameraToScene(p);

		if (p.y > s.height) {
			arrow.visible = true;
			s.addChild(arrow);
			var h = PlayState.instance.horse;
			var dx = p.x;
			if (horizontal) {
				dx = Math.round(s.width * 0.5);
			}

			arrow.x = dx; //s.width * 0.5;
			arrow.y = s.height - 8;
		} else {
			arrow.remove();
		}

		delay -= dt;
		if (delay < 0) {
			onDone(this);
			remove();
		}
	}
}