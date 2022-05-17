// bent_cone() demos

use <bent_cone.scad>;

// show p="inside" vs center(default) vs outside 
/*
r = 40;   // main arc path radius
a = 90;   // main arc path angle
d1 = 10;  // beginning outside diameter
w1 = 1;   // beginning wall thickness
d2 = 30;  // ending outside diameter
w2 = w1;  // ending wall thickness
fn = 72;  // virtual $fn for big arc
$fn = 36; // $fn for everything else
$fs = 0.5;
translate([r,0,0]) rotate([90,0,0]) %cylinder(r=r,h=d2*6,center=true,$fn=fn);
bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,fn=fn);
translate([0,d2*2,0])
 bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,p="inside",fn=fn);
translate([0,-d2*2,0])
 bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w1,w2=w2,p="outside",fn=fn);
*/

// d2 smaller than d1, fn greater than $fn
//bent_cone(a=180,d1=20,d2=15,r=60,w1=0.4,fn=72,$fn=32);

// r=0 p="inside"
//bent_cone(a=180,r=0,d1=20,d2=15,w1=1,p="inside",$fs=0.5);

// 40mm to 60mm 90 degree fan adapter
o = 1/128;
a = 90;
d1 = 40;
b1 = 32;
m1 = 2.8;
d2 = 60;
b2 = 50;
m2 = 3.7;
r = d2/2;
w = 1;
ft = 3;
bent_cone(a=a,r=r,d1=d1,d2=d2,w1=w,fn=72,$fs=0.5);
translate([0,0,-ft/2+o]) flange(s=d1,b=b1,t=ft,w=w,m=2.8,$fs=0.5);
translate([r,0,0]) rotate([0,a,0]) translate([-r,0,ft/2-o]) flange(s=d2,b=b2,t=ft,w=w,m=3.7,$fs=0.5);
module flange (s=50,b=40,t=3,w=1,m=3) {
 co = b/2;
 cd = s-b;
 difference() {
  hull() {
   translate([-co,-co,0]) cylinder(h=t,d=cd,center=true);
   translate([-co,co,0]) cylinder(h=t,d=cd,center=true);
   translate([co,co,0]) cylinder(h=t,d=cd,center=true);
   translate([co,-co,0]) cylinder(h=t,d=cd,center=true);
  }
  group(){
   translate([-co,-co,0]) cylinder(h=t+1,d=m,center=true);
   translate([-co,co,0]) cylinder(h=t+1,d=m,center=true);
   translate([co,co,0]) cylinder(h=t+1,d=m,center=true);
   translate([co,-co,0]) cylinder(h=t+1,d=m,center=true);
   cylinder(h=t+1,d=s-w*2,center=true);
  }
 }
}