import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _serviceId = 'service_j80x42j';
  static const String _templateId = 'template_e9c4r48';
  static const String _publicKey = 'Bzg_ouabUpbUgDm7l';
  static const String _endpoint =
      'https://api.emailjs.com/api/v1.0/email/send';

  Future<bool> sendScriptApprovedEmail({
    required String toEmail,
    required String customerName,
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': customerName,
            'order_id': orderId,
            'subject': 'Script Approved – Bubu Dudu Custom Video',
            'message':
                'Your script has been approved and animation production has started. We will send you a preview soon.',
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendEmail({
    required String toEmail,
    required String customerName,
    required String orderId,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': customerName,
            'order_id': orderId,
            'subject': subject,
            'message': message,
          },
        }),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
