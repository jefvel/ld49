package entities;

import h2d.Tile;
import gamestates.PlayState;
import h2d.Bitmap;
import elke.entity.Entity2D;

enum BulletType {
	Gun;
	Sword;
}

class Bullet extends Entity2D {
	public var bulletType: BulletType = Gun;
	var dir = .0;
	var b : Bitmap;
	var bulletSpeed = 15.0;
	var bulletDistance = 230.;
	var sx = 0.;
	var sy = 0.;

	public var radius = 2;
	public var multiHit = false;
	public var willRemove = false;

	var lifetime = 999.;
	public var damage = 10.0;
	public function new(direction, startX, startY, speed = 15., lifeTime = 999., ?p, ?t: Tile) {
		super(p);
		if (t != null) {
			b = new Bitmap(t, this);
			b.tile.dy = -8;
			b.tile.dx = -24;
			b.rotation = direction;
		}
		dir = direction;
		x = startX;
		y = startY;
		sx = startX;
		sy = startY; 

		bulletSpeed = speed;
		lifetime = lifeTime;

		dx = Math.cos(direction) * bulletSpeed;
		dy = Math.sin(direction) * bulletSpeed;

		PlayState.instance.bullets.push(this);
	}

	var dx = .0;
	var dy = .0;

	var distTravelled = 0.;
	public function moveBullet(dt:Float) {
		distTravelled += bulletSpeed;

		lifetime-= dt;
		if(lifetime < 0){
			remove();
			return;
		}

		x += dx;
		y += dy;

		if (b != null) {
			b.scaleX =  1. - (distTravelled / bulletDistance);
		}

		if (distTravelled >= bulletDistance) {
			remove();
		}
	}

	override function onRemove() {
		super.onRemove();
		PlayState.instance.bullets.remove(this);
	}
}