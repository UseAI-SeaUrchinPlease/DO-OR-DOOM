import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uint8List を一時ファイルに書き、共有するユーティリティ
Future<void> shareBytesAsImage(Uint8List bytes, {String? filename, String? text}) async {
  final dir = await getTemporaryDirectory();
  final fileName = filename ?? 'badge_${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);

  await Share.shareXFiles([XFile(file.path)], text: text ?? '共有されたバッジ');
}

/// テキストを Twitter の intent で開く
Future<void> shareToTwitter(String text) async {
  final encoded = Uri.encodeComponent(text);
  final url = Uri.parse('https://twitter.com/intent/tweet?text=$encoded');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

/// テキストを LINE の共有URLで開く
Future<void> shareToLine(String text) async {
  final encoded = Uri.encodeComponent(text);
  final url = Uri.parse('https://social-plugins.line.me/lineit/share?text=$encoded');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
