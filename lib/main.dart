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
  
  // Note: Camera initialization moved to splash screen
  runApp(const FusionLensApp());
}

class FusionLensApp extends StatelessWidget {
  const FusionLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FusionLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class DualCameraHome extends StatelessWidget {
  const DualCameraHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/FusionLens_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            const Text('FusionLens'),
          ],
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Advanced Camera Experience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Choose your preferred camera viewing mode',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Camera mode buttons
                _buildCameraModeButton(
                  context,
                  title: 'Dual Camera Mode',
                  subtitle: 'May show single camera on some devices',
                  icon: Icons.view_module_rounded,
                  color: Colors.blue,
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
                
                _buildCameraModeButton(
                  context,
                  title: 'Compat Mode',
                  subtitle: 'Enhanced compatibility mode',
                  icon: Icons.dashboard_customize_rounded,
                  color: Colors.purple,
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
                
                _buildCameraModeButton(
                  context,
                  title: 'Solo Camera Mode',
                  subtitle: 'Best performance and reliability',
                  icon: Icons.camera_alt_rounded,
                  color: Colors.green,
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
                
                _buildCameraModeButton(
                  context,
                  title: 'Camera Diagnostics',
                  subtitle: 'Test and troubleshoot camera features',
                  icon: Icons.build_rounded,
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraDiagnosticScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraModeButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.5),
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
  bool showRearCamera = false; // Track which camera to prioritize - start with front
  bool isSwitching = false; // Track switching state
  bool hasShownWarning = false; // Track if warning popup has been shown

  @override
  void initState() {
    super.initState();
    initializeCameras();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(
                Icons.view_module_rounded,
                color: Colors.blue.shade400,
              ),
              const SizedBox(width: 8),
              const Text(
                'Dual Camera Mode',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'This mode attempts to show both cameras simultaneously. However, most devices can only activate one camera at a time due to hardware limitations. Use the switch button to toggle between front and rear cameras.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: Colors.blue.shade400),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWarningPopup() {
    if (hasShownWarning) return;
    
    setState(() {
      hasShownWarning = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Device Limitation',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              'Most devices can only activate one camera at a time due to hardware limitations. You can switch between front and rear cameras using the toggle button.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Understood',
                  style: TextStyle(color: Colors.orange.shade400),
                ),
              ),
            ],
          );
        },
      );
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
        
        // Show warning popup once cameras are initialized
        _showWarningPopup();
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[900]!,
              Colors.grey[800]!,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: controller == null ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller == null ? Colors.red.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  controller == null ? Icons.videocam_off : Icons.camera_alt,
                  color: controller == null ? Colors.red.shade400 : Colors.blue.shade400,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller == null ? 'Camera not found' : 'Initializing...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              if (controller != null) ...[
                const SizedBox(height: 16),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview with rounded corners effect
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRect(
            child: CameraPreview(controller),
          ),
        ),
        // Camera label with modern design
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label.contains('Rear') ? Icons.camera_rear : Icons.camera_front,
                  color: Colors.blue.shade400,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$label - Active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Resolution info
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.value.previewSize != null 
                ? '${controller.value.previewSize!.width.toInt()}×${controller.value.previewSize!.height.toInt()}'
                : 'Loading...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Status indicator
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.view_module_rounded,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Dual Camera'),
            ],
          ),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.red.shade400,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Camera Permission Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: initializeCameras,
                    icon: const Icon(Icons.security),
                    label: const Text('Grant Camera Permission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!isInitialized && errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.view_module_rounded,
                  size: 20,
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Dual Camera Mode',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F3460),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Camera Error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        errorMessage = '';
                      });
                      initializeCameras();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_module_rounded,
                size: 20,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Dual Camera Mode',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
          if (frontCameraController != null || rearCameraController != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: isSwitching ? null : switchCamera,
                icon: Icon(
                  showRearCamera ? Icons.camera_rear : Icons.camera_front,
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
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                // Portrait mode: Top and bottom layout
                return Column(
                  children: [
                    // Rear camera on top
                    Expanded(
                      child: buildCameraPreview(rearCameraController, 'Rear'),
                    ),
                    // Divider with loading indicator
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSwitching) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Switching Camera...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.swap_vert,
                              color: Colors.blue.shade400,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Camera Views',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Front camera on bottom
                    Expanded(
                      child: buildCameraPreview(frontCameraController, 'Front'),
                    ),
                  ],
                );
              } else {
                // Landscape mode: Left and right layout
                return Row(
                  children: [
                    // Rear camera on left
                    Expanded(
                      child: buildCameraPreview(rearCameraController, 'Rear'),
                    ),
                    // Divider with loading indicator
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSwitching) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'Switching',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ] else ...[
                            Icon(
                              Icons.swap_horiz,
                              color: Colors.blue.shade400,
                              size: 16,
                            ),
                            const SizedBox(height: 8),
                            const RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'Cameras',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Front camera on right
                    Expanded(
                      child: buildCameraPreview(frontCameraController, 'Front'),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
