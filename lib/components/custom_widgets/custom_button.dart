import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onTap;

  final bool isLoading;
  final OutlinedBorder? outlineShape;
  final Widget? child;
  final String? text;
  final double? elevation;
  final Size? minimumSize;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderSide? side;

  const CustomElevatedButton({
    super.key,
    this.color,
    required this.onTap,
    this.isLoading = false,
    this.outlineShape,
    this.child,
    this.elevation,
    this.minimumSize,
    this.padding,
    this.width,
    this.margin,
    this.height,
    this.text,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: padding,
          side: side,
          backgroundColor: color,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shadowColor: Colors.transparent,
          splashFactory: InkSplash.splashFactory,
          minimumSize: minimumSize ?? const Size(0, 0),
          elevation: elevation,
          shape: outlineShape,
        ),
        onPressed: onTap,
        child: Builder(builder: (context) {
          if (isLoading) {
            return const _ButtonLoader();
          } else {
            return child ??
                Text(
                  text ?? "",
                );
          }
        }),
      ),
    );
  }
}

class _ButtonLoader extends StatelessWidget {
  const _ButtonLoader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double height =
            constraints.maxHeight.isInfinite ? 21 : constraints.maxHeight;
        return SizedBox(
          height: height,
          width: height,
          child: const CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      },
    );
  }
}
