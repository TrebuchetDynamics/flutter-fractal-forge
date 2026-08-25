import 'package:flutter_fractals/features/renderer/cpu/cpu_seed_hash.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fnv1a32 matches fixed 32-bit reference vectors', () {
    expect(fnv1a32(''), 0x811c9dc5);
    expect(fnv1a32('a'), 0xe40c292c);
    expect(fnv1a32('foobar'), 0xbf9cf968);
    expect(fnv1a32('sierpinski_triangle'), 0x2929b303);
  });
}
