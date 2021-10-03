package gamestates;

import h2d.ScaleGrid;
import elke.Game;
import entities.Bullet;
import h2d.col.Point;
import entities.God;
import h2d.Bitmap;
import entities.Rope;
import entities.Horse;
import h2d.Object;
import h3d.scene.World;
import elke.process.Timeout;
import hxd.snd.effect.ReverbPreset;
import elke.graphics.Transition;
import h2d.Text;
import hxd.Event;

class PlayState extends elke.gamestate.GameState {
	public var container:Object;
	public var world : Object;

	var horse: Horse;
	var rope: Rope;

	var swordCrate: Bitmap;
	var gunCrate: Bitmap;

	var lRooftop: Bitmap;
	var rRooftop: Bitmap;

	var god: God;

	public var bullets: Array<Bullet>;

	public static var instance: PlayState;

	var timeElapsed = 0.;
	var timeText : Text;

	var bossBar : ScaleGrid;
	var bossShieldBar : ScaleGrid;

	public function new() {}
	override function onEnter() {
		super.onEnter();
		instance = this;
		container = new Object(game.s2d);
		world = new Object(container);

		god = new God(world);
		god.originX = Const.GAP_SIZE * 0.5;
		god.originY = -390;
		
		horse = new Horse(world);
		horse.x = 0;
		horse.y = 0;

		rope = new Rope(world);

		wy = (game.s2d.height * 0.7 - (horse.y - 64));
		wx = (game.s2d.width * 0.5 - horse.x);

		swordCrate = new Bitmap(hxd.Res.img.swordcrate.toTile(), world);
		swordCrate.x = 0 - 64 - 20; 
		swordCrate.y = -64;

		gunCrate = new Bitmap(hxd.Res.img.guncrate.toTile(), world);
		gunCrate.x = Const.GAP_SIZE + 20;
		gunCrate.y = -64;

		var rt = hxd.Res.img.rooftop.toTile();
		lRooftop = new Bitmap(rt, world);
		lRooftop.y = -8;
		lRooftop.x = -rt.width;

		rRooftop = new Bitmap(rt, world);
		rRooftop.y = -8;
		rRooftop.x = Const.GAP_SIZE;

		bullets = [];

		timeText = new Text(hxd.Res.fonts.picory.toFont(), container);
		timeText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x312c3b,
			alpha: 0.8,
		}

		timeText.x = 16;
		timeText.y = 16;

		bossBar = new ScaleGrid(hxd.Res.img.hpbar.toTile(), 3, 3, 3, 3, container);
		bossBar.height = 9;
		bossBar.width = 128;
		
		bossShieldBar = new ScaleGrid(hxd.Res.img.shieldbar.toTile(), 3, 3, 3, 3, container);
		bossShieldBar.height = 5;
		bossShieldBar.width = 128;

