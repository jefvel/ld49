package entities;

import elke.graphics.Sprite;
import elke.entity.Entity2D;

class Eye extends Entity2D {
	var sprite : Sprite;
	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.eye_tilesheet.toSprite2D(this);
		sprite.originX = sprite.originY = 16;
		sprite.animation.play("idle", true, false, Math.random());
	}
}