package entities;

import h2d.Tile;
import h2d.Bitmap;
import elke.entity.Entity2D;

class Frame extends Entity2D {
	public var left = 0.;
	var aspect = 1 / 2.39;

	var botBm: Bitmap;
	var topBm: Bitmap;

	public var hide = false;
	var targetH = 0.;
	public var borderWidth = 0.;

	public function new(?c) {
		super(c);
		var t = Tile.fromColor(0x1b111f);
		botBm = new Bitmap(t, this);
		topBm = new Bitmap(t, this);
	}

	override function onAdd() {
		super.onAdd();
		var s = getScene();
		var h = Math.floor(s.width * aspect);
		targetH = Math.round((s.height - h) * 0.5);
		borderWidth = targetH;
	}

	override function update(dt:Float) {
		super.update(dt);
		var s = getScene();
		if (s == null) {
			return;
		}

		var h = Math.floor(s.width * aspect);
		var p = (s.height - h) * 0.5;

		if (hide) {
			 p = 0.;
		}

		borderWidth = p;

		targetH += (p - targetH) * 0.1;

		p = Math.round(targetH);

		topBm.width = botBm.width = s.width;
		topBm.height = botBm.height = p;

		botBm.y = s.height - p;
	}
}