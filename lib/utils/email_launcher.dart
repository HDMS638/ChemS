import 'package:url_launcher/url_launcher.dart';

Future<void> launchEmail({
  required String toEmail,
  String subject = '',
  String body = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: toEmail,
    query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw '이메일 앱을 열 수 없습니다.';
  }
}
