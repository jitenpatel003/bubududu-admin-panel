import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../theme.dart';
import '../services/whatsapp_service.dart';

class ContactPanelWidget extends StatelessWidget {
  final OrderModel order;

  const ContactPanelWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final whatsappService = WhatsAppService();

    return Row(
      children: [
        if (order.whatsapp.isNotEmpty)
          Expanded(
            child: _ContactButton(
              icon: Icons.chat_bubble_outline,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () => _launchUrl(
                whatsappService.buildWhatsAppUrl(order.whatsapp),
              ),
            ),
          ),
        if (order.whatsapp.isNotEmpty) const SizedBox(width: 8),
        if (order.email.isNotEmpty)
          Expanded(
            child: _ContactButton(
              icon: Icons.email_outlined,
              label: 'Email',
              color: AppColors.primary,
              onTap: () => _launchUrl('mailto:${order.email}'),
            ),
          ),
        if (order.email.isNotEmpty && order.instagram.isNotEmpty)
          const SizedBox(width: 8),
        if (order.instagram.isNotEmpty)
          Expanded(
            child: _ContactButton(
              icon: Icons.camera_alt_outlined,
              label: 'Instagram',
              color: const Color(0xFFE1306C),
              onTap: () => _launchUrl(
                'https://instagram.com/${order.instagram}',
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
    );
  }
}
