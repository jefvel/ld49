package entities;

import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;
import elke.entity.Entity2D;

class SwordCondition extends Entity2D {
	public var condition = 0.0;

	var swordBg : Bitmap;
	var swordVisible : Bitmap;
	var o : Bitmap;
	var swordTile: Tile;
	public function new(?p) {
		super(p);
		var tile = hxd.Res.img.sword.toTile();
		swordTile = tile;
		swordBg = new Bitmap(tile, this);
		swordBg.alpha = 0.1;
		o = new Bitmap(Tile.fromColor(0xffffff), this);
		o.width = tile.width;
		o.height = tile.height;
		swordVisible = new Bitmap(tile, this);
		swordVisible.filter = new h2d.filter.Mask(o);
	}

	override function update(dt:Float) {
		super.update(dt);
		o.height = Math.round(swordTile.height * (condition / 1.0));
		o.y = swordTile.height - o.height;
	}
}