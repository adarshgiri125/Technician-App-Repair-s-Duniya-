
import 'package:flutter/material.dart';

class CustomCheckboxButton extends StatelessWidget {
  CustomCheckboxButton({
    Key? key,
    required this.onChange,
    this.decoration,
    this.alignment,
    this.isRightCheck,
    this.iconSize,
    this.value,
    this.text,
    this.width,
    this.padding,
    this.textStyle,
    this.textAlignment,
    this.isExpandedText = false,
    this.height,
  }) : super(key: key);

  final BoxDecoration? decoration;
  final Alignment? alignment;
  final bool? isRightCheck;
  final double? iconSize;
  bool? value;
  final Function(bool) onChange;
  final String? text;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final TextAlign? textAlignment;
  final bool isExpandedText;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildCheckBoxWidget(),
          )
        : buildCheckBoxWidget();
  }

  Widget buildCheckBoxWidget() {
    return InkWell(
      onTap: () {
        value = !(value!);
        onChange(value!);
      },
      child: Container(
        decoration: decoration,
        width: width,
        child:
            (isRightCheck ?? false) ? rightSideCheckbox() : leftSideCheckbox(),
      ),
    );
  }

  Widget leftSideCheckbox() {
    return Row(
      children: [
        Padding(
          child: checkboxWidget(),
          padding: EdgeInsets.only(right: 8),
        ),
        isExpandedText ? Expanded(child: textWidget()) : textWidget(),
      ],
    );
  }

  Widget rightSideCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        isExpandedText ? Expanded(child: textWidget()) : textWidget(),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: checkboxWidget(),
        ),
      ],
    );
  }

  Widget textWidget() {
    return Text(
      text ?? "",
      textAlign: textAlignment ?? TextAlign.center,
      style: textStyle?.copyWith(
            color: Colors.black,
            fontSize: 20.0, // Set the desired font size for the text
          ) ??
          TextStyle(
            color: Colors.black,
            fontSize: 20.0, // Adjust font size as needed
          ),
    );
  }

  Color getColor() {
    if (value ?? false) {
      return Colors.blue; // Change color based on the checkbox state
    } else {
      return Colors.white;
    }
  }

  Widget checkboxWidget() {
    return SizedBox(
      height: 50.0, // Set the desired height for the checkbox container
      width: 50.0, // Set the desired width for the checkbox container
      child: Transform.scale(
        scale: 1.5, // Adjust the scale factor to make the checkbox larger
        child: Checkbox(
          value: value ?? false,
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith((states) => getColor()),
          onChanged: (value) {
            onChange(value!);
          },
        ),
      ),
    );
  }
}
