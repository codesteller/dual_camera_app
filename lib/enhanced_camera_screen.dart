import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'main.dart'; // Import to access the cameras list

class EnhancedDualCameraScreen extends StatefulWidget {
  const EnhancedDualCameraScreen({super.key});

  @override
  State<EnhancedDualCameraScreen> createState() => _EnhancedDualCameraScreenState();
}

class _EnhancedDualCameraScreenState extends State<EnhancedDualCameraScreen> {
  CameraController? frontCameraController;
  CameraController? rearCameraController;
  bool isInitialized = false;
  bool hasPermission = false;
  String errorMessage = '';
  bool isRearCameraOnTop = true;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  Future<void> initializeCameras() async {
    // Request camera permission
    final permissionStatus = await Permission.camera.request();
    
    if (permissionStatus != PermissionStatus.granted) {
      setState(() {
        hasPermission = false;
        errorMessage = 'Camera permission denied';
      });
      return;
    }

    setState(() {
      hasPermission = true;
    });

    if (cameras.isEmpty) {
      setState(() {
        errorMessage = 'No cameras available';
      });
      return;
    }

    try {
      // Find front and rear cameras
      CameraDescription? frontCamera;
      CameraDescription? rearCamera;

      for (CameraDescription camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
        } else if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
        }
      }

      // Initialize controllers
      if (rearCamera != null) {
        rearCameraController = CameraController(
          rearCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await rearCameraController!.initialize();
      }

      if (frontCamera != null) {
        frontCameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await frontCameraController!.initialize();
      }

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing cameras: $e';
      });
    }
  }

  Future<void> takePicture(CameraController? controller, String cameraType) async {
    if (controller == null || !controller.value.isInitialized || isCapturing) {
      return;
    }

    setState(() {
      isCapturing = true;
    });

    try {
      // Get the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${appDocDir.path}/${cameraType}_$timestamp.jpg';

      // Take the picture
      final XFile picture = await controller.takePicture();
      
      // Copy to app directory
      await picture.saveTo(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cameraType picture saved!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking $cameraType picture: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  void switchCameraPositions() {
    setState(() {
      isRearCameraOnTop = !isRearCameraOnTop;
    });
  }

  @override
  void dispose() {
    frontCameraController?.dispose();
    rearCameraController?.dispose();
    super.dispose();
  }

  Widget buildEnhancedCameraPreview(CameraController? controller, String label, bool isTopCamera) {
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        CameraPreview(controller),
        // Camera label
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Capture button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: label,
            mini: true,
            onPressed: isCapturing ? null : () => takePicture(controller, label),
            backgroundColor: isCapturing ? Colors.grey : Colors.white,
            child: isCapturing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/FusionLens_logo.png',
                height: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Dual View',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.cyanAccent,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF181A2A),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/FusionLens_logo.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  initializeCameras();
                },
                child: const Text('Grant Camera Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (!isInitialized && errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/FusionLens_logo.png',
                height: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Dual View',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.cyanAccent,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF181A2A),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/FusionLens_logo.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    errorMessage = '';
                  });
                  initializeCameras();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final topCamera = isRearCameraOnTop ? rearCameraController : frontCameraController;
            final bottomCamera = isRearCameraOnTop ? frontCameraController : rearCameraController;
            final topLabel = isRearCameraOnTop ? 'Rear Camera' : 'Front Camera';
            final bottomLabel = isRearCameraOnTop ? 'Front Camera' : 'Rear Camera';

            if (orientation == Orientation.portrait) {
              // Portrait mode: Top and bottom layout
              return Column(
                children: [
                  // Top camera
                  Expanded(
                    child: buildEnhancedCameraPreview(topCamera, topLabel, true),
                  ),
                  // Controls bar
                  Container(
                    height: 60,
                    color: Colors.grey[900],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: switchCameraPositions,
                          icon: const Icon(Icons.swap_vert, color: Colors.white),
                          tooltip: 'Switch Camera Positions',
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Dual Camera View',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom camera
                  Expanded(
                    child: buildEnhancedCameraPreview(bottomCamera, bottomLabel, false),
                  ),
                ],
              );
            } else {
              // Landscape mode: Left and right layout
              return Row(
                children: [
                  // Left camera
                  Expanded(
                    child: buildEnhancedCameraPreview(topCamera, topLabel, true),
                  ),
                  // Controls bar
                  Container(
                    width: 60,
                    color: Colors.grey[900],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: switchCameraPositions,
                          icon: const Icon(Icons.swap_horiz, color: Colors.white),
                          tooltip: 'Switch Camera Positions',
                        ),
                        const SizedBox(height: 20),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'Dual Camera',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right camera
                  Expanded(
                    child: buildEnhancedCameraPreview(bottomCamera, bottomLabel, false),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
