use fractal_core::{
    catalog_baseline::Dimension,
    precision::{
        Capabilities, Decision, Hysteresis, HysteresisState, RenderPath, Sample, decide,
        gpu_renderable_ceiling_zoom, scaled_gpu_iterations,
    },
};
use serde_json::{Value, json};
use std::{env, fs};

fn number(value: &Value) -> f64 {
    match value.get("nonfinite").and_then(Value::as_str) {
        Some("nan") => f64::NAN,
        Some("+infinity") => f64::INFINITY,
        Some("-infinity") => f64::NEG_INFINITY,
        Some(other) => panic!("unknown nonfinite operand: {other}"),
        None => value.as_f64().expect("numeric precision operand"),
    }
}

fn result(decision: &Decision<'_>, event: &Value, caps: Capabilities) -> Value {
    json!({
        "renderPath": decision.render_path,
        "tier": decision.tier,
        "exactness": decision.exactness,
        "cpuFallbackPending": decision.cpu_fallback_pending,
        "nativeCpu": caps.native_cpu,
        "scaledGpuIterations": scaled_gpu_iterations(
            event["baseIterations"].as_i64().unwrap_or(200), number(&event["zoom"])),
    })
}

fn helpers(decision: &Decision<'_>) -> Value {
    json!({
        "usesCpuRenderer": decision.uses_cpu_renderer(),
        "usesDoubleFloatGpu": decision.uses_double_float_gpu(),
        "usesPerturbationGpu": decision.uses_perturbation_gpu(),
        "usesExtendedGpu": decision.uses_extended_gpu(),
        "showPrecisionIndicator": decision.show_precision_indicator(),
        "statusLabel": decision.status_label(),
        "debugRendererLabel": decision.debug_renderer_label(),
    })
}

// Always executed by ordinary cargo test: named core cases are not a claim that
// the opt-in live Dart comparison below ran.
#[test]
fn named_policy_helpers_and_ordered_hysteresis() {
    let native = Capabilities {
        native_cpu: true,
        perturbation: false,
    };
    let perturbable = Capabilities {
        perturbation: true,
        ..native
    };
    let unknown = Capabilities {
        native_cpu: false,
        perturbation: false,
    };
    for (id, dimension, zoom, power, caps, active, path, pending) in [
        (
            "mandelbrot",
            Dimension::TwoD,
            5e6,
            2.0,
            native,
            true,
            RenderPath::GpuDoubleFloat,
            false,
        ),
        (
            "mandelbrot",
            Dimension::TwoD,
            1e12,
            2.0,
            native,
            true,
            RenderPath::Cpu,
            false,
        ),
        (
            "burning_ship",
            Dimension::TwoD,
            1e20,
            2.0,
            perturbable,
            false,
            RenderPath::GpuPerturbation,
            false,
        ),
        (
            "burning_ship",
            Dimension::TwoD,
            1e20,
            f64::from_bits(2.0_f64.to_bits() + 1),
            perturbable,
            false,
            RenderPath::GpuFloat,
            true,
        ),
        (
            "burning_ship",
            Dimension::ThreeD,
            f64::INFINITY,
            3.0,
            perturbable,
            true,
            RenderPath::GpuFloat,
            false,
        ),
        (
            "unknown",
            Dimension::TwoD,
            f64::INFINITY,
            2.0,
            unknown,
            true,
            RenderPath::GpuFloat,
            false,
        ),
        (
            "weierstrass_p",
            Dimension::TwoD,
            f64::NAN,
            2.0,
            native,
            true,
            RenderPath::GpuFloat,
            false,
        ),
    ] {
        let sample = Sample {
            module_id: id,
            dimension: &dimension,
            zoom,
            power,
            capabilities: caps,
        };
        let decision = decide(sample, active);
        assert_eq!(
            (decision.render_path, decision.cpu_fallback_pending),
            (path, pending),
            "{id}"
        );
        assert_eq!(decision.module_id, id);
        assert!(std::ptr::eq(decision.dimension, &dimension));
        assert!(decision.zoom == zoom || decision.zoom.is_nan() && zoom.is_nan());
    }
    assert_eq!(
        gpu_renderable_ceiling_zoom("burning_ship", perturbable),
        1e30
    );
    assert_eq!(gpu_renderable_ceiling_zoom("mandelbrot", native), 1e12);
    assert_eq!(gpu_renderable_ceiling_zoom("unknown", unknown), 1e7);
    for (base, zoom, expected) in [
        (1, f64::NAN, 4),
        (256, 1e6, 794),
        (256, f64::INFINITY, 2000),
        (2001, -1.0, 2000),
    ] {
        assert_eq!(scaled_gpu_iterations(base, zoom), expected);
    }
    let mut hysteresis = Hysteresis::default();
    for (id, zoom, power, dimension, path, count, active) in [
        (
            "burning_ship",
            1e20,
            3.0,
            Dimension::TwoD,
            RenderPath::GpuFloat,
            1,
            false,
        ),
        (
            "burning_ship",
            1e20,
            3.0,
            Dimension::TwoD,
            RenderPath::Cpu,
            2,
            true,
        ),
        (
            "julia",
            1e30,
            2.0,
            Dimension::TwoD,
            RenderPath::GpuFloat,
            1,
            false,
        ),
        (
            "julia",
            1e30,
            2.0,
            Dimension::TwoD,
            RenderPath::Cpu,
            2,
            true,
        ),
        (
            "julia",
            1.0,
            2.0,
            Dimension::TwoD,
            RenderPath::GpuFloat,
            0,
            false,
        ),
        (
            "burning_ship",
            1e20,
            2.0,
            Dimension::TwoD,
            RenderPath::GpuPerturbation,
            0,
            false,
        ),
        (
            "burning_ship",
            1e20,
            3.0,
            Dimension::ThreeD,
            RenderPath::GpuFloat,
            0,
            false,
        ),
    ] {
        let decision = hysteresis.update(Sample {
            module_id: id,
            dimension: &dimension,
            zoom,
            power,
            capabilities: perturbable,
        });
        assert_eq!(decision.render_path, path);
        assert_eq!(
            hysteresis.state(),
            &HysteresisState {
                module_id: Some(id.into()),
                above_threshold_count: count,
                cpu_active: active
            }
        );
    }
    hysteresis.reset();
    assert_eq!(hysteresis.state(), &HysteresisState::default());
    assert!(hysteresis.state().next("julia", true, 1).cpu_active);
}

