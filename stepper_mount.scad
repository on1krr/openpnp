//NOTE : Bearing top surface is 13mm above top of extrusion
//       Also need to take into account distance to top of "belt grab"

include <fillet.scad>;

extrusion = "motor";
bearing = "mgn12h";
stepper = "nema17";
teeth = 50;

motor_x = 75;
motor_y = 42;

idle_x = 50;
idle_y = 27.5;
idle_d = 15;
idle_mount_d = 3;

cross_shaft_d = 5;
bearing_id = 10;
bearing_od = 20;
bearing_t = 5;

make_motor = 0;
make_idler = 1;
make = "idler";  //"motor", "motor2", "idler", "passive", "passive2"

function mount_table(idx) =
             //[ hat_w, hat_t, base_t, base_w1, base_l1, base_w2, base_l2,     base_r] 
idx==2020     ?[     6,   3.5,    4.0,    0.0,     25.0,                       2.0   ]:
idx=="motor"  ?[     6,   3.5,    4.0,    40.0,    40.0,    65.0,    60.0,     4.0   ]:
idx==3030     ?[     8,   1.7,    7.0,    16.0,     2.0,      2.0   ]:
idx==4040     ?[    10,   5.0,    7.0,    19.0,     2.0,      2.0   ]: //4040 not proven
"Error";

mount_dimensions=mount_table(extrusion);
hat_w    = mount_dimensions[0];
hat_t    = mount_dimensions[1];
base_t   = mount_dimensions[2];
base_w1  = mount_dimensions[3];
base_l1  = mount_dimensions[4];
base_w2  = mount_dimensions[5];
base_l2  = mount_dimensions[6];
base_r   = mount_dimensions[7];

function stepper_table(idx) =
              //[   W,      H,      C,    M  ] 
idx=="nema17"  ?[  42.0,   22.0,   23.0,  3  ]:
"Error";

stepper_dimensions     = stepper_table(stepper);
stepper_body           = stepper_dimensions[0];
stepper_center_hole_d  = stepper_dimensions[1];
stepper_mount_r        = pow(2*pow(stepper_dimensions[2],2),0.5)/2;
stepper_mount_hole_d   = stepper_dimensions[3];

extrude_step = 10;
extrude_base = 20;

slot_w = hat_w;
slot_offset = (extrude_base - slot_w)/2;

echo("base_w = ",base_w1);
echo("slot_w = ",slot_w);
echo("slot_offset = ",slot_offset);

base_points =  [ [0,0], [0,base_w1], [base_l1,base_w1], [base_l1,base_w2],[base_l1+base_l2,base_w2], [base_l1+base_l2,0]];

$fn=60;

remove_center = [ [0,base_w1/2-slot_offset,base_t], [0,base_w1/2+slot_offset,base_t],
                 [base_l1,base_w1/2+slot_offset,base_t], [base_l1,base_w1/2-slot_offset,base_t] ];

remove_lower = [ [0,base_w1/2-extrude_base,base_t], [0,base_w1/2-extrude_base+slot_offset,base_t],
                 [base_l1,base_w1/2-extrude_base+slot_offset,base_t], [base_l1,base_w1/2-extrude_base,base_t] ];

remove_upper = [ [0,base_w1/2+extrude_base,base_t], [0,base_w1/2+extrude_base-slot_offset,base_t],
                 [base_l1,base_w1/2+extrude_base-slot_offset,base_t], [base_l1,base_w1/2+extrude_base,base_t] ];


module rounded_box(points, radius, height){
    hull(){
        for (p = points){
            translate(p) cylinder(r=radius, h=height, $fn=60);
        }
    }
}

module nema_mount(x=0,y=0,z=0) {
    translate([x,y,z]) {
        cylinder(d=stepper_center_hole_d+0.5, h=20, center=true);
        for (i =[0:3]) {
            rotate([0,0,45+i*90]) translate([0,stepper_mount_r,0]) cylinder(d=stepper_mount_hole_d+0.2, h=20, center=true);
        }
    }
}

/*
difference(){
    union() {
        // round all vertices and preserve polygon dimensions
        linear_extrude(height=base_t+hat_t) {
            offset(-base_r,$fn=24) offset(base_r,$fn=24)
            offset(base_r,$fn=24) offset(-base_r,$fn=24) polygon(base_points);
        }
        //add mounting features for bearing
        translate([motor_x,motor_y,-10])cylinder(d=20, h=10);
    }
*/

difference(){
    if (make == "idler") {
        fillet(r=4,steps=5) {
            // round all vertices and preserve polygon dimensions
            linear_extrude(height=base_t+hat_t) {
                offset(-base_r,$fn=24) offset(base_r,$fn=24)
                offset(base_r,$fn=24) offset(-base_r,$fn=24) polygon(base_points);
            }
            //add mounting features for bearing
            translate([motor_x,motor_y,base_t+hat_t])cylinder(d=bearing_od, h=bearing_t);
        }
    }
    if (make == "motor" || make == "motor2" || make == "passive" || make == "passive2") {
        union() {
            // round all vertices and preserve polygon dimensions
            linear_extrude(height=base_t+hat_t) {
                offset(-base_r,$fn=24) offset(base_r,$fn=24)
                offset(base_r,$fn=24) offset(-base_r,$fn=24) polygon(base_points);
            }        
        }
    }
    
    //extrusion clear out
    if (make == "motor" || make == "passive2") {
        rounded_box(remove_center,0.01,hat_t+0.01);
        rounded_box(remove_lower ,0.01,hat_t+0.01);
        rounded_box(remove_upper ,0.01,hat_t+0.01);
    }
    if (make == "idler" || make == "passive" || make == "motor2") {
        translate([0,0,-base_t-0.01]) {
            rounded_box(remove_center,0.01,hat_t+0.01);
            rounded_box(remove_lower ,0.01,hat_t+0.01);
            rounded_box(remove_upper ,0.01,hat_t+0.01);
        }
    }
    
    
    //add mounting features for stepper
    if (make == "motor" || make == "motor2") {
        nema_mount(motor_x,motor_y,0);
    }

    if (make == "idler") {
        //remove bearing id
        translate([motor_x,motor_y,base_t+hat_t])cylinder(d=bearing_id, h=bearing_t+0.1);

        //remove cross shaft od
        translate([motor_x,motor_y,0-0.1])cylinder(d=cross_shaft_d, h=base_t+hat_t+bearing_t+0.2);
    }
        

    if (make == "passive" || make == "passive2") {
        //add mounting hole for idler
        translate([motor_x,motor_y,0-0.1]) cylinder(d=idle_mount_d+0.2, h=base_t+hat_t+0.2);
    }
    
    //add mounting hole for idler
    translate([idle_x,idle_y,0]) cylinder(d=idle_mount_d+0.2, h=base_t+hat_t+0.1, center = true);

}


    echo("Belt Pitch Diameter", teeth*2/3.1415);
    echo("Belt Centerline above top of extrusion",teeth*2/3.1415/2+motor_y-40); 
    //Motor Pulley
    //color([0,1,0]) translate([motor_x,motor_y,10]) cylinder(d=teeth*2/3.1415, h=5, center=true);
    //echo("Idler Bottom", idle_y-idle_d/2);
    //Idler Pulley
    //color([1,0,0]) translate([idle_x,idle_y,10]) cylinder(d=idle_d, h=5, center=true);

