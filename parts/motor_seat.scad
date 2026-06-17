// parts/motor_seat.scad - NEMA stepper-motor seat geometry cut into printed plates (NopSCADlib printed-part style).
// Negative for difference(), parameterised by a NopSCADlib NEMA type: a body recess shaped to NEMA_outline that
// captures the motor end cap, a centering boss recess (the deepest cut, leaving only seat_shoulder_thickness behind
// as the axial back-stop) that aligns the spindle, a shaft clearance bore through that shoulder, and four
// mounting-screw clearance holes.
// from_top selects which face the motor mounts onto, so plates carrying the motor on either side can share it.
//
// NEMA 스텝모터를 판재에 앉히기 위해 깎는 음형(negative) 제작 형상이다. 구입 부품(vitamin)이 아니라 가공 형상이라 parts/에 둔다.
// 치수는 NopSCADlib NEMA 타입(NEMA17_47 등)에서 접근자(NEMA_*, NEMA_outline)로 읽어 하드코딩을 피한다.
// 바디 리세스(NEMA_outline 외곽으로 끝단 안착) + 센터링 보스 리세스(가장 깊은 리세스, 바닥에 seat_shoulder_thickness만 남김) +
// 샤프트 관통 보어(그 shoulder 관통) + 마운팅 스크류 홀 4개로 이루어진다.
// from_top으로 모터가 붙는 면을 골라, 모터를 어느 면에 다는 판이든 같은 모듈을 공유한다.

include <../config.scad>

//! 모터 페이스가 판 표면에서 내려앉는 깊이 — 센터링 보스 리세스 바닥 뒤에 seat_shoulder_thickness만 남도록 잡는다.
function nema_motor_seat_face_inset(type, part_thickness) =
    part_thickness - seat_shoulder_thickness - NEMA_boss_height(type);

//! NEMA 모터 시트(motor seat) 음형(negative) — 원점에서 바디 리세스 + 센터링 보스 리세스 + 샤프트 보어 + 스크류 홀. difference() 피연산자.
//! NEMA_outline 리세스가 끝단을 받고, 가장 깊은 보스 리세스가 센터링 보스를 꼭 물어 축을 정렬하며 바닥에 seat_shoulder_thickness만 남긴다. 샤프트는 그 shoulder를 관통해 반대 면으로 나간다.
//! from_top=false면 바닥면, true면 윗면으로 열린다(판 중립면 기준 대칭).
module nema_motor_seat_pocket(type, part_thickness, from_top = false) {
    boss_height = NEMA_boss_height(type);
    face_inset = nema_motor_seat_face_inset(type, part_thickness);
    boss_recess_bottom_z = part_thickness - seat_shoulder_thickness;

    // 가장 깊은 보스 리세스가 바닥에 seat_shoulder_thickness만 남기려면, 바디 리세스 + 보스 높이가 들어갈 여유가 있어야 한다.
    assert(face_inset > 0,
           "part_thickness는 seat_shoulder_thickness + 보스 높이(NEMA_boss_height)보다 커야 한다");

    // 바닥면 기준 음형 — 바디·보스 리세스가 바닥면에 열리고 샤프트는 반대 면으로 관통한다.
    // from_top이면 판 중립면 기준으로 뒤집어 윗면으로 연다(모든 시트 모듈이 쓰는 동일 패턴).
    module pocket() {
        // 바디 리세스 깊이 — 모터 페이스가 판 표면에서 내려앉는 깊이이며, seat shoulder 자체가 아니라 남은 깊이에서 계산한다.
        body_recess_depth = face_inset;

        // 바디 리세스(body recess) — 모터 외곽(NEMA_outline: 모서리 둥근 사각)을 따라 끝단을 받아 회전(rotation)을 잡는다.
        // clearance만큼 키워 압입이 아닌 헐거운 끼움(slip fit)으로 둔다.
        translate_z(-eps)
            linear_extrude(body_recess_depth + eps)
                offset(r = clearance) NEMA_outline(type);

        // 센터링 보스 리세스(centering boss recess, 가장 깊은 리세스) — 모터 페이스 중앙의 센터링 보스(centering boss)를
        // 꼭 맞게 받아 축을 정렬하고(NEMA_big_hole = 보스+0.2 근접 끼움), 뒤에 seat_shoulder_thickness만 남긴다.
        translate_z(body_recess_depth)
            cylinder(r = NEMA_big_hole(type), h = boss_height + eps);

