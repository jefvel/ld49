package entities;

import elke.entity.Entity2D;

// Enemy attack class
class Attack extends Entity2D {

	public var done = false;

	override function onRemove() {
		super.onRemove();
		done = true;
	}
}