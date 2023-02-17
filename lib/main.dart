import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle
      (SystemUiOverlayStyle(statusBarColor:Colors.transparent));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List todos = List.empty();
  String title = "";
  String description = "";
  @override
  void initState() {
    super.initState();
    todos = ["Hello", "Hey There"];
  }

  createToDo() {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("MyTodos").doc(title);

    Map<String, String> todoList = {
      "todoTitle": title,
      "todoDesc": description
    };

    documentReference
        .set(todoList)
        .whenComplete(() => print("Data stored successfully"));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: tdBGColor,
      //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      appBar: AppBar(
        backgroundColor:tdBGColor,
        title: Center(child: Text(
          'TODOs',style: TextStyle(color:tdBlack,
            fontSize: 25,
            fontWeight: FontWeight.bold),)),
        elevation: 0,
      ),


      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index)
                {
                  QueryDocumentSnapshot<Object?>? documentSnapshot =
                  snapshot.data?.docs[index];
                  return Dismissible(
                      key: Key(index.toString()),

                      child: Card(
                        elevation: 4,
                          child: ListTile(
                            leading: IconButton(
                              icon: const Icon(Icons.edit,),
                              color: tdGrey,
                              onPressed: () {

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10)),
                                      title: const Text("Update ToDo"),
                                      content: Container(
                                        width: 400,
                                        height: 100,
                                        child: Column(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(

                                                  hintText: 'Enter title ',
                                                  hintStyle: TextStyle(
                                                      color: tdGrey,
                                                      fontSize: 16),
                                              ),

                                              onChanged: (String value) {
                                                title = value;
                                              },
                                            ),
                                            TextField(
                                              decoration: InputDecoration(

                                                  hintText: 'Description',
                                                  hintStyle: TextStyle(
                                                      color: tdGrey,
                                                      fontSize: 16)
                                              ),
                                              onChanged: (String value) {
                                                description = value;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () {
                                              setState(() {

                                                snapshot.data?.docs[index].reference
                                                    .update({
                                                  'todoTitle':title,
                                                  'todoDesc':description,
                                                });


                                                //updateToDo();
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("UPDATE",
                                              style: TextStyle(color: tdBlack,
                                                  fontSize: 20),))
                                      ],
                                    );
                                  },
                                );
                              }),

                            title: Text((documentSnapshot != null) ? (documentSnapshot["todoTitle"]) : "",
                                style:TextStyle(fontSize: 16,color: tdBlue,fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              (documentSnapshot != null) ? ((documentSnapshot["todoDesc"] != null)
                                  ? documentSnapshot["todoDesc"] : "") : "",
                              style: TextStyle(color: tdGrey,fontSize: 12,),),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,),
                              color: Colors.red,
                              onPressed: () {
                                setState(() {
                                  snapshot.data?.docs[index].reference.delete();

                                });
                              },
                            ),


                          ),

                      )
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Text("Add ToDo"),
                  content: Container(
                    width: 400,
                    height: 100,
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(

                              hintText: 'Enter title ',
                              hintStyle: TextStyle(color:tdGrey,fontSize: 16)

                          ),

                          onChanged: (String value) {
                            title = value;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(

                              hintText: 'Description',
                              hintStyle: TextStyle(color:tdGrey,fontSize: 16)
                          ),
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          setState(() {
                            //todos.add(title);
                            createToDo();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("ADD",style: TextStyle(color: tdBlack,fontSize: 20),))
                  ],
                );
              });

        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: tdBlack,

      ),

    );
  }
}