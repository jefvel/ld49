package entities;

import gamestates.PlayState;
import elke.Game;
import elke.graphics.Sprite;

class Eye extends Enemy {
	var sprite : Sprite;
	public static final MAX_HEALTH = 15.;
	public var health = MAX_HEALTH;
	var bar : HpBar;

	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.eye_tilesheet.toSprite2D(this);
		sprite.originX = sprite.originY = 16;
		sprite.animation.play("idle", true, false, Math.random());

		bar = new HpBar(this);
		bar.maxHp = health;

		bar.y = 20;
	}

	var htime = 0.0;

	public var dead = false;

	public function hurt(amount = 4.0) {
		if (dead) {
			return;
		}

		var am = Math.min(amount, health);
		PlayState.instance.doDamage(am);

		health -= am;
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

		bar.hp = health;
	}

	var vx = .0;
	var vy = .0;
	var vr = .0;
	var tt = Math.random() * 3.1;

	public override function update(dt:Float) {
		super.update(dt);

		tt += dt;
		var ox = Math.cos(tt) * 4;
		var oy = Math.sin(tt) * 4;
		sprite.x = Math.round(ox);
		sprite.y = Math.round(oy);


		if (htime > 0) {
			htime -= dt; 
			if (htime <= 0) {
				sprite.color.set(1, 1, 1);
			}
		}

		if (dead) {
			x += vx;
			y += vy;
			vy += 0.5;
			rotation += vr;
			if (y > 500){
				remove();
			}
		}
	}
}