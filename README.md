# Dual Camera App

A Flutter application that displays camera feeds with responsive layout based on device orientation.

## Important Device Limitation Discovery

**Finding**: During testing, we discovered that most mobile devices can only have **one camera active at a time**. This is a hardware/OS limitation, not an app limitation.

**Evidence**: Camera logs show that when the front camera initializes, the rear camera automatically closes:
```
I/flutter: Rear camera initialized successfully
I/flutter: Initializing front camera...
I/CameraManagerGlobal: Camera 0 facing CAMERA_FACING_BACK state now CAMERA_STATE_CLOSED
```

## Solutions Provided

### 1. **Single Camera View (Recommended)**
- Displays one camera at a time with easy switching
- Fast camera switching with smooth transitions
- Works on all devices without limitations
- Best user experience for devices with the hardware limitation

### 2. **Dual Camera View (Original)**
- Shows both camera views simultaneously
- May show only one active camera on devices with limitations
- Includes debug information to understand device capabilities
- Good for testing and demonstration

### 3. **Camera Diagnostic Tool**
- Tests each camera individually
- Provides detailed logs and status information
- Helps troubleshoot camera-related issues
- Useful for developers and debugging

## Features

### Core Features
- **Camera Detection**: Automatically detects available front and rear cameras
- **Permission Handling**: Automatic camera permission requests with user-friendly prompts
- **Error Handling**: Graceful handling of camera initialization errors and missing cameras
- **Responsive Layout**: Adapts to device orientation changes
- **Camera Labels**: Clear identification of active cameras

### Enhanced Features
- **Camera Switching**: Toggle between front and rear cameras
- **Real-time Status**: Shows camera initialization and active status
- **Debug Information**: Detailed camera status and device capability information
- **Visual Feedback**: Loading indicators and status messages

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Android Configuration:**
   The app is configured with Android SDK 36 and NDK 27.0.12077973 to ensure compatibility with the camera plugin. These settings are in `android/app/build.gradle.kts`:
   ```kotlin
   android {
       compileSdk = 36
       ndkVersion = "27.0.12077973"
       // ... other settings
   }
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **Build for release:**
   ```bash
   flutter build apk --release
   ```

## Permissions

The app requires camera permissions to function properly:

### Android
- `CAMERA` permission is automatically requested
- Camera hardware features are declared as optional to support devices with single cameras
- Storage permissions for saving captured images

### iOS
- Camera usage description is provided for permission prompt
- Photo library usage for saving images

## Project Structure

```
lib/
├── main.dart                    # Main app entry point with navigation
├── enhanced_camera_screen.dart  # Enhanced version with capture features
└── ...

android/
├── app/src/main/AndroidManifest.xml  # Android permissions
└── ...

ios/
├── Runner/Info.plist            # iOS permissions and configuration
└── ...

test/
└── widget_test.dart            # Widget tests
```

## Architecture

The app uses the following key components:

- **Camera Plugin**: Uses the `camera` package for accessing device cameras
- **Permission Handler**: Uses `permission_handler` for runtime permission requests
- **Path Provider**: Uses `path_provider` for image storage
- **Responsive Design**: Uses `OrientationBuilder` to adapt layout based on device orientation
- **Error Handling**: Comprehensive error handling for camera initialization and permissions
- **Navigation**: Clean navigation structure with home screen

## Usage

1. **Launch the app**
2. **Tap "Open Basic Camera View"** to access the dual camera interface
3. **Grant camera permission** when prompted
4. The app will automatically detect and display:
   - Rear camera feed
   - Front camera feed (if available)
5. **Rotate the device** to see the layout change:
   - Portrait: Top/bottom layout
   - Landscape: Left/right layout

### Enhanced Features Usage
- **Take Pictures**: Tap the camera button on any feed to capture an image
- **Switch Positions**: Use the swap button in the center control bar
- **View Status**: Watch for loading indicators and success messages

## Technical Details

- **Camera Resolution**: 
  - Basic version: Medium resolution for optimal performance
  - Enhanced version: High resolution for better image quality
- **Audio**: Disabled for camera feeds to focus on video preview
- **Frame Rate**: Standard frame rate for smooth preview
- **Memory Management**: Proper disposal of camera controllers to prevent memory leaks
- **Storage**: Images saved with timestamps to prevent conflicts

## Development

### Available VS Code Tasks
- `Flutter: Run App` - Start the app in debug mode
- `Flutter: Build APK` - Build release APK
- `Flutter: Analyze` - Run static analysis
- `Flutter: Test` - Run unit tests
- `Flutter: Clean` - Clean build artifacts

### Available Launch Configurations
- `Flutter: Launch` - Default launch configuration
- `Flutter: Debug` - Debug mode with hot reload
- `Flutter: Profile` - Profile mode for performance testing

## Testing

Run tests with:
```bash
flutter test
```

The app includes widget tests that verify:
- App initialization
- Home screen navigation
- Basic UI components

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**
   - Solution: Grant camera permission when prompted or in device settings

2. **No Cameras Available**
   - Solution: Ensure device has cameras and they're not being used by another app

3. **Camera Initialization Failed**
   - Solution: Restart the app or check device logs for specific errors

4. **Images Not Saving**
   - Solution: Ensure storage permissions are granted

### Device Requirements
- Android 5.0 (API 21) or higher
- iOS 10.0 or higher
- At least one camera (front or rear)
- Sufficient storage space for captured images

### Performance Optimization
- The app automatically selects appropriate resolution based on device capabilities
- Camera controllers are properly disposed to prevent memory leaks
- UI updates are optimized to prevent unnecessary rebuilds

## Advanced Configuration

### Customizing Camera Settings
You can modify camera settings in the source code:
- Resolution preset in `CameraController` initialization
- Frame rate and other camera parameters
- Image compression and quality settings

### Adding New Features
The modular structure makes it easy to add:
- Video recording capabilities
- Advanced camera controls (zoom, flash, etc.)
- Image processing filters
- Custom UI themes

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request

## License

This project is open source and available under the MIT License.
