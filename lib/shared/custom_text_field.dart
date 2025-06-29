import 'package:bookmywod_admin/shared/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool? readOnly;
  final Function()? onTap;
  final String? initialValue;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final Color? labelColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool? isVisible;
  final VoidCallback? onVisibilityToggle;
  final Icon? prefixIcon;

  const CustomTextField({
    super.key,
    this.label,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    required this.controller,
    this.initialValue = '',
    this.obscureText = false,
    this.enabled = true,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.labelColor,
    this.isVisible,
    this.onVisibilityToggle,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = widget.isVisible ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      readOnly: widget.readOnly!,
      controller: widget.controller,
      obscureText: widget.obscureText && !_isPasswordVisible,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: widget.labelColor ?? Colors.white),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: customBlue),
          borderRadius: BorderRadius.all(
            Radius.circular(40.0),
          ),
        ),
        filled: true,
        fillColor: customDarkBlue,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: customGrey),
          borderRadius: BorderRadius.all(
            Radius.circular(40.0),
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(40.0),
          ),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.onVisibilityToggle != null
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                  if (widget.onVisibilityToggle != null) {
                    widget.onVisibilityToggle!();
                  }
                },
              )
            : null,
      ),
    );
  }
}
