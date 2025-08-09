import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart'; // Import to access the cameras list

class AlternatingCameraScreen extends StatefulWidget {
  const AlternatingCameraScreen({super.key});

  @override
  State<AlternatingCameraScreen> createState() => _AlternatingCameraScreenState();
}

class _AlternatingCameraScreenState extends State<AlternatingCameraScreen> {
  CameraController? currentCameraController;
  bool isInitialized = false;
  bool hasPermission = false;
  String errorMessage = '';
  bool isShowingRearCamera = true;
  bool isSwitching = false;
  
  CameraDescription? frontCamera;
  CameraDescription? rearCamera;

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

    // Find available cameras
    for (CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
      } else if (camera.lensDirection == CameraLensDirection.back) {
        rearCamera = camera;
      }
    }

    // Start with rear camera
    await switchToCamera(isShowingRearCamera);
  }

  Future<void> switchToCamera(bool useRearCamera) async {
    if (isSwitching) return;
    
    setState(() {
      isSwitching = true;
    });

    try {
      // Dispose current controller
      await currentCameraController?.dispose();
      currentCameraController = null;

      // Select camera
      final selectedCamera = useRearCamera ? rearCamera : frontCamera;
      
      if (selectedCamera == null) {
        setState(() {
          errorMessage = useRearCamera ? 'No rear camera available' : 'No front camera available';
          isSwitching = false;
        });
        return;
      }

      // Initialize new controller
      currentCameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await currentCameraController!.initialize();

      if (mounted) {
        setState(() {
          isInitialized = true;
          isShowingRearCamera = useRearCamera;
          errorMessage = '';
          isSwitching = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error switching camera: $e';
        isSwitching = false;
      });
    }
  }

  void toggleCamera() {
    switchToCamera(!isShowingRearCamera);
  }

  @override
  void dispose() {
    currentCameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Alternating Camera'),
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
        appBar: AppBar(
          title: const Text('Alternating Camera'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
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
        title: Text(isShowingRearCamera ? 'Rear Camera' : 'Front Camera'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: isSwitching ? null : toggleCamera,
            icon: Icon(
              isShowingRearCamera ? Icons.camera_front : Icons.camera_rear,
              color: isSwitching ? Colors.grey : Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[900],
            child: Row(
              children: [
                Icon(
                  isShowingRearCamera ? Icons.camera_rear : Icons.camera_front,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isShowingRearCamera ? "Rear" : "Front"} Camera Active',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isSwitching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                const SizedBox(width: 8),
                Text(
                  'Front: ${frontCamera != null ? "✓" : "✗"} | Rear: ${rearCamera != null ? "✓" : "✗"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Camera preview
          Expanded(
            child: currentCameraController != null && 
                   currentCameraController!.value.isInitialized
                ? Stack(
                    children: [
                      CameraPreview(currentCameraController!),
                      // Camera info overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isShowingRearCamera ? 'Rear Camera' : 'Front Camera',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentCameraController!.value.previewSize != null
                                    ? '${currentCameraController!.value.previewSize!.width.toInt()}x${currentCameraController!.value.previewSize!.height.toInt()}'
                                    : 'Loading...',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Initializing camera...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),
          // Control panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                const Text(
                  'Note: This device can only use one camera at a time.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isSwitching || isShowingRearCamera ? null : () => switchToCamera(true),
                        icon: const Icon(Icons.camera_rear),
                        label: const Text('Rear Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isShowingRearCamera ? Colors.blue : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isSwitching || !isShowingRearCamera ? null : () => switchToCamera(false),
                        icon: const Icon(Icons.camera_front),
                        label: const Text('Front Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isShowingRearCamera ? Colors.blue : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
