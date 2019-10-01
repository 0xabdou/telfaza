import 'dart:async';

import 'package:flutter/material.dart';

class BottomSheetDragger extends StatefulWidget {
  final StreamController<double> _dragUpdateStream;

  final Widget child;

  BottomSheetDragger({this.child})
      : _dragUpdateStream = StreamController<double>();

  Stream<double> get dragUpdateStream => _dragUpdateStream.stream;

  @override
  _BottomSheetDraggerState createState() => _BottomSheetDraggerState();
}

const double kFullSlide = 400.0;

class _BottomSheetDraggerState extends State<BottomSheetDragger>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  Offset _startingPoint;
  double dragPercent = 0.0;
  SheetState state = SheetState.closed;

  void _onDragStart(DragStartDetails details) {
    _startingPoint = details.globalPosition;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_startingPoint != null) {
      double dy = _startingPoint.dy - details.globalPosition.dy;

      // if the slider is open and the user drags up
      // or if it's closed and the user drags down
      // we don't update
      if ((state == SheetState.open && dy > 0) ||
          state == SheetState.closed && dy < 0) return;

      if ((state == SheetState.closed || state == SheetState.opening) &&
          dy > 0) {
        dragPercent = (dy / kFullSlide).abs().clamp(0.0, 1.0);
        if (dragPercent == 1)
          state = SheetState.open;
        else
          state = SheetState.opening;
        widget._dragUpdateStream.add(dragPercent);
      } else if ((state == SheetState.open || state == SheetState.closing) &&
          dy < 0) {
        dragPercent = 1 - (dy / kFullSlide).abs().clamp(0.0, 1.0);
        if (dragPercent == 0)
          state = SheetState.closed;
        else
          state = SheetState.closing;
        widget._dragUpdateStream.add(dragPercent);
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (dragPercent != 0.0 && dragPercent != 1) _animate();
    _startingPoint = null;
    dragPercent = 0.0;
  }

  void _animate({bool backPressed = false}) {
    double begin = (backPressed && state == SheetState.open) ? 1 : dragPercent;
    double end;
    if (backPressed) {
      end = 0.0;
      state = SheetState.closed;
    } else {
      if (state == SheetState.closing) {
        if (dragPercent > 0.8) {
          end = 1.0;
          state = SheetState.open;
        } else {
          end = 0.0;
          state = SheetState.closed;
        }
      } else {
        if (dragPercent > 0.15) {
          end = 1.0;
          state = SheetState.open;
        } else {
          end = 0.0;
          state = SheetState.closed;
        }
      }
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _animation = Tween<double>(begin: begin, end: end).animate(_controller)
      ..addListener(() {
        widget._dragUpdateStream.add(_animation.value);
      });

    _controller.forward();
  }

  @override
  void initState() {
    super.initState();

    // animate bottom sheet when the screen is first displayed
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: -0.4, end: 0).animate(_controller);
    _animation.addListener(() {
      setState(() {
        widget._dragUpdateStream.add(_animation.value);
      });
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (state == SheetState.open) {
          _animate(backPressed: true);
          return Future<bool>.value(false);
        } else {
          return Future<bool>.value(true);
        }
      },
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
      ),
    );
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    widget._dragUpdateStream.close();
    super.dispose();
  }
}

enum SheetState {
  open,
  closed,
  opening,
  closing,
}
