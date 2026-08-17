import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/backend_process.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackendProcess.initialize();

  await BackendProcess.start();

  runApp(const JualBeliApp());
}