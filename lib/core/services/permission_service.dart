import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await permission_handler.Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    final status = await permission_handler.Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await permission_handler.Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    final status = await permission_handler.Permission.photos.status;
    return status.isGranted;
  }

  Future<bool> openAppSettings() async {
    return await permission_handler.openAppSettings();
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await checkCameraPermission(),
      'storage': await checkStoragePermission(),
    };
  }

  Future<bool> requestAllPermissions() async {
    final Map<
      permission_handler.Permission,
      permission_handler.PermissionStatus
    >
    statuses = await [
      permission_handler.Permission.camera,
      permission_handler.Permission.photos,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
}
