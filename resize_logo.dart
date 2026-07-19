import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Read the original logo
  final originalFile = File('assets/images/logo.png');
  final originalBytes = await originalFile.readAsBytes();
  final originalImage = img.decodeImage(originalBytes);

  if (originalImage == null) {
    print('Error: Could not decode image');
    return;
  }

  // Target size for app icon
  const targetSize = 1024;

  // Calculate the size to fit the logo (70% of canvas)
  final maxLogoSize = (targetSize * 0.85).round();

  // Resize logo to fit within the max size while maintaining aspect ratio
  final resizedImage = img.copyResize(
    originalImage,
    width: maxLogoSize,
    height: maxLogoSize,
    maintainAspect: true,
  );

  // Create a new image with transparent background
  final outputImage = img.Image(width: targetSize, height: targetSize);

  // Fill with transparent (alpha = 0)
  for (int y = 0; y < targetSize; y++) {
    for (int x = 0; x < targetSize; x++) {
      outputImage.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
    }
  }

  // Calculate position to center the logo
  final offsetX = (targetSize - resizedImage.width) ~/ 2;
  final offsetY = (targetSize - resizedImage.height) ~/ 2;

  // Composite the logo onto the transparent background
  img.compositeImage(outputImage, resizedImage, dstX: offsetX, dstY: offsetY);

  // Save the resized logo
  final outputBytes = img.encodePng(outputImage);
  await File('assets/images/logo.png').writeAsBytes(outputBytes);

  print('Logo resized to $targetSize x $targetSize with proper padding');
  print('Logo size within canvas: ${resizedImage.width} x ${resizedImage.height}');
  print('Offset: X=$offsetX, Y=$offsetY');
}
