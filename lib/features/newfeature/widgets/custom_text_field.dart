import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primaryBlue),
                color: Colors.white,
              ),
              child: TextField(
                controller: widget.controller,
                obscureText: _isObscure,
                keyboardType: widget.keyboardType,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  suffixIcon: widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: -8,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
