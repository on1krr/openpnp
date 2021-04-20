extrusion = 2040;
bearing = "mgn12h";

function mount_table(idx) =
          //[ hat_w, hat_t, base_t, base_w, base_l, base_r] 
idx==2020  ?[   6,   3.5,    4.0,   30.0,   25.0,   2.0   ]:
idx==2040  ?[   6,   3.5,    4.0,   50.0,   60.0,   2.0   ]:
idx==3030  ?[   8,   1.7,    7.0,   16.0,   2.0,    2.0   ]:
idx==4040  ?[  10,   5.0,    7.0,   19.0,   2.0,    2.0   ]: //4040 not proven
"Error";

mount_dimensions=mount_table(extrusion);
hat_w   = mount_dimensions[0];
hat_t   = mount_dimensions[1];
base_t  = mount_dimensions[2];
base_w  = mount_dimensions[3];
base_l  = mount_dimensions[4];
base_r  = mount_dimensions[5];


function bearing_table(idx) =
              //[     W,    B,    C,     L,   M  ] 
idx=="mgn12h"  ?[  27.0, 20.0, 20.0,  45.4,   3  ]:
"Error";

bearing_dimensions=bearing_table(bearing);
bearing_W  = bearing_dimensions[0];
bearing_B  = bearing_dimensions[1];
bearing_C  = bearing_dimensions[2];
bearing_L  = bearing_dimensions[3];
bearing_screw  = bearing_dimensions[4];

screw_head_dia  = bearing_dimensions[4] * 1.5;
screw_head_l    = bearing_dimensions[4] * 1.25;

//extrude_step = 10-hat_w/2;
extrude_step = 10;
extrude_base = 20;

slot_w = hat_w;
slot_offset = (extrude_base - slot_w)/2;

echo("base_w = ",base_w);
echo("slot_w = ",slot_w);
echo("slot_offset = ",slot_offset);


base_points =  [ [0+base_r,0+base_r,0], [0+base_r,base_w-base_r,0], [base_l-base_r,base_w-base_r,0], [base_l-base_r,0+base_r,0] ];

inset_points = [ [0,base_w/2-extrude_step-hat_w/2,base_t], [0,base_w/2-extrude_step+hat_w/2,base_t],
                 [base_l,base_w/2-extrude_step+hat_w/2,base_t], [base_l,base_w/2-extrude_step-hat_w/2,base_t] ];

inset_points2 = [ [0,base_w/2+extrude_step-hat_w/2,base_t], [0,base_w/2+extrude_step+hat_w/2,base_t],
                 [base_l,base_w/2+extrude_step+hat_w/2,base_t], [base_l,base_w/2+extrude_step-hat_w/2,base_t] ];

remove_center = [ [0,base_w/2-slot_offset,base_t], [0,base_w/2+slot_offset,base_t],
                 [base_l,base_w/2+slot_offset,base_t], [base_l,base_w/2-slot_offset,base_t] ];

remove_lower = [ [0,base_w/2-extrude_base,base_t], [0,base_w/2-extrude_base+slot_offset,base_t],
                 [base_l,base_w/2-extrude_base+slot_offset,base_t], [base_l,base_w/2-extrude_base,base_t] ];

remove_upper = [ [0,base_w/2+extrude_base,base_t], [0,base_w/2+extrude_base-slot_offset,base_t],
                 [base_l,base_w/2+extrude_base-slot_offset,base_t], [base_l,base_w/2+extrude_base,base_t] ];

module rounded_box(points, radius, height){
    hull(){
        for (p = points){
            translate(p) cylinder(r=radius, h=height, $fn=60);
        }
    }
}

difference(){
    union() {
        rounded_box(base_points,2.0,base_t+hat_t);
    }
    //extrusion clear out
    rounded_box(remove_center,0.01,hat_t+0.01);
    rounded_box(remove_lower,0.01,hat_t+0.01);
    rounded_box(remove_upper,0.01,hat_t+0.01);
    
    // mounting holes for linear bearing
    rotate([0,0,-90])translate([-base_w/2-bearing_B/2,base_l/2-bearing_C/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    rotate([0,0,-90])translate([-base_w/2+bearing_C/2,base_l/2-bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    rotate([0,0,-90])translate([-base_w/2-bearing_C/2,base_l/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    rotate([0,0,-90])translate([-base_w/2+bearing_C/2,base_l/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    //translate([base_l/2-bearing_C/2,base_w/2-bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    //translate([base_l/2+bearing_C/2,base_w/2-bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    //translate([base_l/2-bearing_C/2,base_w/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    //translate([base_l/2+bearing_C/2,base_w/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);

    // countersink for SHCS holes for linear bearing
    translate([base_l/2-bearing_C/2,base_w/2-bearing_B/2,base_t+hat_t-screw_head_l-0.3])cylinder(r=screw_head_dia/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([base_l/2+bearing_C/2,base_w/2-bearing_B/2,base_t+hat_t-screw_head_l-0.3])cylinder(r=screw_head_dia/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([base_l/2-bearing_C/2,base_w/2+bearing_B/2,base_t+hat_t-screw_head_l-0.3])cylinder(r=screw_head_dia/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([base_l/2+bearing_C/2,base_w/2+bearing_B/2,base_t+hat_t-screw_head_l-0.3])cylinder(r=screw_head_dia/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    
    // mounting holes for crossmember
    translate([0+(base_l/2-bearing_W/2)/2,base_w/2-bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([base_l/2+(base_l/2+bearing_W/2)/2,base_w/2-bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([0+(base_l/2-bearing_W/2)/2,base_w/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);
    translate([base_l/2+(base_l/2+bearing_W/2)/2,base_w/2+bearing_B/2,0])cylinder(r=bearing_screw/2+0.2, h=base_t+hat_t+0.01, $fn=60);

    //tnut clear out 
//    rounded_box(remove_center,0.01,hat_t+0.01);
//    rounded_box(remove_lower,0.01,hat_t+0.01);
//    rounded_box(remove_upper,0.01,hat_t+0.01);
    
    
}