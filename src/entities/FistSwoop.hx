package entities;

import h2d.Tile;
import gamestates.PlayState;
import elke.Game;
import elke.T;
import h2d.Bitmap;

class FistSwoop extends Attack {
	var gap = 60.;
	var attackX = 0.;
	var attackY = -200.;
	var fistBm: Bitmap;
	var fistVisible = false;

	var swoopTime = 1.3;
	var st = 0.;
	var fromLeft = false;

	public function new(?p) {
		super(p);
		attackType = FistSwoosh;
		var horse = PlayState.instance.horse;

		fromLeft = Math.random() > 0.5;

		attackX = Math.round(Math.random() * 150 - 75 + horse.x);
		attackX = Math.min(Const.GAP_SIZE - gap, Math.max(gap, attackX));
		var attackWidth = Const.GAP_SIZE - gap * 2;
		var attackHeight = 128;

		attackX = gap;
		attackY = 0;

		var d = new DangerZone(2.5, initiateAttack, attackWidth, attackHeight, true, false, fromLeft, this);

		d.x = attackX;
		d.y = attackY;

		fistBm = new Bitmap(hxd.Res.img.fist.toTile(), this);
		fistBm.tile.dx = fistBm.tile.dy = -64;
		fistBm.alpha = 0;

		if (!fromLeft) {
			fistBm.scaleX = -1;
		}

		fistBm.y = attackY;
		fistBm.x = attackX;
	}

	var alreadyHit = false;

	override function update(dt:Float) {
		super.update(dt);
		if (!fistVisible) {
			return;
		}

		st += dt;

		fistBm.alpha += 0.33;
		fistBm.alpha = Math.min(1, fistBm.alpha);
		var g = gap + 50;
		var dx = Const.GAP_SIZE - g * 2;
		var tx = g + dx;
		if (!fromLeft) {
			fistBm.x = Math.round(g + T.bounceOut(st / swoopTime) * dx);
		} else {
			tx = Const.GAP_SIZE - g - dx;
			fistBm.x = Math.round(Const.GAP_SIZE - g - T.bounceOut(st / swoopTime) * dx);
		}

		if (!alreadyHit) {
			var w = 70;
			var h = 64;
			var fx = fistBm.x - w * 0.5;
			var fy = fistBm.y - 32;

			if (PlayState.instance.tryHitHorse(fx, fy, w, h)) {
				alreadyHit = true;
			}
		}

		if (Math.abs(fistBm.x - tx) < 20) {
			alreadyHit = true;
		}

		if (st >= swoopTime) {
			remove();
		}
	}

	function initiateAttack(e) {
		fistVisible = true;
		Game.instance.sound.playWobble(hxd.Res.sound.fistswoophorizontal);
	}
}