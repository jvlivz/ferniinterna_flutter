import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'FullScreenImage.dart';

class DetailScreen extends StatefulWidget {
  final List<String> listOfUrls;
  final String idArtic;
  final String titulo;
  DetailScreen(
      {required this.listOfUrls, required this.titulo, required this.idArtic});

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
          style: new TextStyle( fontSize: 12),
        ),
        backgroundColor: Color.fromARGB(255, 254, 0, 36),
      ),
      body: SafeArea(
        child: ListView.builder(
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
                child: Padding(
                    padding:
                        EdgeInsets.all(MediaQuery.of(context).size.width * .04),
                    child: Material(
                        borderRadius: BorderRadius.circular(7.0),
                        elevation: 2,
                        shadowColor: Color.fromARGB(255, 228, 228, 228),
                        child: Column(children: [
                          Hero(
                            child: Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * .004),
                                child: CachedNetworkImage(
                                  imageUrl: widget.listOfUrls[index],
                                  fit: BoxFit.scaleDown,
                                )),
                            tag: "gridTag" + index.toString(),
                          ),
                          ElevatedButton(
                            child: const Text('Zoom / Reportar'),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return FullScreenImage(
                                  titulo: (index + 1).toString() +
                                      " - " +
                                      widget.titulo,
                                  imageUrl: widget.listOfUrls[index],
                                  tag: "detailTag" + index.toString(),
                                  idArtic: widget.idArtic,
                                );
                              }));
                            },
                          )
                        ]))));
          },
        ),
      ),
    );
  }
}
