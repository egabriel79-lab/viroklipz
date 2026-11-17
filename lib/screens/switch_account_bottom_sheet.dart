import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

void showSwitchAccountBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Cambiar de cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ...auth.savedAccounts.map((account) {
                          final bool isActive =
                              auth.currentUser?.id == account.id;
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(account.avatarUrl),
                            ),
                            title: Text(
                              account.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: isActive
                                ? const Icon(
                                    Icons.check,
                                    color: Color(0xFFFE2C55),
                                    size: 22,
                                  )
                                : account.unreadCount > 0
                                    ? Container(
                                        width: 22,
                                        height: 22,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFE2C55),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${account.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                            onTap: () {
                              auth.switchAccount(account);
                              Navigator.pop(sheetContext);
                            },
                          );
                        }),
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey[800],
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                          title: const Text(
                            'Agregar cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            final bool limitReached =
                                auth.savedAccounts.length >=
                                    AuthProvider.maxSavedAccounts;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  limitReached
                                      ? 'Error: máximo 10 cuentas guardadas'
                                      : 'Función para añadir cuenta',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}