package entities;

import h2d.Graphics;
import elke.entity.Entity2D;

class Rope extends Entity2D {
	public var horseX = 0.;
	public var horseY = 0.;

	public var ropeY = -4.0;
	public var ropeXStart = 0.;
	public var ropeXEnd = Const.GAP_SIZE;

	public var horseFellOff = false;

	var vy = 0.;
	var ay = 0.;
	
	var g : Graphics;
	public function new(?p) {
		super(p);
		g = new Graphics(this);
		g.filter = new h2d.filter.Outline(1, 0x312c3b);
	}

	override function update(dt:Float) {
		super.update(dt);

		if (horseFellOff || horseY < 0) {
			for (_ in 0...2) {
				ay += (0 - horseY) * 0.1;
				vy += ay;
				ay *= 0.83;
				vy *= 0.5;
				horseY += vy;
			}
		}

		g.clear();
		g.lineStyle(1, 0xFEFEFE);
		g.moveTo(ropeXStart, ropeY - 0.1);
		g.lineTo(Math.round(horseX), Math.round(horseY));
		g.lineTo(ropeXEnd, ropeY - 0.1);
	}
}