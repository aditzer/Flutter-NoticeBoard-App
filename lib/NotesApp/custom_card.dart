import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_3/util/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class CustomCard extends StatelessWidget {
  final QuerySnapshot snapshot;
  final int index;
  const CustomCard({Key? key, required this.snapshot, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var snapshotData = snapshot.docs[index];
    var docId = snapshot.docs[index].id;
    TextEditingController nameInput =
        TextEditingController(text: snapshotData.get("name"));
    TextEditingController titleInput =
        TextEditingController(text: snapshotData.get("title"));
    TextEditingController descriptionInput =
        TextEditingController(text: snapshotData.get("description"));

    var timeToDate = DateTime.fromMillisecondsSinceEpoch(
        snapshotData["time"].seconds * 1000);
    var dateFormatted = DateFormat("EEEE, MMM d").format(timeToDate);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
          child: Card(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            color: primaryGreenLight,
            elevation: 9,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF449B44), primaryGreenLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1D421E),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ]),
              child: Stack(children: [
                Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: CustomPaint(
                      size: Size(120, 50),
                      painter: CustomCardShapePainter(
                          24, secondaryGreenLight, secondaryGreenDark),
                    )),
                Column(
                  children: [
                    ListTile(
                      minVerticalPadding: 10,
                      horizontalTitleGap: 12,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          snapshotData["title"],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor1,
                              fontSize: 20),
                        ),
                      ),
                      subtitle: Text(snapshotData["description"]),
                      leading: CircleAvatar(
                        backgroundColor: secondaryGreenDark,
                        radius: 34,
                        child: Text(
                          snapshotData["title"].toString()[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.only(right: 20, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(" By: ${snapshotData["name"]} ",style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor1,
                              fontSize: 16.5),),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(dateFormatted),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.penToSquare,
                                size: 20,
                              ),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: const EdgeInsets.all(10),
                                      content: Column(
                                        children: [
                                          const Text("Update the details:"),
                                          Expanded(
                                              child: TextField(
                                            autofocus: true,
                                            autocorrect: true,
                                            decoration: const InputDecoration(
                                                labelText: "Your Name:"),
                                            controller: nameInput,
                                          )),
                                          Expanded(
                                              child: TextField(
                                            autofocus: true,
                                            autocorrect: true,
                                            decoration: const InputDecoration(
                                                labelText: "Title:"),
                                            controller: titleInput,
                                          )),
                                          Expanded(
                                              child: TextField(
                                            autofocus: true,
                                            autocorrect: true,
                                            decoration: const InputDecoration(
                                                labelText: "Description:"),
                                            controller: descriptionInput,
                                          )),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              nameInput.clear();
                                              titleInput.clear();
                                              descriptionInput.clear();
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              if (titleInput.text.isNotEmpty &&
                                                  nameInput.text.isNotEmpty &&
                                                  descriptionInput
                                                      .text.isNotEmpty) {
                                                FirebaseFirestore.instance
                                                    .collection("notes")
                                                    .doc(docId)
                                                    .update({
                                                  "name": nameInput.text,
                                                  "title": titleInput.text,
                                                  "description":
                                                      descriptionInput.text,
                                                  "time": DateTime.now(),
                                                }).then((response) {
                                                  Navigator.pop(context);
                                                });
                                              }
                                            },
                                            child: const Text("Update")),
                                      ],
                                    );
                                  },
                                );
                              }),
                          const SizedBox(
                            height: 19,
                          ),
                          IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.trashCan,
                                size: 20,
                              ),
                              onPressed: () async {
                                var collectionReference = FirebaseFirestore
                                    .instance
                                    .collection("notes");
                                await collectionReference.doc(docId).delete();
                              })
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomCardShapePainter extends CustomPainter {
  final double radius;
  final Color startColor;
  final Color endColor;

  CustomCardShapePainter(this.radius, this.startColor, this.endColor);

  @override
  void paint(Canvas canvas, Size size) {
    var radius = 24.0;

    var paint = Paint();
    paint.shader = ui.Gradient.linear(
        Offset(0, 0), Offset(size.width, size.height), [
      HSLColor.fromColor(startColor).withLightness(0.8).toColor(),
      endColor
    ]);

    var path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(
          size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, radius)
      ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
      ..lineTo(size.width - 1.5 * radius, 0)
      ..quadraticBezierTo(-radius, 2 * radius, 0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
