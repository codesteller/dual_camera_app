import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_diagnostic_screen.dart';
import 'alternating_camera_screen.dart';
import 'dual_camera_compatibility_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Get available cameras
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
  }
  
  runApp(const DualCameraApp());
}

class DualCameraApp extends StatelessWidget {
  const DualCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DualCameraHome(),
    );
  }
}

class DualCameraHome extends StatelessWidget {
  const DualCameraHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera App'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 40),
            const Text(
              'Camera App with Multiple Views',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose your preferred camera viewing mode',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DualCameraScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Dual Camera (May Show One)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DualCameraCompatibilityScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                'Dual Camera (Compatibility)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlternatingCameraScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Single Camera (Recommended)',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraDiagnosticScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Camera Diagnostic',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DualCameraScreen extends StatefulWidget {
  const DualCameraScreen({super.key});

  @override
  State<DualCameraScreen> createState() => _DualCameraScreenState();
}

class _DualCameraScreenState extends State<DualCameraScreen> {
  CameraController? frontCameraController;
  CameraController? rearCameraController;
  bool isInitialized = false;
  bool hasPermission = false;
  String errorMessage = '';
  bool showRearCamera = true; // Track which camera to prioritize
  bool isSwitching = false; // Track switching state

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
      // Debug: Print available cameras
      debugPrint('Total cameras found: ${cameras.length}');
      for (int i = 0; i < cameras.length; i++) {
        debugPrint('Camera $i: ${cameras[i].name} - ${cameras[i].lensDirection}');
      }

      // Find front and rear cameras
      CameraDescription? frontCamera;
      CameraDescription? rearCamera;

      for (CameraDescription camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          debugPrint('Found front camera: ${camera.name}');
        } else if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
          debugPrint('Found rear camera: ${camera.name}');
        }
      }

      // Initialize rear camera first
      if (rearCamera != null) {
        debugPrint('Initializing rear camera...');
        rearCameraController = CameraController(
          rearCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await rearCameraController!.initialize();
        debugPrint('Rear camera initialized successfully');
      } else {
        debugPrint('No rear camera found');
      }

      // Initialize front camera
      if (frontCamera != null) {
        debugPrint('Initializing front camera...');
        frontCameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await frontCameraController!.initialize();
        debugPrint('Front camera initialized successfully');
      } else {
        debugPrint('No front camera found');
      }

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
        debugPrint('Camera initialization completed. Front: ${frontCameraController != null}, Rear: ${rearCameraController != null}');
      }
    } catch (e) {
      debugPrint('Error during camera initialization: $e');
      setState(() {
        errorMessage = 'Error initializing cameras: $e';
      });
    }
  }

  Future<void> switchCamera() async {
    if (isSwitching) return;
    
    setState(() {
      isSwitching = true;
    });

    try {
      // Dispose both controllers
      await frontCameraController?.dispose();
      await rearCameraController?.dispose();
      frontCameraController = null;
      rearCameraController = null;

      // Switch the priority
      showRearCamera = !showRearCamera;

      // Find cameras
      CameraDescription? frontCamera;
      CameraDescription? rearCamera;

      for (CameraDescription camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
        } else if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
        }
      }

      // Initialize the prioritized camera first
      if (showRearCamera && rearCamera != null) {
        debugPrint('Switching to rear camera...');
        rearCameraController = CameraController(
          rearCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await rearCameraController!.initialize();
        debugPrint('Rear camera activated');
      } else if (!showRearCamera && frontCamera != null) {
        debugPrint('Switching to front camera...');
        frontCameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await frontCameraController!.initialize();
        debugPrint('Front camera activated');
      }

      if (mounted) {
        setState(() {
          isSwitching = false;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
      setState(() {
        errorMessage = 'Error switching camera: $e';
        isSwitching = false;
      });
    }
  }

  @override
  void dispose() {
    frontCameraController?.dispose();
    rearCameraController?.dispose();
    super.dispose();
  }

  Widget buildCameraPreview(CameraController? controller, String label) {
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.videocam_off,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                '$label - Not Available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                controller == null ? 'Camera not found' : 'Initializing...',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
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
              '$label - Active',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Add resolution info
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              controller.value.previewSize != null 
                ? '${controller.value.previewSize!.width.toInt()}x${controller.value.previewSize!.height.toInt()}'
                : 'Loading...',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
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
        child: Column(
          children: [
            // Debug info panel with switch button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange[900],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: const Text(
                          'Device Limitation: Only one camera can be active at a time',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: isSwitching ? null : switchCamera,
                        icon: Icon(
                          showRearCamera ? Icons.camera_front : Icons.camera_rear,
                          size: 16,
                        ),
                        label: Text(
                          showRearCamera ? 'Front' : 'Rear',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: const Size(80, 32),
                          backgroundColor: isSwitching ? Colors.grey : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cameras Found: ${cameras.length} | Front: ${frontCameraController != null ? "✓" : "✗"} | Rear: ${rearCameraController != null ? "✓" : "✗"}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Front Init: ${frontCameraController?.value.isInitialized ?? false} | Rear Init: ${rearCameraController?.value.isInitialized ?? false}',
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                      if (isSwitching) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Switching...',
                          style: TextStyle(color: Colors.white70, fontSize: 9),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Camera views
            Expanded(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.portrait) {
                    // Portrait mode: Top and bottom layout
                    return Column(
                      children: [
                        // Rear camera on top
                        Expanded(
                          child: buildCameraPreview(rearCameraController, 'Rear Camera'),
                        ),
                        // Divider
                        Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        // Front camera on bottom
                        Expanded(
                          child: buildCameraPreview(frontCameraController, 'Front Camera'),
                        ),
                      ],
                    );
                  } else {
                    // Landscape mode: Left and right layout
                    return Row(
                      children: [
                        // Rear camera on left
                        Expanded(
                          child: buildCameraPreview(rearCameraController, 'Rear Camera'),
                        ),
                        // Divider
                        Container(
                          width: 2,
                          color: Colors.white,
                        ),
                        // Front camera on right
                        Expanded(
                          child: buildCameraPreview(frontCameraController, 'Front Camera'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
