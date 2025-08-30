import 'dart:convert';
import 'dart:io';

/// Paste base64 strings for images below and run this script with:
/// dart run tools/write_assets_from_base64.dart

void main() async {
  // Replace these with the Base64 strings of your attachments.
  const xLogoBase64 = '''REPLACE_WITH_X_BASE64''';
  const lineLogoBase64 = '''REPLACE_WITH_LINE_BASE64''';

  final assetsDir = Directory('assets/icons');
  if (!assetsDir.existsSync()) assetsDir.createSync(recursive: true);

  if (xLogoBase64.isNotEmpty && xLogoBase64 != 'REPLACE_WITH_X_BASE64') {
    final bytes = base64.decode(xLogoBase64);
    final file = File('${assetsDir.path}/x_logo.png');
    await file.writeAsBytes(bytes);
    print('Wrote ${file.path} (${bytes.length} bytes)');
  } else {
    // Attempt to copy an existing asset (x-close.png) as a fallback so the app can reference x_logo.png
    final existing = File('${assetsDir.path}/x-close.png');
    final target = File('${assetsDir.path}/x_logo.png');
    if (existing.existsSync()) {
      await existing.copy(target.path);
      print('Copied existing ${existing.path} -> ${target.path}');
    } else {
      print('x logo base64 not provided and ${existing.path} not found; skipping x_logo.png');
    }
  }

  if (lineLogoBase64.isNotEmpty && lineLogoBase64 != 'REPLACE_WITH_LINE_BASE64') {
    final bytes = base64.decode(lineLogoBase64);
    final file = File('${assetsDir.path}/line_logo.png');
    await file.writeAsBytes(bytes);
    print('Wrote ${file.path} (${bytes.length} bytes)');
  } else {
    // Attempt to copy an existing LINE brand icon as a fallback
    final existingLine = File('${assetsDir.path}/LINE_Brand_icon.png');
    final targetLine = File('${assetsDir.path}/line_logo.png');
    if (existingLine.existsSync()) {
      await existingLine.copy(targetLine.path);
      print('Copied existing ${existingLine.path} -> ${targetLine.path}');
    } else {
      print('line logo base64 not provided and ${existingLine.path} not found; skipping line_logo.png');
    }
  }
}
