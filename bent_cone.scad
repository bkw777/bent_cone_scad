// bent_cone.scad - Brian K. White - b.kenyon.w@gmail.com - licenced CC-BY-SA
// arc_cylinder() and arc_tube()

// bent_cone() is like cylinder()
// where d1 and d2 describe two circles at the ends
// but where the centers of the circles in cylinder() follow a straight line path described by height h,
// the centers of the circles in bent_cone() follow an arc path described by radius r and degrees a.
//
// parameters:
// d1 = small-end outside diameter (required)
// d2 = large-end outside diameter
// r = main arc radius
// a = main arc angle
// e1 = extend the small end with a normal cylinder this long
// e2 = extend the large end with a normal cylinder this long
// p = main arc path alignment relative to the body
//   "center" (default) = the main arc defines the center of the tube
//   "inside" = the main arc defines the concave side of the tube (the tube hugs the outside of a cylinder)
//   "outside" = the main arc defines the convex side of the tube (the tube hugs the inside of a cylinder)
// w = wall thickness
//   0(default) = solid object
//   >0 = hollow tube
// $fn = used to size the main arc segments the same as normal cylinders. If $fn is not set, 36 is used.

// TODO - allow the wall thickness to change along the way too

// demo
/*
od_small = 10;
od_large = 30;
arc_radius = 40;
arc_angle = 90;
wall_thickness = 1;
end_ext=0;
$fn = 64;

translate([0,-od_large*2,0])
 bent_cone(d1=od_small,d2=od_large,r=arc_radius,e1=end_ext,e2=end_ext,p="inside",w=wall_thickness);

bent_cone(d1=od_small,d2=od_large,r=arc_radius,e1=end_ext,e2=end_ext,w=wall_thickness);
translate([arc_radius,0,0]) rotate([90,0,0]) %cylinder(r=arc_radius,h=od_large*6,center=true);

translate([0,od_large*2,0])
 bent_cone(d1=od_small,d2=od_large,r=arc_radius,e1=end_ext,e2=end_ext,p="outside",w=wall_thickness);
*/

module bent_cone(d1,d2=0,a=90,r=0,e1=0,e2=0,w=0,p="center") {
 o=0.01;
 assert(d1>0);
 _d2 = d2>0 ? d2 : d1;  // d2 default = d1
 _r = r>0 ? r : _d2/2;  // r default = d2/2
 _r2 =                  // r for cut object offset by w according to p
  p == "inside" ? _r + w:
  p == "outside" ? _r - w:
  _r;
 _t =                   // position of cut object offset by w according to p
  p == "inside" ? -w :
  p == "outside" ? w :
  0;

 if(w>0)
  difference() {
   arc_cylinder(d1=d1,d2=_d2,a=a,r=_r,e1=e1,e2=e2,p=p);
   translate([_t,0,0])
    arc_cylinder(d1=d1-w*2,d2=_d2-w*2,a=a,r=_r2,e1=e1+o,e2=e2+o,p=p);
  }
 else
  arc_cylinder(d1=d1,d2=_d2,a=a,r=_r,e1=e1,e2=e2,p=p);

}

module arc_cylinder(d1,d2=0,a=90,r=0,e1=0,e2=0,p="center") {
 c = 0.001;              // thickness of cylinder ends of hull
 assert(d1>0);
 _d2 = d2>0 ? d2 : d1;   // d2 default = d1
 _r = r>0 ? r : _d2/2;   // r default = d2/2
 _fn = $fn>0 ? $fn : 36; // $fn default = 36
 fn = _fn / (360/a);     // apply $fn to the main arc
 rs = a / fn;            // rotation angle per segment
 ds = (d2-d1) / fn;      // diameter increase per segment
 ns = fn-1;              // number of segments

 translate([_r,0,0])
  for (i = [0:ns]) {
   ra = rs * i;      // rotation angle a
   rb = ra + rs;     // rotation angle b
   da = d1 + ds * i; // diameter a
   db = da + ds;     // diameter b
   ta =              // translation a
    p=="inside" ? -_r - da/2 :
    p=="outside" ? -_r + da/2 :
    -_r;
   tb =              // translation b
    p=="inside" ? -_r - db/2 :
    p=="outside" ? -_r + db/2 :
    -_r;

   // one segment
   hull() {
    rotate([0,ra,0])
     translate([ta,0,0])
      cylinder(h=c,d=da,center=true,$fn=_fn);
    rotate([0,rb,0])
     translate([tb,0,0]) {
      cylinder(h=c,d=db,center=true,$fn=_fn);
     }
   }
   // extend small end
   if(i==0)
    rotate([0,ra,0])
     translate([ta,0,-e1/2])
      cylinder(h=e1+c,d=da,center=true,$fn=_fn);
   // extend large end
   if(i>=ns)
    rotate([0,rb,0])
     translate([tb,0,e2/2-c/2])
      cylinder(h=e2+c,d=db,center=true,$fn=_fn);
  }
}
