import 'package:flutter/material.dart';

class TextWithDivider extends StatelessWidget {
  const TextWithDivider(
      {Key? key,
      this.texto,
      required this.size,
      required this.fontWeight,
      required this.maxLines,
      this.color,
      this.visibleDivider = true})
      : super(key: key);

  final String? texto;
  final int maxLines;
  final double size;
  final Color? color;
  final FontWeight fontWeight;
  final bool visibleDivider;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            children: [
          if (texto != null && texto != "")
            Text(
              texto.toString(),
              style: TextStyle(
                  fontWeight: fontWeight, fontSize: size, color: color),
              overflow: TextOverflow.clip,
              maxLines: maxLines,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          if (visibleDivider && texto != null && texto != "")   Divider(),
          if (!visibleDivider && texto != null && texto != "")
            SizedBox(width: 50),
        ]));
  }
}
