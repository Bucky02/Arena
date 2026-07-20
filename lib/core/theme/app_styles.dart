import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

/// CLASSE DEGLI STILI (Usata per componenti custom come la Data di Nascita)
class AppStyles {
  static InputDecoration capsuleDecoration(
    String label,
    IconData? icon, {
    Widget? suffixIcon,
    Color coloreTema = AppTheme.neonCyan,
    String? hintText,
  }) {
    const double angoliBottoni = 15.0;
    const Color coloreBordoRiposo = Colors.white54;

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      labelStyle: const TextStyle(color: coloreBordoRiposo),
      floatingLabelStyle: TextStyle(
        color: coloreTema,
        fontWeight: FontWeight.bold,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      filled: true,
      fillColor: AppTheme.cardBg,

      prefixIcon: icon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 4.0),
              child: Icon(icon, color: coloreTema),
            )
          : null,

      suffixIcon: suffixIcon,
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return coloreTema;
        return Colors.white54;
      }),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(angoliBottoni),
        borderSide: const BorderSide(color: Colors.white54, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(angoliBottoni),
        borderSide: BorderSide(
          color: coloreTema,
          width: 2.0,
        ), // Bordo illuminato
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(angoliBottoni),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(angoliBottoni),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );
  }
}

class NeonFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final Color coloreTema;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLength;
  final String? hintText;
  final bool readOnly;
  final String? initialValue;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;

  const NeonFormField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.coloreTema = AppTheme.neonCyan,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.hintText,
    this.readOnly = false,
    this.initialValue,
    this.focusNode,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
      validator: validator,
      autovalidateMode: autovalidateMode,

      decoration: AppStyles.capsuleDecoration(
        label,
        icon,
        coloreTema: coloreTema,
        suffixIcon: suffixIcon,
        hintText: hintText,
      ),
    );
  }
}
