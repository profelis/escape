package deep.h3d.extrusion;

import deep.h3d.bezier.Path;
import deep.h3d.extrusion.ExtrusionTools;
import h3d.Matrix;
import h3d.prim.Point;
import h3d.prim.Polygon;
import h3d.prim.UV;
import h3d.Vector;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */
class LatheExtrude extends Polygon
{
	var profile:Path;
	var num:Int;
	
	public function new(profile:Path, num = 8) {
		this.profile = profile;
		this.num = num;
		var points = [];
		
		var prev = [for (p in profile.pointsIterator()) ExtrusionTools.toPoint(p)];
		var a = 0.0;
		var da = 2 * Math.PI / num;
		var sn = prev.length - 1;
		
		var m = new Matrix();
		for (i in 0...num) {
			m.initRotateZ(a += da);
			var cur = [for (p in profile.pointsIterator()) ExtrusionTools.toPoint(p).transform(m)];
			for (j in 0...sn) {
				var p0 = prev[j];
				var p1 = cur[j];
				var p2 = prev[j + 1];
				var p3 = cur[j + 1];
				points.push(p0);
				points.push(p1);
				points.push(p2);
				points.push(p2);
				points.push(p1);
				points.push(p3);
			}
			prev = cur;
		}
		
		super(points);
	}
	
	public var pathTextureType:PathTextureType;
	public var latheTextureType:LatheTextureType;
	
	public function calcUVs(?ptt:PathTextureType, ?ltt:LatheTextureType) {
		if (ptt != null) pathTextureType = ptt;
		if (ltt != null) latheTextureType = ltt;
		addUVs();
	}
	
	override public function addUVs():Void {
		if (pathTextureType == null) pathTextureType = PathTextureType.FILL;
		if (latheTextureType == null) latheTextureType = LatheTextureType.FILL;
		
		tcoords = [];
		
		var vs = [0.0];
		switch (pathTextureType) {
			case PathTextureType.FILL: 
				var v = profile.length;
				var vt = 0.0;
				for (p in profile.segmentsIterator()) {
					vt += p.length / v;
					vs.push(vt);
				}
		}
		var vt = 0.0;
		
		var du = 1 / num;
		var sn = profile.pointsNum - 1;
		
		var u0 = 0.0;
		var u1 = 1.0;
		for (i in 0...num) {
			for (j in 0...sn) {
				var vs0 = 1 - vs[j];
				var vs1 = 1 - vs[j + 1];
				switch (latheTextureType) {
					case LatheTextureType.FILL:
						u0 = i * du;
						u1 = (i + 1) * du;
					case LatheTextureType.SEGMENT:
				}
				var t0 = new UV(u0, vs0);
				var t1 = new UV(u1, vs0);
				var t2 = new UV(u0, vs1);
				var t3 = new UV(u1, vs1);
				tcoords.push(t0);
				tcoords.push(t1);
				tcoords.push(t2);
				tcoords.push(t2);
				tcoords.push(t1);
				tcoords.push(t3);
			}
		}
	}
	
	var smoothNormals:Bool = true;
	
	public function calcNormals(smoothNormals = true) {
		this.smoothNormals = smoothNormals;
		addNormals();
	}
	
	override public function addNormals():Void 
	{
		if (!smoothNormals) {
			super.addNormals();
			return;
		}
		normals = [];
		
		var angles = [
			for (p in profile.segmentsIterator())
				ExtrusionTools.getLineAngles(p, true, true, false)
		];
		var allAngles:Array<Array<Point>> = [];
		var a = 0.0;
		var da = 2 * Math.PI / num;
		var sn = profile.pointsNum - 1;
		
		var m = new Matrix();
		for (i in 0...num) {
			allAngles[i] = [
				for (j in 0...sn) {
					var angle = angles[j];
					m.initRotate( -angle.y, angle.x, a);
					new Point(1, 0, 0).transform(m);
				}
			];
			a += da;
		}
		allAngles.push(allAngles[0]);
		
		for (i in 0...num) {
			var t0 = allAngles[i];
			var t1 = allAngles[i + 1];
			for (j in 0...sn) {
				var n0 = t0[j];
				var n1 = t1[j];
				normals.push(n0);
				normals.push(n1);
				normals.push(n0);
				normals.push(n0);
				normals.push(n1);
				normals.push(n1);
			}
		}
	}
}