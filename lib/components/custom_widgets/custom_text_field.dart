import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final bool isDense;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final EdgeInsets? contentPadding;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final bool? isObscureText;
  final bool allowSpaces;
  final String? obscuringCharacter;
  final String? hintText;
  final VoidCallback? onTap;
  final bool readOnly;
  final Color? fillColor;
  final bool filled;
  final int maxLine;
  final int minLine;
  final bool isError;
  final Function(String?)? onChanged;
  final Function(String?)? onSubmit;
  final BoxConstraints? suffixConstraints;
  final BoxConstraints? prefixConstraints;
  final Widget? prefix;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final TextAlign? textAlign;
  final ScrollController? scrollController;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final double leftGap;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.isDense = true,
    this.textStyle,
    this.focusedBorder,
    this.errorBorder,
    this.contentPadding,
    this.controller,
    this.validator,
    this.suffix,
    this.isObscureText,
    this.obscuringCharacter,
    this.hintText,
    this.onTap,
    this.readOnly = false,
    this.fillColor,
    this.filled = true,
    this.suffixConstraints,
    this.isError = false,
    this.maxLine = 1,
    this.minLine = 1,
    this.textInputAction,
    this.textInputType,
    this.onChanged,
    this.onSubmit,
    this.hintStyle,
    this.scrollController,
    this.textAlign,
    this.inputFormatters,
    this.prefixConstraints,
    this.prefix,
    this.suffixText,
    this.autovalidateMode,
    this.leftGap = 20,
    this.allowSpaces = true, this.errorStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      autovalidateMode: autovalidateMode,
      scrollController: scrollController,
      obscureText: isObscureText ?? false,
      onFieldSubmitted: onSubmit,
      onChanged: onChanged,
      textAlign: textAlign ?? TextAlign.start,
      obscuringCharacter: obscuringCharacter ?? "•",
      readOnly: readOnly,
      keyboardType: textInputType,
      inputFormatters: [
        ...inputFormatters ?? []
      ],
      textInputAction: textInputAction,
      style: textStyle ?? Theme.of(context).textTheme.titleMedium,
      validator: validator,
      maxLines: minLine > maxLine ? minLine : maxLine,
      minLines: minLine,
      decoration: InputDecoration(
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: hintStyle,
        suffixIconConstraints: suffixConstraints,
        filled: filled,
        suffixText: suffixText,
        suffixIcon: suffix,
        isDense: isDense,
        prefixIcon: prefix,
        prefixIconConstraints: prefixConstraints,
        errorStyle: errorStyle,
        // prefixIcon: prefix ?? const SizedBox(),
        // prefixIconConstraints:
        // prefixConstraints ?? BoxConstraints(minWidth: leftGap),
        contentPadding: contentPadding,
        focusedErrorBorder: focusedBorder,
        focusedBorder: focusedBorder,
        enabledBorder: focusedBorder,
        errorBorder: errorBorder,
      ),
    );
  }
}
// prefixConstraints: BoxConstraints(minWidth: 16),
// prefix: CustomText(""),

/// Uncomment this -- if you need to the show Custom Error below textField use this or modify this

