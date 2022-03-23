import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  String title;
  String content;
  VoidCallback continueCallBack;
  VoidCallback cancelCallBack;

  BlurryDialog(
      this.title, this.content, this.continueCallBack, this.cancelCallBack);
  TextStyle textStyle = TextStyle(color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: new Text(
            title,
            style: textStyle,
          ),
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("Continuar"),
              onPressed: () {
                Navigator.of(context).pop();
                continueCallBack();
              },
            ),
            new TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
                cancelCallBack();
              },
            ),
          ],
        ));
  }
}
