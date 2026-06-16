include <../config.scad>
use <NopSCADLib/vitamins/ball_bearings.scad>

module bearing_inner_race_boss(type, height = bearing_shoulder_thickness) {
    id = bb_bore(type) + shaft_clearance;
    od = id + bb_hub(type) + bearing_clearance;

    linear_extrude(height)
    difference() {
        circle(d = od);
        translate([0, 0, -boolean_epsilon]) circle(d = id);
    }
}

bearing_inner_race_boss(BB608);