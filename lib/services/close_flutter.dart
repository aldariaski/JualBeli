import 'package:flutter/material.dart';

import 'backend_process.dart';

class CloseFlutter {
  static Widget builder(
    BuildContext context,
    Widget? child,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child ?? const SizedBox.shrink(),

        ValueListenableBuilder<bool>(
          valueListenable: BackendProcess.isClosing,
          builder: (
            context,
            isClosing,
            _,
          ) {
            if (!isClosing) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        ),

                        SizedBox(height: 20),

                        Text(
                          'Closing JualBeli',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Stopping backend...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}