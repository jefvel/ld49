package entities;

import elke.Game;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

class HandEnemy extends Enemy {
	var sprite : Sprite;
	public var health = 46.0;

	var closedTime = 3.0;
	var openTime = 5.0;

	public var open = false;
	var rotSpeed = 2.4;
	var cw = Math.random() > 0.5;

	public function new(mirrored = false, ?p) {
		super(p);
		sprite = hxd.Res.img.handenemy_tilesheet.toSprite2D(this);
		sprite.originX = 70;
		sprite.originY = 100;
		if (mirrored) {
			sprite.scaleX = -1;
		}

		alpha = -Math.random() * 0.5;
		sprite.animation.play("closed", true, false, Math.random());
	}

	var anX = .0;
	var anY = .0;
	public function setAnchorPos(x, y) {
		anX = x;
		anY = y;
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
			Game.instance.sound.playWobble(hxd.Res.sound.handdead, 0.5);
		}

		htime = 0.05;
		sprite.color.set(1000, 1000, 1000);
		sprite.animation.play("hurt", false, true, 0, (s) -> {
			if (!dead) {
				if (open) {
					sprite.animation.play("open", true, false, Math.random());
				} else {
					sprite.animation.play("closed", true, false, Math.random());
				}
			}
		});
	}

	var vx = .0;
	var vy = .0;
	var vr = .0;

	function openHand(){
		tt = 0;
		open = true;
		sprite.animation.play("open");
	}

	function closeHand(){
		tt = 0;
		open = false;
		sprite.animation.play("closed");
	}

	var tt = Math.random() * 2.;
	var el = 0.;
	public override function update(dt:Float) {
		super.update(dt);

		el += dt;
		if (!dead) {
			var t = cw ? 1 : -1;
			x = Math.round(anX + Math.cos(el * rotSpeed * t) * 10);
			y = Math.round(anY + Math.sin(el * rotSpeed * t) * 10);
		}

		if (alpha <= 1.0) {
			alpha += 0.04;
		}

		tt += dt;
		if (!open) {
			if (tt > closedTime) {
				openHand();
			}
		} else {
			if (tt > openTime) {
				closeHand();
			}
		}

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