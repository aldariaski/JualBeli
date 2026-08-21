import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

class BackendProcess {
  static Process? _process;
  static HttpServer? _mobileServer;

  static bool _closing = false;

  // UI listens to this to show the closing overlay.
  static final ValueNotifier<bool> isClosing =
      ValueNotifier<bool>(false);

  static const int backendPort = 8080;

  // ==============================================================
  // WINDOW CLOSE HANDLER
  // ==============================================================

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    if (!(Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux)) {
      return;
    }

    await windowManager.ensureInitialized();

    await windowManager.setPreventClose(true);

    
    windowManager.addListener(
      _BackendWindowListener(),
    );
  }

  static Future<void> _handleWindowClose() async {
    if (_closing) {
      return;
    }

    _closing = true;

    print('[Backend] Flutter window is closing.');

    isClosing.value = true;

    // Allow the closing UI to render.
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );

    await stop();

    print('[Backend] Backend cleanup completed.');

    await windowManager.setPreventClose(false);

    await windowManager.destroy();
  }

  // ==============================================================
  // START
  // ==============================================================

  static Future<void> start() async {
    // ============================================================
    // ANDROID / IOS
    // ============================================================

    if (!kIsWeb &&
        (Platform.isAndroid || Platform.isIOS)) {
      await _startMobileBackend();
      return;
    }

    // ============================================================
    // WEB
    // ============================================================

    if (kIsWeb) {
      print(
        '[Backend] Web backend must already be running.',
      );
      return;
    }

    // ============================================================
    // DESKTOP
    // ============================================================

    if (!(Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux)) {
      return;
    }

    if (_process != null) {
      print('[Backend] Already running.');
      return;
    }

    // ============================================================
    // FIND DIRECTORY WHERE FLUTTER EXE IS LOCATED
    // ============================================================

    final executableDirectory =
        File(Platform.resolvedExecutable).parent.path;

    print(
      '[Backend] Executable directory:\n'
      '$executableDirectory',
    );

    // ============================================================
    // WINDOWS
    //
    // Expected:
    //
    // Release/
    //   jualbeli.exe
    //   jualbeli_backend.exe
    // ============================================================

    String backendExecutable;

    if (Platform.isWindows) {
      backendExecutable = p.join(
        executableDirectory,
        'jualbeli_backend.exe',
      );
    } else {
      backendExecutable = p.join(
        executableDirectory,
        'jualbeli_backend',
      );
    }

    final backendFile = File(backendExecutable);

    if (!await backendFile.exists()) {
      throw Exception(
        'Backend executable not found:\n'
        '$backendExecutable',
      );
    }

    print('[Backend] Starting...');
    print('[Backend] $backendExecutable');

    // ============================================================
    // START COMPILED BACKEND
    // ============================================================

    _process = await Process.start(
      backendExecutable,
      [],
      workingDirectory: executableDirectory,
      runInShell: false,
    );

    print(
      '[Backend] Started. PID: ${_process!.pid}',
    );

    // ============================================================
    // BACKEND STDOUT
    // ==============================================================

    _process!.stdout
        .transform(SystemEncoding().decoder)
        .listen((data) {
      stdout.write('[Backend] $data');
    });

    // ============================================================
    // BACKEND STDERR
    // ==============================================================

    _process!.stderr
        .transform(SystemEncoding().decoder)
        .listen((data) {
      stderr.write('[Backend ERROR] $data');
    });

    // ============================================================
    // WATCH PROCESS
    // ==============================================================

    final process = _process;

    unawaited(
      process!.exitCode.then((exitCode) {
        print(
          '[Backend] Exited with code $exitCode',
        );

        if (_process == process) {
          _process = null;
        }
      }),
    );
  }

  // ==============================================================
  // LOCAL MOBILE BACKEND
  // ==============================================================

  static Future<void> _startMobileBackend() async {
    if (_mobileServer != null) {
      print(
        '[Backend] Mobile backend already running.',
      );
      return;
    }

    print(
      '[Backend] Starting local mobile backend...',
    );

    _mobileServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      backendPort,
    );

    print(
      '[Backend] Mobile backend running:',
    );

    print(
      'http://localhost:$backendPort',
    );

    _mobileServer!.listen(
      (HttpRequest request) async {
        await _handleRequest(request);
      },
    );
  }

  // ==============================================================
  // MOBILE API ROUTER
  // ==============================================================

  static Future<void> _handleRequest(
    HttpRequest request,
  ) async {
    final path = request.uri.path;

    print(
      '[Backend] ${request.method} $path',
    );

    if (path == '/api/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'status': 'ok',
            'backend': 'mobile',
          }),
        );

      await request.response.close();
      return;
    }

    if (path == '/api/test') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'message':
                'JualBeli backend is running locally.',
          }),
        );

      await request.response.close();
      return;
    }

    request.response
      ..statusCode = HttpStatus.notFound
      ..headers.contentType = ContentType.json
      ..write(
        jsonEncode({
          'error': 'Endpoint not found',
        }),
      );

    await request.response.close();
  }

  // ==============================================================
  // STOP
  // ==============================================================

  static Future<void> stop() async {
    // ============================================================
    // STOP MOBILE BACKEND
    // ============================================================

    if (_mobileServer != null) {
      print('[Backend] Stopping mobile backend...');

      await _mobileServer!.close(force: true);

      _mobileServer = null;

      print('[Backend] Mobile backend stopped.');
    }

    // ============================================================
    // STOP DESKTOP BACKEND
    // ============================================================

    final process = _process;

    if (process == null) {
      print('[Backend] No desktop backend process.');
      return;
    }

    final pid = process.pid;

    print(
      '[Backend] Stopping desktop backend '
      '(PID $pid)...',
    );

    if (Platform.isWindows) {
      try {
        // Kill the exact backend process we started.
        final pidResult = await Process.run(
          'taskkill',
          [
            '/PID',
            pid.toString(),
            '/T',
            '/F',
          ],
          runInShell: true,
        );

        print(
          '[Backend] PID taskkill exit code: '
          '${pidResult.exitCode}',
        );

        print(
          '[Backend] PID taskkill stdout: '
          '${pidResult.stdout}',
        );

        print(
          '[Backend] PID taskkill stderr: '
          '${pidResult.stderr}',
        );

        // Also kill any remaining jualbeli_backend.exe.
        final nameResult = await Process.run(
          'taskkill',
          [
            '/IM',
            'jualbeli_backend.exe',
            '/T',
            '/F',
          ],
          runInShell: false,
        );

        print(
          '[Backend] Name taskkill exit code: '
          '${nameResult.exitCode}',
        );

        print(
          '[Backend] Name taskkill stdout: '
          '${nameResult.stdout}',
        );

        print(
          '[Backend] Name taskkill stderr: '
          '${nameResult.stderr}',
        );
      } catch (e) {
        print(
          '[Backend] Failed to kill backend: $e',
        );
      }

      try {
        final result = await Process.run(
          'taskkill',
          [
            '/PID',
            pid.toString(),
            '/T',
            '/F',
          ],
          runInShell: true,
        );

        print(
          '[Backend] taskkill exit code: '
          '${result.exitCode}',
        );

        print(
          '[Backend] taskkill stdout: '
          '${result.stdout}',
        );

        print(
          '[Backend] taskkill stderr: '
          '${result.stderr}',
        );
      } catch (e) {
        print(
          '[Backend] Failed to kill backend: $e',
        );
      }
    } else {
      try {
        process.kill(
          ProcessSignal.sigterm,
        );
      } catch (e) {
        print(
          '[Backend] Failed to stop backend: $e',
        );
      }
    }

    // ============================================================
    // CLEAR PROCESS REFERENCE
    // ============================================================

    _process = null;

    print(
      '[Backend] Desktop backend stopped.',
    );
  }

  // ==============================================================
  // BASE URL
  // ==============================================================

  static String get baseUrl {
    return 'http://localhost:$backendPort';
  }
}

// ==============================================================
// WINDOW LISTENER
// ==============================================================

class _BackendWindowListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    print('[Backend] WINDOW CLOSE EVENT');

    await BackendProcess._handleWindowClose();
  }
}