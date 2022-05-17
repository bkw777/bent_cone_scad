// bent_cone() demo
include <BOSL2/std.scad>;

// 40mm to 60mm 90 degree fan adapter
o = 1/128;
a = 90;
d1 = 40;
b1 = 32;
m1 = 2.8;
d2 = 60;
b2 = 50;
m2 = 3.7;
r = max(d1,d2)/2;
w = 1;
ft = 3;
$fs = 0.5;

bent_cone(a=a,r=r,d1=d1,d2=d2,w=w,fn=72);

translate([0,0,-ft/2+o]) flange(s=d1,b=b1,t=ft,w=w,m=2.8);
translate([r,0,0]) rotate([0,a,0]) translate([-r,0,ft/2-o]) flange(s=d2,b=b2,t=ft,w=w,m=3.7);

module flange(s=50,b=40,t=3,w=1,m=3) {
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

module bent_cone(r=-1,a=90,d1=10,d2=20,fn=-1,w=0) {
 if(w<=0)
  _bent_cone(d1=d1,d2=d2,a=a,r=r,fn=fn);
 else
  difference(){
  _bent_cone(a=a,r=r,d1=d1,d2=d2,fn=fn);
  _bent_cone(a=a,r=r,d1=d1-w*2,d2=d2-w*2,fn=fn,e=true);
  }
}

module _bent_cone(r=-1,a=90,d1=10,d2=20,fn=-1,e=false) {
 o = 1/128;
 _r = r<0 ? max(d1,d2)/2 : r;
 _fn = fn>0 ? fn : $fn>0 ? $fn : 36;
 nv = _fn/(360/a);
 s = ((d2/d1)-1)/nv;
 T = [for(i=[0:nv]) yrot(a*i/nv,cp=[_r,0,0])*scale([1+i*s,1+i*s,1])];
 sweep(circle(d=d1),T);
 if (e) {
  cylinder(d=d1,h=o,center=true);
  translate([_r,0,0]) rotate([0,a,0]) translate([-_r,0,0]) cylinder(d=d2,h=o,center=true);
 }
}
