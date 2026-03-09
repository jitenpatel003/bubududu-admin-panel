import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../services/firebase_service.dart';

class AdminNotesWidget extends StatefulWidget {
  final String docId;
  final List<Map<String, dynamic>> notes;

  const AdminNotesWidget({
    super.key,
    required this.docId,
    required this.notes,
  });

  @override
  State<AdminNotesWidget> createState() => _AdminNotesWidgetState();
}

class _AdminNotesWidgetState extends State<AdminNotesWidget> {
  final _controller = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    try {
      await _firebaseService.addNote(widget.docId, text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(widget.notes)
      ..sort((a, b) {
        final ta = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final tb = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return tb.compareTo(ta);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sorted.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'No notes yet.',
              style: TextStyle(color: AppColors.textSubtext, fontSize: 13),
            ),
          )
        else
          ...sorted.map((note) {
            final ts = (note['timestamp'] as Timestamp?)?.toDate();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['text'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (ts != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('MMM d, yyyy · hh:mm a').format(ts),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSubtext,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add a note...',
                  hintStyle: TextStyle(fontSize: 13),
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saving ? null : _addNote,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
