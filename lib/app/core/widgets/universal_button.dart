import 'package:flutter/material.dart';

import '../helper/general_sizes.dart';
import 'custom_text.dart';

class UniversalButton extends StatefulWidget {
  const UniversalButton({
    super.key,
    this.widthPortion,
    this.height,
    required this.onTap,
    required this.title,
    required this.color,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.bRadius,
  });
  final VoidCallback onTap;
  final double? widthPortion;
  final double? height;
  final IconData? icon;
  final String title;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double? bRadius;

  @override
  State<UniversalButton> createState() => _UniversalButtonState();
}

class _UniversalButtonState extends State<UniversalButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  void _handleTap() {
    widget.onTap();
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: _handleTap,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        borderRadius: BorderRadius.circular(widget.bRadius ?? borderRadiusL),
        child: Container(
          width: widget.widthPortion == null
              ? widget.widthPortion
              : screenWidth * widget.widthPortion!,
          height: widget.height == null ? widget.height : widget.height!,
          padding: EdgeInsets.symmetric(
            horizontal: GeneralSizes.small,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(
              widget.bRadius ?? borderRadiusL,
            ),
            border: Border.all(color: widget.borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, size: 18, color: widget.textColor),
              SizedBox(width: GeneralSizes.small + 3),
              CustomText(
                text: widget.title,
                color: widget.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
