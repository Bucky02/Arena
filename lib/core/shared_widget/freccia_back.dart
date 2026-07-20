import 'package:flutter/material.dart';
import 'package:app_campi/core/theme/app_theme.dart';

class FrecciaBack extends StatelessWidget {
  final List<Color> coloriGradiente;
  final VoidCallback? onPressed;
  final double size;

  const FrecciaBack({
    super.key,
    this.coloriGradiente = const [AppTheme.neonOrange, AppTheme.neonCyan],
    this.onPressed,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Se non passi una funzione personalizzata, per default torna indietro (pop)
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: coloriGradiente,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}
