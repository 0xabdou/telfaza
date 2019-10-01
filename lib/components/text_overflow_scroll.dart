import 'package:flutter/material.dart';

class TextOverflowScroll extends StatefulWidget {
  final String text;
  final TextStyle style;

  const TextOverflowScroll(
    this.text, {
    this.style,
  });

  @override
  _TextOverflowScrollState createState() => _TextOverflowScrollState();
}

class _TextOverflowScrollState extends State<TextOverflowScroll> {
  final Duration pauseDuration = Duration(seconds: 2);
  final Duration backDuration = Duration(milliseconds: 500);

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _animate();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
      ),
    );
  }

  _animate() async {
    await Future.delayed(pauseDuration);
    // the user can quit but this will still execute
    // prevent it
    if (!_scrollController.hasClients) return;

    Duration scrollDuration = Duration(
      milliseconds: 10 * _scrollController.position.maxScrollExtent.floor(),
    );
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: scrollDuration,
        curve: Curves.linear);

    await Future.delayed(pauseDuration);
    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(0.0,
        duration: backDuration, curve: Curves.ease);
    _animate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
