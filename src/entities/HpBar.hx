package entities;

import h2d.Object;
import h2d.RenderContext;
import h2d.Tile;
import h2d.Bitmap;

class HpBar extends Object {
	public var maxHp(default, set) = 1.0;
	public var hp(default, set) = 1.0;
	var bar : Bitmap;

	var pixelsPerHp = 2;
	var totalHpBar: Bitmap;

	static var bb1: Tile;
	static var bb2: Tile;

	public function new(?p) {
		super(p);
		if (bb1 == null) {
			bb1 = Tile.fromColor(0xffffff);
		}
		totalHpBar = new Bitmap(bb1, this);
		totalHpBar.height = 5;
		totalHpBar.alpha = 0.4;

		if (bb2 == null) {
			bb2 = Tile.fromColor(0xa43760);
		}

		bar = new Bitmap(bb2, this);
		bar.height = 5;
		bar.visible = false;
		totalHpBar.visible = false;
	}

	function set_maxHp(m: Float) {
		totalHpBar.width = Std.int(Math.round(m * pixelsPerHp));
		totalHpBar.x = Math.round(-totalHpBar.width * 0.5);

		return this.maxHp = m;
	}

	function set_hp(hp: Float) {
		hp = Math.max(0, hp);
		bar.width = Std.int(Math.round(hp * pixelsPerHp));
		bar.x = totalHpBar.x;

		if (hp >= maxHp || hp <= 0) {
			bar.visible = false;
		} else {
			bar.visible = true;
		}

		totalHpBar.visible = bar.visible;

		return this.hp = hp;
	}
}