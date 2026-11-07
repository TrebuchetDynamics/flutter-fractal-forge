//! Pure parameter steps matching FractalController's randomization interpolation.
//! Scheduling, cancellation and session/animation ownership belong to callers.

use crate::{
    catalog_baseline::{Parameter, ParameterKind, ParameterValue},
    normalization::{RawScalar, normalize_parameter},
};
use std::collections::BTreeMap;

/// Step zero retains the entire starting map; step >= 36 assigns the entire
/// target without normalization. Interim maps contain only schema parameters.
/// The source schedules 36 ticks at 16 ms, not a measured 600 ms guarantee.
pub fn interpolate_parameters(
    schema: &[Parameter],
    from: &BTreeMap<String, ParameterValue>,
    target: &BTreeMap<String, ParameterValue>,
    step: u32,
) -> BTreeMap<String, ParameterValue> {
    if step == 0 {
        return from.clone();
    }
    if step >= 36 {
        return target.clone();
    }
    let eased = 1.0 - (1.0 - f64::from(step) / 36.0).powi(3);
    schema
        .iter()
        .map(|param| {
            let from = from.get(&param.id).unwrap_or(&param.default);
            let target = target.get(&param.id).unwrap_or(&param.default);
            let value = if param.id == "colorScheme"
                || param.id == "colorCycleSpeed"
                || matches!(
                    param.kind,
                    ParameterKind::Boolean | ParameterKind::Enumeration
                ) {
                from.clone()
            } else if let (ParameterValue::Number(a), ParameterValue::Number(b)) = (from, target) {
                let a = a.as_f64().expect("JSON number");
                let b = b.as_f64().expect("JSON number");
                let value = a + (b - a) * eased;
                // Dart rounds integers before the shared normalizer clamps them.
                normalize_parameter(
                    param,
                    &RawScalar::Float(if param.kind == ParameterKind::Integer {
                        value.round()
                    } else {
                        value
                    }),
                )
            } else {
                from.clone()
            };
            (param.id.clone(), value)
        })
        .collect()
}
