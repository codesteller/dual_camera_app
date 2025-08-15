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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.build_rounded,
                size: 20,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Camera Diagnostic'),
          ],
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: isRunningDiagnostic ? null : runDiagnostic,
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-run Diagnostic',
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
        child: Column(
          children: [
            // Status indicator
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isRunningDiagnostic 
                    ? Colors.orange.withValues(alpha: 0.2) 
                    : Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRunningDiagnostic 
                      ? Colors.orange.withValues(alpha: 0.5) 
                      : Colors.green.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRunningDiagnostic 
                          ? Colors.orange.withValues(alpha: 0.3) 
                          : Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isRunningDiagnostic ? Icons.sync : Icons.check_circle,
                      color: isRunningDiagnostic ? Colors.orange : Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isRunningDiagnostic ? 'Running diagnostic tests...' : 'Diagnostic completed successfully',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isRunningDiagnostic)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
                      ),
                    ),
                ],
              ),
            ),
            // Messages list
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
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
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
            ),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DualCameraScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Test Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
