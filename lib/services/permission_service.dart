import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

class PermissionService {
  // Request camera permission
  static Future<PermissionResult> requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return PermissionResult.granted;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return PermissionResult.granted;
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  // Request photo library permission
  static Future<PermissionResult> requestPhotoLibraryPermission() async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return PermissionResult.granted;
    }

    if (status.isDenied) {
      final result = await Permission.photos.request();
      if (result.isGranted) {
        return PermissionResult.granted;
      } else if (result.isPermanentlyDenied) {
        return PermissionResult.permanentlyDenied;
      } else {
        return PermissionResult.denied;
      }
    }

    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  // Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    return await Permission.camera.isGranted;
  }

  // Check if photo library permission is granted
  static Future<bool> isPhotoLibraryPermissionGranted() async {
    return await Permission.photos.isGranted;
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.grey[300],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90EE90),
                foregroundColor: Colors.black,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
