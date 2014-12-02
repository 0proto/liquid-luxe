package;

import hxmath.math.Vector2;
import haxe.ds.ObjectMap;

class SpartialHash<T>
{
	var map: Map<Int, Array<T>>;
	var objects: ObjectMap<T, Int>;
	var cellSize: Int;

	public function new(cellSize: Int){
		this.cellSize = cellSize;
		map = new Map<Int, Array<T>>();
		objects = new ObjectMap<T, Int>();
	}

	public function insert(vector: Vector2, obj: T)
	{
		var key = hash(vector);
		if (map.exists(key))
		{
			map.get(key).push(obj);
		} else 
		{
			map.set(key,new Array<T>());
			map.get(key).push(obj);
		}
		objects.set(obj,key);
	}

	public function updatePosition(vector: Vector2, obj: T)
	{
		if (objects.exists(obj))
		{
			map.get(objects.get(obj)).remove(obj);
		}
		insert(vector, obj);
	}

	public function queryPosition(vector: Vector2) : Array<T>
	{
		var key = hash(vector);
		return map.exists(key) ? map.get(key) : new Array<T>();
	}

	public function containsKey(vector: Vector2) : Bool
	{
		return map.exists(hash(vector));
	}

	public function clear()
	{
		for (i in map.keys())
		{
			//map.get(i) = null;
		}
		map = new Map<Int, Array<T>>();
		objects = new ObjectMap<T, Int>();
	}

	public function Reset()
	{
		trace("Reset!");
	}

	function hash(v:Vector2)
	{
		return ((Math.floor(v.x / cellSize) * 73856093) ^ 
				(Math.floor(v.y / cellSize) * 19349663));
	}

}