// class CustomTextField extends StatefulWidget {
//   final bool isDense;
//   final TextStyle? textStyle;
//   final TextStyle? hintStyle;
//   final TextStyle? errorStyle;
//   final InputBorder? focusedBorder;
//   final InputBorder? errorBorder;
//   final EdgeInsets? contentPadding;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final Widget? suffix;
//   final bool? isObscureText;
//   final bool allowSpaces;
//   final String? obscuringCharacter;
//   final String? hintText;
//   final VoidCallback? onTap;
//   final bool readOnly;
//   final Color? fillColor;
//   final bool filled;
//   final int maxLine;
//   final int minLine;
//   final bool isError;
//   final Function(String?)? onChanged;
//   final Function(String?)? onSubmit;
//   final BoxConstraints? suffixConstraints;
//   final BoxConstraints? prefixConstraints;
//   final Widget? prefix;
//   final TextInputAction? textInputAction;
//   final TextInputType? textInputType;
//   final TextAlign? textAlign;
//   final ScrollController? scrollController;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? suffixText;
//   final double leftGap;
//   final AutovalidateMode? autovalidateMode;
//
//   const CustomTextField({
//     super.key,
//     this.isDense = true,
//     this.textStyle,
//     this.focusedBorder,
//     this.errorBorder,
//     this.contentPadding,
//     this.controller,
//     this.validator,
//     this.suffix,
//     this.isObscureText,
//     this.obscuringCharacter,
//     this.hintText,
//     this.onTap,
//     this.readOnly = false,
//     this.fillColor,
//     this.filled = true,
//     this.suffixConstraints,
//     this.isError = false,
//     this.maxLine = 1,
//     this.minLine = 1,
//     this.textInputAction,
//     this.textInputType,
//     this.onChanged,
//     this.onSubmit,
//     this.hintStyle,
//     this.scrollController,
//     this.textAlign,
//     this.inputFormatters,
//     this.prefixConstraints,
//     this.prefix,
//     this.suffixText,
//     this.autovalidateMode,
//     this.leftGap = 20,
//     this.allowSpaces = true,
//     this.errorStyle,
//   });
//
//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   final key = GlobalKey<FormFieldState>();
//
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       widget.controller?.addListener(() {
//         key.currentState?.didChange(
//           (widget.controller?.text) ?? "",
//         );
//       });
//     });
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     widget.controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FormField(
//       key: key,
//       validator: widget.validator,
//       autovalidateMode: widget.autovalidateMode,
//       initialValue: widget.controller?.text ?? "",
//       builder: (state) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               onTap: widget.onTap,
//               controller: widget.controller,
//               // autovalidateMode: autovalidateMode,
//               scrollController: widget.scrollController,
//               obscureText: widget.isObscureText ?? false,
//               onFieldSubmitted: widget.onSubmit,
//               onChanged: (s) {
//                 if (widget.onChanged != null) {
//                   widget.onChanged!(s);
//                 }
//                 state.didChange(s);
//               },
//               cursorColor: ThemeColors.white,
//               textAlign: widget.textAlign ?? TextAlign.start,
//               obscuringCharacter: widget.obscuringCharacter ?? "•",
//               readOnly: widget.readOnly,
//               keyboardType: widget.textInputType,
//               inputFormatters: [
//                 if (!widget.allowSpaces) GetFormatter.removeSpaces,
//                 ...widget.inputFormatters ?? []
//               ],
//               textInputAction: widget.textInputAction,
//               style:
//               widget.textStyle ?? Theme.of(context).textTheme.titleMedium,
//               // validator: validator,
//               maxLines: widget.minLine > widget.maxLine
//                   ? widget.minLine
//                   : widget.maxLine,
//               minLines: widget.minLine,
//               cursorErrorColor: ThemeColors.white,
//               decoration: InputDecoration(
//                 fillColor: widget.fillColor,
//                 hintText: widget.hintText,
//                 hintStyle: widget.hintStyle,
//                 suffixIconConstraints: widget.suffixConstraints,
//                 filled: widget.filled,
//                 suffixText: widget.suffixText,
//                 suffixIcon: widget.suffix,
//                 isDense: widget.isDense,
//                 prefixIcon: widget.prefix,
//                 prefixIconConstraints: widget.prefixConstraints,
//                 errorStyle: widget.errorStyle,
//                 // prefixIcon: prefix ?? const SizedBox(),
//                 // prefixIconConstraints:
//                 // prefixConstraints ?? BoxConstraints(minWidth: leftGap),
//                 contentPadding: widget.contentPadding,
//                 focusedErrorBorder: widget.focusedBorder,
//                 focusedBorder: widget.focusedBorder,
//                 enabledBorder: widget.focusedBorder,
//                 errorBorder: widget.errorBorder,
//               ),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             if (state.hasError)
//               CustomText(
//                 state.errorText ?? "",
//                 textStyle: Theme.of(context).inputDecorationTheme.errorStyle,
//               )
//           ],
//         );
//       },
//     );
//   }
// }

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key,  this.controller, this.onChanged, this.fillColor});
final TextEditingController? controller;
final Color? fillColor;
final  dynamic Function(String?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      fillColor:fillColor,
      hintText: "Enter Search",
      controller: controller,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      // prefix: const CustomSvg(
      //   SvgPath.search,
      //   width: 26,
      //   height: 26,
      // ),
      onChanged:onChanged,
      prefixConstraints: const BoxConstraints(minWidth: 40),
    );
  }
}
