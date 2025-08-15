import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_diagnostic_screen.dart';
import 'alternating_camera_screen.dart';
import 'dual_camera_compatibility_screen.dart';
import 'splash_screen.dart';

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
  const DualCameraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FusionLens',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181A2A),
          foregroundColor: Colors.cyanAccent,
          elevation: 0,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.deepPurpleAccent,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            letterSpacing: 2.0,
            fontSize: 32,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
      home: const _SplashToHome(),
    );
  }
}

class _SplashToHome extends StatefulWidget {
  const _SplashToHome();
  @override
  State<_SplashToHome> createState() => _SplashToHomeState();
}

class _SplashToHomeState extends State<_SplashToHome> {
  bool _showHome = false;
  @override
  Widget build(BuildContext context) {
    if (_showHome) {
      return const DualCameraHome();
    }
    return SplashScreen(onFinish: () {
      setState(() {
        _showHome = true;
      });
    });
  }
}


class DualCameraHome extends StatelessWidget {
  const DualCameraHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/FusionLens_logo.png',
              height: 36,
            ),
            const SizedBox(width: 12),
            const Text(
              'FusionLens',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.cyanAccent,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF181A2A),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Futuristic logo and glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/FusionLens_logo.png',
                height: 120,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'MULTIPLE VIEWS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
                letterSpacing: 6.0,
                fontSize: 32,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent.withOpacity(0.7),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose your futuristic camera mode',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Roboto',
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _FuturisticButton(
              label: 'Dual View',
              color: Colors.cyanAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DualCameraScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _FuturisticButton(
              label: 'Compat View',
              color: Colors.deepPurpleAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DualCameraCompatibilityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _FuturisticButton(
              label: 'Solo View',
              color: Colors.greenAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlternatingCameraScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _FuturisticButton(
              label: 'Diagnostics',
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CameraDiagnosticScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FuturisticButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const _FuturisticButton({required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: color,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: color, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ).copyWith(
          foregroundColor: MaterialStateProperty.all(color),
          overlayColor: MaterialStateProperty.all(color.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: color.withOpacity(0.7),
                blurRadius: 8,
              ),
            ],
          ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeCameras();
    });
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

    // Show warning popup if only one camera is available
    if (cameras.length == 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[300]),
                const SizedBox(width: 8),
                const Text('Device Limitation', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Only one camera can be active at a time on this device.',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Roboto'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK', style: TextStyle(color: Colors.cyanAccent)),
              ),
            ],
          ),
        );
      });
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
        actions: [
          IconButton(
            onPressed: isSwitching ? null : switchCamera,
            icon: Icon(
              showRearCamera ? Icons.camera_front : Icons.camera_rear,
              color: isSwitching ? Colors.grey : Colors.cyanAccent,
            ),
            tooltip: showRearCamera ? 'Switch to Front Camera' : 'Switch to Rear Camera',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
