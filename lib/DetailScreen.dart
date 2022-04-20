import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'FullScreenImage.dart';

class DetailScreen extends StatefulWidget {
  final List<String> listOfUrls;
  final String idArtic;
  final String titulo;
  DetailScreen({required this.listOfUrls, required this.titulo, required this.idArtic});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
/*   @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo,
          style: new TextStyle(fontFamily: "Gretoon", fontSize: 12),
        ),
        backgroundColor: Color.fromARGB(255, 254, 0, 36),
      ),
      body: SafeArea(
        child: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: widget.listOfUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return FullScreenImage(
                    titulo: (index + 1).toString() + " - " + widget.titulo,
                    imageUrl: widget.listOfUrls[index],
                    tag: "detailTag" + index.toString(),
                    idArtic: widget.idArtic,
                  );
                }));
              },
              child: Hero(
                child: CachedNetworkImage(
                  imageUrl: widget.listOfUrls[index],
                  fit: BoxFit.scaleDown,
                ),
                tag: "gridTag" + index.toString(),
              ),
            );
          },
        ),
      ),
    );
  }
}
