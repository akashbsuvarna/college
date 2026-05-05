import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../viewmodels/attendance_notification_viewmodels.dart';
import '../../subject/viewmodels/subject_viewmodel.dart';
import '../../core/app_theme.dart';

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: QRScannerView(),
    );
  }
}


class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  bool _isProcessing = false;

  void _handleScan(BuildContext context, String studentId) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    final attVm = Provider.of<AttendanceViewModel>(context, listen: false);
    // Note: sessionId and subjectId are now optional in the API
    final bool success = (await attVm.markByAdmin(studentId, "", "")) == true;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Attendance Marked for Student ID: $studentId" : (attVm.errorMessage ?? "Failed to mark attendance")),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        )
      );
    }

    // Cooling period
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                _handleScan(context, code);
                break;
              }
            }
          },
        ),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentIndigo),
                  SizedBox(height: 16),
                  Text("Processing Scan...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Daily Attendance: Scan Student's QR",
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
