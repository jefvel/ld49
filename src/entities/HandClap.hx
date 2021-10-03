package entities;

import h2d.Object;
import h2d.Tile;
import gamestates.PlayState;
import elke.Game;
import elke.T;
import h2d.Bitmap;

import entities.HandEnemy.HandPosition;

enum ClapState {
	Waiting;
	MovingIntoPosition;
	Swooping;
	MovingBack;
}

class HandClapHand extends Object {
	var bm: Bitmap;
	public var h: HandEnemy;

	public var movingLeft = false;
	public var startX = 0.;
	public var willGoAllWay = false;

	public function new(movingLeft = true, hand,  ?p) {
		super(p);
		this.h = hand;

		bm = new Bitmap(hxd.Res.img.clapfist.toTile(), this);
		bm.tile.dx = -84;
		bm.tile.dy = -128;

		if (movingLeft) {
			bm.scaleX = -1;
		}

		this.movingLeft = movingLeft;

		x = (hand.x + hand.parent.x);
		y = (hand.y + hand.parent.y) - 32;

		startX = x;
	}
}

class HandClap extends Attack {
	var gap = 60.;
	var attackX = 0.;
	var attackY = -200.;

	var fistsVisible = false;

	var swoopTime = 0.7;
	var st = 0.;
	var fromLeft = false;

	var hands : Array<HandEnemy>;
	var state: ClapState = Waiting;

	var handclaps: Array<HandClapHand>;
	var dangerzone: DangerZone;
	public function new(hands: Array<HandEnemy>, ?p) {
		super(p);
		canOnlyBeOne = true;
		attackType = HandClap;

		var horse = PlayState.instance.horse;

		this.hands = hands;

		fromLeft = Math.random() > 0.5;

		var ay = 0.;
		var c = 0.;
		var god = PlayState.instance.god;

		for (h in hands) {
			h.openHand();
			h.beingControlled = true;
			ay += (h.y + god.y);
			c ++;
		}

		attackX = Math.round(Math.random() * 150 - 75 + horse.x);
		attackX = Math.min(Const.GAP_SIZE - gap, Math.max(gap, attackX));
		var attackWidth = Const.GAP_SIZE - gap * 2;
		var attackHeight = 256;

		attackX = gap;
		c = Math.max(1, c);
		attackY = (ay / c);

		var d = new DangerZone(1.8, initiateAttack, attackWidth, attackHeight, true, false, this);

		d.x = attackX;
		d.y = attackY;

		dangerzone = d;

		state = MovingIntoPosition;

		handclaps = [];
	}

	var alreadyHit = false;

	override function update(dt:Float) {
		super.update(dt);
		if (dangerzone != null) {
			var ay = 0.;
			var c = 0.;
			var god = PlayState.instance.god;

			for (h in hands) {
				ay += (h.y + god.y);
				c ++;
			}

			c = Math.max(1, c);
			attackY = (ay / c);
			dangerzone.y = attackY;
		}

		if (!fistsVisible) {
			return;
		}

		st += dt;

		var g = gap + 50;
		var dx = Const.GAP_SIZE - g * 2;

		st = Math.min(swoopTime, st);

		var time = T.expoIn(st / swoopTime);
		var elastoTime = T.elasticOut(st / swoopTime);
		
		var center = Const.GAP_SIZE * 0.5;
		if (!alreadyHit) {
			for (hand in handclaps) {
				var g = gap + 50;
				var sx = hand.startX;
				var endX = hand.movingLeft ? center + 20 : center - 20;

				var t = time;
				if (hand.willGoAllWay) {
					//endX = hand.movingLeft ? g : Const.GAP_SIZE - g;
					t = elastoTime;
				}


				var dx = endX - sx;
				hand.x = Math.round(sx + t * dx);

				var w = 80;
				var h = 140;
				var fx = hand.x - w * 0.5;
				var fy = hand.y - 71;

				PlayState.instance.tryHitHorse(fx, fy, w, h);
			}
		}

		if (st >= swoopTime) {
			alreadyHit = true;
		}

		if (st >= swoopTime) {
			if (!clapped && willClap) {
				clapped = true;
				Game.instance.sound.playSfx(hxd.Res.sound.megaclap, 0.5);
			}
			untilRemove -= dt;
			if (untilRemove < 0) {
				remove();
			}
		}
	}

	var clapped = false;
	var willClap = false;

	override function onRemove() {
		super.onRemove();

		var god = PlayState.instance.god;
		for (clap in handclaps) {
			var h = clap.h;
			h.beingControlled = false;
			h.closeHand(Math.random() * 2.0);
			h.targetX = clap.x - god.x;
			h.targetY = clap.y - god.y;
			h.x = h.targetX;
			h.y = h.targetY;
			h.sprite.visible = true;
			h.invulnerable = false;
			clap.remove();
		}
	}

	var untilRemove = 0.3;

	function initiateAttack(e) {
		fistsVisible = true;
		var c = PlayState.instance.attackContainer;
		var existingHands = new Map();

		for (h in hands) {
			if (!h.dead) {
				existingHands.set(h.pos, true);
			}
		}

		for (h in hands) {
			if (h.dead) {
				continue;
			}

			h.sprite.visible = false;
			h.invulnerable = true;

			var hitsOtherHand = switch(h.pos) {
				case TopLeft: existingHands.exists(TopRight);
				case TopRight: existingHands.exists(TopLeft);

				case BottomLeft: existingHands.exists(BottomRight);
				case BottomRight: existingHands.exists(BottomLeft);
			}

			var hh = new HandClapHand(h.x > 0, h, c);
			hh.willGoAllWay = !hitsOtherHand;

			if (hitsOtherHand) {
				willClap = true;
			}

			handclaps.push(hh);

			dangerzone = null;
		}

		Game.instance.sound.playWobble(hxd.Res.sound.fistswoophorizontal);
	}
}