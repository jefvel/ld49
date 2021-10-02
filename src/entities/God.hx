package entities;

import elke.graphics.Sprite;
import elke.entity.Entity2D;

enum Phases {
	Eyes;
	Hands;
	CenterEye;
}

class God extends Entity2D {
	var sprite: Sprite;
	public var phase: Phases = Eyes;

	var eyePositions = [
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

		{x : 0, y: 40},
	];

	public var eyes: Array<Eye>;

	public function new(?p){
		super(p);
		sprite = hxd.Res.img.god_tilesheet.toSprite2D(this);
		sprite.originX = 128;
		sprite.originY = 88;

		eyes = [];
		for (p in eyePositions) {
			var e = new Eye(this);
			e.x = Math.round((p.x) * 1.5);
			e.y = Math.round((p.y + 40) * 1.5);
			eyes.push(e);
		}
	}

	public var originX = 0.;
	public var originY = 0.;

	var time = 0.;
	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		x = Math.round(originX + Math.sin(time * 0.5) * 10);
		y = Math.round(originY + Math.cos(time * 0.7) * 30);

		for (e in eyes) {
			if (e.dead) {
				eyes.remove(e);
			}
		}
	}



	
}