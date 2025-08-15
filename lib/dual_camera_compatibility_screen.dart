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
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Dual Camera (Compatibility)'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white, size: 100),
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeCameras,
                child: const Text('Grant Camera Permission'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_isInitialized && _errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Dual Camera (Compatibility)'),
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 100),
              const SizedBox(height: 20),
              Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = '';
                  });
                  _initializeCameras();
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
        title: const Text('Dual Camera (Compatibility)'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
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
    );
  }
}
