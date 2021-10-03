package entities;

import elke.Game;
import elke.graphics.Sprite;

class GodEye extends Enemy {
	var sprite : Sprite;
	public var health = 100.0;
	public var maxHealth = 100.0;

	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.godeye_tilesheet.toSprite2D(this);
		sprite.originX = sprite.originY = 32;
		sprite.animation.play("idle", true, false, Math.random());
		y = -28;
		x = -2;
		alpha = 0;
	}
	var htime = 0.0;

	public var dead = false;

	public function hurt(amount = 4.0) {
		if (dead) {
			return;
		}

		health -= amount;
		if (health <= 0) {
			dead = true;
			vx = Math.random() * 10 - 5;
			vy = -5 - Math.random() * 9;
			vr = (Math.random() - 0.5) * 4;
			Game.instance.sound.playWobble(hxd.Res.sound.eyedead);
		}

		htime = 0.05;
		sprite.color.set(1000, 1000, 1000);
		sprite.animation.play("hurt", false, true, 0, (s) -> {
			if (!dead) {
				sprite.animation.play("idle", true, false, Math.random());
			}
		});
	}

	var vx = .0;
	var vy = .0;
	var vr = .0;

	public override function update(dt:Float) {
		super.update(dt);
		if (htime > 0) {
			htime -= dt; 
			if (htime <= 0) {
				sprite.color.set(1, 1, 1);
			}
		}

		if (alpha < 1) {
			alpha += 0.05;
		}


		if (dead) {
			/*
			x += vx;
			y += vy;
			vy += 0.5;
			rotation += vr;
			if (y > 500){
				remove();
			}
			*/
		}
	}
}