import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'DO OR DOOM',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: const Color(0xFFE7E0EC),
      foregroundColor: const Color(0xFF49454F),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.description),
        onPressed: () => _showDocumentStub(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // 設定機能は準備中（通知なし）
          },
        ),
      ],
    );
  }

  void _showDocumentStub(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.description,
                color: Color(0xFF6750A4),
                size: 24,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ドキュメント',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF49454F),
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF6750A4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF6750A4),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ドキュメント機能は現在開発中です。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6750A4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '以下の機能を予定しています：\n• ユーザーガイド\n• 使い方説明\n• FAQ\n• ヘルプドキュメント',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF79747E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFF6750A4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
