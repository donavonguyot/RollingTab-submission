import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('rollingtabSnapshot')
external set snapshotFunction(JSFunction value);
@JS('rollingtabCommand')
external set commandFunction(JSFunction value);
String get audioBackend => 'Web Audio scheduled PCM';
Future<void> registerEvidence(
  Map<String, dynamic> Function() snapshot,
  Future<void> Function(Map<String, dynamic>) command,
  Future<Uint8List> Function() capture,
) async {
  snapshotFunction = (() => jsonEncode({
    ...snapshot(),
    'audioBackend': audioBackend,
  }).toJS).toJS;
  commandFunction = ((JSString data) => command(
    jsonDecode(data.toDart),
  ).then((_) => jsonEncode(snapshot()).toJS).toJS).toJS;
}
