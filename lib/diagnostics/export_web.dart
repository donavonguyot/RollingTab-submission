import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

Future<void> saveEvidence(String name, Uint8List bytes, String mime) async {
  if (const bool.fromEnvironment('ROLLINGTAB_EVIDENCE')) {
    final response = await http.post(
      Uri.base.resolve('/__review/$name'),
      body: bytes,
      headers: {'Content-Type': mime},
    );
    if (response.statusCode == 201) return;
  }
  final url = web.URL.createObjectURL(
    web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime)),
  );
  final a = web.HTMLAnchorElement()
    ..href = url
    ..download = name;
  web.document.body!.appendChild(a);
  a.click();
  a.remove();
  Future.delayed(
    const Duration(seconds: 5),
    () => web.URL.revokeObjectURL(url),
  );
}
