import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

class BackendProcess {
  static Process? _process;
  static HttpServer? _mobileServer;

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

    windowManager.addListener(
      _BackendWindowListener(),
    );
  }

  static Future<void> _handleWindowClose() async {
    print('[Backend] Flutter window is closing.');

    await stop();

    print('[Backend] Backend cleanup completed.');

    await windowManager.destroy();
  }

  // ==============================================================
  // START
  // ==============================================================

  static Future<void> start() async {
    // ============================================================
    // ANDROID / IOS
    // Run a local HTTP backend inside the Flutter app.
    // ============================================================

    if (!kIsWeb &&
        (Platform.isAndroid || Platform.isIOS)) {
      await _startMobileBackend();
      return;
    }

    // ============================================================
    // WEB
    // Browser cannot start a local Dart process.
    // ============================================================

    if (kIsWeb) {
      print('[Backend] Web backend must already be running.');
      return;
    }

    // ============================================================
    // WINDOWS / MACOS / LINUX
    // Start your existing separate backend.
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

    final projectDirectory = Directory.current;

    final backendDirectory = Directory(
      p.join(
        projectDirectory.path,
        'jualbeli_backend',
      ),
    );

    if (!await backendDirectory.exists()) {
      throw Exception(
        'jualbeli_backend not found:\n'
        '${backendDirectory.path}',
      );
    }

    print('[Backend] Starting...');
    print('[Backend] ${backendDirectory.path}');

    _process = await Process.start(
      'dart',
      ['run'],
      workingDirectory: backendDirectory.path,
      runInShell: true,
    );

    print('[Backend] Started. PID: ${_process!.pid}');

    _process!.stdout
        .transform(SystemEncoding().decoder)
        .listen((data) {
      stdout.write('[Backend] $data');
    });

    _process!.stderr
        .transform(SystemEncoding().decoder)
        .listen((data) {
      stderr.write('[Backend ERROR] $data');
    });

    unawaited(
      _process!.exitCode.then((exitCode) {
        print('[Backend] Exited with code $exitCode');
        _process = null;
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

    // Health check
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

    // Example endpoint
    if (path == '/api/test') {
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write(
          jsonEncode({
            'message': 'JualBeli backend is running locally.',
          }),
        );

      await request.response.close();
      return;
    }

    // Not found
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
    // Stop mobile backend
    if (_mobileServer != null) {
      print('[Backend] Stopping mobile backend...');

      await _mobileServer!.close(force: true);

      _mobileServer = null;

      print('[Backend] Mobile backend stopped.');
    }

    // Stop desktop backend
    final process = _process;

    if (process == null) {
      return;
    }

    print('[Backend] Stopping desktop backend...');

    if (Platform.isWindows) {
      await Process.run(
        'taskkill',
        [
          '/PID',
          process.pid.toString(),
          '/T',
          '/F',
        ],
        runInShell: true,
      );
    } else {
      process.kill(ProcessSignal.sigterm);
    }

    _process = null;

    print('[Backend] Desktop backend stopped.');
  }

  // ==============================================================
  // BASE URL
  // ==============================================================

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$backendPort';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return 'http://localhost:$backendPort';
    }

    return 'http://localhost:$backendPort';
  }
}

// ==============================================================
// WINDOW LISTENER
// ==============================================================

class _BackendWindowListener extends WindowListener {
  @override
  Future<void> onWindowClose() async {
    await BackendProcess._handleWindowClose();
  }
}