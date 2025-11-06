import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'camera': await checkCameraPermission(),
      'storage': await checkStoragePermission(),
    };
  }

  Future<bool> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
}
