import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

// The official adapter decodes the binding's terminal response and exits nonzero
// on failure. Only its success callback can produce the supervisor's receipt.
Future<void> main() async {
  await integrationDriver(responseDataCallback: (data) async {
    await writeResponseData(data);
    await File(Platform.environment['NATIVE_INTEGRATION_RESULT']!)
        .writeAsString('{"allTestsPassed":true}');
  });
}
