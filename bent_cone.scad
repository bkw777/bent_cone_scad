// bent_cone.scad - Brian K. White - b.kenyon.w@gmail.com - CC-BY-SA

// Like cylinder(), in that d1 and d2 define two circles with a solid filled between them
// But where the centers of the circles in cylinder() follow a straight line path described by "h" (height),
// the centers of the circles in bent_cone() follow an arc path described by "r" (radius) and "a" (angle).
//
// bent_cone(r,a,d1,d2,w1,w2,p,fn)
//   r = main arc radius (d2/2)
//   a = main arc angle (90)
//   d1 = beginning outside diameter (10)
//   d2 = ending outside diameter (d1)
//   w1 = beginning wall thickness (0)
//   w2 = ending wall thickness (w1)
//     0 = solid object
//     >0 = hollow tube
//   p = main arc path alignment relative to the body ("center")
//     "center" (or "" or anything else) = the main arc defines the center of the tube
//     "inside" = the main arc defines the concave side of the tube (the tube hugs the outside of a cylinder)
//     "outside" = the main arc defines the convex side of the tube (the tube hugs the inside of a cylinder)
//   fn = virtual $fn just for the main arc ($fn, else 36)

// TODO
//   * different math so that both the inside and outside curves end in tangents for smoother transition
//     essentially get p="inside" and p="outside" at the same time, and probably obsolete the p parameter
//   * replace this initial quick & dirty cylinder-cylinder-hull implementation with something using sweep() and skin()
//   * refactor p and r2 away into a single more generic offset param
//   * properly handle remainder angle when a doesn't evenly divide by fn

module bent_cone(d1=10,d2=-1,a=90,r=-1,w1=0,w2=-1,p="center",fn=0) {
 assert(a>0,"bent_cone()");
 _d2 = d2>-1 ? d2 : d1;         // d2 default = d1
 _r = r>-1 ? r : max(d1,_d2)/2; // r default = max(d1,d2)/2

 if(w1>0 || w2>0) {
  // hollow
  _w2 = w2>-1 ? w2 : w1;         // w2 default = w1
  _r1c =                         // r1 for cut object offset by w1 according to p
   p == "inside" ? _r + w1:
   p == "outside" ? _r - w1:
   _r;
  _r2c =                         // r2 for cut object offset by w2 according to p
   p == "inside" ? _r + _w2:
   p == "outside" ? _r - _w2:
   _r;
  _t =                           // position of cut object offset by w1 according to p
   p == "inside" ? -w1 :
   p == "outside" ? w1 :
   0;
  difference() {
   arc_cylinder(d1=d1,d2=_d2,a=a,r1=_r,p=p,fn=fn);
   translate([_t,0,0])
    arc_cylinder(d1=d1-w1*2,d2=_d2-_w2*2,a=a,r1=_r1c,r2=_r2c,p=p,e=true,fn=fn);
  }
 }
 else
  // solid
  arc_cylinder(d1=d1,d2=_d2,a=a,r1=_r,p=p,fn=fn);
}

module arc_cylinder(d1=10,d2=-1,a=90,r1=-1,r2=-1,p="center",e=false,fn=0) {
 assert(a>0,"arc_cylinder()");
 c = 1/256;                // thickness of cylinder ends of hull (tiny even fp value)
 _fn =                     // fn default = $fn else 36
  fn>0 ? fn :
  $fn>0 ? $fn :
  36;
 afn = _fn/(360/a);        // main arc fn
 ns = afn-1;               // number of segments
 _d2 = d2>-1 ? d2 : d1;    // d2 default = d1
 _r1 = r1>-1 ? r1 : max(d1,_d2)/2; // r1 default = max(d1,d2)/2
 _r2 = r2>-1 ? r2 : _r1;   // r2 default = r1
 as = a / afn;             // rotation angle per segment
 ds =                      // diameter change per segment
  _d2>d1 ? (_d2-d1) / afn :
  d1>_d2 ? -(d1-_d2) / afn :
  0;
 rs =                      // radius change per segment
  _r2>_r1 ? (_r2-_r1)/afn :
  _r1>_r2 ? -(_r1-_r2)/afn :
  0;

 translate([_r1,0,0])
  for (i = [0:ns]) {
   aa = as * i;       // rotation angle a
   ab = aa + as;      // rotation angle b
   da = d1 + ds * i;  // diameter a
   db = da + ds;      // diameter b
   ra = _r1 + rs * i; // radius a
   rb = ra + rs;      // radius b
   xa =               // ra & da to x translation
    p=="inside" ? -ra - da/2 :
    p=="outside" ? -ra + da/2 :
    -_r1;
   xb =               // rb & db to x translation
    p=="inside" ? -rb - db/2 :
    p=="outside" ? -rb + db/2 :
    -_r1;
   za = i>0 || e ? 0 : c/2;   // disc a elevation
   zb = i<ns || e ? 0 : -c/2; // disc b elevation

   // one segment
   hull() {
    rotate([0,aa,0])
     translate([xa,0,za])
      cylinder(h=c,d=da,center=true);
    rotate([0,ab,0])
     translate([xb,0,zb]) {
      cylinder(h=c,d=db,center=true);
     }
   }
  }
}
