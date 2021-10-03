package entities;

import entities.God.AttackType;
import elke.entity.Entity2D;

// Enemy attack class
class Attack extends Entity2D {

	public var attackType: AttackType = null;
	public var canOnlyBeOne = false;
	public var done = false;

	override function onRemove() {
		super.onRemove();
		done = true;
	}
}