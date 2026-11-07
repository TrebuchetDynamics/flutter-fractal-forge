//! Pure scalar policies matching the Dart parameter and view input normalizers.
//! No session history, gesture transforms, trajectories or prime certification.

use crate::catalog_baseline::{Parameter, ParameterKind, ParameterValue};
use serde_json::Number;

/// JSON numbers retain their representation; `Float` also admits NaN/infinities.
/// Text is never parsed as a number.
#[derive(Debug, Clone, PartialEq)]
pub enum RawScalar {
    Number(Number),
    Float(f64),
    Boolean(bool),
    Text(String),
}

impl From<ParameterValue> for RawScalar {
    fn from(value: ParameterValue) -> Self {
        match value {
            ParameterValue::Number(n) => Self::Number(n),
            ParameterValue::Boolean(b) => Self::Boolean(b),
            ParameterValue::Text(s) => Self::Text(s),
        }
    }
}

impl RawScalar {
    fn value(&self) -> Option<ParameterValue> {
        match self {
            Self::Number(n) => Some(ParameterValue::Number(n.clone())),
            Self::Float(n) => Number::from_f64(*n).map(ParameterValue::Number),
            Self::Boolean(b) => Some(ParameterValue::Boolean(*b)),
            Self::Text(s) => Some(ParameterValue::Text(s.clone())),
        }
    }

    fn finite_number(&self) -> Option<f64> {
        match self {
            Self::Number(n) => n.as_f64(),
            Self::Float(n) if n.is_finite() => Some(*n),
            _ => None,
        }
    }
}

/// Invalid types, nonfinite numbers and unusable bounds use the schema default.
/// Canonical decimal text is syntax only, not primality or capability evidence.
pub fn normalize_parameter(schema: &Parameter, raw: &RawScalar) -> ParameterValue {
    match schema.kind {
        ParameterKind::DecimalInteger => {
            if let RawScalar::Text(text) = raw {
                let bytes = text.as_bytes();
                if text == "0"
                    || (matches!(bytes.first(), Some(b'1'..=b'9'))
                        && bytes.iter().all(u8::is_ascii_digit))
                {
                    return ParameterValue::Text(text.clone());
                }
            }
        }
        ParameterKind::Boolean => {
            return match raw {
                RawScalar::Boolean(b) => ParameterValue::Boolean(*b),
                _ => match &schema.default {
                    ParameterValue::Boolean(b) => ParameterValue::Boolean(*b),
                    _ => ParameterValue::Boolean(false),
                },
            };
        }
        ParameterKind::Enumeration => {
            if let Some(value) = raw.value()
                && schema
                    .options
                    .iter()
                    .any(|option| match (&option.value, &value) {
                        (ParameterValue::Number(a), ParameterValue::Number(b)) => {
                            numbers_equal(a, b)
                        }
                        (a, b) => a == b,
                    })
            {
                return value;
            }
        }
        ParameterKind::Integer | ParameterKind::Float => {
            if let (Some(value), Some(min), Some(max)) = (
                raw.finite_number(),
                schema.min.as_f64(),
                schema.max.as_f64(),
            ) && min <= max
            {
                let bounded = clamp(value, min, max);
                if schema.kind == ParameterKind::Float {
                    return ParameterValue::Number(
                        Number::from_f64(bounded).expect("finite bounds"),
                    );
                }
                if min.ceil() <= max.floor() {
                    let integer = clamp(bounded.round(), min.ceil(), max.floor());
                    return ParameterValue::Number(Number::from(integer as i64));
                }
            }
        }
    }
    schema.default.clone()
}

fn numbers_equal(a: &Number, b: &Number) -> bool {
    if a == b {
        return true;
    }
    match (a.is_f64(), b.is_f64()) {
        (true, true) => a.as_f64().zip(b.as_f64()).is_some_and(|(a, b)| a == b),
        (true, false) => integer_equals_float(b, a),
        (false, true) => integer_equals_float(a, b),
        // JSON can retain integer -0; Dart considers it equal to 0.
        (false, false) => a.as_i64().zip(b.as_i64()).is_some_and(|(a, b)| a == b),
    }
}

fn integer_equals_float(integer: &Number, float: &Number) -> bool {
    float.as_f64().is_some_and(|f| {
        f.fract() == 0.0
            && (integer.to_string() == format!("{f:.0}")
                || (f == 0.0 && integer.as_i64() == Some(0)))
    })
}

// Dart compareTo/clamp orders -0.0 below +0.0, unlike partial comparisons.
fn clamp(value: f64, min: f64, max: f64) -> f64 {
    if value.total_cmp(&min).is_lt() {
        min
    } else if value.total_cmp(&max).is_gt() {
        max
    } else {
        value
    }
}

pub const MAX_ZOOM: f64 = 1e12;
pub const DEFAULT_MIN_ZOOM: f64 = 1e-9;
pub const CANTOR_SET_MIN_ZOOM: f64 = 0.2;
pub const MIN_PAN: f64 = -3.0;
pub const MAX_PAN: f64 = 3.0;

/// Only scalar view inputs. Trajectory semantics must be handled by their owner,
/// not discarded or treated as supported by this API.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct ViewInput {
    pub zoom: f64,
    pub pan: [f64; 2],
    pub rotation: [f64; 3],
}

/// Finite scalar output, constructible only through normalization.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct FiniteView(ViewInput);

impl FiniteView {
    pub fn zoom(&self) -> f64 {
        self.0.zoom
    }

    pub fn pan(&self) -> [f64; 2] {
        self.0.pan
    }

    pub fn rotation(&self) -> [f64; 3] {
        self.0.rotation
    }
}

pub fn min_zoom_for_module(module_id: &str) -> f64 {
    if module_id == "cantor_set" {
        CANTOR_SET_MIN_ZOOM
    } else {
        DEFAULT_MIN_ZOOM
    }
}

pub fn normalize_zoom(candidate: f64, current: f64, module_id: &str) -> f64 {
    let min = min_zoom_for_module(module_id);
    let fallback = if current.is_nan() { min } else { current };
    clamp(
        if candidate.is_nan() {
            fallback
        } else {
            candidate
        },
        min,
        MAX_ZOOM,
    )
}

pub fn normalize_pan_component(candidate: f64, current: f64) -> f64 {
    let fallback = if current.is_nan() { 0.0 } else { current };
    clamp(
        if candidate.is_nan() {
            fallback
        } else {
            candidate
        },
        MIN_PAN,
        MAX_PAN,
    )
}

pub fn normalize_rotation_component(candidate: f64, current: f64) -> f64 {
    if candidate.is_finite() {
        candidate
    } else if current.is_finite() {
        current
    } else {
        0.0
    }
}

pub fn normalize_view(candidate: ViewInput, current: ViewInput, module_id: &str) -> FiniteView {
    FiniteView(ViewInput {
        zoom: normalize_zoom(candidate.zoom, current.zoom, module_id),
        pan: std::array::from_fn(|i| normalize_pan_component(candidate.pan[i], current.pan[i])),
        rotation: std::array::from_fn(|i| {
            normalize_rotation_component(candidate.rotation[i], current.rotation[i])
        }),
    })
}
