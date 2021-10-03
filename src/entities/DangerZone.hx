package entities;

import elke.Game;
import h2d.Tile;
import elke.T;
import h2d.Bitmap;
import elke.entity.Entity2D;

class DangerZone extends Entity2D {
	var onDone: DangerZone -> Void;
	var delay = 1.0;

	var bm : Bitmap;

	public function new(delay: Float = 2.0, onDone: DangerZone -> Void, width = 100., height = 100., horizontal = false, ?p) {
		super(p);
		this.delay = delay;
		this.onDone = onDone;

		bm = new Bitmap(Tile.fromColor(0xbf6767, 1, 1, 0.6), this);
		bm.tile.scaleToSize(width, height);

		if (horizontal) {
			bm.y = -Math.round(height * 0.5);
		} else {
			bm.x = -Math.round(width * 0.5);
		}

		alpha = 0.;
	}

	override function onAdd() {
		super.onAdd();
		Game.instance.sound.playSfx(hxd.Res.sound.dangerzone, 0.3);
	}

	override function update(dt:Float) {
		if (alpha < 1) {
			alpha += (dt * (1 / 0.2));
			alpha = Math.min(1, alpha);
		}

		delay -= dt;
		if (delay < 0) {
			onDone(this);
			remove();
		}
	}
}