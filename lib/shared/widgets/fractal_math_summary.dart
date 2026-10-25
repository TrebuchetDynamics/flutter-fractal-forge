import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractal_mathematics.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/theme/app_theme.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

String mathematicalLabel(BuildContext context, String value) {
  if (Localizations.localeOf(context).languageCode != 'es') return value;
  final label = const <String, String>{
    'Inspired; not an exotic sphere. Not escaped within N is not proven boundedness; orbit of 0 only, not complete connectedness locus':
        'Inspirada; no es una esfera exótica. Sin escape en N no demuestra acotación; solo la órbita de 0, no el lugar completo de conexidad',
    'Translated-triangle union': 'Unión de triángulos trasladados',
    'Finite approximation; not a zero-area set or continuous needle motion':
        'Aproximación finita; no es un conjunto de área cero ni un movimiento continuo de aguja',
    'Complex dynamics': 'Dinámica compleja',
    'Root finding': 'Búsqueda de raíces',
    'IFS and geometric constructions': 'IFS y construcciones geométricas',
    'Maps, flows and attractors': 'Mapas, flujos y atractores',
    'Tilings, substitutions and L-systems':
        'Teselados, sustituciones y sistemas L',
    'Cellular automata and growth': 'Autómatas celulares y crecimiento',
    'Fields, spectra and scientific visualization':
        'Campos, espectros y visualización científica',
    'Procedural and artistic systems': 'Sistemas procedurales y artísticos',
    'Unclassified': 'Sin clasificar',
    'Source-reviewed recurrence': 'Recurrencia revisada en código',
    'Named configuration': 'Configuración con nombre',
    'Unverified identity': 'Identidad no verificada',
    'Formula not reviewed': 'Fórmula no revisada',
    'Tiling-inspired visualization': 'Visualización inspirada en teselados',
    'Packing-inspired construction':
        'Construcción inspirada en empaquetamientos',
    'Parameter configuration': 'Configuración de parámetros',
    'Exponent-family member': 'Miembro de una familia de exponentes',
    'Coloring variant': 'Variante de coloreado',
    'Coloring/measurement variant': 'Variante de coloreado o medición',
    'Related method': 'Método relacionado',
    'Different recurrence': 'Recurrencia diferente',
    'Parameter plane': 'Plano de parámetros',
    'Dynamical plane': 'Plano dinámico',
    'Root basins': 'Cuencas de raíces',
    'Escape/boundedness view': 'Vista de escape o acotación',
    '2D slice': 'Sección 2D',
    '3D volume': 'Volumen 3D',
    'Complex': 'Complejo',
    'Real': 'Real',
    'Quaternion': 'Cuaternión',
    'Bicomplex': 'Bicomplejo',
    'Unverified': 'No verificado',
    'Discrete': 'Discreto',
    '2D view': 'Vista 2D',
    '3D view': 'Vista 3D',
    'Source-reviewed recurrence; named starting configuration':
        'Recurrencia revisada en código; configuración inicial con nombre',
    'Source-reviewed recurrence; numerical regularization may apply':
        'Recurrencia revisada en código; puede tener regularización numérica',
    'Source-reviewed update; color does not prove convergence':
        'Actualización revisada en código; el color no demuestra convergencia',
    'Unverified effective update: relaxation uniform is not bound':
        'Actualización efectiva no verificada: la relajación no está vinculada',
    'Tiling-inspired; exact substitution tiling unverified':
        'Inspirado en teselados; sustitución exacta no verificada',
    'Packing-inspired; canonical tangency unverified':
        'Inspirado en empaquetamientos; tangencia canónica no verificada',
    'Rule-inspired procedural visualization':
        'Visualización procedural inspirada en reglas',
    'Procedural rule view': 'Vista procedural de reglas',
    'Procedural rule visualization': 'Visualización procedural de reglas',
    'Nearest-root basin coloring': 'Coloreado según la raíz más cercana',
    'Escape/boundedness of initial conditions, not orbit density':
        'Escape o acotación de condiciones iniciales, no densidad de órbitas',
    '2D time-varying slice of 4D state':
        'Sección 2D variable en el tiempo de un estado 4D',
    'Escape-time': 'Tiempo de escape',
    'Orbit-trap coloring': 'Coloreado por trampas orbitales',
    'Householder correction': 'Corrección de Householder',
    'No verified relationship': 'Sin relación verificada',
    'Parameter configuration of quadratic Julia':
        'Configuración de parámetros de Julia cuadrática',
    'Exponent-family member; not necessarily polynomial':
        'Miembro de una familia de exponentes; no necesariamente polinómico',
    'Different recurrence: memory term, not Julia coloring':
        'Recurrencia diferente: término de memoria, no coloreado de Julia',
    'Coloring/measurement variant of quadratic Mandelbrot':
        'Variante de coloreado o medición de Mandelbrot cuadrático',
    'Different recurrence: conjugate before powering':
        'Recurrencia diferente: conjugación antes de elevar a la potencia',
    'Different recurrence: componentwise absolute value before powering':
        'Recurrencia diferente: valor absoluto por componente antes de elevar',
    'Rule configuration; procedural visualization, not verified CA evolution':
        'Configuración de reglas; visualización procedural, no evolución celular verificada',
    'Related root-finding methods; not aliases':
        'Métodos relacionados de búsqueda de raíces; no son alias',
    'Related aperiodic tilings; not aliases':
        'Teselados aperiódicos relacionados; no son alias',
    'Related inversive constructions, different dimension; slice/projection unverified':
        'Construcciones inversivas relacionadas de distinta dimensión; sección o proyección no verificada',
    'Underlying algebra differs from rendered dimension':
        'El álgebra subyacente es distinta de la dimensión representada',
    'Related method in a different algebra; not a complex alias':
        'Método relacionado en otra álgebra; no es un alias complejo',
    'Unverified formula: this renderer has not been mathematically reviewed':
        'Fórmula no verificada: este renderizador no se ha revisado matemáticamente',
  }[value];
  if (label != null) return label;
  var translated = value;
  for (final entry in const <String, String>{
    'Unverified effective formula': 'Fórmula efectiva no verificada',
    'relaxation uniform not bound': 'relajación no vinculada',
    'branch-selected real power': 'potencia real con rama seleccionada',
    'rational-map variant, not inverse iteration':
        'variante de mapa racional, no iteración inversa',
    'integer-degree polynomial': 'polinomio de grado entero',
    'radius floor': 'radio mínimo',
    'power-family member': 'miembro de una familia de potencias',
    'quadratic Tricorn': 'Tricorn cuadrático',
    'changes measurement/coloring, not recurrence':
        'cambia la medición o el coloreado, no la recurrencia',
    'orbit-trap mode': 'modo de trampa orbital',
    'procedural rule visualization, not verified CA evolution':
        'visualización procedural de reglas, no evolución celular verificada',
    'color does not prove convergence': 'el color no demuestra convergencia',
    'regularized division': 'división regularizada',
    'initial state': 'estado inicial',
    'finite orbit of 0 only': 'solo la órbita finita de 0',
    'escape/boundedness view': 'vista de escape o acotación',
    'transcendental components clamped to':
        'componentes trascendentes limitados a',
    'input components clamped to': 'componentes de entrada limitados a',
    'safe log/division': 'logaritmo y división protegidos',
    'quaternion': 'cuaternión',
  }.entries) {
    translated = translated.replaceAll(entry.key, entry.value);
  }
  return translated;
}

