package entities;

import elke.graphics.Sprite;
import h2d.Object;
import gamestates.PlayState;
import elke.Game;
import elke.T;
import h2d.Bitmap;
class Rail extends Object {
	var s : Sprite;
	public function new(?p) {
		super(p);
		s = hxd.Res.img.rail_tilesheet.toSprite2D(this);
		s.originX = 16;
		s.animation.play("zap");
	}
}

class SkyRails extends Attack {
	var attackX = 0.;
	var attackY = -200.;
	var fistBm: Bitmap;
	var fistVisible = false;

	var swoopTime = 0.9;
	var st = 0.;

	var totalRails = 8;
	var timePerSpawn = 0.1;
	var spawnTime = 0.;

	var timeUntilDisappear = 0.1;
	var spawning = true;
	var despawning = false;

	var rails: Array<Rail> = [];
	var dangerZones: Array<DangerZone> = [];

	public function new(?p) {
		super(p);
		attackType = FistSlam;
		
		var horse = PlayState.instance.horse;

		attackX = Math.round(Math.random() * 150 - 75 + horse.x);
		attackY = -226;
	}

	var alreadyHit = false;

	var spawnCount = 0;
	function spawnRail() {
		spawnTime = 0;
		var rGap = 50;
		var g = (Const.GAP_SIZE - rGap * 2) / Math.max(totalRails - 1, 1);
		var sx = rGap + spawnCount * g;

		var d = new DangerZone(200, createRail, 32, 256, false, true, this);
		Game.instance.sound.playWobble(hxd.Res.sound.thunderspawn, 0.2);

		d.x = sx;
		d.y = attackY;

		dangerZones.push(d);

		spawnCount ++;

		if (spawnCount >= totalRails) {
			spawning = false;
		}
	}

	function doCrack() {
		for (d in dangerZones) {
			createRail(d);
			d.remove();
		}

		PlayState.instance.doShake();
		Game.instance.sound.playSfx(hxd.Res.sound.thunderclap, 0.3);
		
		dangerZones = [];
	}

	function createRail(dangerzone) {
		var c = PlayState.instance.attackContainer;
		var r = new Rail(c);
		r.x = dangerzone.x;
		r.y = dangerzone.y;

		rails.push(r);

		if (!alreadyHit) {
			var w = 40;
			var h = 256;
			var fx = r.x - w * 0.5;
			var fy = r.y + 128;

			if (PlayState.instance.tryHitHorse(fx, fy, w, h)) {
				alreadyHit = true;
			}
		}
	}

	override function onRemove() {
		super.onRemove();
		for (r in rails) {
			r.remove();
		}
	}

	var timeUntilCrack = 0.5;

	override function update(dt:Float) {
		super.update(dt);
		if (spawning) {
			spawnTime += dt;
			if (spawnTime > timePerSpawn) {
				spawnRail();
			}
		}

		if (dangerZones.length == totalRails) {
			timeUntilCrack -= dt;
			if (timeUntilCrack <= 0) {
				doCrack();
			}
		}

		if (rails.length == totalRails) {
			timeUntilDisappear -= dt;
		}

		if (timeUntilDisappear <= 0) {
			despawning = true;
		}

		if (despawning) {
			var despawned = false;
			for (r in rails) {
				r.alpha -= 0.1;
				if (r.alpha < 0) {
					despawned = true;
				}
			}

			if (despawned) {
				remove();
			}
		}
	}

	function initiateAttack(e) {
		fistVisible = true;
		Game.instance.sound.playWobble(hxd.Res.sound.fistswoop);
	}
}