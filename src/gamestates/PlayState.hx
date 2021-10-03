package gamestates;

import entities.SwordCondition;
import entities.BulletList;
import elke.gamestate.GameState;
import h3d.Engine;
import entities.Frame;
import elke.graphics.Sprite;
import h2d.col.Bounds;
import h2d.Tile;
import hxd.Key;
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
	public var attackContainer: Object;

	public var chopper: Sprite;
	public var horse: Horse;
	var rope: Rope;

	var swordCrate: Bitmap;
	var gunCrate: Bitmap;

	var lRooftop: Bitmap;
	var rRooftop: Bitmap;

	public var god: God;

	public var bullets: Array<Bullet>;

	public static var instance: PlayState;

	var timeElapsed = 0.;
	var timeText : Text;

	var bulletInfo: BulletList;
	var swordInfo : SwordCondition;

	var bossBar : ScaleGrid;
	var bossShieldBar : ScaleGrid;

	var introMusic: hxd.snd.Channel;

	var phase1Music: hxd.snd.Channel;
	var phase2Music: hxd.snd.Channel;
	var phase3Music: hxd.snd.Channel;

	public var startedGame = false;
	var initialChoppY = -650;
	var choppX = 0.0;
	var choppY = 0.0;

	var introFrame: Frame;

	var introContainer: Object;

	var startCooldown = 0.;
	public function new(cooldown = 0.0) {
		startCooldown = cooldown;
	}

	override function onEnter() {
		super.onEnter();
		game.engine.backgroundColor = 0x71a5d9;
		instance = this;
		container = new Object(game.s2d);
		world = new Object(container);

		god = new God(world);
		god.originX = Const.GAP_SIZE * 0.5;
		god.originY = -390;
		god.visible = false;

		chopper = hxd.Res.img.chopper_tilesheet.toSprite2D(world);
		chopper.originX = 363;
		chopper.originY = 183;
		chopper.animation.play();
		
		horse = new Horse(world);
		horse.x = Const.GAP_SIZE * 0.5;
		horse.y = initialChoppY;

		choppX = horse.x;
		choppY = horse.y;
		chopper.x = horse.x;
		chopper.y = horse.y;

		rope = new Rope(world);

		rope.visible = false;

		wx = (game.s2d.width * 0.5 - horse.x);

		wy = (game.s2d.height * 0.5 - (initialChoppY - 24));
		world.x = Math.round(wx);
		world.y = Math.round(wy);

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

		attackContainer = new Object(world);

		timeText = new Text(hxd.Res.fonts.picory.toFont(), container);
		timeText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x312c3b,
			alpha: 0.8,
		}

		timeText.visible = false;

		timeText.x = 16;
		timeText.y = 16;

		bulletInfo = new BulletList(container);
		swordInfo = new SwordCondition(container);

		bossBar = new ScaleGrid(hxd.Res.img.hpbar.toTile(), 3, 3, 3, 3, container);
		bossBar.height = 9;
		bossBar.width = 128;
		
		bossShieldBar = new ScaleGrid(hxd.Res.img.shieldbar.toTile(), 3, 3, 3, 3, container);
		bossShieldBar.height = 5;
		bossShieldBar.width = 128;

		bossBar.visible = false;
		bossShieldBar.visible = false;

		introMusic = game.sound.playSfx(hxd.Res.sound.chopper, 0.05, true);

		introFrame = new Frame(container);

		introContainer = new Object(container);
		var titleText = new Text(hxd.Res.fonts.headline.toFont(), introContainer);
		titleText.text = 'Horse with a Human Mask\nOn a Tightrope';
		titleText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x1b111f,
			alpha: 0.7,
		};

		taskText = new Text(hxd.Res.fonts.picory.toFont(), container);
		taskText.dropShadow = {
			dx: 1,
			dy: 1,
			color: 0x1b111f,
			alpha: 0.4,
		};

		tutorialImage = new Bitmap(hxd.Res.img.tutorial.toTile(), container);

		positionIntroThing();

		//startMusic();
	}

	var taskStrIndex = 0;
	var untilNextChar = 1.5;
	var taskString = "Mission #1\nKill God. Don't die";
	var taskText: Text;
	var tutorialImage: Bitmap;

	function startMusic() {
		phase1Music = game.sound.playSfx(hxd.Res.sound.phase1music, 0.5, true);
		phase2Music = game.sound.playSfx(hxd.Res.sound.phase2music, 0., true);
		phase3Music = game.sound.playSfx(hxd.Res.sound.phase3music, 0., true);
	}

	public function startPhase2Music() {
		if (phase1Music != null) {
			phase1Music.fadeTo(0, 0.3, () -> {
				phase1Music.stop();
			});
		}

		phase2Music.fadeTo(0.5, 0.2);
	}

	public function startPhase3Music() {
		phase2Music.fadeTo(0, 0.3, () -> {
			phase2Music.stop();
		});

		phase3Music.fadeTo(0.5, 0.2);
	}

	function positionIntroThing() {
		if (introContainer != null) {
			var b = introContainer.getBounds();
			var s = game.s2d;
			introContainer.y = Math.round(introFrame.borderWidth + 32.0);
			introContainer.x = 32;
		}

		var s = game.s2d;

		if (taskText != null) {
			taskText.x = 32;
			taskText.y = Math.round(s.height - introFrame.borderWidth - 30.0 - 13 * 2);
		}

		if (tutorialImage != null) {
			var t = tutorialImage.tile;
			tutorialImage.x = Math.round(s.width - t.width);
			tutorialImage.y = Math.round(s.height - introFrame.borderWidth - t.height);
		}
	}

	public function stopAllMusic() {
		if (introMusic != null) {
			introMusic.stop();
		}

		if (winMusic != null) {
			winMusic.stop();
		}

		if (phase1Music != null) {
			phase1Music.stop();
			phase1Music = null;
		}

		if (phase2Music != null) {
			phase2Music.stop();
			phase2Music = null;
		}

		if (phase3Music != null) {
			phase3Music.stop();
			phase3Music = null;
		}
	}

	public function startGame() {
		if (startedGame) {
			return;
		}

		new Timeout(0.2, () -> {
			introContainer.remove();
			taskText.remove();
			tutorialImage.remove();
			taskText = null;
			introContainer = null;
			tutorialImage = null;
		});

		god.visible = true;
		rope.visible = true;

		startedGame = true;

		if (introMusic != null) {
			introMusic.fadeTo(0, 0.3, () -> {
				introMusic.stop();
				introMusic = null;
			});
		}

		horse.jumpOffChopper();
	}

	var firstLand = true;
	public function onHorseLanded() {
		if (firstLand) {
			startMusic();
			introFrame.hide = true;
		}

		firstLand = false;
	}

	var maxBarWidth = 128;

	var timeTilCrouch = 0.1;

	var steppingLeft = false;
	var steppingRight = false;

	var testB = new Bounds();
	public function tryHitHorse(sx, sy, w, h) {
		if (horse.invulnerable) {
			return false;
		}

		testB.empty();
		testB.addPos(sx, sy);
		testB.addPos(sx + w, sy + w);

		if (horse.hitbox.intersects(testB)) {
			horse.hitByEnemy();
			return true;
		}

		return false;
	}

	var deathTimeout = 0.5;
	override function onEvent(e:Event) {
		if (startCooldown > 0) {
			return;
		}

		if (e.kind == EPush) {

			if (horse.sitting) {
				startGame();
				return;
			}

			if ((horse.fellOff || heroContainer != null) && deathTimeout < 0) {
				reset();
			}

			if (e.button == 0) {
				steppingLeft = true;
				if (horse.jumping && horse.landedFirstTime) {
					horse.attack();
				}
			}

			if (e.button == 1) {
				steppingRight = true;
			}
		}

		#if debug
		if (e.kind == EKeyDown) {
			if(e.keyCode == Key.O) {
				winGame();
			}
		}
		#end

		if (e.kind == EKeyDown) {
			if(e.keyCode == Key.R) {
				reset();
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
		if (wonGame) {
			return;
		}

		stopAllMusic();

		bossBar.alpha = 0;
		for (s in god.skeletons) {
			s.hurt(1000);
		}

		wonGame = true;
		
		horse.land();
		god.kill();
	}


	var choppVX = 0.;
	var choppVY = 0.;
	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		startCooldown -= dt;

		if (!startedGame) {
			if (taskStrIndex < taskString.length) {
				untilNextChar -= dt;
				if (untilNextChar <= 0) {
					taskStrIndex ++;
					taskStrIndex = Std.int(Math.min(taskStrIndex, taskString.length));
					var newStr = taskString.substr(0, taskStrIndex);
					taskText.text = newStr;
					if (newStr.charAt(newStr.length - 1) == '\n') {
						untilNextChar = 0.8;
					} else {
						untilNextChar = 0.08;
					}
				}
			}

			positionIntroThing();
		}

		bulletInfo.bullets = horse.ammo;
		bulletInfo.y = timeText.y;
		bulletInfo.x = game.s2d.width - 16 - 16;

		swordInfo.visible = horse.hasSword && horse.landedFirstTime;
		swordInfo.condition = horse.swordCondition;

		swordInfo.y = timeText.y;
		swordInfo.x = game.s2d.width - 16 - 32;

		if (horse.sitting) {
			chopper.y = Math.round(choppY + Math.sin(time * 2.0) * 6);
			horse.y = chopper.y;
		} else if (chopper != null) {
			chopper.rotation += (0.2 - chopper.rotation) * 0.2;
			choppVX += 0.3;
			choppVX = Math.min(choppVX, 5);

			choppVY -= 0.2;
			choppVY = Math.max(choppVY, -5);

			chopper.x += choppVX;
			chopper.y += choppVY;
			if (chopper.x > Const.GAP_SIZE + 100) {
				chopper.remove();
				chopper = null;
			}
		}

		if (!horse.fellOff && !wonGame && startedGame && horse.landedFirstTime) {
			timeText.visible = true;
			timeElapsed += dt;
		}

		if (horse.dead || horse.fellOff || wonGame) {
			deathTimeout -= dt;
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
			if (horse.landedFirstTime) {
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

			var wtgs = horse.landedFirstTime ? 1 : 0.0;

			wx += ((game.s2d.width * 0.5 - horse.x) - wx - d.x * wtgs) * 0.3;
			if (!horse.sitting) {
				wy += ((game.s2d.height * ty - (horse.y - 64) - d.y * wtgs) - wy) * 0.5;
			} else {
				wy += ((game.s2d.height * ty - (initialChoppY - 24) - d.y * wtgs) - wy) * 0.5;
			}
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
					if (e.dead || !e.open || e.invulnerable) {
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

		if (wonGame) {
			if (!horse.jumping) {
				wonTime += dt;
				god.commenceFalling = true;
			}

			if (wonTime > 1.3) {
				var dx = -(god.x - horse.x) * 0.5;
				var dy = -(god.y - (horse.y - 42)) * 0.5;
				wtgx += (dx - wtgx) * .05;
				wtgy += (dy - wtgy) * .05;
			}
		}

		world.x = Math.round(wx + shakeX + wtgx);
		world.y = Math.round(wy + shakeY + wtgy);

		if (heroContainer != null) {
			var b = heroContainer.getBounds();
			heroContainer.x = Math.round((game.s2d.width - b.width) * 0.5);
			heroContainer.y = Math.round((game.s2d.height * 0.25 - b.height * 0.5));
		}
	}

	var winMusic : hxd.snd.Channel;

	var heroContainer: Object;
	public function onGodExplode() {
		var bb = new Bitmap(Tile.fromColor(0xFFFFFFF), container);
		bb.tile.scaleToSize(game.s2d.width, game.s2d.height);
		new Timeout(0.01, () -> {
			bb.remove();
		});

		new Timeout(2.2, () -> {
			heroContainer = new Object(container);
			var winBm = new Bitmap(hxd.Res.img.hero.toTile(), heroContainer);
			var b = heroContainer.getBounds();
			heroContainer.x = Math.round((game.s2d.width - b.width) * 0.5);
			heroContainer.y = Math.round((game.s2d.height * 0.25 - b.height * 0.5));

			winMusic = game.sound.playSfx(hxd.Res.sound.winsong, 0.5, true);


			var t = new Text(hxd.Res.fonts.picory.toFont(), heroContainer);
			t.x = 28;
			t.y = 64;
			t.dropShadow = {
				dx: 1,
				dy: 1,
				color: 0x312c3b,
				alpha: 0.9
			};

			t.maxWidth = 144;
			t.text = "You did it. You saved things. Great job";
			if (!horse.hasBeenHit) {
				t.text += "\n\nZero damage run. Nice.";
			}
		});
	}

	var wonTime = 0.;

	var wtgx = 0.;
	var wtgy = 0.;

	public function reset() {
		game.states.setState(new PlayState());
	}

	override function onLeave() {
		super.onLeave();
		container.remove();

		stopAllMusic();
	}
}