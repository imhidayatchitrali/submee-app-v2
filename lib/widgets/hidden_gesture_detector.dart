import 'dart:async';

import 'package:flutter/material.dart';
import 'package:submee/utils/preferences.dart';

class HiddenGestureDetector extends StatefulWidget {
  const HiddenGestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  _HiddenGestureDetectorState createState() => _HiddenGestureDetectorState();
}

class _HiddenGestureDetectorState extends State<HiddenGestureDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;

  void _handleTap() {
    _tapCount++;

    // Reset the timer
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      _tapCount = 0;
    });

    // Check if we've hit the required number of taps
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showLogsModal();
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _showLogsModal() {
    showDialog(
      context: context,
      builder: (context) => const LogsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

// Modal to display logs
class LogsModal extends StatelessWidget {
  const LogsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logs = Preferences.logs;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 50),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Application Logs',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () async {
                          await Preferences.clearLogs();
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[800]!,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            logs[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
