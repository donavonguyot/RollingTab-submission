import 'dart:io';
import 'dart:typed_data';

Future<void> saveEvidence(String name, Uint8List bytes, String mime) async {
  final directory = Directory('${Directory.systemTemp.path}/rollingtab-review')
    ..createSync(recursive: true);
  await File('${directory.path}/$name').writeAsBytes(bytes);
}
