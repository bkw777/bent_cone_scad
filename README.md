# bent_cone_scad
OpenSCAD module to create a bent cone

![](bent_cone_demo.png)
![](bent_cone_demo_1.png)
![](bent_cone_demo_2.png)
![](bent_cone_demo_3.png)

## bent_cone()
Creates a curved cylinder or cone.  
Like cylinder() in that d1 and d2 describe two circles at the ends, and they may be different diameters to make a cone rather than a cylinder.  
but where the centers of the circles in cylinder() follow a straight line path described by height h,  
the centers of the circles in bent_cone() follow an arc path described by radius r and angle a.

r = main arc path radius (d2/2)  
a = main arc path angle (90)  
d1 = small end outside diameter (10)  
d2 = large end outside diameter (d1)  
w1 = small end wall thickness (0)  
w2 = large end wall thickness (w1)  
<ul>
0 = solid object<br>
>0 = hollow tube
</ul>

e1 = small end extension (0)  
e2 = large end extension (0)  
p = main arc path alignment relative to the body ("center")  
<ul>
"center" = the main arc defines the center of the tube<br>
"inside" = the main arc defines the concave/inside side of the tube (the tube hugs the outside of a cylinder)<br>
"outside" = the main arc defines the convex/outside side of the tube (the tube hugs the inside of a cylinder)
</ul>

$fn = used to size the main arc segments the same as normal cylinders. If $fn is not set, 36 is used.