		bossBar.visible = false;
		bossShieldBar.visible = false;
	}

	var maxBarWidth = 128;

	var timeTilCrouch = 0.1;

	var steppingLeft = false;
	var steppingRight = false;

	override function onEvent(e:Event) {
		if (e.kind == EPush) {
			if (horse.fellOff) {
				reset();
			}

			if (e.button == 0) {
				steppingLeft = true;
				if (horse.jumping) {
					horse.attack();
				}
			}

			if (e.button == 1) {
				steppingRight = true;
			}
		}

		if (e.kind == ERelease || e.kind == EReleaseOutside) {
			if (e.button == 0) {
				steppingLeft = false;
			}

			if (e.button == 1) {
				steppingRight = false;
			}
		}
	}

	var time = 0.0;

	var wx = 0.;
	var wy = 0.;

	var timePerStep = 0.1;
	var stepTime = 0.;

	var targetOffY = 0.7;

	var shakeY = 0.;
	var shakeX = 0.;
	public function doShake() {
		var intensity = 10.;
		shakeX = (Math.random() * 2 - 1) * intensity;
		shakeY = (Math.random() * 2 - 1) * intensity;
	}

	public var wonGame = false;
	public function winGame() {
		bossBar.alpha = 0;
		for (s in god.skeletons) {
			s.hurt(1000);
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		time += dt;

		if (!horse.fellOff && !wonGame) {
			timeElapsed += dt;
		}

		if (god.phase == CenterEye && god.godEye != null) {
			bossBar.y = 8;
			bossBar.x = Math.round((game.s2d.width - maxBarWidth) * 0.5);
			bossBar.width = (god.godEye.health / god.godEye.maxHealth) * maxBarWidth;

			var shields = 0.;
			if (god.skeletons.length > 0) {
				shields = god.skeletons.length / god.skeletonCount;
			}

			bossShieldBar.y = 8 + 12;
			bossShieldBar.x = Math.round((game.s2d.width - maxBarWidth) * 0.5);
			bossShieldBar.width = (shields) * maxBarWidth;
			if (shields <= 0) {
				bossShieldBar.alpha *= 0.7;
			}

			bossBar.visible = true;
			bossShieldBar.visible = true;
		}

		var minutes = Math.floor(timeElapsed / 60);
		var seconds = timeElapsed - minutes * 60;
		var extraZero = minutes < 10 ? '0' : '';
		var extraSecondZero = seconds < 10 ? '0' : '';
		var hundredsSplit = '${seconds}'.split('.');
		var hundreds = "000";
		if (hundredsSplit.length > 1) {
			hundreds = '${hundredsSplit[1].substr(0, 3)}';
			while(hundreds.length < 3){
				hundreds = "0" + hundreds;
			}
		}

		timeText.text = '$extraZero$minutes:$extraSecondZero${Math.floor(seconds)}:$hundreds';

		if (!horse.fellOff) {
			if (steppingLeft && steppingRight) {
				timeTilCrouch -= dt;
				if (timeTilCrouch <= 0) {
					horse.crouch();
					timeTilCrouch = 0.1;
				}
			} else if (horse.crouching) {
				if (!steppingLeft || !steppingRight) {
					horse.jump();
				}
			}

			if (stepTime > 0) {
				stepTime -= dt;
			} else if (!(steppingLeft && steppingRight)) {
				if (steppingLeft) {
					horse.stepLeft();
					stepTime = timePerStep;
				} else if (steppingRight) {
					horse.stepRight();
					stepTime = timePerStep;
				}
			}

			rope.horseX = horse.x;
			rope.horseY = horse.y;

			var d = new Point(game.s2d.mouseX, game.s2d.mouseY);
			d.x -= game.s2d.width * 0.5;
			d.y -= game.s2d.height * 0.5;
			
			d.scale(0.6);

			var ml = 80;
			if (d.lengthSq() > ml * ml) {
				d.normalize();
				d.scale(ml);
			}

			if (!horse.jumping) {
				d.scale(0);
			}

			var ty = horse.jumping ? 0.5 : 0.7;
			targetOffY += (ty - targetOffY) * 0.4;

			wx += ((game.s2d.width * 0.5 - horse.x) - wx - d.x) * 0.3;
			wy += ((game.s2d.height * ty - (horse.y - 64) - d.y) - wy) * 0.5;
		} else {
			rope.horseFellOff = true;
		}

		var steps = 2;
		for (_ in 0...steps) {
			for (b in bullets) {
				b.moveBullet(dt);
				if (b.willRemove || (b.bulletType == Sword && horse.swordCondition <= 0)) {
					b.remove();
					continue;
				}

				for (e in god.eyes) {
					if (e.dead) {
						continue;
					}

					var ex = e.x + god.x;
					var ey = e.y + god.y;
					var dx = ex - b.x;
					var dy = ey - b.y;
					var distSq = dx * dx + dy * dy;
					var totalRadius = 25 + b.radius;
					if (distSq < totalRadius * totalRadius) {
						game.sound.playSfx(hxd.Res.sound.gunhit);
						game.freeze(2);
						e.hurt(b.damage);
						if (e.dead) {
							god.playHurt();
						}
						horse.onBulletHitEnemy(b, e);
						b.willRemove = true;
						if (!b.multiHit) {
							b.remove();
						}
					}
				}

				for (e in god.hands) {
					if (e.dead || !e.open) {
						continue;
					}

					var ex = e.x + god.x;
					var ey = e.y + god.y;
					var dx = ex - b.x;
					var dy = ey - b.y;
					var distSq = dx * dx + dy * dy;
					var totalRadius = 25 + b.radius;
					if (distSq < totalRadius * totalRadius) {
						game.sound.playSfx(hxd.Res.sound.gunhit);
						game.freeze(2);
						e.hurt(b.damage);
						if (e.dead) {
							god.playHurt();
						}
						horse.onBulletHitEnemy(b, e);
						b.willRemove = true;
						if (!b.multiHit) {
							b.remove();
						}
					}
				}

				for (e in god.skeletons) {
					if (e.dead) {
						continue;
					}

					var ex = e.x + god.x;
					var ey = e.y + god.y;
					var dx = ex - b.x;
					var dy = ey - b.y;
					var distSq = dx * dx + dy * dy;
					var totalRadius = 25 + b.radius;
					if (distSq < totalRadius * totalRadius) {
						game.sound.playSfx(hxd.Res.sound.gunhit);
						game.freeze(2);
						e.hurt(b.damage);
						if (e.dead) {
							god.playHurt();
						}
						horse.onBulletHitEnemy(b, e);
						b.willRemove = true;
						if (!b.multiHit) {
							b.remove();
						}
					}
				}

				if (god.godEye != null) {
					var e = god.godEye;
					if (e.dead) {
						continue;
					}

					var ex = e.x + god.x;
					var ey = e.y + god.y;
					var dx = ex - b.x;
					var dy = ey - b.y;
					var distSq = dx * dx + dy * dy;
					var totalRadius = 25 + b.radius;
					if (distSq < totalRadius * totalRadius) {
						game.sound.playSfx(hxd.Res.sound.gunhit);
						game.freeze(2);

						var shields = 0.;
						if (god.skeletons.length > 0) {
							shields = god.skeletons.length / god.skeletonCount;
						}

						e.hurt((1 - shields) * b.damage);

						if (e.dead) {
							winGame();
						}
						horse.onBulletHitEnemy(b, e);
						b.willRemove = true;
						if (!b.multiHit) {
							b.remove();
						}
					}
				}
			}
		}

		shakeX *= 0.6;
		shakeY *= 0.6;

		world.x = Math.round(wx + shakeX);
		world.y = Math.round(wy + shakeY);
	}

	public function reset() {
		game.states.setState(new PlayState());
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}