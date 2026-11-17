import 'dart:async';
import 'package:flutter/material.dart';

class StoryViewerScreen extends StatefulWidget {
  final String title;
  final String coverUrl;
  final List<String> slides;

  const StoryViewerScreen({
    super.key,
    required this.title,
    required this.coverUrl,
    required this.slides,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  int _currentIndex = 0;
  bool _liked = false;
  Timer? _autoTimer;
  final TextEditingController _replyController = TextEditingController();

  List<String> get _safeSlides =>
      widget.slides.isNotEmpty ? widget.slides : [widget.coverUrl];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (_currentIndex < _safeSlides.length - 1) {
        setState(() => _currentIndex++);
        _startTimer();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _handleTap(TapUpDetails details, double width) {
    if (details.localPosition.dx < width * 0.35) {
      setState(() => _currentIndex = (_currentIndex - 1).clamp(0, _safeSlides.length - 1));
      _startTimer();
    } else if (_currentIndex < _safeSlides.length - 1) {
      setState(() => _currentIndex++);
      _startTimer();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTapUp: (details) => _handleTap(details, width),
              child: Image.network(
                _safeSlides[_currentIndex],
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Row(
                    children: List.generate(_safeSlides.length, (idx) {
                      return Expanded(
                        child: Container(
                          height: 2.5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: idx <= _currentIndex
                                ? Colors.white
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(widget.coverUrl),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enviar mensaje...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        filled: true,
                        fillColor: Colors.white12,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      color: _liked ? const Color(0xFFFF2D55) : Colors.white,
                    ),
                    onPressed: () => setState(() => _liked = !_liked),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}