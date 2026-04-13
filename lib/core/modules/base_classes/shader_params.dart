// Shared types for pipeline-emitted modules.

/// Strategy for rendering at extreme zoom depths.
enum DeepZoomStrategy {
  none,
  perturbation,
  seriesApproximation,
}

/// Abstract interface for setting shader uniforms.
///
/// Modules call [setFloat] / [setInt] to bind uniforms without
/// knowing the underlying shader backend (Impeller / SkSL / Flutter GPU).
abstract class ShaderParams {
  void setFloat(String name, double value);
  void setInt(String name, int value);
  void setBool(String name, bool value);
  void setVec2(String name, double x, double y);
  void setVec3(String name, double x, double y, double z);
}
