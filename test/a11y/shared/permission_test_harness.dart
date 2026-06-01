import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class DenyAllPermissions extends PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return {
      for (final p in permissions) p: PermissionStatus.denied,
    };
  }

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return PermissionStatus.denied;
  }
}

void installDenyAllPermissionsHandler() {
  PermissionHandlerPlatform.instance = DenyAllPermissions();
}
