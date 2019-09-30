import 'package:flutter/material.dart';

class SelectableItem extends StatefulWidget {
  const SelectableItem({
    Key key,
    @required this.index,
    @required this.color,
    @required this.selected,
  }) : super(key: key);

  final int index;
  final MaterialColor color;
  final bool selected;

  @override
  _SelectableItemState createState() => _SelectableItemState();
}

class _SelectableItemState extends State<SelectableItem>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      value: widget.selected ? 1 : 0,
      duration: kThemeChangeDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void didUpdateWidget(SelectableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: DecoratedBox(
            child: child,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: calculateColor(),
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          'Item\n#${widget.index}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

  Color calculateColor() {
    return Color.lerp(
      widget.color.shade500,
      widget.color.shade900,
      _controller.value,
    );
  }
}
