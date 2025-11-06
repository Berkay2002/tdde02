import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/permission_service.dart';
import '../providers/camera_provider.dart';
import '../widgets/camera_controls_widget.dart';
import 'image_preview_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = PermissionService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraState = ref.read(cameraNotifierProvider);
    final controller = cameraState.controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await _permissionService.checkCameraPermission();

    if (!hasPermission) {
      final granted = await _permissionService.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
    }

    await ref.read(cameraNotifierProvider.notifier).initializeCamera();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to scan your fridge. Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _permissionService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCapture() async {
    final image =
        await ref.read(cameraNotifierProvider.notifier).takePicture();

    if (image != null && mounted) {
      _navigateToPreview(image.path);
    }
  }

  Future<void> _handleGalleryPick() async {
    final hasPermission = await _permissionService.checkStoragePermission();

    if (!hasPermission) {
      final granted = await _permissionService.requestStoragePermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to access photos'),
            ),
          );
        }
        return;
      }
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      _navigateToPreview(image.path);
    }
  }

  void _navigateToPreview(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
          imagePath: imagePath,
          onRetake: () => Navigator.pop(context),
          onConfirm: () {
            Navigator.pop(context);
            Navigator.pop(context, imagePath);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Fridge',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(cameraState),
    );
  }

  Widget _buildBody(CameraState cameraState) {
    switch (cameraState.status) {
      case CameraStatus.initial:
      case CameraStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );

      case CameraStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  cameraState.errorMessage ?? 'An error occurred',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _initializeCamera,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case CameraStatus.ready:
      case CameraStatus.capturing:
        final controller = cameraState.controller;
        if (controller == null || !controller.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CameraControlsWidget(
                onCapture: _handleCapture,
                onToggleFlash: () =>
                    ref.read(cameraNotifierProvider.notifier).toggleFlash(),
                onGalleryPick: _handleGalleryPick,
                isFlashOn: cameraState.isFlashOn,
                isCapturing: cameraState.status == CameraStatus.capturing,
              ),
            ),
          ],
        );
    }
  }
}
