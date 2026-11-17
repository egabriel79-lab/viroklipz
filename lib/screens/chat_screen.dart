import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatarUrl;
  final String otherUserInitials;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatarUrl,
    required this.otherUserInitials,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _typingDebounce;
  bool _isCurrentlyTyping = false;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference<Map<String, dynamic>> get _chatDocRef =>
      FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

  @override
  void dispose() {
    _typingDebounce?.cancel();
    if (_isCurrentlyTyping && _myUid.isNotEmpty) {
      _updateTypingStatus(false);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Actualiza chats/{chatId} -> typingStatus.{_myUid} = isTyping
  Future<void> _updateTypingStatus(bool isTyping) async {
    final uid = _myUid;
    if (uid.isEmpty) return;
    if (_isCurrentlyTyping == isTyping && isTyping) return;

    _isCurrentlyTyping = isTyping;

    try {
      await _chatDocRef.set(
        {
          'typingStatus': {uid: isTyping},
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Silenciar errores transitorios de red al escribir
    }
  }

  /// Lógica del emisor: onChanged + Timer Debounce de 2.5 segundos
  void _onMessageChanged(String value) {
    _typingDebounce?.cancel();

    if (value.trim().isEmpty) {
      _updateTypingStatus(false);
      return;
    }

    _updateTypingStatus(true);

    _typingDebounce = Timer(const Duration(milliseconds: 2500), () {
      _updateTypingStatus(false);
    });
  }

  /// Envía el mensaje y apaga typingStatus.{_myUid} = false inmediatamente
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final uid = _myUid;
    if (text.isEmpty || uid.isEmpty) return;

    _typingDebounce?.cancel();
    _messageController.clear();
    await _updateTypingStatus(false);

    await _chatDocRef.collection('messages').add({
      'senderId': uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chatDocRef.set(
      {
        'lastMessage': text,
        'updatedAt': FieldValue.serverTimestamp(),
        'typingStatus': {uid: false},
      },
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF27272A),
              backgroundImage: NetworkImage(widget.otherUserAvatarUrl),
              child: widget.otherUserAvatarUrl.isEmpty
                  ? Text(
                      widget.otherUserInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.otherUserName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. LÓGICA DEL RECEPTOR: StreamBuilder escuchando chats/{chatId}
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _chatDocRef.snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final typingStatus =
                  data?['typingStatus'] as Map<String, dynamic>?;
              final isOtherTyping =
                  typingStatus?[widget.otherUserId] == true;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: isOtherTyping
                    ? Container(
                        key: const ValueKey('typing_indicator_active'),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Escribiendo...',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('typing_indicator_idle'),
                      ),
              );
            },
          ),

          // 2. LISTA DE MENSAJES EN TIEMPO REAL
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatDocRef
                  .collection('messages')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF2D55),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Envía un mensaje para iniciar la conversación',
                      style: TextStyle(
                        color: Color(0xFF71717A),
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = docs[index].data();
                    final isMe = msg['senderId'] == _myUid;
                    final text = (msg['text'] as String?) ?? '';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFFF2D55)
                              : const Color(0xFF1B1B1F),
                          borderRadius: BorderRadius.circular(18),
                          border: isMe
                              ? null
                              : Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                        ),
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 3. CAMPO DE ENTRADA DEL EMISOR
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onMessageChanged,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enviar mensaje...',
                        hintStyle: const TextStyle(color: Color(0xFF71717A)),
                        filled: true,
                        fillColor: const Color(0xFF18181B),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF2D55),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D55),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}