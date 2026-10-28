import 'package:integration_test/integration_test.dart';

import '../../test/fractal/quaternion_julia_3d_drag_direction_test.dart'
    as regression;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  regression.main();
}
