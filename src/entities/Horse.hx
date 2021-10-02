package entities;

import h2d.col.Point;
import elke.graphics.Sprite;
import h2d.Bitmap;
import elke.Game;
import elke.entity.Entity2D;

class Horse extends Entity2D {
	var sprite:elke.graphics.Sprite;

	var frame = 0;
	var walkTags = ["left", "right"];
	var rotSpeed = 0.0;
	var rotAcc = 0.01;

	var maxRotSpeed = 0.2;
	
	public var fellOff = false;

	var rotUntilFallOff = Math.PI * 0.45;

	var stepLength = 11.0;
	var vx = 0.;

	public var walkingRight = true;
	public var crouching = false;
	public var jumping = false;

	public var hasGun = false;
	public var hasSword = true;

	public var ammo = 0;

	var gun: Bitmap;
	var sword: Bitmap;

	var offsetY = 0.;
	var oy = 0.;

	var arm: Sprite;

	static var stepSounds : Array<hxd.res.Sound>;

	public function new(?parent) {
		super(parent);
		if (stepSounds == null) {
			stepSounds = [
				hxd.Res.sound.steps.s1,
				hxd.Res.sound.steps.s2,
				hxd.Res.sound.steps.s3,
				hxd.Res.sound.steps.s4,
				hxd.Res.sound.steps.s5,
				hxd.Res.sound.steps.s6,
			];
		}

		arm = hxd.Res.img.horsearm_tilesheet.toSprite2D(this);
		arm.originY = 48;
		arm.x = 0;
		arm.y = -78;
		arm.animation.play("unarmed");

		sprite = hxd.Res.img.horse_tilesheet.toSprite2D(this);
		sprite.originX = 32;
		sprite.originY = 128;

		sword = new Bitmap(hxd.Res.img.sword.toTile(), sprite);
		gun = new Bitmap(hxd.Res.img.gun.toTile(), sprite);

		positionEquipment();
	}

	function positionEquipment() {
		if (!crouching) {
			sword.x = 12;
			sword.y = -125;
			gun.x = 20;
			gun.y = -111;
		} else {
			sword.y = -80;
			gun.y = -50;
		}
	}

	function stepForward() {
		frame ++;
		frame = frame % walkTags.length;
		sprite.animation.play(walkTags[frame]);

		if (walkingRight) {
			vx += stepLength;
		} else {
			vx -= stepLength;
		}

		var s = stepSounds[Std.int(Math.random() * stepSounds.length)];
		Game.instance.sound.playWobble(s);
	}

	public function stepLeft() {
		if (crouching || jumping) {
			return;
		}

		stepForward();
		rotSpeed -= rotAcc;
	}

	public function stepRight() {
		if (crouching || jumping) {
			return;
		}

		stepForward();
		rotSpeed += rotAcc;
	}

	var maxJumpSpeed = 22.0;
	var gravity = 0.4;
	var jumpPower = 0.;
	var ay = 0.;
	var inAir = false;

	public function crouch() {
		if (jumping || crouching) {
			return;
		}
		
		crouching = true;
		jumpPower = Math.sin(Math.PI * (x / Const.GAP_SIZE));
		jumpPower = Math.max(0.4, jumpPower);
		offsetY = Math.round(jumpPower * 30);
		
		Game.instance.sound.playWobble(hxd.Res.sound.crouch, 0.3, 0.05);
	}

	public function jump() {
		if (!crouching || jumping) {
			return;
		}

		offsetY = 0;
		inAir = false;
		vy = -jumpPower * maxJumpSpeed;
		jumping = true;
		crouching = false;

		slashRatio = 1.;

		Game.instance.sound.playWobble(hxd.Res.sound.jump, 0.3, 0.05);
		updateArmAnim();
	}

	function onDied() {
		fellOff = true;
	}

	function giveSword() {
		hasSword = true;
	}


	function giveGun() {
		hasGun = true;
		ammo = Const.BULLETS_PER_GUN;
	}

	var armRotOffset = 0.;
	var shootVelocity = 7;

	var shootTime = 0.3;

	function shoot() {
		if (ammo <= 0 || shootTime > 0) {
			return;
		}

		shootTime = 0.3;
		ammo --;
		armRotOffset = 0.9;

		vy = Math.sin(pointDir) * shootVelocity * 1.2;
		vx = Math.cos(pointDir) * shootVelocity;

		Game.instance.sound.playWobble(hxd.Res.sound.gunshot, 0.4, 0.05);

		arm.animation.play("shoot", false, true, 0, (s) -> {
			updateArmAnim();
		});

		if (ammo <= 0) {
			arm.animation.play("unarmed");
			dropGun();
		}
	}

