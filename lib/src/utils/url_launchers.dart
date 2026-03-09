
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

Future<void> openRouteInMap({
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) async {
  final yandexUrl = Uri.parse(
    'yandexmaps://maps.yandex.ru/?rtext=$fromLat,$fromLng~$toLat,$toLng&rtt=auto',
  );
  if (await canLaunchUrl(yandexUrl)) {
    await launchUrl(yandexUrl);
    return;
  }

  final googleUrl = Uri.parse(
    'comgooglemaps://?saddr=$fromLat,$fromLng&daddr=$toLat,$toLng&directionsmode=driving',
  );
  if (await canLaunchUrl(googleUrl)) {
    await launchUrl(googleUrl);
    return;
  }

  final webUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$toLat,$toLng&travelmode=driving',
  );
  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
}