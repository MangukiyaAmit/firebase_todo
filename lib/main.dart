import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Demo(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final titleTextEditCtr = TextEditingController();
  final descriptionTextEditCtr = TextEditingController();

  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.orderBy('timetamp').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("loading"),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              var data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text("${data['title']}"),
                subtitle: Text("${data['desc']}"),
                trailing: Wrap(
                  children: [
                    IconButton(
                        onPressed: () {
                          titleTextEditCtr.text = data['title'];
                          descriptionTextEditCtr.text = data['desc'];

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Column(
                                children: [
                                  Text('Add Notes'),
                                  TextFormField(
                                    controller: titleTextEditCtr,
                                    decoration: InputDecoration(
                                      hintText: 'Title',
                                    ),
                                  ),
                                  TextFormField(
                                    controller: descriptionTextEditCtr,
                                    decoration: InputDecoration(
                                      hintText: 'Description',
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  color: Colors.red,
                                  child: Text(
                                    'Cancel',
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Map<String, dynamic> data = {
                                      "title": titleTextEditCtr.text,
                                      "desc": descriptionTextEditCtr.text
                                    };
                                    usersCollection
                                        .doc(snapshot.data!.docs[index].id)
                                        .update(data)
                                        .then((value) => print("User updated"))
                                        .catchError((error) => print(
                                            "Failed to update user: $error"));
                                    titleTextEditCtr.clear();
                                    descriptionTextEditCtr.clear();

                                    Navigator.pop(context);
                                  },
                                  color: Colors.green,
                                  child: Text('Add'),
                                )
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () {
                          usersCollection
                              .doc(snapshot.data!.docs[index].id)
                              .delete()
                              .then((value) {
                            print("delete");
                          }).catchError((error) => print("error: $error"));
                        },
                        icon: Icon(Icons.delete)),
                  ],
                ),
              );
            },
            itemCount: snapshot.data!.docs.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Column(
                children: [
                  Text('Add Notes'),
                  TextFormField(
                    controller: titleTextEditCtr,
                    decoration: InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  TextFormField(
                    controller: descriptionTextEditCtr,
                    decoration: InputDecoration(
                      hintText: 'Description',
                    ),
                  ),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  child: Text(
                    'Cancel',
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Map<String, dynamic> data = {
                      "title": titleTextEditCtr.text,
                      "desc": descriptionTextEditCtr.text,
                      "timetamp": DateTime.now()
                    };
                    usersCollection
                        .add(data)
                        .then((value) => print("User Added"))
                        .catchError(
                            (error) => print("Failed to add user: $error"));
                    titleTextEditCtr.clear();
                    descriptionTextEditCtr.clear();

                    Navigator.pop(context);
                  },
                  color: Colors.green,
                  child: Text('Add'),
                )
              ],
            ),
          );
        },
        // onPressed: () {
        //   dataAdd();
        // },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
