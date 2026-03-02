
import 'package:url_launcher/url_launcher.dart';

Future<void> callPhone(String phone) async {
  print('Calling phone number: +998$phone');
  final uri = Uri.parse('tel:+998$phone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
  else{
    print('Could not launch $uri');
  }
}