        // 샤프트 관통 보어(shaft clearance bore) — 남은 seat shoulder만 관통한다.
        translate_z(boss_recess_bottom_z)
            cylinder(d = NEMA_shaft_dia(type) + shaft_clearance, h = seat_shoulder_thickness + eps);

        // 마운팅 스크류 홀(mounting screw holes) — NEMA 홀 피치 코너 4곳에 모터 고정 스크류 클리어런스 홀.
        for (x = NEMA_holes(type), y = NEMA_holes(type))
            translate([x, y, -eps])
                cylinder(d = NEMA_thread_d(type) + clearance, h = part_thickness + eps * 2);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

//! NEMA 모터 시트 슬롯 음형(negative) — 모터가 travel_vector 방향으로 미끄러지도록 바디·보스·샤프트·스크류 홀을 각각 슬롯화한다.
//! 전체 시트를 hull()로 뭉개지 않고 feature별로 슬롯을 만들어, 센터링 보스와 체결 홀의 기계적 역할을 보존한다.
module nema_motor_seat_slot_pocket(type, part_thickness, travel_vector, from_top = false) {
    boss_height = NEMA_boss_height(type);
    face_inset = nema_motor_seat_face_inset(type, part_thickness);
    boss_recess_bottom_z = part_thickness - seat_shoulder_thickness;

    assert(face_inset > 0,
           "part_thickness는 seat_shoulder_thickness + 보스 높이(NEMA_boss_height)보다 커야 한다");
    assert(norm(travel_vector) > 0, "travel_vector는 0이 아니어야 한다");

    module at_slot_ends() {
        for (slot_offset = [[0, 0], travel_vector])
            translate(slot_offset)
                children();
    }

    module pocket() {
        body_recess_depth = face_inset;

        // 바디 슬롯(body slot) — 모터 끝단 외곽이 Y 방향으로 미끄러질 수 있게 NEMA_outline 리세스를 늘린다.
        translate_z(-eps)
            linear_extrude(body_recess_depth + eps)
                hull()
                    at_slot_ends()
                        offset(r = clearance) NEMA_outline(type);

        // 센터링 보스 슬롯(centering-boss slot) — 보스가 슬롯 전 구간에서 축 정렬 기준으로 작동하도록 한다.
        translate_z(body_recess_depth)
            hull()
                at_slot_ends()
                    cylinder(r = NEMA_big_hole(type), h = boss_height + eps);

        // 샤프트 슬롯(shaft slot) — 남은 seat shoulder를 통과하는 축 경로도 모터 이동량만큼 열어준다.
        translate_z(boss_recess_bottom_z)
            hull()
                at_slot_ends()
                    cylinder(d = NEMA_shaft_dia(type) + shaft_clearance, h = seat_shoulder_thickness + eps);

        // 마운팅 스크류 슬롯(mounting-screw slots) — 모터를 이동시킨 뒤 같은 M3 체결구로 고정한다.
        for (x = NEMA_holes(type), y = NEMA_holes(type))
            hull()
                at_slot_ends()
                    translate([x, y, -eps])
                        cylinder(d = NEMA_thread_d(type) + clearance, h = part_thickness + eps * 2);
    }

    if (from_top)
        translate_z(part_thickness) mirror([0, 0, 1]) pocket();
    else
        pocket();
}

// 미리보기(preview) — 시험 블록 양쪽에 깎은 모터 시트(음형): 왼쪽 바닥 열림, 오른쪽 윗면 열림.
if ($preview) {
    difference() {
        cylinder(h = 10, d = NEMA_radius(NEMA17_47) * 2 + 6);
        nema_motor_seat_pocket(NEMA17_47, part_thickness = 10);
    }
    translate([NEMA_radius(NEMA17_47) * 2 + 16, 0, 0])
        difference() {
            cylinder(h = 10, d = NEMA_radius(NEMA17_47) * 2 + 6);
            nema_motor_seat_pocket(NEMA17_47, part_thickness = 10, from_top = true);
        }
}
