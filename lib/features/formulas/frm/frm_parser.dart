import 'frm_ast.dart';
import 'frm_lexer.dart';

/// Parser for a small Fractint-style .frm subset.
///
/// Current supported subset:
/// - Multiple formulas per file.
/// - `name { <init-stmts> : <iter-stmts> }`
/// - Stmts: `<ident> = <expr>` separated by newlines.
/// - Expr: numbers, identifiers, (re,im) complex literals, + - * / with parens.
///
/// This is intentionally small; we’ll extend it iteratively with functions,
/// power, comparisons, and bailout conditions once golden iteration tests are in.
final class FrmParser {
  FrmParser(String src) : _toks = FrmLexer(src).tokenize();

  final List<FrmTok> _toks;
  int _p = 0;

  FrmFile parseFile() {
    final formulas = <FrmFormula>[];
    _skipNewlines();
    while (!_peekIs(FrmTokKind.eof)) {
      formulas.add(_parseFormula());
      _skipNewlines();
    }
    return FrmFile(formulas);
  }

  FrmFormula _parseFormula() {
    final nameTok = _expect(FrmTokKind.ident, 'Expected formula name');
    _skipNewlines();
    _expect(FrmTokKind.lBrace, 'Expected "{" after formula name');

    final init = <FrmStmt>[];
    final iter = <FrmStmt>[];

    _skipNewlines();
    while (!_peekIs(FrmTokKind.colon)) {
      if (_peekIs(FrmTokKind.rBrace)) {
        throw FormatException('Expected ":" in formula body', '', _peek().offset);
      }
      final stmt = _parseStmt();
      init.add(stmt);
      _skipNewlines();
    }

    _expect(FrmTokKind.colon, 'Expected ":" separating init/iter');
    _skipNewlines();

    while (!_peekIs(FrmTokKind.rBrace)) {
      if (_peekIs(FrmTokKind.eof)) {
        throw FormatException('Unterminated formula body', '', _peek().offset);
      }
      final stmt = _parseStmt();
      iter.add(stmt);
      _skipNewlines();
    }

    _expect(FrmTokKind.rBrace, 'Expected "}"');

    return FrmFormula(name: nameTok.lexeme, init: init, iter: iter);
  }

  FrmStmt _parseStmt() {
    final name = _expect(FrmTokKind.ident, 'Expected identifier').lexeme;
    _expect(FrmTokKind.eq, 'Expected "="');
    final expr = _parseExpr();
    return FrmAssign(name, expr);
  }

  FrmExpr _parseExpr() => _parseAddSub();

  FrmExpr _parseAddSub() {
    var expr = _parseMulDiv();
    while (true) {
      if (_match(FrmTokKind.plus)) {
        expr = FrmBinary(FrmBinaryOp.add, expr, _parseMulDiv());
        continue;
      }
      if (_match(FrmTokKind.minus)) {
        expr = FrmBinary(FrmBinaryOp.sub, expr, _parseMulDiv());
        continue;
      }
      return expr;
    }
  }

  FrmExpr _parseMulDiv() {
    var expr = _parsePrimary();
    while (true) {
      if (_match(FrmTokKind.star)) {
        expr = FrmBinary(FrmBinaryOp.mul, expr, _parsePrimary());
        continue;
      }
      if (_match(FrmTokKind.slash)) {
        expr = FrmBinary(FrmBinaryOp.div, expr, _parsePrimary());
        continue;
      }
      return expr;
    }
  }

  FrmExpr _parsePrimary() {
    if (_match(FrmTokKind.number)) {
      return FrmNumber(double.parse(_prev().lexeme));
    }

    if (_match(FrmTokKind.ident)) {
      return FrmVar(_prev().lexeme);
    }

    if (_match(FrmTokKind.lParen)) {
      // Could be (expr) or (re,im)
      final first = _parseExpr();
      if (_match(FrmTokKind.comma)) {
        final second = _parseExpr();
        _expect(FrmTokKind.rParen, 'Expected ")"');
        return FrmComplexLiteral(first, second);
      }
      _expect(FrmTokKind.rParen, 'Expected ")"');
      return first;
    }

    if (_match(FrmTokKind.minus)) {
      // unary minus: -x  => (0 - x)
      return FrmBinary(FrmBinaryOp.sub, const FrmNumber(0), _parsePrimary());
    }

    throw FormatException('Expected expression', '', _peek().offset);
  }

  void _skipNewlines() {
    while (_match(FrmTokKind.newline)) {}
  }

  bool _match(FrmTokKind kind) {
    if (_peekIs(kind)) {
      _p++;
      return true;
    }
    return false;
  }

  FrmTok _expect(FrmTokKind kind, String msg) {
    final tok = _peek();
    if (tok.kind != kind) {
      throw FormatException(msg, '', tok.offset);
    }
    _p++;
    return tok;
  }

  FrmTok _peek() => _toks[_p];
  FrmTok _prev() => _toks[_p - 1];
  bool _peekIs(FrmTokKind k) => _peek().kind == k;
}
