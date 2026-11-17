import 'package:flutter/material.dart';

void showPrivacyAudienceBottomSheet({
  required BuildContext context,
  required String title,
  required String question,
  required String footerNote,
  required String currentValue,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                question,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<String>(
                value: 'Todo el mundo',
                groupValue: currentValue,
                activeColor: const Color(0xFFFF5722),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(
                  'Todo el mundo',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
                onChanged: (val) {
                  if (val != null) onSelected(val);
                  Navigator.pop(sheetContext);
                },
              ),
              RadioListTile<String>(
                value: 'Solo tú',
                groupValue: currentValue,
                activeColor: const Color(0xFFFF5722),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(
                  'Solo tú',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
                onChanged: (val) {
                  if (val != null) onSelected(val);
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 8),
              Text(
                footerNote,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    },
  );
}