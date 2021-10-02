package entities;

import h2d.Bitmap;
import elke.entity.Entity2D;

class DroppedItem extends Entity2D {
	var bm: Bitmap;
	var vx = 0.;
	var vy = 0.;
	var rs = 0.;
	public function new(tile, ?p) {
		super(p);
		bm = new Bitmap(tile, this);
		bm.x = -tile.width * 0.5;
		bm.y = -tile.height * 0.5;
		vx = Math.random() * 10 - 5;
		vy = -(Math.random() * 4 + 2);
		rs = (Math.random() * 0.2 - 0.1) * 5;
	}

	override function update(dt:Float) {
		super.update(dt);
		x += vx;
		y += vy;
		rotation += rs;
		vx *= 0.92;
		rs *= 0.99;
		vy += 0.4;
		if (y > 700) {
			remove();
		}
	}
}