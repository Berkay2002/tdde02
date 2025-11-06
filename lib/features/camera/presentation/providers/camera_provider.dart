import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'camera_provider.g.dart';

enum CameraStatus { initial, loading, ready, error, capturing }

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final String? errorMessage;
  final bool isFlashOn;
  final List<CameraDescription> availableCameras;

  CameraState({
    required this.status,
    this.controller,
    this.errorMessage,
    this.isFlashOn = false,
    this.availableCameras = const [],
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    String? errorMessage,
    bool? isFlashOn,
    List<CameraDescription>? availableCameras,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      errorMessage: errorMessage ?? this.errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      availableCameras: availableCameras ?? this.availableCameras,
    );
  }
}

@riverpod
class CameraNotifier extends _$CameraNotifier {
  @override
  CameraState build() {
    ref.onDispose(() {
      state.controller?.dispose();
    });

    return CameraState(status: CameraStatus.initial);
  }

  Future<void> initializeCamera() async {
    state = state.copyWith(status: CameraStatus.loading);

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'No cameras available',
        );
        return;
      }

      final camera = cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      await controller.setFlashMode(FlashMode.off);

      state = state.copyWith(
        status: CameraStatus.ready,
        controller: controller,
        availableCameras: cameras,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to initialize camera: ${e.toString()}',
      );
    }
  }

  Future<XFile?> takePicture() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return null;
    }

    if (state.status == CameraStatus.capturing) {
      return null;
    }

    state = state.copyWith(status: CameraStatus.capturing);

    try {
      final image = await controller.takePicture();
      state = state.copyWith(status: CameraStatus.ready);
      return image;
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to capture image: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> toggleFlash() async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final newFlashState = !state.isFlashOn;
      await controller.setFlashMode(
        newFlashState ? FlashMode.torch : FlashMode.off,
      );
      state = state.copyWith(isFlashOn: newFlashState);
    } catch (e) {
      debugPrint('Failed to toggle flash: $e');
    }
  }

  void dispose() {
    state.controller?.dispose();
  }
}
