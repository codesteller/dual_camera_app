import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

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
      title: 'Dual Camera App',
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
        title: const Text('Dual Camera App'),
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
              'Dual Camera App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'View front and rear cameras simultaneously',
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
                'Open Basic Camera View',
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
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await rearCameraController!.initialize();
      }

      if (frontCamera != null) {
        frontCameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
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
    );
  }
}
