//! Pure ordered-schema targets from the pinned Dart randomizer/controller.
//! No Session, animation, undo, entropy service or production-module admission.

use crate::{
    catalog_baseline::{Parameter, ParameterKind, ParameterValue},
    normalization::{RawScalar, clamp, normalize_parameter},
    seeded_random::{InvalidBound, SeededRandom},
};
use std::{collections::BTreeMap, fmt};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RandomizationError {
    InvalidBound(InvalidBound),
    UnsupportedIntegerBounds(String),
    MissingWallSources,
}

impl fmt::Display for RandomizationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidBound(error) => error.fmt(f),
            Self::UnsupportedIntegerBounds(id) => {
                write!(f, "{id}: integer bounds must fit i64 with a span <= 2^32")
            }
            Self::MissingWallSources => write!(f, "Number Walls requires nonempty source options"),
        }
    }
}

impl std::error::Error for RandomizationError {}

impl From<InvalidBound> for RandomizationError {
    fn from(error: InvalidBound) -> Self {
        Self::InvalidBound(error)
    }
}

/// Iterate the supplied slice, not map-key order or catalog metadata order.
/// Palette fields retain current/default values without normalization or a draw.
/// Other current fields are discarded. Errors may follow earlier schema draws.
pub fn general_targets(
    schema: &[Parameter],
    current: &BTreeMap<String, ParameterValue>,
    random: &mut SeededRandom,
) -> Result<BTreeMap<String, ParameterValue>, RandomizationError> {
    schema
        .iter()
        .map(|param| {
            let value = if param.id == "colorScheme" || param.id == "colorCycleSpeed" {
                current.get(&param.id).unwrap_or(&param.default).clone()
            } else {
                random_value(param, random)?
            };
            Ok((param.id.clone(), value))
        })
        .collect()
}

fn random_value(
    param: &Parameter,
    random: &mut SeededRandom,
) -> Result<ParameterValue, RandomizationError> {
    let raw = match param.kind {
        ParameterKind::Float => {
            let min = param.min.as_f64().expect("JSON number");
            let max = param.max.as_f64().expect("JSON number");
            let draw = random.next_double();
            let value = if param.id == "juliaCReal" || param.id == "juliaCImag" {
                let center = match &param.default {
                    ParameterValue::Number(n) => n.as_f64().expect("JSON number"),
                    _ => (min + max) * 0.5,
                };
                if min <= max {
                    clamp(center + (draw * 2.0 - 1.0) * 0.35, min, max)
                } else {
                    return Ok(param.default.clone());
                }
            } else {
                min + draw * (max - min)
            };
            RawScalar::Float(round_to_step(
                value,
                param.step.as_f64().expect("JSON number"),
            ))
        }
        ParameterKind::Integer => {
            let min = param.min.as_f64().expect("JSON number").ceil();
            let max = param.max.as_f64().expect("JSON number").floor();
            if !min.is_finite() || !max.is_finite() || min > max {
                return Ok(normalize_parameter(param, &param.default.clone().into()));
            }
            // Avoid saturating Rust casts or an overflowing inclusive range.
            if min < i64::MIN as f64 || max >= -(i64::MIN as f64) {
                return Err(RandomizationError::UnsupportedIntegerBounds(
                    param.id.clone(),
                ));
            }
            let min = min as i64;
            let span = i128::from(max as i64) - i128::from(min) + 1;
            if span > 1_i128 << 32 {
                return Err(RandomizationError::UnsupportedIntegerBounds(
                    param.id.clone(),
                ));
            }
            RawScalar::Number((min + random.next_int(span as i64)?).into())
        }
        ParameterKind::Enumeration => {
            if param.options.is_empty() {
                return Ok(param.default.clone());
            }
            let index = random.next_int(param.options.len() as i64)? as usize;
            return Ok(param.options[index].value.clone());
        }
        ParameterKind::DecimalInteger => return Ok(param.default.clone()),
        ParameterKind::Boolean => RawScalar::Boolean(random.next_bool()),
    };
    Ok(normalize_parameter(param, &raw))
}

fn round_to_step(value: f64, step: f64) -> f64 {
    if !value.is_finite() || !step.is_finite() || step <= 0.0 {
        return value;
    }
    // Dart round returns a signed VM integer (including saturation and +0).
    let snapped = (value / step).round() as i64 as f64 * step;
    if !snapped.is_finite() || snapped.abs() >= 1e21 {
        return if snapped.is_finite() { snapped } else { value };
    }
    // Fixed decimal formatting rounds the exact binary value. Rust uses even
    // ties; Dart uses away ties. Exact six-place halves are odd multiples of 1/128.
    let scaled = snapped * 128.0;
    if scaled.abs() < (1_u64 << 53) as f64 && scaled.fract() == 0.0 && (scaled as i64) % 2 != 0 {
        // Keep decimal rounding exact even when micro-units exceed 2^53.
        let n = scaled as i64;
        let micros = (i128::from(n).abs() * 15625 + 1) / 2;
        format!(
            "{}{}.{:06}",
            if n < 0 { "-" } else { "" },
            micros / 1_000_000,
            micros % 1_000_000
        )
        .parse()
        .expect("finite decimal")
    } else {
        format!("{snapped:.6}").parse().expect("finite decimal")
    }
}

/// Materialize/mask an explicit seed, preserve custom prime unless opted in,
/// then normalize schema values as Dart loadState does. No grid or undo changes.
pub fn number_wall_targets(
    schema: &[Parameter],
    current: &BTreeMap<String, ParameterValue>,
    seed: i64,
) -> Result<BTreeMap<String, ParameterValue>, RandomizationError> {
    let sources = schema
        .iter()
        .find(|param| param.id == "source" && !param.options.is_empty())
        .ok_or(RandomizationError::MissingWallSources)?;
    let seed = seed & 0x7fffffff;
    let mut random = SeededRandom::new(seed);
    let mut target = current.clone();
    target.insert("randomSeed".into(), ParameterValue::Number(seed.into()));
    let index = random.next_int(sources.options.len() as i64)? as usize;
    target.insert("source".into(), sources.options[index].value.clone());
    for (id, bound, mask) in [
        ("colorScheme", 64, 0),
        ("backgroundColor", 0x404040, 0),
        ("foregroundColor", 0x1000000, 0),
        ("zeroColor", 0x1000000, 0x808080),
    ] {
        target.insert(
            id.into(),
            ParameterValue::Number((mask | random.next_int(bound)?).into()),
        );
    }
    if current.get("randomizeModulus") == Some(&ParameterValue::Boolean(true)) {
        let primes = ["2", "3", "5", "7", "11", "13"];
        target.insert(
            "prime".into(),
            ParameterValue::Text(primes[random.next_int(6)? as usize].into()),
        );
    }
    Ok(schema
        .iter()
        .map(|param| {
            let raw = target
                .get(&param.id)
                .unwrap_or(&param.default)
                .clone()
                .into();
            (param.id.clone(), normalize_parameter(param, &raw))
        })
        .collect())
}
