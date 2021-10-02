package entities;

import h2d.Bitmap;
import elke.entity.Entity2D;

class Fist extends Entity2D {
	var b: Bitmap;
	public function new(?p) {
		super(p);
		b = new Bitmap(hxd.Res.img.fist.toTile(), this);
	}
}