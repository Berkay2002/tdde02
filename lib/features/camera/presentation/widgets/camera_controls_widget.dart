import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraControlsWidget extends ConsumerWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleFlash;
  final VoidCallback onGalleryPick;
  final bool isFlashOn;
  final bool isCapturing;

  const CameraControlsWidget({
    super.key,
    required this.onCapture,
    required this.onToggleFlash,
    required this.onGalleryPick,
    required this.isFlashOn,
    required this.isCapturing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: onGalleryPick,
              icon: const Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 32,
              ),
            ),
            GestureDetector(
              onTap: isCapturing ? null : () {
                HapticFeedback.mediumImpact();
                onCapture();
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            IconButton(
              onPressed: onToggleFlash,
              icon: Icon(
                isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
