package entities;

import gamestates.PlayState;
import elke.Game;
import elke.T;
import h2d.Bitmap;

class FistSlam extends Attack {
	var attackX = 0.;
	var attackY = -200.;
	var fistBm: Bitmap;
	var fistVisible = false;

	var swoopTime = 0.9;
	var st = 0.;

	public function new(?p) {
		super(p);
		var horse = PlayState.instance.horse;

		attackX = Math.round(Math.random() * 150 - 75 + horse.x);

		var gap = 60;
		attackX =  Math.min(Const.GAP_SIZE - gap, Math.max(gap, attackX));

		var d = new DangerZone(2.0, initiateAttack, 100, 300, false, this);

		d.x = attackX;
		d.y = attackY;

		fistBm = new Bitmap(hxd.Res.img.fist.toTile(), this);
		fistBm.tile.dx = fistBm.tile.dy = -64;
		fistBm.alpha = 0;

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
		fistBm.y = Math.round(attackY + T.elasticOut(st / swoopTime) * 300);

		if (!alreadyHit) {
			var w = 64;
			var h = 64;
			var fx = fistBm.x - 32;
			var fy = fistBm.y - 32;

			if (PlayState.instance.tryHitHorse(fx, fy, w, h)) {
				alreadyHit = true;
			}
		}

		if (st >= swoopTime) {
			remove();
		}
	}

	function initiateAttack(e) {
		fistVisible = true;
		Game.instance.sound.playWobble(hxd.Res.sound.fistswoop);
	}
}