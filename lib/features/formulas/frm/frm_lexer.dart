// A small lexer for a restricted Fractint-like .frm subset.
//
// Supported tokens (initial subset):
// - identifiers: [A-Za-z_][A-Za-z0-9_]*
// - numbers: 123, 1.23, .5, 1e-3
// - punctuation: { } ( ) , : = + - * / ^
// - comparisons: == != < <= > >=
// - comments: ; to end of line

enum FrmTokKind {
  ident,
  number,
  lBrace,
  rBrace,
  lParen,
  rParen,
  comma,
  colon,
  eq,
  eqEq,
  lt,
  le,
  gt,
  ge,
  ne,
  plus,
  minus,
  star,
  slash,
  caret,
  newline,
  eof,
}

final class FrmTok {
  const FrmTok(this.kind, this.lexeme, this.offset);

  final FrmTokKind kind;
  final String lexeme;
  final int offset;

  @override
  String toString() => '$kind("$lexeme")@$offset';
}

final class FrmLexer {
  FrmLexer(this.src);

  final String src;
  int _i = 0;

  List<FrmTok> tokenize() {
    final out = <FrmTok>[];
    while (true) {
      final tok = _next();
      out.add(tok);
      if (tok.kind == FrmTokKind.eof) return out;
    }
  }

  FrmTok _next() {
    _skipSpaces();
    if (_i >= src.length) return FrmTok(FrmTokKind.eof, '', _i);

    final c = src.codeUnitAt(_i);

    // newline
    if (c == 0x0A) {
      _i++;
      return FrmTok(FrmTokKind.newline, '\n', _i - 1);
    }
    if (c == 0x0D) {
      // CRLF or CR
      final start = _i;
      _i++;
      if (_i < src.length && src.codeUnitAt(_i) == 0x0A) _i++;
      return FrmTok(FrmTokKind.newline, '\n', start);
    }

    // comment ;...
    if (c == 0x3B) {
      while (_i < src.length) {
        final cc = src.codeUnitAt(_i);
        if (cc == 0x0A || cc == 0x0D) break;
        _i++;
      }
      // emit newline separately in next call
      return _next();
    }

    switch (c) {
      case 0x7B: // {
        _i++;
        return FrmTok(FrmTokKind.lBrace, '{', _i - 1);
      case 0x7D: // }
        _i++;
        return FrmTok(FrmTokKind.rBrace, '}', _i - 1);
      case 0x28: // (
        _i++;
        return FrmTok(FrmTokKind.lParen, '(', _i - 1);
      case 0x29: // )
        _i++;
        return FrmTok(FrmTokKind.rParen, ')', _i - 1);
      case 0x2C: // ,
        _i++;
        return FrmTok(FrmTokKind.comma, ',', _i - 1);
      case 0x3A: // :
        _i++;
        return FrmTok(FrmTokKind.colon, ':', _i - 1);
      case 0x3D: // = or ==
        _i++;
        if (_i < src.length && src.codeUnitAt(_i) == 0x3D) {
          _i++;
          return FrmTok(FrmTokKind.eqEq, '==', _i - 2);
        }
        return FrmTok(FrmTokKind.eq, '=', _i - 1);
      case 0x3C: // < or <=
        _i++;
        if (_i < src.length && src.codeUnitAt(_i) == 0x3D) {
          _i++;
          return FrmTok(FrmTokKind.le, '<=', _i - 2);
        }
        return FrmTok(FrmTokKind.lt, '<', _i - 1);
      case 0x3E: // > or >=
        _i++;
        if (_i < src.length && src.codeUnitAt(_i) == 0x3D) {
          _i++;
          return FrmTok(FrmTokKind.ge, '>=', _i - 2);
        }
        return FrmTok(FrmTokKind.gt, '>', _i - 1);
      case 0x21: // != (a bare ! is not a valid token)
        _i++;
        if (_i < src.length && src.codeUnitAt(_i) == 0x3D) {
          _i++;
          return FrmTok(FrmTokKind.ne, '!=', _i - 2);
        }
        throw FormatException('Unexpected character: !', src, _i - 1);
      case 0x2B: // +
        _i++;
        return FrmTok(FrmTokKind.plus, '+', _i - 1);
      case 0x2D: // -
        _i++;
        return FrmTok(FrmTokKind.minus, '-', _i - 1);
      case 0x2A: // *
        _i++;
        return FrmTok(FrmTokKind.star, '*', _i - 1);
      case 0x2F: // /
        _i++;
        return FrmTok(FrmTokKind.slash, '/', _i - 1);
      case 0x5E: // ^
        _i++;
        return FrmTok(FrmTokKind.caret, '^', _i - 1);
    }

    if (_isDigit(c) || c == 0x2E /* . */) {
      return _number();
    }

    if (_isAlpha(c) || c == 0x5F /* _ */) {
      return _ident();
    }

    throw FormatException(
        'Unexpected character: ${String.fromCharCode(c)}', src, _i);
  }

  void _skipSpaces() {
    while (_i < src.length) {
      final c = src.codeUnitAt(_i);
      if (c == 0x20 || c == 0x09) {
        _i++;
        continue;
      }
      break;
    }
  }

  FrmTok _ident() {
    final start = _i;
    _i++;
    while (_i < src.length) {
      final c = src.codeUnitAt(_i);
      if (_isAlphaNum(c) || c == 0x5F) {
        _i++;
      } else {
        break;
      }
    }
    return FrmTok(FrmTokKind.ident, src.substring(start, _i), start);
  }

  FrmTok _number() {
    final start = _i;

    bool sawDigit = false;

    // int part or leading '.'
    if (_i < src.length && _isDigit(src.codeUnitAt(_i))) {
      sawDigit = true;
      while (_i < src.length && _isDigit(src.codeUnitAt(_i))) {
        _i++;
      }
    }

    // decimal
    if (_i < src.length && src.codeUnitAt(_i) == 0x2E /* . */) {
      _i++;
      while (_i < src.length && _isDigit(src.codeUnitAt(_i))) {
        sawDigit = true;
        _i++;
      }
    }

    if (!sawDigit) {
      throw FormatException('Invalid number', src, start);
    }

    // exponent
    if (_i < src.length) {
      final c = src.codeUnitAt(_i);
      if (c == 0x65 /* e */ || c == 0x45 /* E */) {
        _i++;
        if (_i < src.length) {
          final s = src.codeUnitAt(_i);
          if (s == 0x2B /* + */ || s == 0x2D /* - */) _i++;
        }
        final expStart = _i;
        while (_i < src.length && _isDigit(src.codeUnitAt(_i))) {
          _i++;
        }
        if (expStart == _i) {
          throw FormatException('Invalid exponent', src, expStart);
        }
      }
    }

    return FrmTok(FrmTokKind.number, src.substring(start, _i), start);
  }

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;
  static bool _isAlpha(int c) =>
      (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  static bool _isAlphaNum(int c) => _isAlpha(c) || _isDigit(c);
}
