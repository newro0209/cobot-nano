include <../config.scad>

module base_mounting_plate() {
    diameter = 60;
    thickness = 5;

    cylinder(h = thickness, d = diameter);
}

base_mounting_plate();
