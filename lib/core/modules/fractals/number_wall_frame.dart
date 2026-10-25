import 'package:flutter_fractals/core/models/number_wall_model.dart';
import 'number_wall_module.dart';

/// One certified set of settings and its completed immutable exact field.
/// Callers publish both together; replay flags never certify a field.
class NumberWallFrame {
  NumberWallFrame(this.params, this.grid);

  final Map<String, Object> params;
  final NumberWallGrid grid;

  static Future<({NumberWallPrimeStatus status, NumberWallFrame? frame})>
      prepare(
    Map<String, Object> params, {
    required bool Function() isCancelled,
    NumberWallFrame? previous,
    int maxTrialDivisions = NumberWallPrimeValidator.defaultMaxTrialDivisions,
  }) async {
    final rawPrime = params['prime'];
    // The previous frame is module-owned proof, unlike replayed JSON flags.
    // Reusing that exact canonical prime also preserves Continue certifications
    // that required more work than the default validation budget.
    final check = previous != null && rawPrime == previous.grid.prime.toString()
        ? NumberWallPrimeCheck(NumberWallPrimeStatus.verifiedPrime,
            prime: previous.grid.prime)
        : await NumberWallPrimeValidator.validate(
            rawPrime is String ? rawPrime : '',
            isCancelled: isCancelled,
            maxTrialDivisions: maxTrialDivisions,
          );
    if (isCancelled()) {
      return (status: NumberWallPrimeStatus.cancelled, frame: null);
    }
    if (check.status != NumberWallPrimeStatus.verifiedPrime) {
      return (status: check.status, frame: null);
    }
    final rows = (params['rows'] as num).toInt();
    final columns = (params['columns'] as num).toInt();
    final start = (params['columnStart'] as num).toInt();
    if (start < rows - 1) {
      return (status: NumberWallPrimeStatus.invalid, frame: null);
    }
    final source = numberWallSequenceFromParameter(params['source']);
    final oldGrid = previous?.grid;
    final grid = oldGrid != null &&
            oldGrid.sequence == source &&
            oldGrid.prime == check.prime &&
            oldGrid.rowCount == rows &&
            oldGrid.columnCount == columns &&
            oldGrid.columnStart == start
        ? oldGrid
        : await NumberWallGrid.generate(
            sequence: source,
            prime: check.prime!,
            rowCount: rows,
            columnStart: start,
            columnCount: columns,
            isCancelled: isCancelled,
          );
    if (isCancelled() || grid == null) {
      return (status: NumberWallPrimeStatus.cancelled, frame: null);
    }
    return (
      status: NumberWallPrimeStatus.verifiedPrime,
      frame: NumberWallFrame(
          Map.unmodifiable({...params, 'prime': check.prime.toString()}), grid),
    );
  }
}
