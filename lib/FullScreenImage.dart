import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final String titulo;
  const FullScreenImage(
      {required this.imageUrl, required this.tag, required this.titulo});

/*   initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Scaffold(
        appBar: AppBar(
            title: Text(
              titulo,
              style: new TextStyle(fontFamily: "Gretoon", fontSize: 12),
            ),
            backgroundColor: Color.fromARGB(255, 254, 0, 36)),
        body: SafeArea(
          child: GestureDetector(
            child: Center(
              child: Hero(
                tag: tag,
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                  imageUrl: imageUrl,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
