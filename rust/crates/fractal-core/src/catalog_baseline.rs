//! Read-only schema-1 catalog data, not a runtime registry or capability certificate.

use serde::{Deserialize, Serialize, de::DeserializeOwned};
use serde_json::{Number, Value};
use std::{
    collections::{BTreeMap, BTreeSet},
    fmt,
};

/// Uninterpreted metadata is retained at every object boundary.
pub type Metadata = BTreeMap<String, Value>;

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(transparent)]
pub struct ModuleId(String);

impl ModuleId {
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
#[serde(transparent)]
pub struct CatalogId(String);

impl CatalogId {
    pub fn as_str(&self) -> &str {
        &self.0
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Envelope<T> {
    pub schema: u32,
    pub kind: String,
    pub payload: Records<T>,
    pub provenance: Provenance,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Records<T> {
    pub records: Vec<T>,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Provenance {
    pub flutter_version: String,
    pub hash_algorithm: String,
    pub registry_mode: String,
    pub source_set_sha256: String,
    pub sources: BTreeMap<String, String>,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Module {
    pub id: ModuleId,
    #[serde(deserialize_with = "Option::deserialize")]
    pub registry_order: Option<u64>,
    pub catalog: Vec<CatalogEntry>,
    pub animation: Animation,
    pub dimension: Dimension,
    pub diagnostic: bool,
    pub display_name_en: String,
    pub hides_effect_controls: bool,
    pub horizontal_orbit_sign: Number,
    pub shader_asset: String,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CatalogEntry {
    pub id: CatalogId,
    #[serde(deserialize_with = "Option::deserialize")]
    pub order: Option<u64>,
    pub aliases: Vec<String>,
    pub category: String,
    pub family: String,
    pub hidden_from_explore: bool,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum Animation {
    Static,
    TimeDriven,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum Dimension {
    TwoD,
    ThreeD,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ModuleParameters {
    pub module_id: ModuleId,
    pub parameters: Vec<Parameter>,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum ParameterKind {
    Integer,
    Float,
    Enumeration,
    Boolean,
    DecimalInteger,
}

/// Numbers retain their JSON representation; strings never pass through binary64.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum ParameterValue {
    Boolean(bool),
    Number(Number),
    Text(String),
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum Control {
    Slider,
    Chips,
    Color,
    Toggle,
    Prime,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Parameter {
    pub id: String,
    #[serde(rename = "type")]
    pub kind: ParameterKind,
    pub default: ParameterValue,
    pub order: u64,
    #[serde(deserialize_with = "Option::deserialize")]
    pub control: Option<Control>,
    pub resolved_control: Control,
    pub label_en: String,
    pub min: Number,
    pub max: Number,
    pub step: Number,
    pub options: Vec<ParameterOption>,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ParameterOption {
    pub label_en: String,
    pub value: ParameterValue,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ModulePresets {
    pub module_id: ModuleId,
    pub default: Preset,
    pub built_in: Vec<Preset>,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Preset {
    pub id: String,
    pub module_id: ModuleId,
    pub name: String,
    pub is_built_in: bool,
    /// Outer `None` means absent; `Some(None)` preserves an explicit JSON null.
    #[serde(
        default,
        skip_serializing_if = "Option::is_none",
        deserialize_with = "present_order"
    )]
    pub order: Option<Option<u64>>,
    pub params: BTreeMap<String, ParameterValue>,
    #[serde(deserialize_with = "Option::deserialize")]
    pub thumbnail_path: Option<String>,
    pub view: View,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct View {
    pub pan_x: Number,
    pub pan_y: Number,
    pub rot_x: Number,
    pub rot_y: Number,
    pub rot_z: Number,
    pub zoom: Number,
    #[serde(flatten)]
    pub metadata: Metadata,
}

/// These are baseline claims only, not evidence of Rust/native support.
#[derive(Debug, Serialize, Deserialize)]
pub struct ModuleCapabilities {
    pub module_id: ModuleId,
    pub curated_cpu: bool,
    pub native_cpu: bool,
    pub gpu_ceiling_zoom: Number,
    pub precision_default_power: Number,
    pub precision_samples: Vec<PrecisionSample>,
    pub mathematics: Mathematics,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Mathematics {
    pub algebra: String,
    pub default_formula: String,
    pub family: String,
    pub group_id: String,
    pub method: String,
    pub qualification: String,
    pub relationship: String,
    pub view: String,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct PrecisionSample {
    pub cpu_fallback_pending: bool,
    pub exactness: Exactness,
    pub path: PrecisionPath,
    #[serde(deserialize_with = "Option::deserialize")]
    pub shader_asset: Option<String>,
    pub tier: PrecisionTier,
    pub zoom: Number,
    #[serde(flatten)]
    pub metadata: Metadata,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum Exactness {
    Approximate,
    CpuPrecision,
    ExtendedGpuPreview,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PrecisionPath {
    GpuFloat,
    Cpu,
    GpuPerturbation,
    GpuDoubleFloat,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum PrecisionTier {
    RealtimeGpu,
    PrecisionRefine,
    ExtendedGpu,
}

#[derive(Debug)]
pub enum CatalogError {
    Json {
        kind: &'static str,
        source: serde_json::Error,
    },
    Schema {
        kind: &'static str,
        schema: u32,
    },
    Kind {
        expected: &'static str,
        actual: String,
    },
    Duplicate {
        kind: &'static str,
        id: String,
    },
    Reference {
        kind: &'static str,
        id: String,
    },
    Invalid {
        kind: &'static str,
        id: String,
    },
}

impl fmt::Display for CatalogError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Json { kind, source } => write!(f, "{kind}: {source}"),
            Self::Schema { kind, schema } => write!(f, "{kind}: unsupported schema {schema}"),
            Self::Kind { expected, actual } => write!(f, "expected {expected}, got {actual}"),
            Self::Duplicate { kind, id } => write!(f, "duplicate {kind} identity: {id}"),
            Self::Reference { kind, id } => write!(f, "{kind}: missing or mismatched module {id}"),
            Self::Invalid { kind, id } => write!(f, "invalid {kind}: {id}"),
        }
    }
}

impl std::error::Error for CatalogError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            Self::Json { source, .. } => Some(source),
            _ => None,
        }
    }
}

/// A complete validated set. Accessors are immutable; loading changes no live state.
#[derive(Debug)]
pub struct CatalogBaseline {
    modules: Envelope<Module>,
    parameters: Envelope<ModuleParameters>,
    presets: Envelope<ModulePresets>,
    capabilities: Envelope<ModuleCapabilities>,
}

impl CatalogBaseline {
    pub fn from_jsons(
        modules: &str,
        parameters: &str,
        presets: &str,
        capabilities: &str,
    ) -> Result<Self, CatalogError> {
        let modules: Envelope<Module> = parse(modules, "modules")?;
        let parameters: Envelope<ModuleParameters> = parse(parameters, "parameters")?;
        let presets: Envelope<ModulePresets> = parse(presets, "presets")?;
        let capabilities: Envelope<ModuleCapabilities> = parse(capabilities, "capabilities")?;

        let module_ids = identities(
            modules.payload.records.iter().map(|m| m.id.as_str()),
            "module",
        )?;
        identities(
            modules
                .payload
                .records
                .iter()
                .flat_map(|m| m.catalog.iter().map(|c| c.id.as_str())),
            "catalog",
        )?;
        references(
            parameters.payload.records.iter().map(|r| &r.module_id),
            &module_ids,
            "parameters",
        )?;
        references(
            presets.payload.records.iter().map(|r| &r.module_id),
            &module_ids,
            "presets",
        )?;
        references(
            capabilities.payload.records.iter().map(|r| &r.module_id),
            &module_ids,
            "capabilities",
        )?;
        for record in &parameters.payload.records {
            identities(record.parameters.iter().map(|p| p.id.as_str()), "parameter")?;
            for parameter in &record.parameters {
                validate_parameter(parameter)?;
            }
        }
        let mut preset_ids = BTreeSet::new();
        for record in &presets.payload.records {
            // The default can alias an identical built-in, apart from role-specific order.
            let mut ids = identities(record.built_in.iter().map(|p| p.id.as_str()), "preset")?;
            if let Some(built_in) = record.built_in.iter().find(|p| p.id == record.default.id) {
                let mut definition = built_in.clone();
                definition.order = record.default.order;
                if definition != record.default {
                    return Err(CatalogError::Duplicate {
                        kind: "preset",
                        id: record.default.id.clone(),
                    });
                }
            }
            ids.insert(record.default.id.as_str());
            for id in ids {
                if !preset_ids.insert(id) {
                    return Err(CatalogError::Duplicate {
                        kind: "preset",
                        id: id.to_owned(),
                    });
                }
            }
            for preset in std::iter::once(&record.default).chain(&record.built_in) {
                if preset.module_id != record.module_id {
                    return Err(CatalogError::Reference {
                        kind: "preset",
                        id: preset.module_id.0.clone(),
                    });
                }
                if preset.id.is_empty() {
                    return Err(CatalogError::Invalid {
                        kind: "preset identity",
                        id: preset.id.clone(),
                    });
                }
            }
        }
        Ok(Self {
            modules,
            parameters,
            presets,
            capabilities,
        })
    }

    pub fn modules(&self) -> &Envelope<Module> {
        &self.modules
    }
    pub fn parameters(&self) -> &Envelope<ModuleParameters> {
        &self.parameters
    }
    pub fn presets(&self) -> &Envelope<ModulePresets> {
        &self.presets
    }
    pub fn capabilities(&self) -> &Envelope<ModuleCapabilities> {
        &self.capabilities
    }
}

fn present_order<'de, D: serde::Deserializer<'de>>(
    deserializer: D,
) -> Result<Option<Option<u64>>, D::Error> {
    Option::deserialize(deserializer).map(Some)
}

fn parse<T: DeserializeOwned>(json: &str, kind: &'static str) -> Result<Envelope<T>, CatalogError> {
    reject_number_objects(json).map_err(|source| CatalogError::Json { kind, source })?;
    let envelope: Envelope<T> =
        serde_json::from_str(json).map_err(|source| CatalogError::Json { kind, source })?;
    if envelope.schema != 1 {
        return Err(CatalogError::Schema {
            kind,
            schema: envelope.schema,
        });
    }
    if envelope.kind != kind {
        return Err(CatalogError::Kind {
            expected: kind,
            actual: envelope.kind,
        });
    }
    Ok(envelope)
}

// Serde's arbitrary-precision marker must not turn a real JSON object into a number.
fn reject_number_objects(json: &str) -> Result<(), serde_json::Error> {
    use serde_json::value::RawValue;
    let mut pending = vec![serde_json::from_str::<&RawValue>(json)?];
    while let Some(raw) = pending.pop() {
        match raw.get().as_bytes()[0] {
            b'{' => {
                let fields: BTreeMap<String, &RawValue> = serde_json::from_str(raw.get())?;
                if fields.contains_key("$serde_json::private::Number") {
                    return Err(serde::de::Error::custom(
                        "reserved arbitrary-precision number object",
                    ));
                }
                pending.extend(fields.into_values());
            }
            b'[' => pending.extend(serde_json::from_str::<Vec<&RawValue>>(raw.get())?),
            _ => {}
        }
    }
    Ok(())
}

fn identities<'a>(
    ids: impl Iterator<Item = &'a str>,
    kind: &'static str,
) -> Result<BTreeSet<&'a str>, CatalogError> {
    let mut seen = BTreeSet::new();
    for id in ids {
        if id.is_empty() {
            return Err(CatalogError::Invalid {
                kind,
                id: id.to_owned(),
            });
        }
        if !seen.insert(id) {
            return Err(CatalogError::Duplicate {
                kind,
                id: id.to_owned(),
            });
        }
    }
    Ok(seen)
}

fn references<'a>(
    ids: impl Iterator<Item = &'a ModuleId>,
    modules: &BTreeSet<&str>,
    kind: &'static str,
) -> Result<(), CatalogError> {
    let ids = identities(ids.map(ModuleId::as_str), kind)?;
    if let Some(id) = ids.symmetric_difference(modules).next() {
        return Err(CatalogError::Reference {
            kind,
            id: (*id).to_owned(),
        });
    }
    Ok(())
}

fn validate_parameter(parameter: &Parameter) -> Result<(), CatalogError> {
    let valid = match (&parameter.kind, &parameter.default) {
        // Preserve descriptor values without introducing a normalization policy.
        (ParameterKind::Integer | ParameterKind::Float, ParameterValue::Number(_)) => true,
        (ParameterKind::Enumeration, value) => parameter
            .options
            .iter()
            .any(|option| std::mem::discriminant(&option.value) == std::mem::discriminant(value)),
        (ParameterKind::Boolean, ParameterValue::Boolean(_)) => true,
        (ParameterKind::DecimalInteger, ParameterValue::Text(text)) => {
            let digits = text.strip_prefix('-').unwrap_or(text);
            !digits.is_empty() && digits.bytes().all(|c| c.is_ascii_digit())
        }
        _ => false,
    };
    if !valid {
        return Err(CatalogError::Invalid {
            kind: "parameter default",
            id: parameter.id.clone(),
        });
    }
    Ok(())
}
