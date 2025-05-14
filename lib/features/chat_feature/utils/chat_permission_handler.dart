import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPermissionHandler {
  // Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(
          context,
          'Camera Permission Required',
          'Camera permission is required for video calls. Please enable it in app settings.'
      );
      return false;
    } else {
      _showPermissionDeniedSnackBar(context, 'Camera permission is required for video calls.');
      return false;
    }
  }

  // Request microphone permission
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(
          context,
          'Microphone Permission Required',
          'Microphone permission is required for calls. Please enable it in app settings.'
      );
      return false;
    } else {
      _showPermissionDeniedSnackBar(context, 'Microphone permission is required for calls.');
      return false;
    }
  }

  // Request both camera and microphone permissions
  static Future<bool> requestCallPermissions(BuildContext context, {bool videoCall = true}) async {
    bool micPermission = await requestMicrophonePermission(context);

    if (!micPermission) {
      return false;
    }

    if (videoCall) {
      bool cameraPermission = await requestCameraPermission(context);
      return cameraPermission;
    }

    return true;
  }

  // Request storage permission for file uploads
  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(
          context,
          'Storage Permission Required',
          'Storage permission is required to upload files. Please enable it in app settings.'
      );
      return false;
    } else {
      _showPermissionDeniedSnackBar(context, 'Storage permission is required to upload files.');
      return false;
    }
  }

  // Show snackbar for denied permission
  static void _showPermissionDeniedSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show dialog for permanently denied permission
  static void _showPermanentlyDeniedDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}