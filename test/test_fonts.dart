import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real app fonts into the test binding.
///
/// Widget tests ship without font assets, so text renders as placeholder
/// boxes. Loading the bundled faces makes goldens show actual type.
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _load('Poppins', const [
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Medium.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
    'assets/fonts/Poppins-ExtraBold.ttf',
  ]);

  await _load('SpaceMono', const ['assets/fonts/SpaceMono-Bold.ttf']);

  // Icon fonts live in the SDK cache, not the project.
  final flutterRoot = _flutterRoot();
  if (flutterRoot != null) {
    final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (icons.existsSync()) {
      await _loadFiles('MaterialIcons', [icons]);
    }
  }
}

Future<void> _load(String family, List<String> paths) => _loadFiles(
  family,
  paths.map(File.new).where((f) => f.existsSync()).toList(),
);

Future<void> _loadFiles(String family, List<File> files) async {
  if (files.isEmpty) return;
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = await file.readAsBytes();
    loader.addFont(
      Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
    );
  }
  await loader.load();
}

String? _flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) return env;

  // Derive from the resolved `flutter` executable on PATH.
  for (final dir in (Platform.environment['PATH'] ?? '').split(';')) {
    final candidate = File('$dir/flutter.bat');
    if (candidate.existsSync()) {
      return Directory(dir).parent.path;
    }
  }
  return null;
}
