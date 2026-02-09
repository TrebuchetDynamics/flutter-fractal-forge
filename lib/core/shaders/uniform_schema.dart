import 'dart:ui' as ui;

/// A strongly-typed uniform layout for FragmentProgram shaders.
///
/// Flutter's FragmentShader uniforms are set by *float index* and the indices
/// depend on the exact declaration order/types in the GLSL shader.
///
/// To avoid fragile hard-coded indices (which caused black output on device),
/// each fractal module should define a [UniformSchema] once and then set
/// uniforms by name.
class UniformSchema {
  UniformSchema._(this._entries, this.floatCount);

  final Map<String, UniformEntry> _entries;

  /// Total number of float slots consumed by all non-sampler uniforms.
  final int floatCount;

  UniformEntry operator [](String name) {
    final e = _entries[name];
    if (e == null) {
      throw ArgumentError('Unknown uniform: $name');
    }
    return e;
  }

  /// Creates a writer for a [ui.FragmentShader].
  UniformWriter writer(ui.FragmentShader shader) => UniformWriter._(this, shader);

  /// Builder.
  static UniformSchema build(void Function(UniformSchemaBuilder b) fn) {
    final b = UniformSchemaBuilder._();
    fn(b);
    return b._finish();
  }
}

sealed class UniformEntry {
  const UniformEntry(this.name, this.index);
  final String name;
  final int index;
  int get width;
}

class FloatEntry extends UniformEntry {
  const FloatEntry(super.name, super.index);
  @override
  int get width => 1;
}

class Vec2Entry extends UniformEntry {
  const Vec2Entry(super.name, super.index);
  @override
  int get width => 2;
}

class Vec3Entry extends UniformEntry {
  const Vec3Entry(super.name, super.index);
  @override
  int get width => 3;
}

class Vec4Entry extends UniformEntry {
  const Vec4Entry(super.name, super.index);
  @override
  int get width => 4;
}

class UniformSchemaBuilder {
  UniformSchemaBuilder._();

  final _entries = <String, UniformEntry>{};
  int _cursor = 0;

  void float(String name) => _add(FloatEntry(name, _cursor));
  void vec2(String name) => _add(Vec2Entry(name, _cursor));
  void vec3(String name) => _add(Vec3Entry(name, _cursor));
  void vec4(String name) => _add(Vec4Entry(name, _cursor));

  void _add(UniformEntry e) {
    if (_entries.containsKey(e.name)) {
      throw ArgumentError('Duplicate uniform: ${e.name}');
    }
    _entries[e.name] = e;
    _cursor += e.width;
  }

  UniformSchema _finish() => UniformSchema._(Map.unmodifiable(_entries), _cursor);
}

class UniformWriter {
  UniformWriter._(this.schema, this.shader);

  final UniformSchema schema;
  final ui.FragmentShader shader;

  void setFloat(String name, double v) {
    final e = schema[name];
    if (e is! FloatEntry) {
      throw ArgumentError('Uniform $name is not float (is ${e.runtimeType})');
    }
    shader.setFloat(e.index, v);
  }

  void setVec2(String name, double x, double y) {
    final e = schema[name];
    if (e is! Vec2Entry) {
      throw ArgumentError('Uniform $name is not vec2 (is ${e.runtimeType})');
    }
    shader.setFloat(e.index + 0, x);
    shader.setFloat(e.index + 1, y);
  }

  void setVec3(String name, double x, double y, double z) {
    final e = schema[name];
    if (e is! Vec3Entry) {
      throw ArgumentError('Uniform $name is not vec3 (is ${e.runtimeType})');
    }
    shader.setFloat(e.index + 0, x);
    shader.setFloat(e.index + 1, y);
    shader.setFloat(e.index + 2, z);
  }

  void setVec4(String name, double x, double y, double z, double w) {
    final e = schema[name];
    if (e is! Vec4Entry) {
      throw ArgumentError('Uniform $name is not vec4 (is ${e.runtimeType})');
    }
    shader.setFloat(e.index + 0, x);
    shader.setFloat(e.index + 1, y);
    shader.setFloat(e.index + 2, z);
    shader.setFloat(e.index + 3, w);
  }
}
