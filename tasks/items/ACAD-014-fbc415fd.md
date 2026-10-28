+++
schema = 1
id = "ACAD-014-fbc415fd"
title = "Correct Quaternion Julia 3D horizontal drag and fling direction"
short = "Reproduce captured quaternion camera pose, align horizontal rotation with rendered pixel motion, preserve vertical and 2D gestures."
status = "open"
goal = "APP-QUALITY-001"
section = "Now"
rank = 2000
depends_on = []
touches = ["lib/core/modules/fractal_module.dart", "lib/core/modules/fractals/quaternion_julia_3d_module.dart", "lib/features/renderer/widgets/renderer/input/gesture_handler.dart", "test/fractal/fractal_renderer_gesture_test.dart", "test/fractal/quaternion_julia_3d_drag_direction_test.dart", "integration_test/flows/quaternion_julia_3d_drag_direction_test.dart"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Shared3D gesture mapping and focused regression/render tests"
acceptance = ["Right/left drags and inertia follow finger in actual quaternion shader at captured view; vertical, viewport sensitivity and2D behavior retained."]
checks = ["Red/green gesture and numeric rendered-motion regression; analyzer/relevant tests; independent review; coordinated Android validation when free."]
exclusions = ["No shader formula rewrite, release publication, commit/push, container reset or unrelated dirty files."]
+++
- Notes: Interactive owner pi:199b38bf-567c-48f8-917b-9d43af57a87e, solewriter for6ownedpaths; no Gitindex/HEAD writes. Report2026-10-28 QuaternionJulia3D rx0.2501456243937165 ry-0.3915631056666277 rz0 zoom1 pan0 defaultparams fluidon. Realshader motion probe proved positiveyaw movesdetailright; legacygesture mappedrightdragnegativeyawandfling. New acceptedgesture->actualshaderpatchmatching test REDrightdisplacement(-2,-1),fixedright(2,1),left(-2,-1),down(0,2),up(0,-2). Reviewfoundglobal3DsignflipwouldregressnegativeZCoralGrowthcamera; rejectedglobalfix. Smallest safe modulecontract horizontalOrbitSign defaults-1alllegacy,onlyQuaternionopts+1; bothdrag/flingreadfield,vertical/shaderformulas/presets/2Dunchanged. Strengthened existingcadence/flingtest withCoral/Quaterniondirectionoracles andretainedmandelbulbviewportlegacy. Final59focusedgesture/widget/render/modulecontract tests pass. ThinAndroidintegrationentrypointreusespixelregression; firstWaydroidrunpassed1testonpriorglobalpatch(sameQuaternionbehavior),notyetfinalbuildqualification. Deviceownershipreleased, finalreruncoordinationpending. Fullofflinegate inisolatedcandidatebase6f825503 /tmp/fractal-quaternion-drag-hL5eYo/ running; initialsnapshotisintermediate, validatorinstructedcopyfinalfrozen6filesONLYafteroldcommandterminalthenrunfinalgate. Reviewresume pending. Otherdirtyexport/Web/supervisor/docs are notowned and preserved. No commit/push/publication.
