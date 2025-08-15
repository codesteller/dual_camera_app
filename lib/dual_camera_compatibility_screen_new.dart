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
  CameraController? _frontController;
  CameraController? _rearController;
  CameraDescription? _frontCamera;
  CameraDescription? _rearCamera;
  bool _isInitialized = false;
  bool _hasPermission = false;
  String _errorMessage = '';
  bool _isSwitching = false;
  late final List<CameraDescription> _cameras;
  double _switchInterval = 2.0;
  Offset _pipOffset = const Offset(20, 60);

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
    await _initControllers();
    _startAutoRefresh();
  }

  Future<void> _initControllers() async {
    try {
      if (_rearCamera != null) {
        _rearController = CameraController(
          _rearCamera!,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _rearController!.initialize();
      }
      if (_frontCamera != null) {
        _frontController = CameraController(
          _frontCamera!,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _frontController!.initialize();
      }
      setState(() {
        _isInitialized = true;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing cameras: $e';
      });
    }
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: _switchInterval.toInt()), _refreshCameras);
  }

  void _refreshCameras() {
    if (!mounted) return;
    setState(() {}); // Triggers UI update, placeholder for future frame grabbing logic
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _frontController?.dispose();
    _rearController?.dispose();
    super.dispose();
  }

  Widget _cameraPlaceholder(String label) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
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
                'Compat View',
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
              Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Roboto', letterSpacing: 1.5), textAlign: TextAlign.center),
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
          title: Row(
            children: [
              Image.asset(
                'assets/FusionLens_logo.png',
                height: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Compat View',
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
              Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Roboto', letterSpacing: 1.5), textAlign: TextAlign.center),
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
        title: Row(
          children: [
            Image.asset(
              'assets/FusionLens_logo.png',
              height: 32,
            ),
            const SizedBox(width: 12),
            const Text(
              'Compat View',
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
      body: SafeArea(
        child: _isInitialized
            ? Stack(
                children: [
                  // Main camera view (always rear)
                  Positioned.fill(
                    child: _rearController != null && _rearController!.value.isInitialized
                        ? CameraPreview(_rearController!)
                        : _cameraPlaceholder('Rear Camera'),
                  ),
                  // PiP overlay (always front)
                  if (_frontController != null && _rearController != null)
                    Positioned(
                      left: _pipOffset.dx,
                      top: _pipOffset.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _pipOffset += details.delta;
                          });
                        },
                        child: Container(
                          width: 120,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.cyanAccent, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _frontController != null && _frontController!.value.isInitialized
                                ? CameraPreview(_frontController!)
                                : _cameraPlaceholder('Front Camera'),
                          ),
                        ),
                      ),
                    ),
                  // Camera label
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
                        child: const Text(
                          'Rear Camera (Main)  |  Front Camera (PiP)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  // Slider for refresh interval
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Refresh Frequency (seconds)', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                        Slider(
                          value: _switchInterval,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _switchInterval.toStringAsFixed(0),
                          onChanged: (v) {
                            setState(() {
                              _switchInterval = v;
                            });
                          },
                          onChangeEnd: (v) {
                            // Restart refresh with new interval
                            _startAutoRefresh();
                          },
                          activeColor: Colors.cyanAccent,
                          inactiveColor: Colors.cyanAccent.withOpacity(0.3),
                        ),
                      ],
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
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