	function updateArmAnim() {
		if (!hasGun && !hasSword) {
			arm.animation.play("unarmed");
		}

		if (hasGun) {
			arm.animation.play("gun");
		}

		if (hasSword) {
			arm.animation.play("sword");
		}
	}

	var slashTime = 0.1;
	var slashVelocity = 7;
	var slashRatio = 1.;

	function slash() {
		if (slashTime > 0) {
			return;
		}

		slashTime = 0.1;
		var slashY = Math.sin(pointDir + Math.PI) * slashVelocity * slashRatio * 3; 
		slashY = Math.min(0.1, slashY);

		var slashX = Math.cos(pointDir + Math.PI) * slashVelocity * slashRatio * 3;
		slashX = Math.max(-3, slashX);
		vy += slashY;
		vx += slashX;

		slashRatio *= 0.6;

		Game.instance.sound.playWobble(hxd.Res.sound.slash, 0.3, 0.05);

		arm.animation.play("slash", false, true, 0, (s) -> {
			arm.animation.play("sword");
		});
	}

	public function attack() {
		if (hasGun) {
			shoot();
		}

		if (hasSword) {
			slash();
		}
	}

	function dropSword() {
		hasSword = false;
		var s = new DroppedItem(sword.tile, parent);
		var p = sword.localToGlobal();
		s.x = p.x - parent.x;
		s.y = p.y - parent.y;

		Game.instance.sound.playWobble(hxd.Res.sound.drop, 0.3, 0.05);
	}

	function dropGun() {
		if (!hasGun) {
			return;
		}

		hasGun = false;

		var s = new DroppedItem(gun.tile, parent);
		var p = gun.localToGlobal();
		s.x = p.x - parent.x;
		s.y = p.y - parent.y;

		Game.instance.sound.playWobble(hxd.Res.sound.drop, 0.3, 0.05);
	}

	var vy = 0.;

	public var aimX = 0.;
	public var aimY = 0.;
	var pointDir = 0.;

	override function update(dt:Float) {
		super.update(dt);

		slashTime -= dt;
		shootTime -= dt;

		var s = getScene();
		if (s != null) {
			aimX = s.mouseX - parent.x;
			aimY = s.mouseY - parent.y;
		}

		armRotOffset *= 0.6;

		sword.visible = hasSword && !jumping;
		gun.visible = hasGun && !jumping;

		arm.visible = jumping;

		pointDir = Math.atan2((y + arm.y) - aimY, x - aimX);
		arm.rotation = pointDir;
		if (walkingRight) {
 			arm.rotation += Math.PI;
			arm.rotation -= armRotOffset;
		} else {
			arm.rotation += armRotOffset;
		}

		arm.scaleX = walkingRight ? 1 : -1;

		positionEquipment();

		sprite.scaleX = walkingRight ? 1 : -1;

		if (!fellOff) {
			var rotMultiplier = 1.0;

			if (!crouching) {
				rotSpeed *= 1.02;
			} else {
				if (crouching) {
					sprite.animation.play("crouch");
				}
				rotMultiplier = 0.4;
			}

			if (jumping) {
				sprite.animation.play("jumping");
				sprite.rotation *= 0.6;

				var maxVel = 20.;
				var d = new Point(vx, vy);
				if (d.lengthSq() > maxVel * maxVel) {
					d.normalize();
					d.scale(maxVel);
					vx = d.x;
					vy = d.y;
				}

				y += vy;
				x += vx;

				vx *= 0.9;
				rotSpeed *= 0.7;
				if (y < 0) {
					vy += gravity;
					inAir = true;
				}
				if (inAir && y >= 0) {
					jumping = false;
					sprite.animation.play("left");
				}

				x = Math.max(32, Math.min(Const.GAP_SIZE - 32, x));
			} else {
				rotSpeed = Math.min(Math.max(-maxRotSpeed, rotSpeed), maxRotSpeed);

				sprite.rotation += rotSpeed * rotMultiplier;

				x += vx;
				vx *= 0.5;

				ay += (offsetY - oy) * 0.1;

				vy += ay;

				ay *= 0.8;
				vy *= 0.5;

				oy += vy;

				y = Math.round(Math.sin(Math.PI * (x / Const.GAP_SIZE)) * 30 + oy);

				if (Math.abs(sprite.rotation) > rotUntilFallOff) {
					onDied();
				}

				if (walkingRight) {
					if (x >= Const.GAP_SIZE) {
						x = Const.GAP_SIZE;
						walkingRight = false;
						
						giveGun();
						dropSword();
					}
				} else if (x <= 0) {
					x = 0;
					walkingRight = true;
					
					giveSword();
					dropGun();
				}
			}
		} else {
			vy += 0.2; 
			y += vy;
			sprite.rotation += rotSpeed;
		}
	}
}