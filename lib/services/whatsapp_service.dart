import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsAppService {
  static const String _apiKey = 'ogFGNJt9vGzu';
  static const String _adminMobile = '919265802481';
  static const String _endpoint = 'https://api.textmebot.com/send.php';

  Future<bool> sendMessage({
    required String recipient,
    required String message,
  }) async {
    try {
      final uri = Uri.parse(_endpoint).replace(
        queryParameters: {
          'recipient': recipient,
          'apikey': _apiKey,
          'text': message,
        },
      );
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> notifyAdmin(String message) async {
    return sendMessage(recipient: _adminMobile, message: message);
  }

  String buildWhatsAppUrl(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final number = cleaned.startsWith('+') ? cleaned.substring(1) : cleaned;
    return 'https://wa.me/$number';
  }
}
