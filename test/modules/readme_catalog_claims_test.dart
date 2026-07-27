import 'dart:convert';
import 'dart:io';

import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Anchors the public copy in README.md (and the store listing) to the code.
///
/// If these fail, the registry or palette set changed size: update the
/// numbers in README.md and docs/store_listing/ together with this test.
void main() {
  test('public production fractal counts match the registry', () {
    final modules = ModuleRegistry().modules;
    final production = modules
        .where((m) => !m.shaderAsset.startsWith('shaders/diagnostic/'))
        .length;
    final diagnostics = modules.length - production;

    expect(production, 977,
        reason: 'README.md advertises 977 production fractals');
    expect(diagnostics, 7,
        reason: 'README.md says debug/test builds add 7 diagnostic modules');

    expect(
      File('README.md').readAsStringSync(),
      contains('$production production fractals'),
    );

    final listing = jsonDecode(
      File('docs/play-store-localized-listings.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(listing['count'], '$production production fractals');

    final locales = listing['locales'] as Map<String, dynamic>;
    for (final entry in locales.entries) {
      final copy = entry.value as Map<String, dynamic>;
      expect(copy['shortDescription'], contains('$production'),
          reason: '${entry.key} short description has a stale catalog count');
      expect(copy['fullDescription'], contains('$production'),
          reason: '${entry.key} full description has a stale catalog count');
    }
  });

  test('README color scheme count is backed by the palette set', () {
    expect(CommonFractalParams.paletteCount, greaterThanOrEqualTo(60),
        reason: 'README.md advertises 60+ color schemes');
  });

  test('public copy does not advertise undeclared device capabilities', () {
    // Counts were already anchored here, which is why "977" survived fifteen
    // translations. Capability claims were not, which is how "camera overlay
    // experiments" reached thirteen locales and the published privacy policy
    // for an app that has never requested camera access.
    //
    // Scope is deliberately store and legal surfaces only. README.md says
    // "camera angles" about the fractal viewport, which is legitimate
    // developer copy; a user reading a store listing cannot tell the two
    // apart, which is exactly why the listing must not say it.
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final declared = RegExp(r'android:name="android\.permission\.([A-Z_]+)"')
        .allMatches(manifest)
        .map((m) => m.group(1)!)
        .toSet();

    // Capability -> the permission that would justify mentioning it, and the
    // words that name it across the locales the listing ships in.
    const capabilities = <String, ({String permission, List<String> terms})>{
      'camera': (
        permission: 'CAMERA',
        terms: [
          'camera', 'kamera', 'caméra', 'cámara', 'fotocamera',
          'カメラ', '카메라', '相机', '相機', 'कैमरा',
        ],
      ),
      'microphone': (
        permission: 'RECORD_AUDIO',
        terms: [
          'microphone', 'mikrofon', 'micrófono', 'microfono',
          'マイク', '마이크', '麦克风', '麥克風', 'माइक',
        ],
      ),
      'bluetooth': (permission: 'BLUETOOTH', terms: ['bluetooth']),
    };

    final surfaces = <String, String>{
      'docs/store_listing/full_description.txt': '',
      'docs/store_listing/short_description.txt': '',
    };
    for (final path in surfaces.keys.toList()) {
      final f = File(path);
      if (f.existsSync()) surfaces[path] = f.readAsStringSync();
    }
    final listing = jsonDecode(
      File('docs/play-store-localized-listings.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final entry in (listing['locales'] as Map<String, dynamic>).entries) {
      final copy = entry.value as Map<String, dynamic>;
      surfaces['play listing ${entry.key}'] =
          '${copy['title']}\n${copy['shortDescription']}\n'
          '${copy['fullDescription']}';
    }

    // The privacy policy is a different case and is checked separately below:
    // it is correct, and deliberate, for it to enumerate capabilities under
    // "Permissions we do not request". A bare-term scan cannot tell that
    // apart from a claim, so the policy is matched on affirmative phrasing
    // instead. It is a single English document, so English patterns suffice.
    final policy = File('web/privacy-policy.html');
    if (policy.existsSync()) {
      final text = policy.readAsStringSync();
      for (final cap in capabilities.entries) {
        if (declared.contains(cap.value.permission)) continue;
        final claim = RegExp(
          r'(requests?|require[sd]?|uses?|access(es)? (to )?(your )?)'
          r'[^.<>]{0,40}\b${cap.key}\b'
              .replaceAll(r'${cap.key}', RegExp.escape(cap.key)),
          caseSensitive: false,
        );
        expect(
          claim.hasMatch(text),
          isFalse,
          reason: 'web/privacy-policy.html appears to claim ${cap.key} use, '
              'but android.permission.${cap.value.permission} is not '
              'declared. Stating that a capability is NOT requested is fine; '
              'claiming it is used is not.',
        );
      }
    }

    for (final cap in capabilities.entries) {
      if (declared.contains(cap.value.permission)) continue;
      for (final term in cap.value.terms) {
        // ASCII terms get word boundaries so "camera" does not match inside
        // an unrelated word; CJK and Devanagari have no such boundaries.
        final ascii = RegExp(r'^[a-zA-Zàâçéèêëîïôûùüÿñæœ]+$').hasMatch(term);
        final pattern = RegExp(
          ascii ? '\\b${RegExp.escape(term)}\\b' : RegExp.escape(term),
          caseSensitive: false,
          unicode: true,
        );
        for (final surface in surfaces.entries) {
          expect(
            pattern.hasMatch(surface.value),
            isFalse,
            reason: '${surface.key} mentions "$term", but the app does not '
                'declare android.permission.${cap.value.permission}. Either '
                'add the permission because the feature is real, or reword '
                'the copy — advertising a capability the app cannot use is a '
                'store-policy and privacy-statement problem.',
          );
        }
      }
    }
  });
}
