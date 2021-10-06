package entities;

import h2d.Tile;
import h2d.Bitmap;
import elke.entity.Entity2D;

class BulletList extends Entity2D {
	var bulletSprites: Array<{ b: Bitmap, y: Float}> = [];
	var bTile: Tile;
	var tSpacing = 12;

	public var bullets(default, set) = 0;

	public function new(?p) {
		super(p);
		bTile = hxd.Res.img.bullet.toTile();
		bTile.dy = -5;
	}

	override function update(dt:Float) {
		super.update(dt);
		var i = 0;
		var multiplier = 1.0;
		for (b in bulletSprites) {
			var bv = (5 + i * tSpacing - b.y) * (0.8 * multiplier);
			b.y += bv;
			b.b.rotation = -bv * 0.03;
			b.b.y = Math.round(b.y);
			i ++;

			multiplier *= 0.9;
		}
	}

	function set_bullets(b: Int) {
		b = Std.int(Math.max(0, Math.min(14, b)));
		if (bulletSprites.length > b) {
			while(bulletSprites.length > b) {
				var b = bulletSprites.shift();
				b.b.remove();
			}
		} else if (bulletSprites.length < b) {
			while(bulletSprites.length < b) {
				var bm = new Bitmap(bTile, this);
				bulletSprites.push({
					b: bm,
					y: bulletSprites.length * tSpacing + 5,
				});
			}
		}

		return this.bullets = b;
	}
}