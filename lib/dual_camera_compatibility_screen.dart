import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

class DualCameraCompatibilityScreen extends StatefulWidget {
  const DualCameraCompatibilityScreen({super.key});

  @override
  State<DualCameraCompatibilityScreen> createState() => _DualCameraCompatibilityScreenState();
}

class _DualCameraCompatibilityScreenState extends State<DualCameraCompatibilityScreen> {
  CameraController? _controller;
  CameraDescription? _frontCamera;
  CameraDescription? _rearCamera;
  bool _isInitialized = false;
  bool _hasPermission = false;
  String _errorMessage = '';
  bool _isFront = false;
  bool _isSwitching = false;
  late final List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _cameras = cameras;
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus != PermissionStatus.granted) {
      setState(() {
        _hasPermission = false;
        _errorMessage = 'Camera permission denied';
      });
      return;
    }
    setState(() {
      _hasPermission = true;
    });
    if (_cameras.isEmpty) {
      setState(() {
        _errorMessage = 'No cameras available';
      });
      return;
    }
    for (final camera in _cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        _frontCamera = camera;
      } else if (camera.lensDirection == CameraLensDirection.back) {
        _rearCamera = camera;
      }
    }
    _startAutoSwitching();
  }

  void _startAutoSwitching() {
    _switchCamera(_isFront);
    Future.delayed(const Duration(seconds: 2), _toggleAndSwitch);
  }

  void _toggleAndSwitch() {
    if (!mounted) return;
    setState(() {
      _isFront = !_isFront;
    });
    _switchCamera(_isFront);
    Future.delayed(const Duration(seconds: 2), _toggleAndSwitch);
  }

  Future<void> _switchCamera(bool useFront) async {
    if (_isSwitching) return;
    setState(() {
      _isSwitching = true;
    });
    try {
      await _controller?.dispose();
      final selectedCamera = useFront ? _frontCamera : _rearCamera;
      if (selectedCamera == null) {
        setState(() {
          _errorMessage = useFront ? 'No front camera available' : 'No rear camera available';
          _isSwitching = false;
        });
        return;
      }
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = '';
          _isSwitching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error switching camera: $e';
        _isSwitching = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  size: 20,
                  color: Colors.purple.shade400,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Dual Camera (Compatible)',
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
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _initializeCameras,
                    icon: const Icon(Icons.security),
                    label: const Text('Grant Camera Permission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
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
    if (!_isInitialized && _errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  size: 20,
                  color: Colors.purple.shade400,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Dual Camera (Compatible)',
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
                    _errorMessage,
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
                        _errorMessage = '';
                      });
                      _initializeCameras();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
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
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard_customize_rounded,
                size: 20,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Dual Camera (Compatible)',
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
            child: Stack(
          children: [
            if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(),
              ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isFront ? 'Front Camera' : 'Rear Camera',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            if (_isSwitching)
              const Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                Icons.dashboard_customize_rounded,
                color: Colors.purple.shade400,
              ),
              const SizedBox(width: 8),
              const Text(
                'Compatibility Mode',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'This mode automatically switches between front and rear cameras every 2 seconds to demonstrate dual camera capability on devices with limited simultaneous camera access.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: Colors.purple.shade400),
              ),
            ),
          ],
        );
      },
    );
  }
}
