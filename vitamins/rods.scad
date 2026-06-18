// vitamins/rods.scad - Local rod and lead-screw types backed by NopSCADlib's rod vitamins.
// Mirrors the local vitamin extension files: include the library module provider, then add project-specific
// type constants that assemblies pass to NopSCADlib's rod() and leadscrew() modules.
//
// 로드/리드스크류 타입 — NopSCADlib rod.scad의 rod(), studding(), leadscrew() 모듈은 그대로 쓰고,
// 프로젝트별 사양은 pillars.scad / pulleys.scad처럼 상수로 둔다.

include <NopSCADlib/vitamins/rod.scad>

//                   code            diameter  length
J1_guide_rod = ["J1_guide_rod",      8,        300];

//                       code               diameter  length  lead  starts
T8x2_lead_screw = ["T8x2_lead_screw",        8,       269.5, 2,    1];

smooth_rods = [J1_guide_rod];
lead_screws = [T8x2_lead_screw];

function smooth_rod_diameter(type) = type[1];
function smooth_rod_length(type)   = type[2];

function lead_screw_diameter(type) = type[1];
function lead_screw_length(type)   = type[2];
function lead_screw_lead(type)     = type[3];
function lead_screw_starts(type)   = type[4];
