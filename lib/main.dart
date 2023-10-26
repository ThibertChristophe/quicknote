import 'package:flutter/material.dart';
import 'package:quicknote/model/note_db.dart';

import 'package:quicknote/model/note.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'QuickNote';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  double _textFieldHeight = 50.0;
  int noteIDCurrent = 0;
  Future<List<Note>>? futureNotes;
  int indexSelected = -1;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("QuickNote"),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: () async {
                await NoteDB.delete(id: noteIDCurrent);
                setState(() {
                  _textEditingController.text = "";
                  noteIDCurrent = 0;
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
              ),
              onPressed: () async {
                if (noteIDCurrent != 0) {
                  await NoteDB.update(
                      id: noteIDCurrent, content: _textEditingController.text);
                } else {
                  await NoteDB.create(content: _textEditingController.text);
                  NoteDB.fetchAll();
                }

                setState(() {
                  _textEditingController.text = "";
                  indexSelected = -1;
                  noteIDCurrent = 0;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: _textFieldHeight,
                    child: TextFormField(
                      controller: _textEditingController,
                      maxLines: null,
                      onChanged: (text) {
                        setState(() {
                          // Met à jour la hauteur du TextField en fonction du contenu
                          _textFieldHeight =
                              50.0 + (text.split('\n').length - 1) * 20.0;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          width: 150,
          child: FutureBuilder(
            future: NoteDB.fetchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              } else {
                List<Note>? items = snapshot.data;

                return ListView.builder(
                  itemCount: items!.length,
                  itemBuilder: (context, index) {
                    Note note = items[index];
                    return SizedBox(
                      height: 50,
                      child: ListTile(
                        selected: indexSelected == index,
                        onTap: () async {
                          Note result = await NoteDB.fetchById(note.id);
                          setState(() {
                            indexSelected = index;
                            _textEditingController.text = result.content;
                            noteIDCurrent = note.id;
                          });
                          Navigator.of(context).pop();
                        },
                        title: Text(
                          note.content,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
