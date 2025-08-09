# Dual Camera App Demo

## Quick Start Guide

### Running the App

1. **Connect your device or start an emulator**
2. **Run the app:**
   ```bash
   flutter run
   ```

### Testing the Features

#### Basic Dual Camera View
1. Open the app
2. Tap "Open Basic Camera View"
3. Grant camera permissions when prompted
4. You'll see both front and rear cameras simultaneously
5. Rotate your device to see the layout change:
   - Portrait: Cameras stacked vertically (top/bottom)
   - Landscape: Cameras side by side (left/right)

#### Enhanced Features (Available in enhanced_camera_screen.dart)
To use the enhanced version, you can modify main.dart to navigate to `EnhancedDualCameraScreen` instead:

1. **Camera Position Switching**
   - Use the swap button in the control bar
   - In portrait: Vertical swap icon to switch top/bottom positions
   - In landscape: Horizontal swap icon to switch left/right positions

2. **Picture Capture**
   - Each camera feed has its own capture button (camera icon)
   - Tap the button to take a picture from that specific camera
   - Images are saved with timestamps to prevent conflicts
   - Success/error messages appear as snackbars

3. **Visual Feedback**
   - Loading indicators show during capture
   - Camera labels clearly identify which is front/rear
   - Control bar provides intuitive interface

### Expected Behaviors

#### Permission Flow
1. App requests camera permission on first launch
2. If denied, shows permission request screen with retry button
3. If granted, initializes cameras and shows dual view

#### Error Handling
1. **No cameras available**: Shows error message with retry option
2. **Camera initialization failed**: Displays specific error and retry button
3. **Single camera device**: Shows available camera with placeholder for missing one

#### Layout Adaptation
1. **Portrait Mode**: 
   - Top camera (default: rear)
   - Control bar with swap button
   - Bottom camera (default: front)

2. **Landscape Mode**:
   - Left camera (default: rear)
   - Vertical control bar with swap button
   - Right camera (default: front)

### Customization Options

You can easily customize the app by modifying:

1. **Camera Resolution**: Change `ResolutionPreset` in camera controller initialization
2. **UI Colors**: Modify theme colors in `DualCameraApp`
3. **Layout**: Adjust spacing and sizes in the build methods
4. **Features**: Add new buttons or controls to the interface

### Troubleshooting Tips

1. **App not detecting cameras**: Ensure device has cameras and they're not in use by another app
2. **Permission issues**: Check device settings and manually grant camera permissions
3. **Build issues**: Run `flutter clean && flutter pub get` to reset dependencies
4. **Performance**: Lower camera resolution if experiencing lag on older devices

### Development Tips

1. **Hot Reload**: Works great for UI changes, but camera initialization changes may require hot restart
2. **Debugging**: Use the debug console to see camera initialization logs
3. **Testing**: Widget tests cover basic functionality, but camera features need device testing
4. **Platform Differences**: Test on both iOS and Android as camera behavior may vary

This app demonstrates a production-ready dual camera interface that can be easily extended with additional features like video recording, image filters, or advanced camera controls.
