// bent_cone.scad - Brian K. White - b.kenyon.w@gmail.com - licenced CC-BY-SA

// Like cylinder(), in that d1 and d2 define two circles with a solid filled between them
// But where the centers of the circles in cylinder() follow a straight line path described by "h" (height),
// the centers of the circles in bent_cone() follow an arc path described by "r" (radius) and "a" (angle).
//
// bent_cone(r,a,d1,d2,w1,w2,e1,e2,p)
//   r = main arc radius (d2/2)
//   a = main arc angle (90)
//   d1 = small end outside diameter (10)
//   d2 = large end outside diameter (d1)
//   w1 = small end wall thickness (0)
//   w2 = large end wall thickness (w1)
//     0 = solid object
//     >0 = hollow tube
//   e1 = small end extension (0)
//   e2 = large end extension (0)
//   p = main arc path alignment relative to the body ("center")
//     "center" (or "" or anything else) = the main arc defines the center of the tube
//     "inside" = the main arc defines the concave side of the tube (the tube hugs the outside of a cylinder)
//     "outside" = the main arc defines the convex side of the tube (the tube hugs the inside of a cylinder)
//   $fn = used to size the main arc segments the same as normal cylinders. If $fn is not set, 36 is used.

// TODO - different math so that both the inside and outside curves end in tangents for smoother transition
// ie: instead of just simply increasing the cross section diameter linearly like a cone (if the path were straight)
// create essentially the effect of both p="inside" and p="outside" at the same time.

// demo
/*
r = 40;   // main arc path radius
a = 90;   // main arc path angle
d1 = 10;  // small end outside diameter
w1 = 1;   // small end wall thickness
d2 = 30;  // large end outside diameter
w2 = 1;   // large end wall thickness
e1 = 0;   // small end extension
e2 = 0;   // large end extension
$fn = 64;

translate([0,-d2*2,0])
 bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,e1=e1,e2=e2,p="inside");

bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,e1=e1,e2=e2);
translate([r,0,0]) rotate([90,0,0]) %cylinder(r=r,h=d2*6,center=true);

translate([0,d2*2,0])
 bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,e1=e1,e2=e2,p="outside");
*/

module bent_cone(d1=10,d2=0,a=90,r=0,e1=0,e2=0,w1=0,w2=-1,p="center") {
 o=0.01;
 assert(d1>0);
 _d2 = d2>d1 ? d2 : d1;    // d2 default = d1
 _r = r>0 ? r : _d2/2;     // r default = d2/2
 _w2 = w2>-1 ? w2 : w1;    // w2 default = w1
 _r1c =                    // r1 for cut object offset by w1 according to p
  p == "inside" ? _r + w1:
  p == "outside" ? _r - w1:
  _r;
 _r2c =                    // r2 for cut object offset by w2 according to p
  p == "inside" ? _r + _w2:
  p == "outside" ? _r - _w2:
  _r;
 _t =                      // position of cut object offset by w1 according to p
  p == "inside" ? -w1 :
  p == "outside" ? w1 :
  0;

 if(w1>0 || _w2>0)
  difference() {
   arc_cylinder(d1=d1,d2=_d2,a=a,r1=_r,e1=e1,e2=e2,p=p);
   translate([_t,0,0])
    arc_cylinder(d1=d1-w1*2,d2=_d2-_w2*2,a=a,r1=_r1c,r2=_r2c,e1=e1+o,e2=e2+o,p=p);
  }
 else
  arc_cylinder(d1=d1,d2=_d2,a=a,r1=_r,e1=e1,e2=e2,p=p);
}

module arc_cylinder(d1=10,d2=0,a=90,r1=0,r2=0,e1=0,e2=0,p="center") {
 c = 0.001;                // thickness of cylinder ends of hull
 _fn = $fn>0 ? $fn : 36;   // $fn default = 36
 fn = _fn / (360/a);       // apply $fn to the main arc
 ns = fn-1;                // number of segments
 _d2 = d2>d1 ? d2 : d1;    // d2 default = d1
 _r1 = r1>0 ? r1 : _d2/2;  // r1 default = d2/2
 _r2 = r2>0 ? r2 : _r1;    // r2 default = r1
 as = a / fn;              // rotation angle per segment
 ds = _d2>d1 ? (_d2-d1) / fn : 0; // diameter increase per segment
 rs =                      // radius change per segment
  _r2>_r1 ? (_r2-_r1)/fn :
  _r1>_r2 ? -(_r1-_r2)/fn :
  0;

 translate([_r1,0,0])
  for (i = [0:ns]) {
   aa = as * i;       // rotation angle a
   ab = aa + as;      // rotation angle b
   da = d1 + ds * i;  // diameter a
   db = da + ds;      // diameter b
   ra = _r1 + rs * i; // radius a
   rb = ra + rs;      // radius b
   ta =               // translation a
    p=="inside" ? -ra - da/2 :
    p=="outside" ? -ra + da/2 :
    -_r1;
   tb =               // translation b
    p=="inside" ? -rb - db/2 :
    p=="outside" ? -rb + db/2 :
    -_r1;

   // one segment
   hull() {
    rotate([0,aa,0])
     translate([ta,0,0])
      cylinder(h=c,d=da,center=true,$fn=_fn);
    rotate([0,ab,0])
     translate([tb,0,0]) {
      cylinder(h=c,d=db,center=true,$fn=_fn);
     }
   }
   // extend small end
   if(i==0)
    rotate([0,aa,0])
     translate([ta,0,-e1/2])
      cylinder(h=e1+c,d=da,center=true,$fn=_fn);
   // extend large end
   if(i>=ns)
    rotate([0,ab,0])
     translate([tb,0,e2/2-c/2])
      cylinder(h=e2+c,d=db,center=true,$fn=_fn);
  }
}