class FractalMathSummary extends StatelessWidget {
  const FractalMathSummary({
    super.key,
    required this.module,
    this.category,
    this.params,
    this.compact = false,
  });

  final FractalModule module;
  final String? category;
  final Map<String, dynamic>? params;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (module.id == 'fibonacci_complex_julia') {
      // Bound the catalog caption visually, retaining the complete legend in
      // Text's semantics and in the unabridged viewer details.
      return Text(AppLocalizations.of(context)!.fibonacciComplexLegend,
          key: const Key('fibonacciComplexLegend'),
          maxLines: compact ? 3 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
          style: compact
              ? AppTypography.labelSmall.copyWith(fontSize: 11, height: 1.25)
              : AppTypography.labelSmall);
    }
    final math = FractalMathematics.forModule(module, category: category);
    final formula = mathematicalLabel(
      context,
      math.formula(params ?? module.defaultPreset.params),
    );
    final qualification = mathematicalLabel(context, math.qualification);
    final spanish = Localizations.localeOf(context).languageCode == 'es';
    final style = AppTypography.labelSmall.copyWith(
      color: AppColors.textSecondary,
      fontSize: compact ? 11 : 12,
      height: 1.25,
    );
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formula,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: style),
          Text(qualification,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ],
      );
    }
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${spanish ? 'Configuración inicial' : 'Starting configuration'}: ${module.displayName(l10n)}',
            style: style,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            spanish ? 'Regla / fórmula actual' : 'Current rule / formula',
            style:
                AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
          ),
          Text(formula,
              key: const Key('currentMathematicalFormula'), style: style),
          Text(
            [math.family, math.algebra, math.view, math.method]
                .where((value) => value.isNotEmpty)
                .map((value) => mathematicalLabel(context, value))
                .join(' · '),
            style: style,
          ),
          Text(qualification, style: style),
          if (math.relationship != 'No verified relationship')
            Text(mathematicalLabel(context, math.relationship), style: style),
        ],
      ),
    );
  }
}
