package;

import luxe.Sprite;
import luxe.Vector;
import hxmath.math.Vector2;
import luxe.Color;

class Particle
{
	public var sprite: Sprite;
	public var trailSprite: Sprite;
	public var pos: Vector2 = new Vector2(0,0);
	public var vel: Vector2 = new Vector2(0,0);
	public var previousPosition = new Vector2(0,0);
	public var neighbors = new Array<Particle>();
	public var hash: String;
	var maxNeighbors = 5;
	public static var neighborDistance = 15;

	public function new(x: Float, y: Float){
		pos = new Vector2(x,y);
		hash = Luxe.utils.uniqueid();
		sprite = new Sprite({
			name: 'drop'+hash,
			pos: new Vector(x,y),
			color: new Color().rgb(0x09FdFF),
			texture: Luxe.loadTexture('assets/drop.png')
		});
		trailSprite = new Sprite({
			name: 'drop'+hash,
			pos: new Vector(x,y),
			color: new Color().rgb(0x09FdFF),
			texture: Luxe.loadTexture('assets/drop.png'),
			size: new Vector(20,20)
		});
	}

	public function update(dt: Float)
	{
		sprite.pos.x = pos.x;
		sprite.pos.y = pos.y;
		trailSprite.pos.x = previousPosition.x;
		trailSprite.pos.y = previousPosition.y;
	}

}