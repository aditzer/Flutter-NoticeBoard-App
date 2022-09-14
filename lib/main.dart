import 'package:flutter/material.dart';
import 'package:flutter_project_3/NotesApp/notes_ui.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: NotesApp(),
  ));
}

