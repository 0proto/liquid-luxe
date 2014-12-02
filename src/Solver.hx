package;

import luxe.Color;
//TODO: Implement some Threading here
#if cpp
import cpp.vm.Thread;
#end
import hxmath.math.Vector2;

class Solver
{
	public var particles = new List<Particle>();
	public var springsMap = new Map<String, Spring>();
	public var flowSrc = new Vector2(10,10);
	public var fixedTimestep = 0.022;
	public static var restLength = 8.0;
	public static var H = 20.0;
	public static var H2 = H * H;
	public static var collisionForce = 0.2;
	public static var wpadding = 20;
	public static var hpadding = 20;
	public var gravity = new Vector2(0,500);
	var sHash = new SpartialHash<Particle>(18);
	var kSpring = 0.4;
	var stiffnessK = 0.904;
	var sigmaViscousity = 0.204;
	var betaViscousity = 0.304;
	var p0 = 1500;
	var maxNeighbors = 4;
	var maxParticles = 500;

	//Temporary variables
	var pressure: Float;
	var len: Int;
	var p: Float;
	var pNear: Float;
	var q: Float;
	var dx: Vector2;
	var tmpVec: Vector2;

	public function new(){
		init();
	}

	public function addParticle(x: Float, y: Float) : Particle
	{
		var d = new Particle(x,y);
		particles.add(d);
		sHash.insert(new Vector2(x,y),d);
		return d;
	}

	public function delParticle(d: Particle)
	{
		particles.remove(d);
	}

	function init()
	{
	}

	public function updateFlow()
	{
		if (particles.length >= maxParticles) 
		{ 
			return; 
		}
		addParticle(flowSrc.x,flowSrc.y);
	}

	public function getSpring(pi:Particle,pj:Particle):Spring
	{
		if (springsMap.get(pi.hash+pj.hash) != null)
		{
			return springsMap.get(pi.hash+pj.hash);
		} else if (springsMap.get(pj.hash+pi.hash) != null) {
			return springsMap.get(pj.hash+pi.hash);
		} else {
			var s = new Spring(pi,pj,restLength);
			springsMap.set(pi.hash+pj.hash,s);
			return s;
		}
	}

	public function updateSprings()
	{
		for (s in springsMap)
		{
			s.currentDistance = (s.pi.pos-s.pj.pos).length;
		}
	}

	public function springDisplacement(dt:Float)
	{
		for (s in springsMap)
		{
			if (s.currentDistance == 0)
				continue;
			var d = dt*dt*kSpring*(1 - s.restLength/Particle.neighborDistance)*(s.restLength - (s.pi.pos-s.pj.pos).length)*s.pi.pos.subtract(s.pj.pos).normal;
			s.pi.pos = s.pi.pos - 0.5*d;
			s.pj.pos = s.pj.pos + 0.5*d;
		}
	}

	public function springAdjustment(dt: Float)
	{
		springsMap = new Map<String, Spring>();
		for (i in particles)
		{
			len = i.neighbors.length;
			if (len>maxNeighbors)
				len = maxNeighbors;
			for (j in 0...len)
			{
				q = (i.pos-i.neighbors[j].pos).length / Particle.neighborDistance;
				if (q < 1)
				{
					var s = getSpring(i,i.neighbors[j]);
					var d = kSpring * (s.restLength - s.currentDistance);
					if ((i.pos-i.neighbors[j].pos).length > restLength + d)
					{
						s.restLength = s.restLength + dt*kSpring*((i.pos-i.neighbors[j].pos).length - restLength - d);
					} else if ((i.pos-i.neighbors[j].pos).length < restLength - d) {
						s.restLength = s.restLength - dt*kSpring*(restLength - d - (i.pos-i.neighbors[j].pos).length);
					}
				}
			}
		}

	}

	public function startUpdateStrings() 
	{

	}

	public function update(dt: Float)
	{	
		updateFlow();
		applyGravity(dt);
		updateSprings();
		updateNeighbors();
		applyViscosity(dt);
		moveParticles(dt);
		springAdjustment(dt);
		springDisplacement(dt);
		doubleDensityRelaxation(dt);
		computeNextVelocity(dt);
	}

	function doubleDensityRelaxation(dt: Float)
	{
		p = 0.0;
		pNear = 0.0;
		for (i in particles)
		{
			p = 0;
			pNear = 0.0;

			len = i.neighbors.length;
			if (len>maxNeighbors)
				len = maxNeighbors;

			for (j in 0...len)
			{
				q = (i.pos-i.neighbors[j].pos).length / Particle.neighborDistance;
				if (q < 1)
				{
					p = p + (1-q)*(1-q);
					pNear = pNear + (1-q)*(1-q)*(1-q);
				}
			}

			pressure = stiffnessK*(p-p0);
			pNear = stiffnessK*pNear;

			dx = Vector2.zero;
			for (j in 0...len)
			{
				q = (i.pos-i.neighbors[j].pos).length / Particle.neighborDistance;
				if (q < 1 && q>0)
				{
					tmpVec = i.pos.subtract(i.neighbors[j].pos).normal;
					var displacement = dt*dt*(pressure*(1-q)+pNear*((1-q)*(1-q)))*tmpVec;
					i.neighbors[j].pos = i.neighbors[j].pos + 0.4*displacement;
					dx = dx - 0.4*displacement;
				}
			}
			i.pos += dx;
		}
	}

	function applyViscosity(dt: Float)
	{
		for (p in particles)
		{
			len = p.neighbors.length;
			if (len>maxNeighbors)
				len = maxNeighbors;
			for (n in 0...len)
			{
				q = (p.neighbors[n].pos-p.pos).length/Particle.neighborDistance;
				if (q<1 && q>0)
				{
					tmpVec = p.pos.subtract(p.neighbors[n].pos).normal;
					var u = (p.vel - p.neighbors[n].vel).dot(tmpVec);
					if (u > 0)
					{
						var I = dt*(1-q)*(sigmaViscousity*u + betaViscousity*u*u)*tmpVec;
						p.vel -= 0.5*I;
						p.neighbors[n].vel += 0.5*I;
					}
				}
			}
		}
	}

	function applyGravity(dt: Float)
	{
		for (p in particles)
		{
			p.update(dt);
			p.vel += dt*gravity;

			if (p.pos.x+p.vel.x*dt > Luxe.screen.w || p.pos.x+p.vel.x*dt < 0)
				p.vel.x = collisionForce*(-p.vel.x);

			if (p.pos.y+p.vel.y*dt>Luxe.screen.h || p.pos.y+p.vel.y*dt<0)
				p.vel.y = collisionForce*(-p.vel.y);
		}
	}

	function moveParticles(dt: Float)
	{
		for (p in particles)
		{
			p.previousPosition = p.pos;
			p.pos += dt*p.vel;
		}
	}

	function updateNeighbors()
	{
		sHash.clear();
		for (p in particles)
		{
			sHash.insert(p.pos, p);
			p.neighbors = sHash.queryPosition(p.pos);
		}
	}

	function computeNextVelocity(dt: Float)
	{
		for (p in particles)
		{
			p.vel = (1/dt)*(p.pos - p.previousPosition);
		}
	}

}