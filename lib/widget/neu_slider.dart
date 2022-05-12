import 'package:game/utils/utils.dart';
import 'package:flutter/material.dart';

class NeuSlider extends StatefulWidget {
  final double percent;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  const NeuSlider({
    Key key,
    @required this.percent,
    @required this.height,
    @required this.width,
    @required this.borderRadius,
  }) : super(key: key);

  @override
  _NeuSliderState createState() => _NeuSliderState();
}

class _NeuSliderState extends State<NeuSlider>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: Color(0xFFFB4747),
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF8F2).mix(Colors.white, .1).withOpacity(0.8),
            Color(0xFFFFF8F2).mix(Colors.white, -0.75).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF854A4A),
            offset: Offset(-1, -1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFFFFC7C7),
            offset: Offset(1, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.decelerate,
          height: widget.height,
          width: widget.percent * widget.width,
          decoration: BoxDecoration(
            color: Color(0xFFFB8212),
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}
