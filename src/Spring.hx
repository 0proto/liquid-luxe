import Particle;

class Spring {
	public var pi : Particle;
	public var pj : Particle;
	public var restLength : Float;
	public var currentDistance : Float;

	public function new(pi:Particle,pj:Particle,restLength:Float) 
	{
		this.pi = pi;
		this.pj = pj;
		this.restLength = restLength;
	}

	public function contains(p: Particle)
	{
		return ((p.hash == pi.hash) || (p.hash == pj.hash));
	}
}