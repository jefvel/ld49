package entities;

import elke.gamestate.GameState;
import gamestates.PlayState;
import elke.Game;
import elke.process.Timeout;
import h2d.Bitmap;
import elke.graphics.Sprite;
import elke.entity.Entity2D;

enum Phases {
	Eyes;
	Hands;
	CenterEye;
}

enum AttackType {
	FistSlam;
	HandSwoosh;
	HandClap;
	SkyLasers;
}

typedef AttackPattern = {
	t: AttackType,
	attackDelay: Float,
}

typedef Blood = {
	b: Bitmap,
	vx: Float,
	vy: Float,
	r: Float,
}

// Attacks
final attackInterval1 = 6.;
final attackInterval2 = 5.;
final attackInterval3 = 4.5;

final fistSlam: AttackPattern = {
	t: FistSlam,
	attackDelay: 15,
}

final handSwoosh: AttackPattern = {
	t: HandSwoosh,
	attackDelay: 10,
}

class God extends Entity2D {
	var sprite: Sprite;

	public var enabledAttacks: Array<AttackPattern>;

	public var timePerAttack = attackInterval1;

	public var attackTimer = 0.;

	public var phase: Phases = Eyes;
	public var shield: Bitmap;

	public var maxHealth = 200.;
	public var health = 200.;

	var eyePositions = [
		/*
		{x : -120, y: -140},
		{x : 120, y: -140},

		{x : -160, y: -120},
		{x : -180, y: -80},
		{x : -170, y: -40},
		{x : -150, y: 0},
		{x : -120, y: 30},

		{x : 160, y: -120},
		{x : 180, y: -80},
		{x : 170, y: -40},
		{x : 150, y: 0},
		{x : 120, y: 30},

		{x : 60, y: 35},
		{x : -60, y: 35},
		*/

		{x : 0, y: 40},
	];

	var handPositions = [
		{x : -210, y: 0},
		/*
		{x : -130, y: -20},

		{x : 210, y: 0},
		{x : 130, y: -20},
		*/
	];

	public var dead = false;

	public var eyes: Array<Eye>;
	public var godEye: GodEye = null;

	public var hands: Array<HandEnemy>;

	//public var skeletonCount = 10;
	public var skeletonCount = 10;
	public var skeletons: Array<Skeleton>;

	public function new(?p){
		super(p);
		sprite = hxd.Res.img.god_tilesheet.toSprite2D(this);
		sprite.originX = 128;
		sprite.originY = 88;

		shield = new Bitmap(hxd.Res.img.godshield.toTile(), this);
		shield.tile.dx = -140;
		shield.tile.dy = -88;

		eyes = [];
		for (p in eyePositions) {
			var e = new Eye(this);
			e.x = Math.round((p.x) * 1.5);
			e.y = Math.round((p.y + 40) * 1.5);
			eyes.push(e);
		}

		enabledAttacks = [
			fistSlam,
		];

		hands = [];
		skeletons = [];
	}

	public var originX = 0.;
	public var originY = 0.;

	var time = 0.;

	var skRot = .0;
	var yOff = 0.;
	var deadTime = 0.0;
	var xOff = 0.;

	var exploded = false;

	function explode() {
		if (exploded) {
			return;
		}

		exploded = true;
		sprite.color.set(1000, 1000, 1000);
		Game.instance.freeze(5);
		PlayState.instance.doShake();

		PlayState.instance.onGodExplode();

		if (godEye != null) {
			godEye.remove();
		}

		var t = hxd.Res.img.blood.toTile();
		var tiles = [];
		for (x in 0...4) {
			for (y in 0...4) {
				var t = t.sub(x * 32, y * 32, 32, 32);
				t.dx = -16;
				t.dy = -16;
				tiles.push(t);
			}
		}

		for (i in 0...100) {
			var tt = tiles[Std.int(Math.random() * tiles.length)];
			var bm  = new Bitmap(tt, this);
			bm.x = Math.random() * 200 - 100;
			bm.y = Math.random() * 100 - 50;
			particles.push({
				b: bm,
				vx: 2 * (Math.random() * 10 - 5),
				vy: -5 - Math.random() * 5,
				r: Math.random() - 0.5 ,
			});
		}

		new Timeout(0.2, () -> {
			sprite.visible = false;
		});
	}

	public var activeAttacks: Array<Attack> = [];
	
	public function removeAttacks() {
		attackTimer = 0;
		for (a in activeAttacks) {
			a.remove();
			activeAttacks.remove(a);
		}
	}

	function doAttack() {
		attackTimer = 0;
		var attackType = enabledAttacks[Std.int(Math.random() * enabledAttacks.length)].t;
		var attack: Attack = null;
		attack = switch(attackType) {
			case FistSlam: new FistSlam(PlayState.instance.attackContainer);
			default: new FistSlam(PlayState.instance.attackContainer);
		}

		sprite.animation.play("mean", false, false, 0, (s) -> {
			sprite.animation.play("idle");
		});

		activeAttacks.push(attack);
	}

