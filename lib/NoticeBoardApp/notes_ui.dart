import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project_3/NoticeBoardApp/custom_card.dart';
import 'package:flutter_project_3/util/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_dialogs/material_dialogs.dart';
class NotesApp extends StatefulWidget {
  const NotesApp({Key? key}) : super(key: key);
  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  late TextEditingController nameInput, titleInput, descriptionInput;
  var firestoreDb = FirebaseFirestore.instance.collection("notes").orderBy("time").snapshots();
  @override
  void initState() {
    super.initState();
    nameInput = TextEditingController();
    titleInput = TextEditingController();
    descriptionInput = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: const Text("Notice Board App",style: TextStyle(color: textColor1),),
        flexibleSpace: Container(
          decoration:  const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreenDark,primaryGreenLight],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(8),
        child: FloatingActionButton(
          onPressed: () => _showDialogue(context),
          backgroundColor: secondaryGreenDark,
          child: const Icon(FontAwesomeIcons.plus),
        ),
      ),
      body: Center(
        child: StreamBuilder(
          stream: firestoreDb,
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
            if(!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return ListView.builder(
              itemCount: snapshot.requireData.docs.length,
              itemBuilder: (context, int index) {
                return CustomCard(snapshot:snapshot.requireData,index:index);
              },
            );
          },
        ),
      ),
    );
  }

  _showDialogue(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          scrollable: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(17.0))),
          content: Column(
            children: [
              const Text("Fill the details:",style: TextStyle(fontSize: 20,color: textColor1,fontWeight:FontWeight.bold),),
              Container(
                margin: const EdgeInsets.only(top:60),
                  child: TextField(
                autofocus: true,
                autocorrect: true,
                decoration: const InputDecoration(labelText: "Your Name:"),
                controller: nameInput,
              )),
              Container(
                margin: const EdgeInsets.only(top:60),
                  child: TextField(
                autofocus: true,
                autocorrect: true,
                decoration: const InputDecoration(labelText: "Title:"),
                controller: titleInput,
              )),
              Container(
                margin: const EdgeInsets.only(top: 60),
                  child: TextField(
                autofocus: true,
                autocorrect: true,
                decoration: const InputDecoration(labelText: "Description:"),
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
                      descriptionInput.text.isNotEmpty) {
                    FirebaseFirestore.instance.collection("notes").add({
                      "name": nameInput.text,
                      "title": titleInput.text,
                      "description": descriptionInput.text,
                      "time": DateTime.now(),
                    }).then((response) {
                      print(response.id);
                      Navigator.pop(context);
                      nameInput.clear();
                      titleInput.clear();
                      descriptionInput.clear();
                    }).catchError((error) => print(error));
                  }
                },
                child: const Text("Save")),
          ],
        );
      },
    );
  }
}
