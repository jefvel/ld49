package entities;

import gamestates.PlayState;
import elke.Game;
import elke.graphics.Sprite;

class Skeleton extends Enemy {
	public var sprite : Sprite;
	public static final MAX_HEALTH = 30.;
	public var health = MAX_HEALTH;

	var bar : HpBar;

	public function new(?p) {
		super(p);
		sprite = hxd.Res.img.skelgeon_tilesheet.toSprite2D(this);
		sprite.originX = sprite.originY = 24;
		sprite.animation.play("idle", true, false, Math.random());

		bar = new HpBar(this);
		bar.maxHp = health;
		bar.y = 40;
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
			vr = (Math.random() - 0.5) * 1;
			Game.instance.sound.playWobble(hxd.Res.sound.eyedead);
		}

		bar.hp = health;

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