	var particles: Array<Blood> = [];

	var untilExplode = 0.9;

	public var commenceFalling = false;
	var rrrrat = 1.0;
	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		var yoffTarget = 0.;
		if (paused) {
			yoffTarget = 200;
		} else {
			attackTimer += dt;
			if (attackTimer > timePerAttack) {
				doAttack();
			}
		}

		for (a in activeAttacks) {
			if (a.done) {
				activeAttacks.remove(a);
			}
		}

		for (p in particles) {
			p.b.x += p.vx;
			p.b.y += p.vy;
			p.b.rotation += p.r;
			p.vy += 0.5;
			p.vx *= 0.98;
			if (p.b.y > 400) {
				p.b.remove();
				particles.remove(p);
			}
		}

		if (dead) {
			if (commenceFalling) {
				deadTime += dt;
			}

			if (deadTime > 2.0) {
				yOff += 1;
				yOff = Math.min(yOff, 350);
			}

			if (yOff >= 350) {
				untilExplode -= dt;
				if (untilExplode < 0.5) {
					rrrrat = 0;
				}
				if (untilExplode < 0) {
					explode();
				}
			}

			xOff = Math.cos(deadTime * 100) * 2.5 * rrrrat;
		} else {
			yOff += (yoffTarget - yOff) * 0.1;
		}

		if (!exploded) {
			x = Math.round(originX + Math.sin(time * 0.5) * 10 + xOff);
			y = Math.round(originY + Math.cos(time * 0.7) * 30 + yOff);
		}

		if (phase == Eyes) {
			for (e in eyes) {
				if (e.dead) {
					eyes.remove(e);
				}
			}
			if (eyes.length == 0) {
				initHandsPhase();
			}
		}

		if (phase == Hands) {
			if (!handsStarted) {
				return;
			}

			for (e in hands) {
				if (e.dead) {
					hands.remove(e);
				}
			}

			if (hands.length == 0) {
				initLastPhase();
			}
		}

		if (phase == CenterEye) {
			if (!lastStarted) {
				return;
			}

			shield.alpha *= 0.98;

			var sRadius = 150 + Math.sin(skRot * 1.4) * 20;

			for (e in skeletons) {
				if (e.dead) {
					skeletons.remove(e);
				}
			}

			var sStep = 0.;
			if (skeletons.length > 0) {
				sStep = ((Math.PI * 2) / skeletons.length);
			}
			var i = 0;
			
			skRot += dt;

			for (s in skeletons) {
				var dx = Math.cos(sStep * i + skRot) * sRadius;
				var dy = Math.sin(sStep * i + skRot) * sRadius;

				dx -= s.x;
				dy -= s.y;

				dx *= 0.2;
				dy *= 0.2;

				s.x += (dx);
				s.y += (dy);
				
				s.x = Math.round(s.x);
				s.y = Math.round(s.y);

				s.sprite.scaleX = s.x > 0 ? -1 : 1;

				i ++;
			}
		}
	}

	public function kill() {
		if (dead) {
			return;
		}

		removeAttacks();
		paused = true;

		sprite.animation.play("dead");

		dead = true;
	}

	var handsStarted = false;
	var lastStarted = false;

	var hurting = false;
	public function playHurt() {
		if (hurting) {
			return;
		}

		hurting = true;

		sprite.animation.play("hurt");
		new Timeout(0.8, () -> {
			hurting = false;
			sprite.animation.play("idle");
		});
	}

	function initHandsPhase() {
		phase = Hands;

		removeAttacks();
		timePerAttack = attackInterval2;

		sprite.animation.play("hurt");
		paused = true;

		enabledAttacks.push(handSwoosh);

		new Timeout(1.2, () -> {
			sprite.animation.play("mean");
			new Timeout(0.8, () -> {
				paused = false;
			});
			new Timeout(1.2, () -> {
				sprite.animation.play("idle");
			});

			handsStarted = true;
			for (p in handPositions) {
				var e = new HandEnemy(p.x < 0, this);
				e.setAnchorPos(
					Math.round((p.x) * 1.5),
					Math.round((p.y + 40) * 1.5)
				);

				hands.push(e);
			}
		});
	}
	public var paused = false;


	function initLastPhase() {
		phase = CenterEye;

		removeAttacks();
		timePerAttack = attackInterval3;

		sprite.animation.play("hurt");
		paused = true;
		new Timeout(1.2, () -> {
			sprite.animation.play("mean");
			new Timeout(0.8, () -> {
				paused = false;
			});

			new Timeout(1.2, () -> {
				sprite.animation.play("idle");
			});

			godEye = new GodEye(this);

			for (_ in 0...skeletonCount){
				var s = new Skeleton(this);
				skeletons.push(s);
			}

			lastStarted = true;
		});
	}
}