#[test]
fn fresh_dart_differential_when_explicitly_requested() {
    let Some(path) = env::var_os("RUST_PRECISION_VECTORS") else {
        eprintln!(
            "Live Dart differential not requested; set RUST_PRECISION_VECTORS to a fresh precision_parity_test.dart export. Embedded core cases run separately."
        );
        return;
    };
    // An explicitly requested missing, empty or malformed file is a hard failure.
    let document: Value =
        serde_json::from_str(&fs::read_to_string(path).expect("read requested Dart vectors"))
            .expect("decode Dart vectors");
    assert_eq!(document["schema"], 1);
    assert_eq!(document["kind"], "precision-parity");
    assert!(document["seededCases"].as_u64().unwrap() >= 1024);
    let bindings = document["source_bindings"].as_object().unwrap();
    for source in [
        "lib/features/renderer/policy/precision_ladder_policy.dart",
        "test/migration/support/replay_codec.dart",
        "pubspec.lock",
    ] {
        assert_eq!(bindings[source].as_str().unwrap().len(), 64);
    }
    let capabilities = document["capabilities"].as_object().unwrap();
    let ceilings = document["gpuCeilings"].as_object().unwrap();
    assert_eq!(capabilities.len(), ceilings.len());
    for (id, facts) in capabilities {
        let caps: Capabilities = serde_json::from_value(facts.clone()).unwrap();
        assert_eq!(
            gpu_renderable_ceiling_zoom(id, caps),
            number(&ceilings[id]),
            "ceiling {id}"
        );
    }
    let inputs = document["inputs"].as_array().unwrap();
    let expected = document["expected"].as_array().unwrap();
    let expected_helpers = document["helpers"].as_array().unwrap();
    assert_eq!(inputs.len(), expected.len());
    assert_eq!(inputs.len(), expected_helpers.len());
    assert!(inputs.iter().filter(|e| e["op"] != "reset").count() >= 1024);
    let mut hysteresis = Hysteresis::default();
    for (i, event) in inputs.iter().enumerate() {
        if event["op"] == "reset" {
            hysteresis.reset();
            assert_eq!(expected[i], json!({"reset": true}));
            assert!(expected_helpers[i].is_null());
            continue;
        }
        let id = event["moduleId"].as_str().unwrap();
        let caps: Capabilities = serde_json::from_value(capabilities[id].clone()).unwrap();
        let dimension: Dimension = serde_json::from_value(event["dimension"].clone()).unwrap();
        let sample = Sample {
            module_id: id,
            dimension: &dimension,
            zoom: number(&event["zoom"]),
            power: event.get("power").map(number).unwrap_or(2.0),
            capabilities: caps,
        };
        let decision = match event["op"].as_str().unwrap() {
            "decide" => decide(sample, event["cpuFallbackActive"].as_bool().unwrap_or(true)),
            "update" => hysteresis.update(sample),
            other => panic!("unknown precision event: {other}"),
        };
        let mut actual = result(&decision, event, caps);
        if event["op"] == "update" {
            actual["history"] = serde_json::to_value(hysteresis.state()).unwrap();
        }
        assert_eq!(actual, expected[i], "event {i}: {event}");
        assert_eq!(
            helpers(&decision),
            expected_helpers[i],
            "helpers {i}: {event}"
        );
    }
    eprintln!(
        "Exactly matched {} ordered Dart events and {} GPU ceilings",
        inputs.len(),
        ceilings.len()
    );
}
