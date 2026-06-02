import 'frm_lexer.dart';

/// Replayable numeric-literal contract for the FRM subset.
///
/// The lexer validates numeric syntax, but `double.parse` can still promote
/// very large exponents (for example `1e999`) to Infinity. FRM evaluation only
/// has finite complex scalars, so reject non-finite literals at the parser
/// boundary before they become hidden NaN/Infinity state.
final class FrmNumberLiteral {
  const FrmNumberLiteral({required this.lexeme, required this.offset});

  factory FrmNumberLiteral.fromToken(FrmTok token) {
    assert(token.kind == FrmTokKind.number, 'expected number token');
    return FrmNumberLiteral(lexeme: token.lexeme, offset: token.offset);
  }

  final String lexeme;
  final int offset;

  double parseFinite() {
    final value = double.parse(lexeme);
    if (value.isFinite) return value;
    throw FormatException('Numeric literal must be finite', lexeme, offset);
  }
}
