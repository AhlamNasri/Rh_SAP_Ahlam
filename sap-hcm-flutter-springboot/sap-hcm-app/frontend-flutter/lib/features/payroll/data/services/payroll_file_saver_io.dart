import 'dart:io';

Future<String> savePayrollFile({
  required List<int> bytes,
  required String fileName,
  required String mimeType,
}) async {
  final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? Directory.current.path;
  final downloads = Directory('$home${Platform.pathSeparator}Downloads');
  if (!downloads.existsSync()) {
    downloads.createSync(recursive: true);
  }
  final target = File('${downloads.path}${Platform.pathSeparator}$fileName');
  await target.writeAsBytes(bytes, flush: true);
  return target.path;
}
