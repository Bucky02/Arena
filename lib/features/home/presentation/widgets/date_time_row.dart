import 'package:flutter/material.dart';

class DateTimeRow extends StatelessWidget {
  final String text;
  final Color? color;

  const DateTimeRow({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.grey.shade400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today, size: 14, color: effectiveColor),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: effectiveColor, fontSize: 13)),
      ],
    );
  }
}

String formattaDataOra(DateTime data, String orarioInizio) {
  final giorno = data.day.toString().padLeft(2, '0');
  final mese = data.month.toString().padLeft(2, '0');
  final orario = orarioInizio.length >= 5
      ? orarioInizio.substring(0, 5)
      : orarioInizio;
  return "$giorno/$mese  •  $orario";
}
