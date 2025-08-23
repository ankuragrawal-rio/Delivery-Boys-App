import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/mock_services/mock_qr_service.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Position the QR code within the frame to scan pickup location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Manual Entry Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _showManualEntryDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Enter Location Code Manually'),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanning = false;
        _processQrCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _processQrCode(String qrData) {
    final qrService = ref.read(mockQrServiceProvider);
    final locationInfo = qrService.verifyLocationQr(qrData);
    
    if (locationInfo != null) {
      _showLocationConfirmation(locationInfo);
    } else {
      _showErrorDialog('Invalid QR Code', 'This QR code is not recognized as a valid pickup location.');
    }
  }

  void _showLocationConfirmation(PickupLocationInfo locationInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pickup Location Verified',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => _isScanning = true);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Location Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            locationInfo.locationCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      locationInfo.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last scanned: ${_formatDateTime(locationInfo.lastScannedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Orders at this location
            const Text(
              'Orders at this location:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: locationInfo.orders.length,
                itemBuilder: (context, index) {
                  final order = locationInfo.orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                      title: Text('Order #${order.orderNumber}'),
                      subtitle: Text(order.customerName),
                      trailing: Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pickup confirmed for location ${locationInfo.locationCode}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Confirm Pickup'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _isScanning = true);
                    },
                    child: const Text('Scan Another'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final codeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Location Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the pickup location code manually:'),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Location Code (e.g., A1, B2)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = codeController.text.trim().toUpperCase();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _processLocationCode(code);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _processLocationCode(String locationCode) {
    final qrService = ref.read(mockQrServiceProvider);
    final locationInfo = qrService.getLocationByCode(locationCode);
    
    if (locationInfo != null) {
      _showLocationConfirmation(locationInfo);
    } else {
      _showErrorDialog('Invalid Location Code', 'Location code "$locationCode" not found.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isScanning = true);
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutSize = cutOutSize < width && cutOutSize < height
        ? cutOutSize
        : (width < height ? width : height) - borderOffset * 2;
    final _cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - _cutOutSize / 2 + borderOffset,
      rect.top + height / 2 - _cutOutSize / 2 + borderOffset,
      _cutOutSize - borderOffset * 2,
      _cutOutSize - borderOffset * 2,
    );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(_cutOutRect, Radius.circular(borderRadius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw the border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderPath = Path();

    // Top-left corner
    borderPath.moveTo(_cutOutRect.left - borderOffset, _cutOutRect.top - borderOffset + borderLength);
    borderPath.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.top - borderOffset + borderRadius);
    borderPath.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.left - borderOffset + borderRadius, _cutOutRect.top - borderOffset);
    borderPath.lineTo(_cutOutRect.left - borderOffset + borderLength, _cutOutRect.top - borderOffset);

    // Top-right corner
    borderPath.moveTo(_cutOutRect.right + borderOffset - borderLength, _cutOutRect.top - borderOffset);
    borderPath.lineTo(_cutOutRect.right + borderOffset - borderRadius, _cutOutRect.top - borderOffset);
    borderPath.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.top - borderOffset,
        _cutOutRect.right + borderOffset, _cutOutRect.top - borderOffset + borderRadius);
    borderPath.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.top - borderOffset + borderLength);

    // Bottom-right corner
    borderPath.moveTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom + borderOffset - borderLength);
    borderPath.lineTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom + borderOffset - borderRadius);
    borderPath.quadraticBezierTo(_cutOutRect.right + borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.right + borderOffset - borderRadius, _cutOutRect.bottom + borderOffset);
    borderPath.lineTo(_cutOutRect.right + borderOffset - borderLength, _cutOutRect.bottom + borderOffset);

    // Bottom-left corner
    borderPath.moveTo(_cutOutRect.left - borderOffset + borderLength, _cutOutRect.bottom + borderOffset);
    borderPath.lineTo(_cutOutRect.left - borderOffset + borderRadius, _cutOutRect.bottom + borderOffset);
    borderPath.quadraticBezierTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom + borderOffset,
        _cutOutRect.left - borderOffset, _cutOutRect.bottom + borderOffset - borderRadius);
    borderPath.lineTo(_cutOutRect.left - borderOffset, _cutOutRect.bottom + borderOffset - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
