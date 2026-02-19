import 'package:flutter/material.dart';
import 'camera_scan_screen.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const ScanScreen({
    super.key,
    this.onClose,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CameraScanScreen(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      onClose: widget.onClose,
    );
  }
}
