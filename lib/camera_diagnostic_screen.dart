import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart'; // Import to access the cameras list

class CameraDiagnosticScreen extends StatefulWidget {
  const CameraDiagnosticScreen({super.key});

  @override
  State<CameraDiagnosticScreen> createState() => _CameraDiagnosticScreenState();
}

class _CameraDiagnosticScreenState extends State<CameraDiagnosticScreen> {
  List<String> diagnosticMessages = [];
  CameraController? testController;
  bool isRunningDiagnostic = false;

  @override
  void initState() {
    super.initState();
    runDiagnostic();
  }

  void addMessage(String message) {
    setState(() {
      diagnosticMessages.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    debugPrint(message);
  }

  Future<void> runDiagnostic() async {
    setState(() {
      isRunningDiagnostic = true;
      diagnosticMessages.clear();
    });

    addMessage('Starting camera diagnostic...');

    // Check permissions
    addMessage('Checking camera permission...');
    final permission = await Permission.camera.status;
    addMessage('Camera permission status: $permission');

    if (permission != PermissionStatus.granted) {
      addMessage('Requesting camera permission...');
      final result = await Permission.camera.request();
      addMessage('Permission request result: $result');
    }

    // Check available cameras
    addMessage('Checking available cameras...');
    addMessage('Global cameras list length: ${cameras.length}');

    if (cameras.isEmpty) {
      addMessage('No cameras in global list, trying to get cameras directly...');
      try {
        final directCameras = await availableCameras();
        addMessage('Direct camera query found: ${directCameras.length} cameras');
        for (int i = 0; i < directCameras.length; i++) {
          addMessage('Camera $i: ${directCameras[i].name} (${directCameras[i].lensDirection})');
        }
      } catch (e) {
        addMessage('Error getting cameras directly: $e');
      }
    } else {
      for (int i = 0; i < cameras.length; i++) {
        addMessage('Camera $i: ${cameras[i].name} (${cameras[i].lensDirection})');
      }
    }

    // Test each camera individually
    final camerasToTest = cameras.isNotEmpty ? cameras : await availableCameras();
    
    for (int i = 0; i < camerasToTest.length; i++) {
      final camera = camerasToTest[i];
      addMessage('Testing camera $i: ${camera.name}');
      
      try {
        addMessage('Creating controller for ${camera.name}...');
        testController = CameraController(
          camera,
          ResolutionPreset.low, // Use low resolution for testing
          enableAudio: false,
        );
        
        addMessage('Initializing ${camera.name}...');
        await testController!.initialize();
        addMessage('✓ ${camera.name} initialized successfully');
        
        // Test preview size
        final previewSize = testController!.value.previewSize;
        addMessage('Preview size: ${previewSize?.width}x${previewSize?.height}');
        
        await Future.delayed(const Duration(seconds: 1)); // Brief delay
        
        addMessage('Disposing ${camera.name}...');
        await testController!.dispose();
        testController = null;
        addMessage('✓ ${camera.name} disposed successfully');
        
      } catch (e) {
        addMessage('✗ Error with ${camera.name}: $e');
        testController?.dispose();
        testController = null;
      }
    }

    addMessage('Diagnostic completed!');
    setState(() {
      isRunningDiagnostic = false;
    });
  }

  @override
  void dispose() {
    testController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Diagnostics',
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
            onPressed: isRunningDiagnostic ? null : runDiagnostic,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isRunningDiagnostic ? Colors.orange[900] : Colors.green[900],
            child: Text(
              isRunningDiagnostic ? 'Running diagnostic...' : 'Diagnostic complete',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: diagnosticMessages.length,
              itemBuilder: (context, index) {
                final message = diagnosticMessages[index];
                Color textColor = Colors.white;
                
                if (message.contains('✓')) {
                  textColor = Colors.green;
                } else if (message.contains('✗') || message.contains('Error')) {
                  textColor = Colors.red;
                } else if (message.contains('Camera') && message.contains(':')) {
                  textColor = Colors.blue;
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                );
              },
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DualCameraScreen(),
                        ),
                      );
                    },
                    child: const Text('Test Dual Camera'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
